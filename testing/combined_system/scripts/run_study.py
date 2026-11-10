from pathlib import Path
import sys,json,pickle,time,secrets,concurrent.futures,subprocess,hashlib
s=Path(__file__).resolve().parents[1];sys.path.insert(0,str(s/'scripts'));from runner import run
from gateway import Gateway
# No final deployment is opened before the source/calibration fits freeze.
while True:
 cs=json.loads((s/'configs/source.json').read_text());ps=[s/'logs'/c['name']/'run.json' for c in cs]
 if all(p.exists() for p in ps):
  assert all(json.loads(p.read_text())['exit_code']==0 for p in ps);break
 time.sleep(5)
subprocess.run([str(s.parent/'venv/bin/python'),'scripts/train_combined.py'],cwd=s,check=True)
variants=['full','network_only','cipher','contrast','no_work','no_action','no_memory'];rows=[]
for seed,top,target in [(1151,'bypass',2),(1152,'grid',3)]:
 for case,net,host,work,rx in [('benign',1,0,0,.9),('mixed',2,1,250,1),('sparse_loss',4,3,1000,.85)]:
  for variant in variants:rows.append(dict(name=f'joint-{case}-{variant}-s{seed}',seed=seed,split='final',variant=variant,case=case,network_case=net,host_case=host,work=work,authorized=1000,rx=rx,target=target,topology=top,duration=900))
(s/'configs/final.json').write_text(json.dumps(rows,indent=2));kp=s/'configs/lab-keys.json';keys=json.loads(kp.read_text())
for c in rows:keys.setdefault(str(c['seed']),dict(session=secrets.randbits(30)+1,keys=[list(secrets.token_bytes(32)) for _ in range(11)]))
kp.write_text(json.dumps(keys));artifact=pickle.load((s/'models/combined.pkl').open('rb'))
def task(c):return run(c,Gateway(c,c['variant'],keys[str(c['seed'])],artifact))
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as p:list(p.map(task,rows))
print('FINAL MATRIX COMPLETE',flush=True)
