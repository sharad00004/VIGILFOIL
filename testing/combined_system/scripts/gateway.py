"""Gateway integration of response-aware network accounting and workload-aware host detection.
The root authenticates incoming wire frames; gateway also checks replay/scope.
"""
from pathlib import Path
from collections import defaultdict,deque
import sys,json,pickle,struct,hmac,hashlib,math
import numpy as np,torch
from threadpoolctl import threadpool_limits
s=Path(__file__).resolve().parents[1];sys.path.insert(0,str(s.parent/'host_detector'))
from models.engine import HMAGuard
from models.stream import MonitorStream
threadpool_limits(1);torch.set_num_threads(1)
class FeatureGuard:
 def __init__(self,model=None):self.model=model;self.last=None;self.states={}
 def step(self,node,at,context,resource):
  self.last=dict(node=node,time=at,context=context.tolist(),resource=resource.tolist());return self.model.step(node,at,context,resource) if self.model else dict(state='collection',risk=None,alarm=False)
class Gateway:
 def __init__(self,c,variant,keys,artifact=None):
  self.c=c;self.variant=variant;self.session=keys['session'];self.keys=[bytes(k) for k in keys['keys']];self.now=0;self.report={};self.facts={};self.direct=defaultdict(set);self.union=defaultdict(set);self.offered={};self.lease_history=defaultdict(set);self.lease_until=defaultdict(int);self.pending={};self.lastquery=defaultdict(lambda:-100);self.nonce=0;self.arrivals=deque();self.lastseq={};self.warnings={};self.decisions=[];self.budget=480
  model=None
  if artifact is not None:
   artifact=pickle.loads(pickle.dumps(artifact))
   if variant=='no_memory':artifact['evidence_v3']['drift_threshold']=float('inf')
   if variant in ['cipher','contrast']:model=AEGuard(artifact,variant)
   else:model=HMAGuard(artifact)
  self.guard=FeatureGuard(model);self.stream=MonitorStream(self.guard);self.a=artifact;self.model_cfg=json.loads((s.parent/'network_controller/weights.json').read_text())
 def wire(self,node,words,port=8766,token=None):
  p=struct.pack('>'+str(len(words))+'I',*words)
  if token is not None:
   from cryptography.hazmat.primitives.ciphers import Cipher,algorithms,modes
   k=hmac.digest(self.keys[node],b'lease-cap-enc','sha256');mask=Cipher(algorithms.AES(k[:16]),modes.ECB()).encryptor().update(p[8:24]);p+=bytes(a^b for a,b in zip(token,mask))
  p+=hmac.digest(self.keys[node],p,'sha256')[:8];return dict(node=node,port=port,hex=p.hex())
 def query(self,node,e,remaining,commands):
  if remaining<136 or self.now-self.lastquery[node]<10:return remaining
  self.nonce+=1;self.pending[node]=(self.nonce,e,self.now);self.lastquery[node]=self.now;commands.append(self.wire(node,[2,node,self.session,self.nonce,e]));return remaining-136
 def helper(self,node):
  z=self.report.get(node)
  if not z or self.now-z[1]>35:return 0
  for h in range(2,11):
   if h==node or not (z[0][14]&(1<<h)):continue
   at=h;seen=set();safe=True
   while at!=1:
    r=self.report.get(at)
    if at==node or at in seen or not r or self.now-r[1]>35 or (self.variant!='network_only' and self.warnings.get(at,(0,False))[1] and self.now-self.warnings[at][0]<=60):safe=False;break
    seen.add(at);v,_,old=r
    if old is not None:
     di=v[7]-old[7];do=v[8]-old[8]
     if di>2 and do*4<di*3:safe=False;break
    at=v[13]
    if at<1 or at>10:safe=False;break
   if safe:return h
  return 0
 def grant(self,node,helper,remaining,commands):
  if remaining<248 or self.lease_until[node]>self.now:return remaining
  self.lease_until[node]=self.now+10;token=hmac.digest(self.keys[node],struct.pack('>4I',node,helper,self.nonce+1,self.session),'sha256')[:16]
  for recipient in [node,helper]:
   self.nonce+=1;commands.append(self.wire(recipient,[5,recipient,self.session,self.nonce,node,helper,10,2,2],token=token))
   if recipient==node:self.lease_history[node].add((self.nonce,self.now))
  return remaining-248
 def model_alarm(self):
  # Same frozen linear network-priority model; actual Z1 TX/RX duty units.
  while self.arrivals and self.now-self.arrivals[0][0]>10:self.arrivals.popleft()
  count=np.zeros(9);gaps=0
  for at,node,gap in self.arrivals:count[node-2]+=1;gaps+=gap
  defv=[];rate=[];own=[];tx=[];rx=[];ranks=[];ages=[];age_reports=[]
  for i in range(2,11):
   ages.append(min(60,self.now-self.lastseq.get(i,(0,0))[1])/10);r=self.report.get(i);age_reports.append(min(120,self.now-r[1]) if r else 120)
   if r and r[2] is not None and self.now-r[1]<=25:
    v,at,old=r;dt=max(1,v[5]-old[5]);di=v[7]-old[7];do=v[8]-old[8];defv.append(max(0,di-do)/max(1,di));rate.append(di/dt);own.append((v[6]-old[6])/dt);tx.append((v[10]-old[10])/dt/32768);rx.append((v[11]-old[11])/dt/32768);ranks.append(v[12]/128)
  avg=lambda z:float(np.mean(z)) if z else 0.
  x=[count.sum()/18,np.count_nonzero(count)/9,gaps/18,np.std(count)/2,avg(ages),max(defv,default=0),avg(defv),max(rate,default=0),avg(own),float(np.median(ranks)) if ranks else 0,float(np.std(ranks)) if ranks else 0,avg(tx),avg(rx),len(ranks)/9,avg(age_reports)/40]
  margin=float(np.dot(x,self.model_cfg['weights'])+self.model_cfg['bias']);return margin>self.model_cfg['threshold'] if 'threshold' in self.model_cfg else margin>self.model_cfg.get('cutoff',0),x,margin
 def decide(self):
  e=int(self.now)//10-2;commands=[];remaining=480;alarm,x,margin=self.model_alarm();jobs=[];ledger=[]
  for node in range(2,11):
   have=(node,e) in self.facts;support=e
   if not have:
    for k in [1,2]:
     if (node,e-k) in self.facts:support=e-k;break
   fact=self.facts.get((node,support));known=fact is not None;submitted=fact['submitted'] if known else 2;expected=submitted;scope=False
   if known and self.variant!='no_action' and fact['action_valid']:expected=fact['original'];scope=True
   d=len(self.direct[node,support]);deficit=max(0,expected-d);host=self.variant!='network_only' and self.warnings.get(node,(0,False))[1] and self.now-self.warnings[node][0]<=60;score=10*deficit+int(alarm and not have)+20*int(host);jobs.append((score,node,deficit,not have,known,host));ledger.append(dict(node=node,epoch=e,support=support,known=known,submitted=submitted,expected=expected,direct=d,action_scope=scope,host=bool(host),deficit=deficit))
  for score,node,deficit,unknown,known,host in sorted(jobs,key=lambda z:(-z[0],z[1])):
   if score<=0:continue
   if deficit and known:
    helper=self.helper(node)
    if helper:remaining=self.grant(node,helper,remaining,commands)
   if remaining>=136 and (unknown or deficit or host):remaining=self.query(node,e,remaining,commands)
  self.decisions.append(dict(time=self.now,used=480-remaining,remaining=remaining,commands=commands,ledger=ledger,network_alarm=bool(alarm),network_margin=margin,features=x));return commands
 def consume(self,line):
  f=line.split(',');self.now=int(f[0])/1e6;kind=f[2];output={};commands=[];self.guard.last=None
  if kind in ['TELEMETRY','AUTH_CONTEXT']:
   if self.variant=='no_work' and kind=='AUTH_CONTEXT':pass
   else:
    v=self.stream.consume(line)
    if v is not None:
     output['host']=v
     if 'node' in v:self.warnings[v['node']]=(self.now,bool(v.get('alarm')))
   if self.guard.last:output['measurement']=self.guard.last
  elif kind=='ROOT_RX':
   p=bytes.fromhex(f[4]);v=list(struct.unpack('>'+str((len(p)-8)//4)+'I',p[:-8]));typ,node,session=v[:3]
   if session==self.session:
    if typ in [1,6]:
     seq,e=v[3:5]
     if e<=self.now//10+1 and self.now//10<=e+6:
      self.union[node,e].add(seq)
      if typ==1:
       self.direct[node,e].add(seq);old=self.lastseq.get(node);gap=max(0,seq-old[0]-1) if old else 0
       if old is None or seq>old[0]:self.lastseq[node]=(seq,self.now)
       self.arrivals.append((self.now,node,gap))
    elif typ==3:
     old=self.report.get(node);nonce=v[4];valid=not old or v[3]>old[0][3]
     valid &= v[5]<=self.now+2 and self.now<=v[5]+35 and 2<=v[15]<v[5]//10
     if nonce:valid &= node in self.pending and nonce==self.pending[node][0] and v[15]==self.pending[node][1] and self.now<=self.pending[node][2]+20
     if old:valid &= all(v[i]>=old[0][i] for i in range(6,12))
     for i in range(3):
      packed=v[16+i];q=v[19+i];o=(packed>>20)&1023;u=(packed>>10)&1023;b=packed&1023;P=(q>>20)&1023;R=(q>>10)&1023;D=q&1023
      valid &= not(packed&0x40000000) and not(q&0xc0000000) and (not(packed&0x80000000) or (o==u+b and P<=u and R<=u and P+R>=u and D<=u-P and u<=o))
     if valid:
      self.report[node]=(v,self.now,old[0] if old else None)
      if nonce:self.pending.pop(node,None)
      for i in range(3):
       packed=v[16+i];q=v[19+i]
       if packed&0x80000000:
        epoch=v[15]-2+i;u=(packed>>10)&1023;P=(q>>20)&1023;D=q&1023;lease=v[22+i];scope=(u==P) or (D and u-P==D and any(n==lease and 0<=self.now-t<=70 for n,t in self.lease_history[node]));self.facts[node,epoch]=dict(offered=(packed>>20)&1023,submitted=u,blocked=packed&1023,original=P,action_valid=bool(scope))
     output['report_accepted']=bool(valid)
  elif kind=='GATEWAY_TICK':commands=self.decide();output['decision']=self.decisions[-1]
  mask=sum(1<<node for node,(at,alarm) in self.warnings.items() if alarm and self.now-at<=60);known=sum(1<<node for node,(at,alarm) in self.warnings.items() if self.now-at<=60)
  return dict(mask=mask,known=known,commands=commands,**output)

class AEGuard:
 def __init__(self,artifact,name):
  import importlib.util
  spec=importlib.util.spec_from_file_location('paper_detectors',s.parent/'baselines/models/paper_detectors.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);self.cfg=artifact['comparators'][name];q=self.cfg;self.net=module.Host(8) if name=='contrast' else module.Temporal(18,q['groups'],2);self.net.load_state_dict(q['state']);self.net.eval();self.states={};self.name=name
 def step(self,node,at,context,resource):
  st=self.states.setdefault(node,dict(history=deque(maxlen=self.cfg['T']),votes=deque(maxlen=5),until=0));raw=np.r_[context[:14],resource,context[14]] if self.name=='cipher' else np.array(resource[:2]);st['history'].append((raw-self.cfg['lo'])/self.cfg['span'])
  if len(st['history'])<self.cfg['T']:return dict(state='warming_up',risk=None,alarm=False)
  x=torch.tensor(np.stack(st['history'])[None],dtype=torch.float32)
  with torch.no_grad():score=float(((self.net(x)[:,-1]-x[:,-1])**2).mean())
  st['votes'].append(score>self.cfg['threshold'])
  if sum(st['votes'])>=3:st['until']=at+30
  alarm=at<=st['until'];return dict(state='resource_misuse_suspected' if alarm else 'no_current_resource_alarm',risk=score,alarm=alarm)
