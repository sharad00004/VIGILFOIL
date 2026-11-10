from pathlib import Path
import json,time,subprocess,sys,hashlib
s=Path(__file__).resolve().parents[1];py=s.parent/'venv/bin/python'
while True:
 p=s/'configs/final.json'
 if p.exists():
  cs=json.loads(p.read_text())
  if {c['seed'] for c in cs}=={1151,1152} and all((s/'logs'/c['name']/'run.json').exists() for c in cs):
   assert all(json.loads((s/'logs'/c['name']/'run.json').read_text())['exit_code']==0 for c in cs);break
 time.sleep(10)
for script in ['analyze.py','write_paper_results.py','validate.py']:
 subprocess.run([str(py),str(s/'scripts'/script)],cwd=s,check=True)
print('REPORT AND VALIDATION COMPLETE',flush=True)
