from pathlib import Path
import json,pickle,sys,numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
s=Path(__file__).resolve().parents[1];sys.path.insert(0,str(s.parent/'host_detector'));from models.engine import features
name='joint-mixed-full-s1151';cfg=next(c for c in json.loads((s/'configs/final.json').read_text()) if c['name']==name);a=pickle.loads((s/'models/combined.pkl').read_bytes());rows=[];decisions=[]
for line in (s/'logs'/name/'gateway.jsonl').read_text().splitlines():
 r=json.loads(line)
 if 'measurement' in r and r['measurement']['node']==cfg['target']:rows.append(r)
 if 'decision' in r:decisions.append(r['decision'])
x=np.array([r['measurement']['time'] for r in rows]);c=np.array([r['measurement']['context'] for r in rows]);resource=np.array([r['measurement']['resource'] for r in rows]);_,expected=features(c,resource,a['predictor']);risk=np.array([r['host'].get('risk',np.nan) if r['host'].get('risk') is not None else np.nan for r in rows]);drift=np.array([r['host'].get('drift_score',np.nan) for r in rows]);alarm=np.array([r['host'].get('alarm',False) for r in rows]);tau=a['evidence_v3'];plt.rcParams.update({'font.family':'DejaVu Serif','font.size':9,'pdf.fonttype':42,'axes.spines.top':False,'axes.spines.right':False});fig,ax=plt.subplots(3,1,figsize=(8,6),sharex=True,layout='constrained')
ax[0].plot(x,resource[:,0]*100,label='Measured CPU');ax[0].plot(x,expected[:,0]*100,label='Expected CPU');ax[0].set_ylabel('CPU duty (%)');ax[0].legend(loc='upper right')
ax[1].plot(x,risk/tau['neural_threshold'],label='Fast score / threshold');ax[1].plot(x,drift/tau['drift_threshold'],label='Residual score / threshold');ax[1].axhline(1,color='k',ls=':',lw=1);ax[1].scatter(x[alarm],np.zeros(sum(alarm)),s=7,color='#a33a32',label='Warning active');ax[1].set_ylabel('Normalized score');ax[1].legend(loc='upper right')
t=[r['time'] for r in decisions];ax[2].bar(t,[r['used'] for r in decisions],width=5,color='#527a9a',label='Admitted query/repair payload');ax[2].axhline(480,color='k',ls=':',label='Discretionary cap');ax[2].set_ylabel('Reserved bytes');ax[2].set_xlabel('Simulation time (s)');ax[2].legend(loc='upper right')
for p in ax:p.axvspan(400,700,color='#c46d48',alpha=.1);p.axvline(300,color='#4b8f63',ls='--',lw=.8);p.axvline(780,color='#4b8f63',ls='--',lw=.8);p.grid(axis='y',alpha=.15)
ax[0].set_title('Actual Z1 observations and coupled gateway decisions; shaded = configured misuse')
out=s/'results/figures';out.mkdir(exist_ok=True);fig.savefig(out/'combined-timeline.pdf');fig.savefig(out/'combined-timeline.png',dpi=300);plt.close(fig);print('live timeline saved')
