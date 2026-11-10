"""Paper architectural reconstructions. Underspecified widths/activations are recorded.
Temporal reconstruction is causal, time-distributed: no future rows enter a score.
"""
import math
import numpy as np
import torch
from torch import nn

def correlation_groups(x,threshold=.7):
 d=x.shape[1];corr=np.nan_to_num(np.corrcoef(x.T),nan=0);left=set(range(d));groups=[]
 while left:
  group={min(left)};todo=list(group);left-=group
  while todo:
   i=todo.pop();new={j for j in left if abs(corr[i,j])>=threshold};left-=new;group|=new;todo+=list(new)
  groups.append(sorted(group))
 return groups
class FC(nn.Module):
 def __init__(self,d):
  super().__init__();self.net=nn.Sequential(nn.Linear(d,max(1,math.isqrt(d))),nn.ReLU(),nn.Linear(max(1,math.isqrt(d)),d))
 def forward(self,x):return self.net(x)
class Temporal(nn.Module):
 def __init__(self,d,groups,width):
  super().__init__();self.groups=groups;self.enc=nn.ModuleList([nn.LSTM(len(g),width,batch_first=True) for g in groups]);self.dec=nn.Linear(width*len(groups),d)
 def forward(self,x):return self.dec(torch.cat([e(x[:,:,g])[0] for e,g in zip(self.enc,self.groups)],-1))
class Host(nn.Module):
 def __init__(self,width):
  super().__init__();self.enc=nn.LSTM(2,width,batch_first=True);self.dec=nn.Sequential(nn.Linear(width,1),nn.ReLU(),nn.Linear(1,2))
 def forward(self,x):return self.dec(self.enc(x)[0])
class LitmusNet(nn.Module):
 def __init__(self,groups):
  super().__init__();self.groups=groups;self.enc=nn.ModuleList([FC(len(g)) for g in groups]);self.aggregator=FC(len(groups))
 def errors(self,x):
  e=torch.stack([((m(x[:,:,g])-x[:,:,g])**2).mean(-1) for m,g in zip(self.enc,self.groups)],-1)
  return e,((self.aggregator(e)-e)**2).mean(-1)
 def forward(self,x):return torch.cat([m(x[:,:,g]) for m,g in zip(self.enc,self.groups)],-1)
