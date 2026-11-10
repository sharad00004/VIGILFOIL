"""Live serial/log adapter. Only verified root records are accepted here.
The firmware is responsible for wire authentication/session/replay checks.
"""
import numpy as np
class MonitorStream:
 def __init__(self,guard,expected_nodes=range(2,11)):
  self.guard=guard;self.expected=set(expected_nodes);self.last={};self.permits={}
 def consume(self,line):
  f=line.strip().split(',')
  if len(f)<4 or not f[0].isdigit() or f[1]!='1':return None
  time=int(f[0])/1e6
  if f[2]=='AUTH_CONTEXT':
   node,at,end,work=map(int,f[3:]);self.permits[node]=(time,time+end-at+3,work);return None
  if f[2]!='TELEMETRY':return None
  try:v=np.array(list(map(int,f[3:])),dtype=np.int64)
  except ValueError:return dict(state='invalid_measurement',time=time)
  if len(v)!=18 or int(v[0]) not in self.expected:return dict(state='invalid_source',time=time)
  node=int(v[0]);previous=self.last.get(node);self.last[node]=(time,v)
  if previous is None:return dict(node=node,time=time,state='warming_up',risk=None)
  pt,pv=previous;dt=v[17]-pv[17];delta=v-pv
  if dt<=0 or (delta[[1,3,4,5,8,9,10,11,12,13,14,15,16]]<0).any():
   self.last.pop(node,None);self.guard.states.pop(node,None);return dict(node=node,time=time,state='counter_discontinuity',risk=None,action='request_fresh_evidence')
  authorized=0
  if node in self.permits:
   begin,end,work=self.permits[node];authorized=work*max(0,min(time,end)-max(time-dt,begin))/dt
  context=np.r_[v[6]/256,int(v[7]!=pv[7]),delta[[8,9,10,11,12,13,14,15,16]]/dt,dt,time-pt,max(0,int(delta[1])-1)/dt,authorized];resource=delta[[3,4,5]]/dt/32768
  return dict(node=node,time=time,**self.guard.step(node,time,context,resource))
