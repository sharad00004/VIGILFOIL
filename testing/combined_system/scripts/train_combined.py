from pathlib import Path
from collections import defaultdict,deque
import sys,json,pickle,copy,hashlib,time,importlib.util
import numpy as np,torch
from torch import nn
from threadpoolctl import threadpool_limits
s=Path(__file__).resolve().parents[1];sys.path.insert(0,str(s.parent/'host_detector'));from models.engine import PhysicalResourcePredictor,features,HMAGuard
threadpool_limits(2);torch.set_num_threads(2);torch.manual_seed(16);torch.use_deterministic_algorithms(True)
configs=json.loads((s/'configs/source.json').read_text());rows=[]
for c in configs:
 d=s/'logs'/c['name'];meta=json.loads((d/'run.json').read_text());assert meta['exit_code']==0;raw=(d/'COOJA.testlog').read_text();assert 'Check failed' not in raw,c['name'];assert 'HELPER_REJECT_AUTH' not in raw,c['name'];assert 'AES_KAT,69,c4,e0,d8,6a,7b,04,30,d8,cd,b7,80,70,b4,c5,5a' in raw,c['name']
 nodes=set()
 for line in (d/'gateway.jsonl').read_text().splitlines():
  v=json.loads(line)
  if 'measurement' in v:
   r=v['measurement'];r.update(run=c['name'],split=c['split']);rows.append(r);nodes.add(r['node'])
 assert nodes==set(range(2,11)),(c['name'],nodes)
(s/'data/source-rows.json').write_text(json.dumps(rows));tr=[r for r in rows if r['split']=='train'];cal=[r for r in rows if r['split']=='calibration'];c=np.array([r['context'] for r in tr]);resource=np.array([r['resource'] for r in tr]);a=pickle.load((s.parent/'host_detector/models/hma_guard_v3.pkl').open('rb'));old_coef=a['predictor'].cpu_per_work
predictor=PhysicalResourcePredictor().fit(np.log1p(c),np.log1p(resource*100));a['predictor']=predictor;xx,expected=features(c,resource,predictor);error=resource[:,0]-expected[:,0];base=max(1/32768,float(1.4826*np.median(np.abs(error-np.median(error)))));cfg=a['evidence_v3'];rates=np.max(c[:,9:11],axis=1);bins=np.searchsorted(cfg['rate_edges'],rates,side='right');noise=[]
for i in range(len(cfg['rate_edges'])+1):
 e=error[bins==i];noise.append(max(base,float(1.4826*np.median(np.abs(e-np.median(e))))) if len(e)>20 else base)
cfg['noise']=noise;cfg['neural_threshold']=float('inf');cfg['drift_threshold']=float('inf');scores=[];drift=[]
for name in sorted({r['run'] for r in cal}):
 g=HMAGuard(a);votes=defaultdict(lambda:deque(maxlen=5))
 for r in [r for r in cal if r['run']==name]:
  v=g.step(r['node'],r['time'],r['context'],r['resource'])
  if v['risk'] is not None:
   q=votes[r['node']];q.append(v['risk']);scores.append(sorted(q,reverse=True)[2] if len(q)>=3 else 0);drift.append(v['drift_score'])
cfg['neural_threshold']=min(1,max(scores)+.005);cfg['drift_threshold']=max(drift)+2
spec=importlib.util.spec_from_file_location('paper_detectors',s.parent/'baselines/models/paper_detectors.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);a['comparators']={};train_info=[]
for name,T,epochs in [('cipher',16,250),('contrast',32,200)]:
 streams=[];raws=[]
 for run,node in sorted({(r['run'],r['node']) for r in tr}):
  rr=[r for r in tr if r['run']==run and r['node']==node];x=np.array([np.r_[r['context'][:14],r['resource'],r['context'][14]] if name=='cipher' else r['resource'][:2] for r in rr]);streams.append(x);raws.append(x)
 flat=np.concatenate(raws);lo=flat.min(0);span=flat.max(0)-lo;span[span<1e-8]=1;groups=m.correlation_groups((flat-lo)/span) if name=='cipher' else [[0,1]];net=m.Temporal(18,groups,2) if name=='cipher' else m.Host(8);opt=torch.optim.Adam(net.parameters(),lr=.05 if name=='cipher' else .001);windows=[]
 for x in streams:
  if len(x)>=T:windows.extend(np.lib.stride_tricks.sliding_window_view((x-lo)/span,T,axis=0).transpose(0,2,1)[::T])
 X=np.stack(windows).astype(np.float32);start=time.monotonic();losses=[]
 for epoch in range(epochs):
  total=0;net.train()
  for ix in torch.randperm(len(X)).split(32 if name=='cipher' else 256):
   x=torch.from_numpy(X[ix]);opt.zero_grad();loss=((net(x)-x)**2).mean();assert torch.isfinite(loss);loss.backward();opt.step();total+=float(loss.detach())
  losses.append(total)
 net.eval();clean_scores=[]
 for run,node in sorted({(r['run'],r['node']) for r in cal}):
  rr=[r for r in cal if r['run']==run and r['node']==node];x=np.array([np.r_[r['context'][:14],r['resource'],r['context'][14]] if name=='cipher' else r['resource'][:2] for r in rr]);z=np.lib.stride_tricks.sliding_window_view((x-lo)/span,T,axis=0).transpose(0,2,1).copy().astype(np.float32)
  with torch.no_grad():q=((net(torch.from_numpy(z))[:,-1]-torch.from_numpy(z)[:,-1])**2).mean(1).numpy()
  for i in range(2,len(q)):clean_scores.append(sorted(q[max(0,i-4):i+1],reverse=True)[2])
 threshold=max(clean_scores)*1.01+1e-8;a['comparators'][name]=dict(T=T,lo=lo,span=span,groups=groups,state=copy.deepcopy(net.state_dict()),threshold=threshold)
 train_info.append(dict(name=name,T=T,epochs=epochs,train_windows=len(X),threshold=threshold,parameters=sum(v.numel() for v in net.parameters()),fit_seconds=time.monotonic()-start,loss=losses,scope='matched architecture adaptation, benign-only new source fit; max benign calibration three-of-five threshold'))
 print('trained',name,train_info[-1]['fit_seconds'],flush=True)
a['version']='vigilfoil-combined-gateway';a['assumptions']+=['new rig benign-only resource recalibration; original supervised GRU/classifier weights retained; no final-test selection'];p=s/'models/combined.pkl';p.write_bytes(pickle.dumps(a));freeze=dict(artifact_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),source_runs=[c['name'] for c in configs],cpu_coefficient=predictor.cpu_per_work,prior_cpu_coefficient=old_coef,source_rows=len(tr),calibration_rows=len(cal),policy=cfg,comparators=train_info,unix_time=time.time(),final_test_used=False)
freeze['runtime_sha256']={str(p.relative_to(s)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [s/'scripts/gateway.py',s/'scripts/runner.py',s/'scripts/run_study.py',s/'firmware/root/pilot.c',s/'firmware/leaf/pilot.c',s/'firmware/root/project-conf.h',s/'firmware/leaf/project-conf.h',s/'firmware/root/build/z1/pilot.z1',s/'firmware/leaf/build/z1/pilot.z1']}
(s/'results/training-freeze.json').write_text(json.dumps(freeze,indent=2));print('FROZEN',freeze['artifact_sha256'],flush=True)
