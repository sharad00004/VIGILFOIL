"""Paired mixed Cooja runs; no privileged or external network operations."""
from pathlib import Path
import copy,json,secrets,hashlib,xml.etree.ElementTree as E,subprocess,time,socket,threading,sys
s=Path(__file__).resolve().parents[1]
_keylock=threading.Lock()
def scenario(c,port):
 tree=E.parse(s/'configs/cooja-template.csc');sim=tree.find('simulation');sim.find('title').text=c['name'];sim.find('randomseed').text=str(c['seed']);radio=sim.find('radiomedium');radio.find('transmitting_range').text='30';radio.find('interference_range').text='45';radio.find('success_ratio_rx').text=str(c.get('rx',1));mt=sim.find('motetype');lm=copy.deepcopy(mt);sim.append(lm)
 mt.find('identifier').text='root';mt.find('source').text='[CONFIG_DIR]/../firmware/root/pilot.c';mt.find('firmware').text='[CONFIG_DIR]/../firmware/root/build/z1/pilot.z1'
 lm.find('identifier').text='leaf';lm.find('source').text='[CONFIG_DIR]/../firmware/leaf/pilot.c';lm.find('firmware').text='[CONFIG_DIR]/../firmware/leaf/build/z1/pilot.z1'
 for m in mt.findall('mote')[1:]:mt.remove(m)
 lm.remove(lm.find('mote'))
 pos=[(0,0),(22,0),(22,20),(44,0),(44,-8),(44,8),(66,0),(66,-8),(66,8),(88,0)] if c.get('topology')!='grid' else [(i//3*22,i%3*22) for i in range(10)]
 for i,m in enumerate(mt.findall('mote')+lm.findall('mote')):
  q=m.find('interface_config/pos');q.set('x',str(pos[i][0]));q.set('y',str(pos[i][1]))
 with _keylock:
  keys_path=s/'configs/lab-keys.json';keys=json.loads(keys_path.read_text()) if keys_path.exists() else {};key=keys.setdefault(str(c['seed']),dict(session=secrets.randbits(30)+1,keys=[list(secrets.token_bytes(32)) for _ in range(11)]));keys_path.write_text(json.dumps(keys))
 signed=lambda a:[v if v<128 else v-256 for v in a];own=[signed(k) for k in key['keys']];peer=sum(own,[])
 vals=dict(pilot_policy=10,pilot_case=c.get('network_case',0),pilot_nodes=10,pilot_relay=c.get('target',2),pilot_fault=0,pilot_start1=400,pilot_end1=700,pilot_start2=1000,pilot_end2=1000,pilot_budget=480,pilot_report_period=30,pilot_model_action=1,pilot_action_aware=0 if c['variant']=='no_action' else 1,pilot_auth=1,pilot_freshness=1,pilot_context=1,pilot_monitor=1,pilot_repair=1,pilot_observed_helpers=1,host_case=c.get('host_case',0),host_work=c.get('work',250),pilot_authorized=c.get('authorized',1000),host_enabled=0 if c['variant']=='network_only' else 1)
 rootvals=dict(experiment_case=13 if c.get('authorized',1000) else 0,attacker_id=c.get('target',2),authorized_work=c.get('authorized',1000),attack_start=400,attack_stop=700)
 leafvals={k:v for k,v in vals.items() if k not in ['pilot_budget','pilot_model_action','pilot_action_aware','pilot_context','pilot_repair','pilot_observed_helpers','host_enabled','pilot_authorized']}
 code="var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var sock=new java.net.Socket('127.0.0.1',"+str(port)+");var out=new java.io.PrintWriter(sock.getOutputStream(),true);var inp=new java.io.BufferedReader(new java.io.InputStreamReader(sock.getInputStream()));function provision(){var motes=sim.getMotes();var own="+json.dumps(own)+";for(var i=0;i<motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setByteArray('stage_session',Java.to("+json.dumps(signed(list(key['session'].to_bytes(4,'little'))))+",'byte[]'));if(i==0){"+''.join(f"mem.setIntValueOf('{k}',{v});" for k,v in rootvals.items())+"}else{"+''.join(f"mem.setIntValueOf('{k}',{v});" for k,v in leafvals.items())+"}mem.setByteArray('own_key',Java.to(own[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to("+json.dumps(peer)+",'byte[]'));}}\nGENERATE_MSG(5000,'PROVISION');TIMEOUT("+str(c.get('duration',900)*1000)+",log.testOK());\nwhile(true){YIELD();if(msg=='PROVISION'){provision();continue;}var line=time+','+id+','+msg;log.log(line+'\\n');if(id==1&&(String(msg).startsWith('TELEMETRY,')||String(msg).startsWith('AUTH_CONTEXT,')||String(msg).startsWith('ROOT_RX,')||String(msg).startsWith('GATEWAY_TICK,'))){out.println(line);var response=inp.readLine();if(response==null)throw 'gateway closed';var answer=JSON.parse(String(response));if(answer.commands&&answer.commands.length){var rm=new VM(sim.getMotes()[0].getMemory());var payload=[];var ns=[],ps=[],ls=[];for(var j=0;j<4;j++){var command=answer.commands[j];ns.push(command?command.node:0);ps.push(command?command.port:0);ls.push(command?command.hex.length/2:0);for(var k=0;k<60;k++){var b=command&&k<command.hex.length/2?parseInt(command.hex.substr(2*k,2),16):0;payload.push(b<128?b:b-256);}}rm.setByteArray('gateway_payload',Java.to(payload,'byte[]'));for(var j=0;j<4;j++){rm.setIntValueOf('gateway_node',ns[0]);break;}var bytes=function(a){var b=[];for(var k=0;k<a.length;k++){b.push(a[k]&255);b.push((a[k]>>8)&255);}return Java.to(b.map(function(x){return x<128?x:x-256;}),'byte[]');};rm.setByteArray('gateway_node',bytes(ns));rm.setByteArray('gateway_port',bytes(ps));rm.setByteArray('gateway_len',bytes(ls));rm.setIntValueOf('gateway_count',answer.commands.length);}}}"
 # VarMemory has no generic integer-array setter; explicit little-endian MSP430 arrays above.
 code=code.replace("for(var j=0;j<4;j++){var command=answer.commands[j];rm.setIntArray('gateway_node',Java.to(answer.commands.map(function(x){return x.node;}),'int[]'));break;}","")
 tree.find('plugin/plugin_config/script').text=code;p=s/'scenarios'/(c['name']+'.csc');tree.write(p,encoding='utf-8',xml_declaration=True);return p

def run(c,detector=None):
 d=s/'logs'/c['name'];d.mkdir(exist_ok=True);listener=socket.socket();listener.bind(('127.0.0.1',0));listener.listen(1);listener.settimeout(120);port=listener.getsockname()[1];sc=scenario(c,port);errors=[]
 def serve():
  try:
   conn,_=listener.accept();conn.settimeout(120)
   with conn,conn.makefile('rw') as f,(d/'gateway.jsonl').open('w') as audit:
    while True:
     line=f.readline()
     if not line:break
     result=detector.consume(line.strip()) if detector else dict(mask=0,known=0)
     audit.write(json.dumps(dict(input=line.strip(),**result))+'\n');audit.flush();f.write(json.dumps(result)+"\n");f.flush()
  except Exception as e:errors.append(repr(e))
 thread=threading.Thread(target=serve,daemon=True);thread.start();start=time.monotonic();print('START',c['name'],flush=True)
 with (d/'console.log').open('w') as f:
  p=subprocess.Popen(['bash',str(s.parent/'simulation/scripts/run_cooja.sh'),'--no-gui','--no-log-color','--logdir',str(d),str(sc)],stdout=f,stderr=subprocess.STDOUT)
  try:code=p.wait(timeout=360)
  except subprocess.TimeoutExpired:p.kill();p.wait();code=124
 listener.close();thread.join(3);raw=d/'COOJA.testlog';ok=raw.exists() and 'TEST OK' in raw.read_text();m=dict(c,exit_code=code if code else 0 if ok and not errors else 2,wall_seconds=time.monotonic()-start,gateway_errors=errors,raw_sha256=hashlib.sha256(raw.read_bytes()).hexdigest() if raw.exists() else None,scenario_sha256=hashlib.sha256(sc.read_bytes()).hexdigest(),leaf_sha256=hashlib.sha256((s/'firmware/leaf/build/z1/pilot.z1').read_bytes()).hexdigest(),source_sha256={role:hashlib.sha256((s/f'firmware/{role}/pilot.c').read_bytes()).hexdigest() for role in ['root','leaf']});(d/'run.json').write_text(json.dumps(m,indent=2));print('END',c['name'],m['exit_code'],round(m['wall_seconds'],1),flush=True)
 if m['exit_code']:raise RuntimeError((m,(d/'console.log').read_text()[-1500:]))
 return m
if __name__=='__main__':run(dict(name='integration-smoke-v10',seed=1090,variant='network_only',duration=900,network_case=2,host_case=1,target=2))
