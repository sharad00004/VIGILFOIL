"""Causal per-device HMA risk engine. Telemetry authenticity is not monitor integrity."""
from collections import deque
import numpy as np
import torch
from torch import nn
from models.evidence import EvidenceState
class TemporalHead(nn.Module):
 def __init__(self,d,width=16):
  super().__init__();self.gru=nn.GRU(d,width,batch_first=True);self.head=nn.Linear(width,1)
 def forward(self,x):return self.head(self.gru(x)[0][:,-1]).squeeze(-1)
def features(context,resource,predictor):
 c=np.asarray(context,dtype=float);r=np.asarray(resource,dtype=float)
 expected=np.expm1(predictor.predict(np.log1p(np.maximum(c,0))))/100
 # Retain signed errors; a reduction must not masquerade as excess host work.
 innovation=(r-expected)*100
 if hasattr(predictor,'cpu_per_work'):
  # The discriminative head sees prediction errors, not rank/identity proxies or
  # a permission bit which could become an unconditional benign shortcut.
  return np.c_[np.log1p(np.maximum(c[:,11:14],0)),innovation,innovation/np.maximum(expected*100,.1)],expected
 return np.c_[np.log1p(np.maximum(c,0)),np.log1p(np.maximum(r,0)*100),innovation],expected
class HMAGuard:
 def __init__(self,artifact,monitor_trusted=True):
  self.a=artifact;self.trusted=monitor_trusted;self.states={};self.net=TemporalHead(len(artifact['mean']));self.net.load_state_dict(artifact['temporal_state']);self.net.eval()
 def prepare(self,contexts,resources):
  """Independent fixed-model predictions; contains no temporal state or future context."""
  x,expected=features(contexts,resources,self.a['predictor']);static=self.a['classifier'].predict_proba(x)[:,1];return x,expected,static
 def step(self,node,at,context,resource,prepared=None):
  if not np.isfinite(at) or len(context)!=15 or len(resource)!=3 or not np.isfinite(context).all() or not np.isfinite(resource).all() or min(resource)<0 or max(resource)>1.25:
   return dict(state='invalid_measurement',risk=None,action='request_fresh_evidence')
  state=self.states.setdefault(node,dict(history=deque(maxlen=8),votes=deque(maxlen=5),last=None,alarm_until=0,baseline=[],cusum=0,evidence=EvidenceState()))
  if state['last'] is not None and at<=state['last']:return dict(state='invalid_order',risk=None,action='request_fresh_evidence')
  if state['last'] is not None and at-state['last']>90:state['history'].clear();state['votes'].clear();state['baseline'].clear();state['cusum']=0;state['evidence']=EvidenceState();state['alarm_until']=0
  state['last']=at
  x,expected,static=self.prepare([context],[resource]) if prepared is None else prepared;z=np.clip((x[0]-self.a['mean'])/self.a['scale'],-20,20).astype(np.float32);state['history'].append(z)
  if len(state['history'])<8:return dict(state='warming_up',risk=None,action='retain_network_protection')
  sequence=np.stack(state['history']);
  with torch.no_grad():temporal=float(torch.sigmoid(self.net(torch.from_numpy(sequence[None])))[0])
  static=float(static[0]);risk=(temporal+static)/2
  innovation=float(max(0,resource[0]-expected[0,0],resource[1]-expected[0,1]));state['votes'].append(risk>self.a['threshold'])
  drift_warning=False
  if 'drift_scale' in self.a and 'evidence_v3' not in self.a:
   residual=float(resource[0]-expected[0,0]);sigma=self.a['drift_scale']
   if len(state['baseline'])<20:state['baseline'].append(residual)
   else:
    bias=float(np.clip(np.median(state['baseline']),-2*sigma,2*sigma));weight=min(3,max(.2,context[11]/5));value=float(np.clip((residual-bias)/sigma,-3,5));state['cusum']=max(0,state['cusum']+(value-.5)*weight);drift_warning=state['cusum']>self.a.get('drift_threshold',float('inf'))
  trigger=sum(state['votes'])>=3 or drift_warning
  if 'evidence_v3' in self.a:
   evidence=state['evidence'].update(risk,float(resource[0]-expected[0,0]),context,expected[0],self.a['evidence_v3']);state['cusum']=evidence['drift_score'];drift_warning=evidence['drift_warning'];trigger=evidence['neural_warning'] or drift_warning
  if trigger:state['alarm_until']=at+30
  alarm=at<=state['alarm_until'];fresh=context[11]<=60
  if not self.trusted:status='untrusted_monitor';action='request_independent_evidence'
  elif not fresh:status='insufficient_time_resolution';action='request_fresh_evidence'
  elif alarm:status='resource_misuse_suspected';action='prioritize_authenticated_evidence'
  else:status='no_current_resource_alarm';action='retain_network_protection'
  return dict(state=status,risk=risk,temporal_risk=temporal,context_risk=static,positive_innovation=innovation,drift_score=state['cusum'],drift_warning=bool(drift_warning),alarm=bool(alarm and self.trusted and fresh),action=action)

 def coverage(self,at,expected_nodes):
  return {node:('missing_evidence' if node not in self.states or at-self.states[node]['last']>60 else 'untrusted_monitor' if not self.trusted else 'observed') for node in expected_nodes}

class PhysicalResourcePredictor:
 """Separate root-authorized local work from ordinary network processing."""
 def fit(self,logcontext,target):
  from sklearn.preprocessing import StandardScaler
  from sklearn.linear_model import HuberRegressor
  from sklearn.ensemble import ExtraTreesRegressor
  raw=np.expm1(logcontext);resource=np.expm1(target)/100
  self.scale=StandardScaler().fit(logcontext[:,:-1]);design=np.c_[self.scale.transform(logcontext[:,:-1]),raw[:,-1]/1000]
  robust=HuberRegressor(epsilon=1.35,alpha=.1,max_iter=1000).fit(design,resource[:,0]*100)
  self.cpu_per_work=max(0,float(robust.coef_[-1])/100000)
  adjusted=resource.copy();adjusted[:,0]=np.maximum(0,adjusted[:,0]-self.cpu_per_work*raw[:,-1])
  self.base=ExtraTreesRegressor(n_estimators=64,min_samples_leaf=12,max_depth=12,random_state=15,n_jobs=2).fit(logcontext[:,:-1],np.log1p(adjusted*100));self.base.n_jobs=1;return self
 def predict(self,logcontext):
  result=np.expm1(self.base.predict(logcontext[:,:-1]))/100;result[:,0]+=self.cpu_per_work*np.expm1(logcontext[:,-1]);return np.log1p(np.maximum(result,0)*100)
