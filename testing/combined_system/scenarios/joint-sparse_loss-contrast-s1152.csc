<?xml version='1.0' encoding='utf-8'?>
<simconf version="2022112801">
  <simulation>
    <title>joint-sparse_loss-contrast-s1152</title>
    <randomseed>1152</randomseed>
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
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="0" y="22" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>2</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="0" y="44" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>3</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="22" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>4</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="22" y="22" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>5</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="22" y="44" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>6</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="44" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>7</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="44" y="22" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>8</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="44" y="44" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>9</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="66" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>10</id>
        </interface_config>
      </mote>
      </motetype>
  </simulation>
  <plugin>org.contikios.cooja.plugins.ScriptRunner<plugin_config>
      <script>var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var sock=new java.net.Socket('127.0.0.1',45957);var out=new java.io.PrintWriter(sock.getOutputStream(),true);var inp=new java.io.BufferedReader(new java.io.InputStreamReader(sock.getInputStream()));function provision(){var motes=sim.getMotes();var own=[[-55, -127, 102, 19, 8, -47, 70, 90, -59, 87, -125, -36, 114, 83, -37, -115, 63, 66, 25, 31, 101, -62, 4, 102, -95, -105, -27, 125, 115, 12, 36, -81], [-45, 30, 95, -38, 11, 42, -123, 16, -66, 75, 9, 29, -89, -11, 117, 27, -1, -56, 90, -111, 29, -52, 21, 102, 50, -4, -3, -4, 21, -55, -67, 41], [-63, -104, 75, 86, -75, -8, -123, -39, 49, -56, 124, 96, -16, 34, 95, 43, -94, -75, -83, 52, 41, -62, 20, -13, -109, -52, 0, 27, -108, -121, 27, 49], [-48, 27, 62, -47, -125, 88, -116, 89, -43, -12, -8, 105, 43, 74, 52, 53, -79, 0, 56, -51, -45, -19, 65, -104, 78, 13, -102, -5, 50, 92, -38, 96], [105, -63, 119, -16, 60, 112, -98, -62, 66, 18, 118, -123, -24, 40, 111, -69, 24, -47, 75, 0, -103, 32, 82, 38, -104, 80, -4, -72, 62, -18, 31, -122], [-107, -72, 112, 46, 69, -108, 114, 127, 40, -51, 47, -74, -128, 122, 97, 90, -82, -98, -39, 61, 82, 49, -39, 33, -47, -82, -47, -67, -112, -100, 9, 59], [0, 19, -10, -88, -99, 93, -58, -99, 98, -83, 67, 74, -58, 10, -103, 20, -13, -75, 54, -16, 22, 75, -90, 51, -39, 109, 102, 103, 100, -5, 125, 103], [105, -60, -114, -46, 83, -70, 84, 23, 41, -57, 27, 82, -42, 113, -51, -10, 127, 59, -12, -71, -10, -62, -10, -63, -109, 75, -102, 94, 112, -51, -38, -49], [15, -57, 21, 121, -25, -122, 109, -22, -5, -108, -82, -28, -127, 79, 55, -117, -90, -70, 55, 84, -68, 105, 6, -27, -117, -25, -82, -114, 72, -105, 107, -11], [22, -15, -36, -90, -27, 23, 44, -64, 58, 39, 25, 58, -6, -30, 104, 27, -44, -64, -17, -80, -101, -56, -59, 14, 1, -63, -16, -74, 33, 27, -47, 117], [-18, -9, 13, 100, -31, 116, -121, -71, -126, -123, 79, -73, -1, 33, 10, -62, 23, -72, 70, -3, -77, -43, 11, 17, -32, 2, 108, -85, 79, -126, -91, -51]];for(var i=0;i&lt;motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setByteArray('stage_session',Java.to([-112, -18, -77, 19],'byte[]'));if(i==0){mem.setIntValueOf('experiment_case',13);mem.setIntValueOf('attacker_id',3);mem.setIntValueOf('authorized_work',1000);mem.setIntValueOf('attack_start',400);mem.setIntValueOf('attack_stop',700);}else{mem.setIntValueOf('pilot_policy',10);mem.setIntValueOf('pilot_case',4);mem.setIntValueOf('pilot_nodes',10);mem.setIntValueOf('pilot_relay',3);mem.setIntValueOf('pilot_fault',0);mem.setIntValueOf('pilot_start1',400);mem.setIntValueOf('pilot_end1',700);mem.setIntValueOf('pilot_start2',1000);mem.setIntValueOf('pilot_end2',1000);mem.setIntValueOf('pilot_report_period',30);mem.setIntValueOf('pilot_auth',1);mem.setIntValueOf('pilot_freshness',1);mem.setIntValueOf('pilot_monitor',1);mem.setIntValueOf('host_case',3);mem.setIntValueOf('host_work',1000);}mem.setByteArray('own_key',Java.to(own[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to([-55, -127, 102, 19, 8, -47, 70, 90, -59, 87, -125, -36, 114, 83, -37, -115, 63, 66, 25, 31, 101, -62, 4, 102, -95, -105, -27, 125, 115, 12, 36, -81, -45, 30, 95, -38, 11, 42, -123, 16, -66, 75, 9, 29, -89, -11, 117, 27, -1, -56, 90, -111, 29, -52, 21, 102, 50, -4, -3, -4, 21, -55, -67, 41, -63, -104, 75, 86, -75, -8, -123, -39, 49, -56, 124, 96, -16, 34, 95, 43, -94, -75, -83, 52, 41, -62, 20, -13, -109, -52, 0, 27, -108, -121, 27, 49, -48, 27, 62, -47, -125, 88, -116, 89, -43, -12, -8, 105, 43, 74, 52, 53, -79, 0, 56, -51, -45, -19, 65, -104, 78, 13, -102, -5, 50, 92, -38, 96, 105, -63, 119, -16, 60, 112, -98, -62, 66, 18, 118, -123, -24, 40, 111, -69, 24, -47, 75, 0, -103, 32, 82, 38, -104, 80, -4, -72, 62, -18, 31, -122, -107, -72, 112, 46, 69, -108, 114, 127, 40, -51, 47, -74, -128, 122, 97, 90, -82, -98, -39, 61, 82, 49, -39, 33, -47, -82, -47, -67, -112, -100, 9, 59, 0, 19, -10, -88, -99, 93, -58, -99, 98, -83, 67, 74, -58, 10, -103, 20, -13, -75, 54, -16, 22, 75, -90, 51, -39, 109, 102, 103, 100, -5, 125, 103, 105, -60, -114, -46, 83, -70, 84, 23, 41, -57, 27, 82, -42, 113, -51, -10, 127, 59, -12, -71, -10, -62, -10, -63, -109, 75, -102, 94, 112, -51, -38, -49, 15, -57, 21, 121, -25, -122, 109, -22, -5, -108, -82, -28, -127, 79, 55, -117, -90, -70, 55, 84, -68, 105, 6, -27, -117, -25, -82, -114, 72, -105, 107, -11, 22, -15, -36, -90, -27, 23, 44, -64, 58, 39, 25, 58, -6, -30, 104, 27, -44, -64, -17, -80, -101, -56, -59, 14, 1, -63, -16, -74, 33, 27, -47, 117, -18, -9, 13, 100, -31, 116, -121, -71, -126, -123, 79, -73, -1, 33, 10, -62, 23, -72, 70, -3, -77, -43, 11, 17, -32, 2, 108, -85, 79, -126, -91, -51],'byte[]'));}}
GENERATE_MSG(5000,'PROVISION');TIMEOUT(900000,log.testOK());
while(true){YIELD();if(msg=='PROVISION'){provision();continue;}var line=time+','+id+','+msg;log.log(line+'\n');if(id==1&amp;&amp;(String(msg).startsWith('TELEMETRY,')||String(msg).startsWith('AUTH_CONTEXT,')||String(msg).startsWith('ROOT_RX,')||String(msg).startsWith('GATEWAY_TICK,'))){out.println(line);var response=inp.readLine();if(response==null)throw 'gateway closed';var answer=JSON.parse(String(response));if(answer.commands&amp;&amp;answer.commands.length){var rm=new VM(sim.getMotes()[0].getMemory());var payload=[];var ns=[],ps=[],ls=[];for(var j=0;j&lt;4;j++){var command=answer.commands[j];ns.push(command?command.node:0);ps.push(command?command.port:0);ls.push(command?command.hex.length/2:0);for(var k=0;k&lt;60;k++){var b=command&amp;&amp;k&lt;command.hex.length/2?parseInt(command.hex.substr(2*k,2),16):0;payload.push(b&lt;128?b:b-256);}}rm.setByteArray('gateway_payload',Java.to(payload,'byte[]'));for(var j=0;j&lt;4;j++){rm.setIntValueOf('gateway_node',ns[0]);break;}var bytes=function(a){var b=[];for(var k=0;k&lt;a.length;k++){b.push(a[k]&amp;255);b.push((a[k]&gt;&gt;8)&amp;255);}return Java.to(b.map(function(x){return x&lt;128?x:x-256;}),'byte[]');};rm.setByteArray('gateway_node',bytes(ns));rm.setByteArray('gateway_port',bytes(ps));rm.setByteArray('gateway_len',bytes(ls));rm.setIntValueOf('gateway_count',answer.commands.length);}}}</script>
      <active>true</active>
    </plugin_config>
  </plugin>
</simconf>