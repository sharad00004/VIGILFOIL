from pathlib import Path
import json,sys,pickle,time,statistics,platform
s=Path(__file__).resolve().parents[1];sys.path.insert(0,str(s/'scripts'));from gateway import Gateway
artifact=pickle.loads((s/'models/combined.pkl').read_bytes());keys=json.loads((s/'configs/lab-keys.json').read_text());c=json.loads((s/'configs/source.json').read_text())[0];inputs=[json.loads(line)['input'] for line in (s/'logs'/c['name']/'gateway.jsonl').read_text().splitlines()][:600];results=[]
for variant in ['full','network_only','cipher','contrast']:
 g=Gateway(c,variant,keys[str(c['seed'])],artifact);timings=[];telemetry=[];decisions=[]
 for line in inputs:
  st=time.perf_counter();r=g.consume(line);elapsed=(time.perf_counter()-st)*1000;timings.append(elapsed)
  if ',TELEMETRY,' in line and r.get('host',{}).get('risk') is not None:telemetry.append(elapsed)
  if ',GATEWAY_TICK,' in line:decisions.append(elapsed)
 def stats(v):return dict(n=len(v),median_ms=statistics.median(v) if v else None,p95_ms=sorted(v)[min(len(v)-1,int(.95*len(v)))] if v else None)
 results.append(dict(variant=variant,all_events=stats(timings),scored_host_reports=stats(telemetry),controller_decisions=stats(decisions)))
parts={k:len(pickle.dumps(artifact[k])) for k in ['predictor','classifier','temporal_state']};parts.update({name+'_AE':len(pickle.dumps(artifact['comparators'][name])) for name in ['cipher','contrast']})
(s/'results/host-profile.json').write_text(json.dumps(dict(results=results,serialized_components_bytes=parts,artifact_bytes=(s/'models/combined.pkl').stat().st_size,scope='same600recorded benign source root events, single-thread Python host replay after simulation; timings are wall-time, not MCU inference or simulated-network outcomes; network-only retains shadow HMA computation',platform=platform.platform()),indent=2));print('host profile saved')
