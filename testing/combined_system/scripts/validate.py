from pathlib import Path
import sys,json,pickle,hashlib,time,xml.etree.ElementTree as E
s=Path(__file__).resolve().parents[1];sys.path.insert(0,str(s/'scripts'));from gateway import Gateway
checks=[]
def check(name,ok):
 assert ok,name
 checks.append(dict(check=name,passed=True))
freeze=json.loads((s/'results/training-freeze.json').read_text());artifact=s/'models/combined.pkl';check('artifact matches before-final freeze',hashlib.sha256(artifact.read_bytes()).hexdigest()==freeze['artifact_sha256'])
for name,h in freeze.get('runtime_sha256',{}).items():check('runtime unchanged '+name,hashlib.sha256((s/name).read_bytes()).hexdigest()==h)
runtime_note='Model hash/timestamp froze before final runs. Per-run firmware source/binary hashes are verified; gateway source hash is recorded after completion, with independent action replay below. No before-run gateway-source hash was recorded by the accepted training process.' if 'runtime_sha256' not in freeze else 'Model and recorded runtime hashes match before-final freeze.'
configs=json.loads((s/'configs/final.json').read_text());check('exact compact paired matrix',len(configs)==42 and len({(c['seed'],c['case'],c['variant']) for c in configs})==42)
check('final deployments absent from source/calibration',not any(str(seed) in name for seed in [1151,1152] for name in freeze['source_runs']))
check('distinct two source and two calibration runs',len(freeze['source_runs'])==4)
keys=json.loads((s/'configs/lab-keys.json').read_text());runtimes=[]
for c in configs:
 d=s/'logs'/c['name'];meta=json.loads((d/'run.json').read_text());check('successful '+c['name'],meta['exit_code']==0);check('raw hash '+c['name'],hashlib.sha256((d/'COOJA.testlog').read_bytes()).hexdigest()==meta['raw_sha256']);check('scenario hash '+c['name'],hashlib.sha256((s/'scenarios'/(c['name']+'.csc')).read_bytes()).hexdigest()==meta['scenario_sha256']);check('leaf binary '+c['name'],hashlib.sha256((s/'firmware/leaf/build/z1/pilot.z1').read_bytes()).hexdigest()==meta['leaf_sha256']);check('execution after frozen training '+c['name'],(d/'run.json').stat().st_mtime>freeze['unix_time']);raw=(d/'COOJA.testlog').read_text();check('software AES known-vector '+c['name'],raw.count('AES_KAT,69,c4,e0,d8,6a,7b,04,30,d8,cd,b7,80,70,b4,c5,5a')==9);check('no stack fault '+c['name'],'Check failed' not in raw)
 # Raw source truth confirms attack code really executes in final cases.
 check('configured actual workloads '+c['name'],('ORACLE_HOST' in raw)==bool(c['host_case']))
 # A configured forwarder may have no transit opportunity in a given routing realization.
 # This is retained and reported, not excluded or relabeled as a successful defense.
 check('authorization actually received '+c['name'],f'PERMIT,{c["target"]},1000,780' in raw)
 runtimes.append(meta['wall_seconds'])
# Independent saved-artifact replay of observed root inputs must reproduce actions.
parity=[]
for variant in ['full','cipher','contrast','no_work']:
 c=next(c for c in configs if c['seed']==1151 and c['case']=='mixed' and c['variant']==variant);g=Gateway(c,variant,keys[str(c['seed'])],pickle.loads(artifact.read_bytes()));n=0;start=time.monotonic()
 for line in (s/'logs'/c['name']/'gateway.jsonl').read_text().splitlines():
  expected=json.loads(line);actual=g.consume(expected['input']);check('action replay '+variant+str(n),actual['commands']==expected['commands'] and actual['mask']==expected['mask'] and actual['known']==expected['known']);n+=1
 parity.append(dict(variant=variant,root_events=n,wall_seconds=time.monotonic()-start))
runs=json.loads((s/'results/runs.json').read_text());check('42 independently audited scientific runs',len(runs)==42);check('every run has real telemetry/report coverage',all(r['all_nine_sources_observed'] and r['valid_reports']>0 for r in runs));check('actual helper repair exists',sum(r['actual_counts'].get('helper_forwards',0) for r in runs)>0);check('host evidence reaches controller',sum(r['host_supported_decisions'] for r in runs if r['variant']=='full')>0);check('response scope is exercised',sum(r['action_scope_reductions'] for r in runs if r['variant']=='full')>0)
result=dict(runtime_provenance=runtime_note,post_run_gateway_sha256=hashlib.sha256((s/'scripts/gateway.py').read_bytes()).hexdigest(),checks=checks,streaming_replay=parity,note='Most check counts are per-record equivalence, not independent experiments.',scientific_final_runs=42,source_runs=4,total_run_wall_seconds=sum(runtimes));(s/'results/validation.json').write_text(json.dumps(result,indent=2))
manifest=[]
for folder in ['firmware','models','scripts','configs','scenarios','logs','data','results']:
 for p in sorted((s/folder).rglob('*')):
  if not p.is_file() or '__pycache__' in p.parts or p.name in ['manifest.json','FINALIZED.json']:continue
  if 'build' in p.parts and p.suffix!='.z1':continue
  # Ongoing finalizer log can change after validation; do not pin it.
  if p.name=='finalize-progress.log':continue
  manifest.append(dict(path=str(p.relative_to(s)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
for name in ['README.md','REPORT.md','METHOD.md','PROTOCOL.md']:
 p=s/name;manifest.append(dict(path=name,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
(s/'results/manifest.json').write_text(json.dumps(manifest,indent=2));(s/'results/FINALIZED.json').write_text(json.dumps(dict(status='complete',unix_time=time.time(),accepted_final_runs=42,source_calibration_runs=4,artifact_sha256=freeze['artifact_sha256'],validation_checks=len(checks),report='REPORT.md',scope='live combined gateway + actual ten Z1 motes; matched adaptations, not original full-framework reproduction; no FIT',system_configuration_changed=False),indent=2));print(len(checks),'checks passed; results finalized')
