from pathlib import Path
from collections import defaultdict,Counter
import json,struct,hmac,hashlib,csv,math,statistics
s=Path(__file__).resolve().parents[1]
def analyze(c):
 d=s/'logs'/c['name'];meta=json.loads((d/'run.json').read_text());assert meta['exit_code']==0;raw=d/'COOJA.testlog';assert hashlib.sha256(raw.read_bytes()).hexdigest()==meta['raw_sha256'];assert 'Check failed' not in raw.read_text()
 keys=json.loads((s/'configs/lab-keys.json').read_text())[str(c['seed'])];offers=set();orig=set();copies=set();delivered=set();original_rx=set();cpu_events=[];counts=Counter();telemetry=set();control_rx=0;framechecks=0;first_exec=None;last_exec=None;tx_commands=[]
 for line in raw.read_text().splitlines():
  f=line.split(',')
  if len(f)<3 or not f[0].isdigit():continue
  at=int(f[0])/1e6;logger=int(f[1]);kind=f[2]
  if kind=='APP_OFFER':offers.add(tuple(map(int,f[3:6])))
  elif kind=='DATA_TX':
   node,seq,e,typ,n=map(int,f[3:]);(orig if typ==1 else copies).add((node,seq,e));counts['repair_source_bytes']+=n if typ==6 else 0
  elif kind=='HOST_TX':counts['host_bytes']+=int(f[-1])
  elif kind=='REPORT_TX':counts['mandatory_report_bytes' if int(f[5])==0 else 'query_reply_bytes']+=int(f[-1])
  elif kind=='HELPER_TX':counts['repair_helper_bytes']+=int(f[-1]);counts['helper_forwards']+=1
  elif kind=='GRANT_RX':counts['grant_receipts']+=1
  elif kind=='HELPER_REJECT_AUTH':counts['helper_capability_rejections']+=1
  elif kind=='SOURCE_ACTION':counts['redirected_offers']+=1
  elif kind=='ORACLE_DROP':counts['malicious_drops']+=1
  elif kind=='ORACLE_HOST':
   cpu_events.append((int(f[4]),at));first_exec=at if first_exec is None else min(first_exec,at);last_exec=at if last_exec is None else max(last_exec,at)
  elif logger==1 and kind=='AUTH_CONTEXT':counts['authorization_bytes']+=32
  elif logger==1 and kind=='GATEWAY_TX':
   node,port,n=map(int,f[3:]);counts['query_bytes' if n==28 else 'grant_bytes']+=n;counts['commands_sent']+=1;tx_commands.append((node,port,n))
  elif logger==1 and kind=='TELEMETRY':telemetry.add(int(f[3]))
  elif logger==1 and kind=='ROOT_RX':
   p=bytes.fromhex(f[4]);v=struct.unpack('>'+str((len(p)-8)//4)+'I',p[:-8]);typ,node,session=v[:3];assert session==keys['session'];assert hmac.digest(bytes(keys['keys'][node]),p[:-8],'sha256')[:8]==p[-8:];framechecks+=1
   if typ in [1,6]:
    seq,e=v[3:5]
    if e<=at//10+1 and at//10<=e+6:
     delivered.add((node,seq,e))
     if typ==1:original_rx.add((node,seq,e))
 assert delivered<=offers,(c['name'],'nonoffered delivery');assert orig|copies<=offers;assert telemetry==set(range(2,11)),(c['name'],telemetry)
 decisions=[];pred=[];valid_reports=0;rejected_reports=0;ledger_known=0;ledger_total=0;scope_reductions=0;planned=[];missing_samples=0
 for line in (d/'gateway.jsonl').read_text().splitlines():
  z=json.loads(line);input=z['input'].split(',')
  if 'report_accepted' in z:valid_reports+=int(z['report_accepted']);rejected_reports+=int(not z['report_accepted'])
  if 'host' in z:
   h=z['host'];local=int(input[20]) if input[2]=='TELEMETRY' else None;node=h.get('node');truth=bool(c['host_case'] and node==c['target'] and local is not None and 400<=local<700);pred.append(dict(node=node,time=int(input[0])/1e6,local=local,truth=truth,alarm=bool(h.get('alarm')) and c['variant']!='network_only',shadow_alarm=bool(h.get('alarm')) if c['variant']=='network_only' else False,scored=h.get('risk') is not None,state=h['state']))
  if 'decision' in z:
   r=z['decision'];assert 0<=r['used']<=480 and r['used']+r['remaining']==480
   expected_cost=0
   for cmd in r['commands']:
    b=bytes.fromhex(cmd['hex']);words=struct.unpack('>'+str((len(b)-8)//4)+'I',b[:-8]);kind=words[0];assert hmac.digest(bytes(keys['keys'][cmd['node']]),b[:-8],'sha256')[:8]==b[-8:];expected_cost+=136 if kind==2 else 124;planned.append((cmd['node'],cmd['port'],len(b)))
   assert expected_cost==r['used'];decisions.append(r);ledger_total+=len(r['ledger']);ledger_known+=sum(v['known'] for v in r['ledger']);scope_reductions+=sum(v['action_scope'] and v['expected']<v['submitted'] for v in r['ledger'])
 # Queue drains all generated commands inside the simulation; compare exact send sequence.
 assert planned==tx_commands,(c['name'],'command plan/wire mismatch',len(planned),len(tx_commands));assert valid_reports>0
 pos=[p for p in pred if p['truth']];scoredpos=[p for p in pos if p['scored']];alerts=[p for p in pos if p['alarm']];ben=[p for p in pred if not p['truth'] and p['scored']];pure=[p for p in ben if not(c['host_case'] and p['node']==c['target'] and p['local']>=700)];recovery=[p for p in ben if c['host_case'] and p['node']==c['target'] and p['local']>=700 and p['alarm']];other=[p for p in ben if p['node']!=c['target'] and p['alarm']];first_alarm=min([p['time'] for p in alerts],default=None)
 # An episode hit alone does not establish coverage of sparse recurring work.
 bursts=[]
 for t,at in cpu_events:
  if not bursts or t>bursts[-1][-1]+1:bursts.append([t])
  elif t!=bursts[-1][-1]:bursts[-1].append(t)
 covered=sum(any(p['alarm'] and b[0]<=p['local']<=b[-1]+15 for p in pos) for b in bursts)
 pernode=[]
 for node in range(2,11):
  n=sum(o[0]==node for o in offers);r=sum(o[0]==node for o in delivered);pernode.append(dict(node=node,offered=n,delivered=r,pdr=r/n if n else None))
 bytekeys=['host_bytes','authorization_bytes','mandatory_report_bytes','query_reply_bytes','query_bytes','grant_bytes','repair_source_bytes','repair_helper_bytes'];total=sum(counts[k] for k in bytekeys);attackoffers={o for o in offers if 40<=o[2]<70};attackdelivered=delivered&attackoffers
 out=dict(run=c['name'],seed=c['seed'],case=c['case'],variant=c['variant'],topology=c['topology'],target=c['target'],rx=c['rx'],offered=len(offers),delivered=len(delivered),pdr=len(delivered)/len(offers),worst_source_pdr=min(p['pdr'] for p in pernode if p['pdr'] is not None),attack_phase_pdr=len(attackdelivered)/len(attackoffers),defense_bytes=total,bytes_by_channel={k:counts[k] for k in bytekeys},actual_counts=dict(counts),valid_reports=valid_reports,rejected_reports=rejected_reports,unknown_ledger_fraction=1-ledger_known/max(1,ledger_total),action_scope_reductions=scope_reductions,host_episode_detected=bool(alerts) if c['host_case'] and c['variant']!='network_only' else None,first_alarm_delay_seconds=None if first_alarm is None else first_alarm-first_exec,first_alarm_source_delay_seconds=min([p['local']-400 for p in alerts],default=None),pre_attack_target_alarm_observations=sum(p['alarm'] for p in pred if c['host_case'] and p['node']==c['target'] and p['local'] is not None and p['local']<400),target_warned_within_15s_before_execution=bool(first_exec is not None and any(p['alarm'] and p['node']==c['target'] and first_exec-15<=p['time']<first_exec for p in pred)),host_attack_observations=len(pos),host_scored_attack_observations=len(scoredpos),host_alarm_attack_observations=len(alerts),benign_scored_observations=len(ben),benign_alarm_observations=sum(p['alarm'] for p in ben),nonrecovery_benign_observations=len(pure),nonrecovery_benign_alarm_observations=sum(p['alarm'] for p in pure),other_device_alarm_observations=len(other),post_attack_alarm_observations=len(recovery),last_post_attack_alarm_seconds=max([p['local']-700 for p in recovery],default=0),executed_cpu_bursts=len(bursts),bursts_with_alarm_within_15s=covered,host_supported_decisions=sum(any(v['host'] for v in r['ledger']) for r in decisions),budget_decisions=len(decisions),admitted_bytes=sum(r['used'] for r in decisions),signed_frames_verified=framechecks,all_nine_sources_observed=True,per_source=pernode)
 tp=len(alerts);fn=len(scoredpos)-tp;fp=sum(p['alarm'] for p in ben);tn=len(ben)-fp
 precision=tp/(tp+fp) if tp+fp else 0.;recall=tp/(tp+fn) if tp+fn else 0.;f1=2*precision*recall/(precision+recall) if precision+recall else 0.
 out.update(host_tp=tp,host_fp=fp,host_fn=fn,host_tn=tn,host_precision=precision,host_recall=recall,host_f1=f1,host_observation_fpr=fp/(fp+tn) if fp+tn else 0.)
 return out,pred
if __name__=='__main__':
 configs=json.loads((s/'configs/final.json').read_text());results=[];predictions=[]
 for c in configs:
  r,p=analyze(c);results.append(r);predictions.extend([dict(run=c['name'],**v) for v in p]);print(c['name'],'PDR',round(r['pdr'],4),'bytes',r['defense_bytes'],'delay',r['first_alarm_source_delay_seconds'],'benign',r['nonrecovery_benign_alarm_observations'],flush=True)
 (s/'results/runs.json').write_text(json.dumps(results,indent=2));(s/'results/host-predictions.json').write_text(json.dumps(predictions));fields=[k for k,v in results[0].items() if not isinstance(v,(list,dict))]
 with (s/'results/paper-runs.csv').open('w') as f:w=csv.DictWriter(f,fieldnames=fields,extrasaction='ignore');w.writeheader();w.writerows(results)
 summary=[]
 for variant in dict.fromkeys(r['variant'] for r in results):
  rr=[r for r in results if r['variant']==variant];attack=[r for r in rr if r['host_episode_detected'] is not None];benign=[r for r in rr if r['case']=='benign'];summary.append(dict(variant=variant,runs=len(rr),mean_pdr=statistics.mean(r['pdr'] for r in rr),mean_worst_source_pdr=statistics.mean(r['worst_source_pdr'] for r in rr),mean_defense_bytes=statistics.mean(r['defense_bytes'] for r in rr),host_episode_hits=sum(r['host_episode_detected'] for r in attack),host_episodes=len(attack),benign_alarms=sum(r['benign_alarm_observations'] for r in benign),benign_scored=sum(r['benign_scored_observations'] for r in benign),sparse_bursts_covered=sum(r['bursts_with_alarm_within_15s'] for r in rr if r['case']=='sparse_loss'),sparse_bursts=sum(r['executed_cpu_bursts'] for r in rr if r['case']=='sparse_loss')))
 for item in summary:
  zz=[r for r in results if r['variant']==item['variant']];tp=sum(r['host_tp'] for r in zz);fp=sum(r['host_fp'] for r in zz);fn=sum(r['host_fn'] for r in zz);tn=sum(r['host_tn'] for r in zz);pr=tp/(tp+fp) if tp+fp else 0.;re=tp/(tp+fn) if tp+fn else 0.;item.update(host_precision=pr,host_recall=re,host_f1=2*pr*re/(pr+re) if pr+re else 0.,host_observation_fpr=fp/(fp+tn) if fp+tn else 0.,host_tp=tp,host_fp=fp,host_fn=fn,host_tn=tn)
 (s/'results/summary.json').write_text(json.dumps(summary,indent=2))
 with (s/'results/paper-summary.csv').open('w') as f:w=csv.DictWriter(f,fieldnames=list(summary[0]));w.writeheader();w.writerows(summary)
 pairs=[]
 for r in results:
  if r['variant']=='full':continue
  q=next(v for v in results if v['variant']=='full' and v['seed']==r['seed'] and v['case']==r['case']);pairs.append(dict(seed=r['seed'],case=r['case'],comparator=r['variant'],pdr_delta_pp=100*(q['pdr']-r['pdr']),worst_source_delta_pp=100*(q['worst_source_pdr']-r['worst_source_pdr']),defense_payload_saving=1-q['defense_bytes']/r['defense_bytes'],byte_delta=q['defense_bytes']-r['defense_bytes']))
 (s/'results/paired-differences.json').write_text(json.dumps(pairs,indent=2));print('validated',len(results),'live runs')
