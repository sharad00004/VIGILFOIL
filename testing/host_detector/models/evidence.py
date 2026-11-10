"""Bounded residual accumulation: a causal CPU evidence lane for HMA."""
from collections import deque
import numpy as np
class EvidenceState:
 def __init__(self):self.baseline=[];self.score=0.;self.votes=deque(maxlen=5)
 def update(self,risk,error,context,expected,settings):
  self.votes.append(risk)
  rate=max(0,context[9],context[10]);bin_id=int(np.searchsorted(settings['rate_edges'],rate,side='right'))
  sigma=max(settings['noise'][bin_id],settings['relative_noise']*expected[0]);value=error/max(sigma,1e-8)
  if len(self.baseline)<20:self.baseline.append(value)
  else:
   bias=float(np.clip(np.median(self.baseline),-2,2));dt=min(15,max(1,context[11]));decay=np.exp(-dt/settings['tau'])
   increment=float(np.clip(value-bias,-3,5))-settings['allowance']
   self.score=max(0,decay*self.score+increment*dt/5)
   self.score=min(self.score,settings.get('cap_multiplier',2)*settings['drift_threshold'])
  order=sorted(self.votes,reverse=True)[2] if len(self.votes)>=3 else 0
  return dict(neural_score=float(order),drift_score=float(self.score),sigma=float(sigma),neural_warning=bool(order>settings['neural_threshold']),drift_warning=bool(self.score>settings['drift_threshold']))
