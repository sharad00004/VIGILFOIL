<?xml version='1.0' encoding='utf-8'?>
<simconf version="2022112801">
  <simulation>
    <title>joint-sparse_loss-no_memory-s1151</title>
    <randomseed>1151</randomseed>
    <motedelay_us>1000000</motedelay_us>
    <radiomedium>org.contikios.cooja.radiomediums.UDGM<transmitting_range>30</transmitting_range>
      <interference_range>45</interference_range>
      <success_ratio_tx>1</success_ratio_tx>
      <success_ratio_rx>0.85</success_ratio_rx>
    </radiomedium>
    <motetype>org.contikios.cooja.mspmote.Z1MoteType<identifier>root</identifier>
      <description>Trusted monitor, application selective forwarding</description>
      <source>[CONFIG_DIR]/../firmware/root/pilot.c</source>
      <commands />
      <firmware>[CONFIG_DIR]/../firmware/root/build/z1/pilot.z1</firmware><moteinterface>org.contikios.cooja.interfaces.Position</moteinterface><moteinterface>org.contikios.cooja.interfaces.IPAddress</moteinterface><moteinterface>org.contikios.cooja.interfaces.Mote2MoteRelations</moteinterface><moteinterface>org.contikios.cooja.interfaces.MoteAttributes</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspClock</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspMoteID</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.Msp802154Radio</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspDefaultSerial</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspLED</moteinterface><mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="0" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>1</id>
        </interface_config>
      </mote>
      </motetype>
  <motetype>org.contikios.cooja.mspmote.Z1MoteType<identifier>leaf</identifier>
      <description>Trusted monitor, application selective forwarding</description>
      <source>[CONFIG_DIR]/../firmware/leaf/pilot.c</source>
      <commands />
      <firmware>[CONFIG_DIR]/../firmware/leaf/build/z1/pilot.z1</firmware><moteinterface>org.contikios.cooja.interfaces.Position</moteinterface><moteinterface>org.contikios.cooja.interfaces.IPAddress</moteinterface><moteinterface>org.contikios.cooja.interfaces.Mote2MoteRelations</moteinterface><moteinterface>org.contikios.cooja.interfaces.MoteAttributes</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspClock</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspMoteID</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.Msp802154Radio</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspDefaultSerial</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspLED</moteinterface><mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="22" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>2</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="22" y="20" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>3</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="44" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>4</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="44" y="-8" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>5</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="44" y="8" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>6</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="66" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>7</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="66" y="-8" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>8</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="66" y="8" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>9</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="88" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>10</id>
        </interface_config>
      </mote>
      </motetype>
  </simulation>
  <plugin>org.contikios.cooja.plugins.ScriptRunner<plugin_config>
      <script>var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var sock=new java.net.Socket('127.0.0.1',49479);var out=new java.io.PrintWriter(sock.getOutputStream(),true);var inp=new java.io.BufferedReader(new java.io.InputStreamReader(sock.getInputStream()));function provision(){var motes=sim.getMotes();var own=[[22, -68, 41, 127, 64, -108, 33, -79, 117, -79, 55, -35, -51, 60, -125, 47, -42, -113, -101, -73, 13, -24, 123, -122, 31, 7, 66, -18, -4, 41, -6, -45], [109, -43, 25, 41, -83, -42, -75, -61, -20, 2, -32, -90, -67, 117, 90, -124, 5, -52, -67, -127, -21, -66, -26, -45, -19, 70, -104, -58, 78, 90, -90, -82], [84, -36, 106, -75, 127, -22, 24, 124, 123, 53, -56, 50, 88, 39, -26, -118, 56, -127, -62, 58, 46, -78, -107, -9, 96, -47, -43, 75, -64, 121, -69, -103], [-36, -12, -126, 56, -93, -29, 60, 9, 54, 117, -53, -121, -67, 25, 105, -54, 81, 122, -100, 49, -80, -102, 0, -115, -107, 50, -39, -128, -99, -55, 62, -14], [-28, 92, -24, 110, -119, 17, 68, -70, 61, -106, -56, 100, 49, -67, 70, 96, -95, 26, -107, 18, -24, -52, 1, -43, -82, 51, 32, 86, 90, -64, -107, 66], [-77, 0, -117, 96, 79, -33, 35, 57, -19, -32, 69, 37, -73, -33, -6, 103, -7, -43, 126, -35, 15, -100, 7, -34, -108, 99, 117, -65, -29, 18, 96, -11], [-50, -32, 17, -102, -47, -77, -5, -65, -59, 115, 54, -74, 48, 122, 12, -95, -93, -95, 65, 18, 112, -102, 119, 74, 13, 38, 17, 15, -115, 18, -123, 90], [-64, -89, 59, 12, 90, 68, 74, -109, 68, 48, 80, 31, -105, 48, -58, -2, -104, -54, 120, 86, -34, 6, -37, -77, 89, 57, -26, -120, 25, 8, 121, 36], [72, -82, 16, 73, 22, -127, -89, 19, 101, 46, 25, 84, -9, 82, -127, 2, -127, -105, 109, -93, 25, 61, -99, 80, -103, 110, 124, -101, -40, -80, -84, -12], [-56, -24, 72, -82, 13, -121, -22, -48, 28, -52, 51, -9, 59, -125, 59, 64, -127, -100, 100, -97, 32, 38, 91, 93, 114, 36, -3, 123, -73, -77, -89, 61], [-21, -34, -102, 16, 20, 5, 75, -31, -123, -78, 37, -109, 71, -37, 85, 94, -47, -72, 101, -76, -99, -105, -90, 15, 27, -48, -1, 104, -48, -39, 67, 72]];for(var i=0;i&lt;motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setByteArray('stage_session',Java.to([-13, 25, 32, 22],'byte[]'));if(i==0){mem.setIntValueOf('experiment_case',13);mem.setIntValueOf('attacker_id',2);mem.setIntValueOf('authorized_work',1000);mem.setIntValueOf('attack_start',400);mem.setIntValueOf('attack_stop',700);}else{mem.setIntValueOf('pilot_policy',10);mem.setIntValueOf('pilot_case',4);mem.setIntValueOf('pilot_nodes',10);mem.setIntValueOf('pilot_relay',2);mem.setIntValueOf('pilot_fault',0);mem.setIntValueOf('pilot_start1',400);mem.setIntValueOf('pilot_end1',700);mem.setIntValueOf('pilot_start2',1000);mem.setIntValueOf('pilot_end2',1000);mem.setIntValueOf('pilot_report_period',30);mem.setIntValueOf('pilot_auth',1);mem.setIntValueOf('pilot_freshness',1);mem.setIntValueOf('pilot_monitor',1);mem.setIntValueOf('host_case',3);mem.setIntValueOf('host_work',1000);}mem.setByteArray('own_key',Java.to(own[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to([22, -68, 41, 127, 64, -108, 33, -79, 117, -79, 55, -35, -51, 60, -125, 47, -42, -113, -101, -73, 13, -24, 123, -122, 31, 7, 66, -18, -4, 41, -6, -45, 109, -43, 25, 41, -83, -42, -75, -61, -20, 2, -32, -90, -67, 117, 90, -124, 5, -52, -67, -127, -21, -66, -26, -45, -19, 70, -104, -58, 78, 90, -90, -82, 84, -36, 106, -75, 127, -22, 24, 124, 123, 53, -56, 50, 88, 39, -26, -118, 56, -127, -62, 58, 46, -78, -107, -9, 96, -47, -43, 75, -64, 121, -69, -103, -36, -12, -126, 56, -93, -29, 60, 9, 54, 117, -53, -121, -67, 25, 105, -54, 81, 122, -100, 49, -80, -102, 0, -115, -107, 50, -39, -128, -99, -55, 62, -14, -28, 92, -24, 110, -119, 17, 68, -70, 61, -106, -56, 100, 49, -67, 70, 96, -95, 26, -107, 18, -24, -52, 1, -43, -82, 51, 32, 86, 90, -64, -107, 66, -77, 0, -117, 96, 79, -33, 35, 57, -19, -32, 69, 37, -73, -33, -6, 103, -7, -43, 126, -35, 15, -100, 7, -34, -108, 99, 117, -65, -29, 18, 96, -11, -50, -32, 17, -102, -47, -77, -5, -65, -59, 115, 54, -74, 48, 122, 12, -95, -93, -95, 65, 18, 112, -102, 119, 74, 13, 38, 17, 15, -115, 18, -123, 90, -64, -89, 59, 12, 90, 68, 74, -109, 68, 48, 80, 31, -105, 48, -58, -2, -104, -54, 120, 86, -34, 6, -37, -77, 89, 57, -26, -120, 25, 8, 121, 36, 72, -82, 16, 73, 22, -127, -89, 19, 101, 46, 25, 84, -9, 82, -127, 2, -127, -105, 109, -93, 25, 61, -99, 80, -103, 110, 124, -101, -40, -80, -84, -12, -56, -24, 72, -82, 13, -121, -22, -48, 28, -52, 51, -9, 59, -125, 59, 64, -127, -100, 100, -97, 32, 38, 91, 93, 114, 36, -3, 123, -73, -77, -89, 61, -21, -34, -102, 16, 20, 5, 75, -31, -123, -78, 37, -109, 71, -37, 85, 94, -47, -72, 101, -76, -99, -105, -90, 15, 27, -48, -1, 104, -48, -39, 67, 72],'byte[]'));}}
GENERATE_MSG(5000,'PROVISION');TIMEOUT(900000,log.testOK());
while(true){YIELD();if(msg=='PROVISION'){provision();continue;}var line=time+','+id+','+msg;log.log(line+'\n');if(id==1&amp;&amp;(String(msg).startsWith('TELEMETRY,')||String(msg).startsWith('AUTH_CONTEXT,')||String(msg).startsWith('ROOT_RX,')||String(msg).startsWith('GATEWAY_TICK,'))){out.println(line);var response=inp.readLine();if(response==null)throw 'gateway closed';var answer=JSON.parse(String(response));if(answer.commands&amp;&amp;answer.commands.length){var rm=new VM(sim.getMotes()[0].getMemory());var payload=[];var ns=[],ps=[],ls=[];for(var j=0;j&lt;4;j++){var command=answer.commands[j];ns.push(command?command.node:0);ps.push(command?command.port:0);ls.push(command?command.hex.length/2:0);for(var k=0;k&lt;60;k++){var b=command&amp;&amp;k&lt;command.hex.length/2?parseInt(command.hex.substr(2*k,2),16):0;payload.push(b&lt;128?b:b-256);}}rm.setByteArray('gateway_payload',Java.to(payload,'byte[]'));for(var j=0;j&lt;4;j++){rm.setIntValueOf('gateway_node',ns[0]);break;}var bytes=function(a){var b=[];for(var k=0;k&lt;a.length;k++){b.push(a[k]&amp;255);b.push((a[k]&gt;&gt;8)&amp;255);}return Java.to(b.map(function(x){return x&lt;128?x:x-256;}),'byte[]');};rm.setByteArray('gateway_node',bytes(ns));rm.setByteArray('gateway_port',bytes(ps));rm.setByteArray('gateway_len',bytes(ls));rm.setIntValueOf('gateway_count',answer.commands.length);}}}</script>
      <active>true</active>
    </plugin_config>
  </plugin>
</simconf>