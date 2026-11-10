<?xml version='1.0' encoding='utf-8'?>
<simconf version="2022112801">
  <simulation>
    <title>source-v5-s1111</title>
    <randomseed>1111</randomseed>
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
      <script>var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var sock=new java.net.Socket('127.0.0.1',34691);var out=new java.io.PrintWriter(sock.getOutputStream(),true);var inp=new java.io.BufferedReader(new java.io.InputStreamReader(sock.getInputStream()));function provision(){var motes=sim.getMotes();var own=[[4, 64, -102, -33, 72, -72, 38, -18, 104, -49, -10, 14, 36, -108, 70, 63, -16, 57, 123, -103, 87, 30, 124, 78, 86, 118, 94, -38, 51, 77, 94, -99], [-92, 20, 70, 78, -36, -65, -114, 58, -122, -75, 60, 46, -46, -77, -42, 59, 82, 4, 2, 110, -13, 19, -116, -102, -19, -38, 46, -92, -48, -99, 18, -33], [-68, -46, -108, -123, 35, 125, -62, -44, 17, 119, -48, -37, 84, 61, 23, 11, -113, 94, -6, -11, -44, -24, 2, -38, -38, -32, 52, 68, -12, -32, -36, 50], [-122, -101, -103, 27, -122, -85, -19, -29, 125, -47, -5, -50, -15, 108, 3, 62, 69, 33, -28, 94, 46, 33, 87, 9, -110, 79, -125, -14, -89, 38, -68, -78], [-76, 34, 64, -41, -58, 85, -77, 40, -108, 16, -13, -14, -23, -41, -18, -77, 45, 15, -81, -35, 87, -87, -82, -37, 10, -33, 123, -64, -89, 16, -125, -47], [-82, 111, -92, -124, 101, -59, -55, -28, 21, 103, 117, 74, -83, -122, -66, -90, 41, 17, -22, 63, 13, 38, -47, -13, 11, 124, 55, 78, 120, -27, 16, 67], [22, 58, -97, 15, 66, 87, -59, 124, -91, -15, -2, 109, 70, 92, -5, 46, -59, 48, 30, -67, -18, -15, 78, -35, 15, -98, -1, -109, -118, -98, 95, -57], [-92, -55, -59, -81, -52, 97, 94, 116, -91, -4, -125, 71, 42, -83, 83, -69, -12, -93, -128, 0, -75, -69, 23, 89, 4, 1, -99, 38, -78, -63, -50, 85], [-56, 97, -13, 19, 81, -25, -94, 30, -66, -90, -119, 42, 49, -73, -110, -111, -65, 53, 4, 38, 105, 54, 95, -63, -4, 95, -89, 51, -104, -102, 54, -92], [40, 19, 107, 19, 64, 80, 95, -95, 84, 118, -96, -94, -57, -9, -62, 31, -24, -38, -13, 104, -83, 50, 87, -126, 43, 56, -65, -95, 58, 121, -91, 6], [-98, -35, -4, 9, 106, 24, 25, 78, 83, 68, 11, -30, 99, 103, -56, 35, 54, 123, 44, -17, -118, 45, -45, 92, -66, 19, -97, -90, -18, -57, 32, -53]];for(var i=0;i&lt;motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setByteArray('stage_session',Java.to([-67, 25, -7, 31],'byte[]'));if(i==0){mem.setIntValueOf('experiment_case',0);mem.setIntValueOf('attacker_id',2);mem.setIntValueOf('authorized_work',0);mem.setIntValueOf('attack_start',400);mem.setIntValueOf('attack_stop',700);}else{mem.setIntValueOf('pilot_policy',10);mem.setIntValueOf('pilot_case',0);mem.setIntValueOf('pilot_nodes',10);mem.setIntValueOf('pilot_relay',2);mem.setIntValueOf('pilot_fault',0);mem.setIntValueOf('pilot_start1',400);mem.setIntValueOf('pilot_end1',700);mem.setIntValueOf('pilot_start2',1000);mem.setIntValueOf('pilot_end2',1000);mem.setIntValueOf('pilot_report_period',30);mem.setIntValueOf('pilot_auth',1);mem.setIntValueOf('pilot_freshness',1);mem.setIntValueOf('pilot_monitor',1);mem.setIntValueOf('host_case',0);mem.setIntValueOf('host_work',0);}mem.setByteArray('own_key',Java.to(own[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to([4, 64, -102, -33, 72, -72, 38, -18, 104, -49, -10, 14, 36, -108, 70, 63, -16, 57, 123, -103, 87, 30, 124, 78, 86, 118, 94, -38, 51, 77, 94, -99, -92, 20, 70, 78, -36, -65, -114, 58, -122, -75, 60, 46, -46, -77, -42, 59, 82, 4, 2, 110, -13, 19, -116, -102, -19, -38, 46, -92, -48, -99, 18, -33, -68, -46, -108, -123, 35, 125, -62, -44, 17, 119, -48, -37, 84, 61, 23, 11, -113, 94, -6, -11, -44, -24, 2, -38, -38, -32, 52, 68, -12, -32, -36, 50, -122, -101, -103, 27, -122, -85, -19, -29, 125, -47, -5, -50, -15, 108, 3, 62, 69, 33, -28, 94, 46, 33, 87, 9, -110, 79, -125, -14, -89, 38, -68, -78, -76, 34, 64, -41, -58, 85, -77, 40, -108, 16, -13, -14, -23, -41, -18, -77, 45, 15, -81, -35, 87, -87, -82, -37, 10, -33, 123, -64, -89, 16, -125, -47, -82, 111, -92, -124, 101, -59, -55, -28, 21, 103, 117, 74, -83, -122, -66, -90, 41, 17, -22, 63, 13, 38, -47, -13, 11, 124, 55, 78, 120, -27, 16, 67, 22, 58, -97, 15, 66, 87, -59, 124, -91, -15, -2, 109, 70, 92, -5, 46, -59, 48, 30, -67, -18, -15, 78, -35, 15, -98, -1, -109, -118, -98, 95, -57, -92, -55, -59, -81, -52, 97, 94, 116, -91, -4, -125, 71, 42, -83, 83, -69, -12, -93, -128, 0, -75, -69, 23, 89, 4, 1, -99, 38, -78, -63, -50, 85, -56, 97, -13, 19, 81, -25, -94, 30, -66, -90, -119, 42, 49, -73, -110, -111, -65, 53, 4, 38, 105, 54, 95, -63, -4, 95, -89, 51, -104, -102, 54, -92, 40, 19, 107, 19, 64, 80, 95, -95, 84, 118, -96, -94, -57, -9, -62, 31, -24, -38, -13, 104, -83, 50, 87, -126, 43, 56, -65, -95, 58, 121, -91, 6, -98, -35, -4, 9, 106, 24, 25, 78, 83, 68, 11, -30, 99, 103, -56, 35, 54, 123, 44, -17, -118, 45, -45, 92, -66, 19, -97, -90, -18, -57, 32, -53],'byte[]'));}}
GENERATE_MSG(5000,'PROVISION');TIMEOUT(900000,log.testOK());
while(true){YIELD();if(msg=='PROVISION'){provision();continue;}var line=time+','+id+','+msg;log.log(line+'\n');if(id==1&amp;&amp;(String(msg).startsWith('TELEMETRY,')||String(msg).startsWith('AUTH_CONTEXT,')||String(msg).startsWith('ROOT_RX,')||String(msg).startsWith('GATEWAY_TICK,'))){out.println(line);var response=inp.readLine();if(response==null)throw 'gateway closed';var answer=JSON.parse(String(response));if(answer.commands&amp;&amp;answer.commands.length){var rm=new VM(sim.getMotes()[0].getMemory());var payload=[];var ns=[],ps=[],ls=[];for(var j=0;j&lt;4;j++){var command=answer.commands[j];ns.push(command?command.node:0);ps.push(command?command.port:0);ls.push(command?command.hex.length/2:0);for(var k=0;k&lt;60;k++){var b=command&amp;&amp;k&lt;command.hex.length/2?parseInt(command.hex.substr(2*k,2),16):0;payload.push(b&lt;128?b:b-256);}}rm.setByteArray('gateway_payload',Java.to(payload,'byte[]'));for(var j=0;j&lt;4;j++){rm.setIntValueOf('gateway_node',ns[0]);break;}var bytes=function(a){var b=[];for(var k=0;k&lt;a.length;k++){b.push(a[k]&amp;255);b.push((a[k]&gt;&gt;8)&amp;255);}return Java.to(b.map(function(x){return x&lt;128?x:x-256;}),'byte[]');};rm.setByteArray('gateway_node',bytes(ns));rm.setByteArray('gateway_port',bytes(ps));rm.setByteArray('gateway_len',bytes(ls));rm.setIntValueOf('gateway_count',answer.commands.length);}}}</script>
      <active>true</active>
    </plugin_config>
  </plugin>
</simconf>