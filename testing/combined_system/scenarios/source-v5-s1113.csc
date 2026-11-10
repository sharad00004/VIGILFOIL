<?xml version='1.0' encoding='utf-8'?>
<simconf version="2022112801">
  <simulation>
    <title>source-v5-s1113</title>
    <randomseed>1113</randomseed>
    <motedelay_us>1000000</motedelay_us>
    <radiomedium>org.contikios.cooja.radiomediums.UDGM<transmitting_range>30</transmitting_range>
      <interference_range>45</interference_range>
      <success_ratio_tx>1</success_ratio_tx>
      <success_ratio_rx>0.9</success_ratio_rx>
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
      <script>var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var sock=new java.net.Socket('127.0.0.1',51405);var out=new java.io.PrintWriter(sock.getOutputStream(),true);var inp=new java.io.BufferedReader(new java.io.InputStreamReader(sock.getInputStream()));function provision(){var motes=sim.getMotes();var own=[[76, 82, -40, 114, -28, 8, -18, 74, -113, -126, 23, 13, 24, -103, 107, -124, -70, 116, -2, -118, -83, -69, -55, -48, -3, 50, 59, -41, -117, -128, -62, 50], [-45, -62, -15, -61, -72, -74, 38, -106, -88, -43, 70, -97, -79, -87, 70, -43, -114, 108, -66, 63, -56, -47, 21, 84, 39, -101, 90, -3, 33, -23, -121, 71], [-18, -122, 41, 21, -77, 5, 89, 8, 81, -66, 49, -32, -106, 103, 105, 92, 111, 0, 0, 11, -46, -61, -27, 9, 112, -38, 34, 34, -110, -56, 90, -80], [96, 115, -65, 10, -97, 9, 70, -51, 119, 43, -40, 7, 74, 22, -90, 58, 19, -9, 3, -45, 117, -90, 84, -3, 7, 58, -70, -52, -42, -116, 125, 17], [-33, -125, 126, -35, 60, -47, 86, -43, 14, -53, 13, 114, 91, -48, -99, 27, -89, 113, -25, 41, 19, -17, 24, -103, 21, -14, -82, 41, -126, 63, -69, -114], [115, 34, 44, -111, 102, -64, -73, -22, 108, -63, 64, -8, 17, -75, -96, 118, 41, -7, 73, 59, -3, 5, 0, 38, 120, -13, 113, 80, -31, 89, 26, 23], [-115, -11, -111, 104, -11, 9, 44, -29, -55, 42, 57, 84, -108, 48, -26, -8, 2, -21, -86, -53, 48, 37, -92, -97, -116, 27, -50, 2, 58, 99, -85, 102], [-62, -74, -61, -94, -65, -14, 58, -59, 95, -82, -58, -34, 82, -118, 18, 46, -89, 56, 54, -23, -117, -81, 98, -80, 31, -113, 20, -2, -98, 14, 88, 107], [-70, -33, 122, -39, 98, 32, 35, -100, -83, -87, -32, 10, -86, -8, 28, 68, 61, -30, -75, 90, 33, -106, 84, -29, -37, -103, 61, -117, -74, 15, 78, -63], [22, 32, 82, -123, 106, -63, -102, -85, -62, -27, -41, 98, 94, -81, 29, 4, 86, 40, 70, -91, -125, 35, 37, -27, -48, 64, 42, 115, -98, -9, -74, 71], [-76, 3, 17, -102, 22, -51, -113, -122, -60, -40, 105, 112, -31, -50, -112, 18, -11, 22, -8, -119, 59, -119, -68, -117, -72, 80, -27, 94, -106, -117, -20, -83]];for(var i=0;i&lt;motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setByteArray('stage_session',Java.to([-55, 109, -45, 13],'byte[]'));if(i==0){mem.setIntValueOf('experiment_case',13);mem.setIntValueOf('attacker_id',2);mem.setIntValueOf('authorized_work',500);mem.setIntValueOf('attack_start',400);mem.setIntValueOf('attack_stop',700);}else{mem.setIntValueOf('pilot_policy',10);mem.setIntValueOf('pilot_case',0);mem.setIntValueOf('pilot_nodes',10);mem.setIntValueOf('pilot_relay',2);mem.setIntValueOf('pilot_fault',0);mem.setIntValueOf('pilot_start1',400);mem.setIntValueOf('pilot_end1',700);mem.setIntValueOf('pilot_start2',1000);mem.setIntValueOf('pilot_end2',1000);mem.setIntValueOf('pilot_report_period',30);mem.setIntValueOf('pilot_auth',1);mem.setIntValueOf('pilot_freshness',1);mem.setIntValueOf('pilot_monitor',1);mem.setIntValueOf('host_case',0);mem.setIntValueOf('host_work',0);}mem.setByteArray('own_key',Java.to(own[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to([76, 82, -40, 114, -28, 8, -18, 74, -113, -126, 23, 13, 24, -103, 107, -124, -70, 116, -2, -118, -83, -69, -55, -48, -3, 50, 59, -41, -117, -128, -62, 50, -45, -62, -15, -61, -72, -74, 38, -106, -88, -43, 70, -97, -79, -87, 70, -43, -114, 108, -66, 63, -56, -47, 21, 84, 39, -101, 90, -3, 33, -23, -121, 71, -18, -122, 41, 21, -77, 5, 89, 8, 81, -66, 49, -32, -106, 103, 105, 92, 111, 0, 0, 11, -46, -61, -27, 9, 112, -38, 34, 34, -110, -56, 90, -80, 96, 115, -65, 10, -97, 9, 70, -51, 119, 43, -40, 7, 74, 22, -90, 58, 19, -9, 3, -45, 117, -90, 84, -3, 7, 58, -70, -52, -42, -116, 125, 17, -33, -125, 126, -35, 60, -47, 86, -43, 14, -53, 13, 114, 91, -48, -99, 27, -89, 113, -25, 41, 19, -17, 24, -103, 21, -14, -82, 41, -126, 63, -69, -114, 115, 34, 44, -111, 102, -64, -73, -22, 108, -63, 64, -8, 17, -75, -96, 118, 41, -7, 73, 59, -3, 5, 0, 38, 120, -13, 113, 80, -31, 89, 26, 23, -115, -11, -111, 104, -11, 9, 44, -29, -55, 42, 57, 84, -108, 48, -26, -8, 2, -21, -86, -53, 48, 37, -92, -97, -116, 27, -50, 2, 58, 99, -85, 102, -62, -74, -61, -94, -65, -14, 58, -59, 95, -82, -58, -34, 82, -118, 18, 46, -89, 56, 54, -23, -117, -81, 98, -80, 31, -113, 20, -2, -98, 14, 88, 107, -70, -33, 122, -39, 98, 32, 35, -100, -83, -87, -32, 10, -86, -8, 28, 68, 61, -30, -75, 90, 33, -106, 84, -29, -37, -103, 61, -117, -74, 15, 78, -63, 22, 32, 82, -123, 106, -63, -102, -85, -62, -27, -41, 98, 94, -81, 29, 4, 86, 40, 70, -91, -125, 35, 37, -27, -48, 64, 42, 115, -98, -9, -74, 71, -76, 3, 17, -102, 22, -51, -113, -122, -60, -40, 105, 112, -31, -50, -112, 18, -11, 22, -8, -119, 59, -119, -68, -117, -72, 80, -27, 94, -106, -117, -20, -83],'byte[]'));}}
GENERATE_MSG(5000,'PROVISION');TIMEOUT(900000,log.testOK());
while(true){YIELD();if(msg=='PROVISION'){provision();continue;}var line=time+','+id+','+msg;log.log(line+'\n');if(id==1&amp;&amp;(String(msg).startsWith('TELEMETRY,')||String(msg).startsWith('AUTH_CONTEXT,')||String(msg).startsWith('ROOT_RX,')||String(msg).startsWith('GATEWAY_TICK,'))){out.println(line);var response=inp.readLine();if(response==null)throw 'gateway closed';var answer=JSON.parse(String(response));if(answer.commands&amp;&amp;answer.commands.length){var rm=new VM(sim.getMotes()[0].getMemory());var payload=[];var ns=[],ps=[],ls=[];for(var j=0;j&lt;4;j++){var command=answer.commands[j];ns.push(command?command.node:0);ps.push(command?command.port:0);ls.push(command?command.hex.length/2:0);for(var k=0;k&lt;60;k++){var b=command&amp;&amp;k&lt;command.hex.length/2?parseInt(command.hex.substr(2*k,2),16):0;payload.push(b&lt;128?b:b-256);}}rm.setByteArray('gateway_payload',Java.to(payload,'byte[]'));for(var j=0;j&lt;4;j++){rm.setIntValueOf('gateway_node',ns[0]);break;}var bytes=function(a){var b=[];for(var k=0;k&lt;a.length;k++){b.push(a[k]&amp;255);b.push((a[k]&gt;&gt;8)&amp;255);}return Java.to(b.map(function(x){return x&lt;128?x:x-256;}),'byte[]');};rm.setByteArray('gateway_node',bytes(ns));rm.setByteArray('gateway_port',bytes(ps));rm.setByteArray('gateway_len',bytes(ls));rm.setIntValueOf('gateway_count',answer.commands.length);}}}</script>
      <active>true</active>
    </plugin_config>
  </plugin>
</simconf>