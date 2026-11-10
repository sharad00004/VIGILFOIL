<?xml version='1.0' encoding='utf-8'?>
<simconf version="2022112801">
  <simulation>
    <title>source-v5-s1112</title>
    <randomseed>1112</randomseed>
    <motedelay_us>1000000</motedelay_us>
    <radiomedium>org.contikios.cooja.radiomediums.UDGM<transmitting_range>30</transmitting_range>
      <interference_range>45</interference_range>
      <success_ratio_tx>1</success_ratio_tx>
      <success_ratio_rx>1</success_ratio_rx>
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
      <script>var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var sock=new java.net.Socket('127.0.0.1',56019);var out=new java.io.PrintWriter(sock.getOutputStream(),true);var inp=new java.io.BufferedReader(new java.io.InputStreamReader(sock.getInputStream()));function provision(){var motes=sim.getMotes();var own=[[-33, -66, -25, 121, 62, -24, -5, -79, 93, -4, -68, -47, 22, 37, 46, -39, 78, 73, 87, -89, -88, -118, 79, 97, 0, 102, 102, -126, 1, 30, 56, -99], [-26, -117, -6, -92, -83, 80, 16, 34, -93, -112, 52, 85, -124, -9, -93, -70, 1, -98, -36, 4, -96, -68, 32, 114, -53, 66, 58, 12, 69, 69, 34, -82], [22, 73, 59, 116, 59, -25, 21, 77, 26, 46, -18, -73, 58, 17, 23, 11, -66, 14, 46, 127, 74, -4, 79, 4, 54, -6, 14, 63, -101, -22, 22, 98], [19, 89, -48, 82, -96, 126, 93, 19, 67, 74, 11, 45, 116, 84, -105, -77, 106, 8, -49, -35, 96, -17, -5, 55, 10, 68, 117, -4, 42, -113, 22, -64], [-85, 63, 47, -83, -17, -55, 90, -59, 108, -21, 72, 104, 103, 72, 50, 83, -104, -12, -102, 17, -15, -6, -53, -107, 11, -65, 10, -94, -17, 85, -99, 79], [-40, -33, 35, -34, -19, 50, -117, -111, 11, 1, -78, -97, -60, -26, -87, -36, -24, -73, 13, -106, 126, 1, 46, 46, 6, 107, 24, 114, 109, 81, 111, 49], [39, -91, 31, 56, -59, -27, 117, 59, 106, -35, 73, -81, -58, 49, -10, -92, 90, 36, -105, -65, 25, 34, -117, 125, 47, -20, 48, 16, -79, 104, 121, -87], [-22, -9, 74, -2, 72, -93, -52, -54, -27, 28, -50, 110, 71, 118, -2, 60, 9, 77, 57, -3, 44, -60, -90, -64, -123, -72, 39, 123, 70, -8, 108, -104], [28, -110, -51, 23, 91, -46, -107, -123, -54, 76, -28, 70, 93, -116, 55, 3, -65, 68, 98, 50, -18, -80, -85, 109, -29, 42, 18, -77, 114, -69, 60, -91], [124, 90, -127, 19, -64, -60, 91, 122, -28, -95, 31, 113, -29, -26, 71, -37, 116, -114, -89, 118, 22, -47, -69, -65, -17, 27, -22, -87, -2, -76, -64, -95], [116, -96, -3, -123, -61, 114, 73, -63, 86, 50, -64, -93, 96, 118, -89, 47, -50, 17, -57, -85, -14, -65, -30, -54, -114, 97, -1, 99, -119, 114, 119, -25]];for(var i=0;i&lt;motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setByteArray('stage_session',Java.to([-118, -57, -44, 48],'byte[]'));if(i==0){mem.setIntValueOf('experiment_case',13);mem.setIntValueOf('attacker_id',2);mem.setIntValueOf('authorized_work',1500);mem.setIntValueOf('attack_start',400);mem.setIntValueOf('attack_stop',700);}else{mem.setIntValueOf('pilot_policy',10);mem.setIntValueOf('pilot_case',1);mem.setIntValueOf('pilot_nodes',10);mem.setIntValueOf('pilot_relay',2);mem.setIntValueOf('pilot_fault',0);mem.setIntValueOf('pilot_start1',400);mem.setIntValueOf('pilot_end1',700);mem.setIntValueOf('pilot_start2',1000);mem.setIntValueOf('pilot_end2',1000);mem.setIntValueOf('pilot_report_period',30);mem.setIntValueOf('pilot_auth',1);mem.setIntValueOf('pilot_freshness',1);mem.setIntValueOf('pilot_monitor',1);mem.setIntValueOf('host_case',0);mem.setIntValueOf('host_work',0);}mem.setByteArray('own_key',Java.to(own[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to([-33, -66, -25, 121, 62, -24, -5, -79, 93, -4, -68, -47, 22, 37, 46, -39, 78, 73, 87, -89, -88, -118, 79, 97, 0, 102, 102, -126, 1, 30, 56, -99, -26, -117, -6, -92, -83, 80, 16, 34, -93, -112, 52, 85, -124, -9, -93, -70, 1, -98, -36, 4, -96, -68, 32, 114, -53, 66, 58, 12, 69, 69, 34, -82, 22, 73, 59, 116, 59, -25, 21, 77, 26, 46, -18, -73, 58, 17, 23, 11, -66, 14, 46, 127, 74, -4, 79, 4, 54, -6, 14, 63, -101, -22, 22, 98, 19, 89, -48, 82, -96, 126, 93, 19, 67, 74, 11, 45, 116, 84, -105, -77, 106, 8, -49, -35, 96, -17, -5, 55, 10, 68, 117, -4, 42, -113, 22, -64, -85, 63, 47, -83, -17, -55, 90, -59, 108, -21, 72, 104, 103, 72, 50, 83, -104, -12, -102, 17, -15, -6, -53, -107, 11, -65, 10, -94, -17, 85, -99, 79, -40, -33, 35, -34, -19, 50, -117, -111, 11, 1, -78, -97, -60, -26, -87, -36, -24, -73, 13, -106, 126, 1, 46, 46, 6, 107, 24, 114, 109, 81, 111, 49, 39, -91, 31, 56, -59, -27, 117, 59, 106, -35, 73, -81, -58, 49, -10, -92, 90, 36, -105, -65, 25, 34, -117, 125, 47, -20, 48, 16, -79, 104, 121, -87, -22, -9, 74, -2, 72, -93, -52, -54, -27, 28, -50, 110, 71, 118, -2, 60, 9, 77, 57, -3, 44, -60, -90, -64, -123, -72, 39, 123, 70, -8, 108, -104, 28, -110, -51, 23, 91, -46, -107, -123, -54, 76, -28, 70, 93, -116, 55, 3, -65, 68, 98, 50, -18, -80, -85, 109, -29, 42, 18, -77, 114, -69, 60, -91, 124, 90, -127, 19, -64, -60, 91, 122, -28, -95, 31, 113, -29, -26, 71, -37, 116, -114, -89, 118, 22, -47, -69, -65, -17, 27, -22, -87, -2, -76, -64, -95, 116, -96, -3, -123, -61, 114, 73, -63, 86, 50, -64, -93, 96, 118, -89, 47, -50, 17, -57, -85, -14, -65, -30, -54, -114, 97, -1, 99, -119, 114, 119, -25],'byte[]'));}}
GENERATE_MSG(5000,'PROVISION');TIMEOUT(900000,log.testOK());
while(true){YIELD();if(msg=='PROVISION'){provision();continue;}var line=time+','+id+','+msg;log.log(line+'\n');if(id==1&amp;&amp;(String(msg).startsWith('TELEMETRY,')||String(msg).startsWith('AUTH_CONTEXT,')||String(msg).startsWith('ROOT_RX,')||String(msg).startsWith('GATEWAY_TICK,'))){out.println(line);var response=inp.readLine();if(response==null)throw 'gateway closed';var answer=JSON.parse(String(response));if(answer.commands&amp;&amp;answer.commands.length){var rm=new VM(sim.getMotes()[0].getMemory());var payload=[];var ns=[],ps=[],ls=[];for(var j=0;j&lt;4;j++){var command=answer.commands[j];ns.push(command?command.node:0);ps.push(command?command.port:0);ls.push(command?command.hex.length/2:0);for(var k=0;k&lt;60;k++){var b=command&amp;&amp;k&lt;command.hex.length/2?parseInt(command.hex.substr(2*k,2),16):0;payload.push(b&lt;128?b:b-256);}}rm.setByteArray('gateway_payload',Java.to(payload,'byte[]'));for(var j=0;j&lt;4;j++){rm.setIntValueOf('gateway_node',ns[0]);break;}var bytes=function(a){var b=[];for(var k=0;k&lt;a.length;k++){b.push(a[k]&amp;255);b.push((a[k]&gt;&gt;8)&amp;255);}return Java.to(b.map(function(x){return x&lt;128?x:x-256;}),'byte[]');};rm.setByteArray('gateway_node',bytes(ns));rm.setByteArray('gateway_port',bytes(ps));rm.setByteArray('gateway_len',bytes(ls));rm.setIntValueOf('gateway_count',answer.commands.length);}}}</script>
      <active>true</active>
    </plugin_config>
  </plugin>
</simconf>