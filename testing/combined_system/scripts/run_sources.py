from pathlib import Path
import sys,json,secrets,time,concurrent.futures
s=Path(__file__).resolve().parents[1];sys.path.insert(0,str(s/'scripts'));from runner import run
from gateway import Gateway
rows=[]
for seed,split,case,auth,rx in [(1111,'train',0,0,1),(1112,'train',1,1500,1),(1113,'calibration',0,500,.9),(1114,'calibration',1,1000,.85)]:
 rows.append(dict(name=f'source-v5-s{seed}',seed=seed,split=split,variant='network_only',network_case=case,host_case=0,authorized=auth,work=0,target=2,topology='bypass',rx=rx,duration=900))
(s/'configs/source.json').write_text(json.dumps(rows,indent=2))
kp=s/'configs/lab-keys.json';keys=json.loads(kp.read_text())
for c in rows:keys.setdefault(str(c['seed']),dict(session=secrets.randbits(30)+1,keys=[list(secrets.token_bytes(32)) for _ in range(11)]))
kp.write_text(json.dumps(keys))
def task(c):return run(c,Gateway(c,'network_only',keys[str(c['seed'])]))
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as p:list(p.map(task,rows))
print('SOURCES COMPLETE',flush=True)
