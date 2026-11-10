<?xml version='1.0' encoding='utf-8'?>
<simconf version="2022112801">
  <simulation>
    <title>source-v5-s1114</title>
    <randomseed>1114</randomseed>
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
      <script>var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var sock=new java.net.Socket('127.0.0.1',42579);var out=new java.io.PrintWriter(sock.getOutputStream(),true);var inp=new java.io.BufferedReader(new java.io.InputStreamReader(sock.getInputStream()));function provision(){var motes=sim.getMotes();var own=[[51, 61, -12, 95, -78, 112, 61, 82, -99, -8, -62, 15, -40, -67, 42, 21, -66, 0, 20, -32, 95, -57, 56, -46, -54, 82, -106, 17, -58, -60, 60, -64], [56, 91, -115, 53, 97, 114, -87, 88, 117, -14, 89, -112, 16, -123, 79, -113, -20, -56, 73, -90, 18, -77, -83, -108, 34, -119, 116, 4, 97, -71, -6, 26], [69, -57, 60, -62, 84, 103, 110, 28, -54, -116, -104, -63, -29, -105, 85, 19, 126, -26, -36, -23, -63, 38, -11, 55, 77, 1, -22, -128, -67, -11, -116, 14], [38, 101, -74, 75, 35, -47, -108, 17, -55, -113, 111, 102, -23, 97, 117, -28, 103, 23, 111, 123, 17, 43, 78, -51, 63, 37, 70, -89, -127, -47, -108, -49], [10, 119, 4, 15, -61, -4, 93, -8, 86, 51, -127, 73, -77, -24, 100, 104, -57, 15, -106, 44, -90, -109, -68, -120, 112, -11, -65, -25, 32, 88, -29, 77], [82, 94, -2, -88, -96, 19, -14, 115, -80, 49, 123, 89, 39, -29, 40, -61, -56, -64, -69, 14, 17, 123, 118, 25, 97, -107, 81, -112, -98, 93, 41, -112], [-53, 112, -87, -10, -28, -11, 87, -82, -94, -75, 20, -37, 92, -19, 115, -16, 87, -106, -42, -15, -12, -99, -99, 15, 0, 42, -13, -43, 4, 118, -92, 19], [-19, -128, 12, 122, 87, 93, 33, -54, 20, 2, 88, 10, -117, -68, 41, -28, 79, -71, 31, -90, -107, 29, -30, -22, 60, 82, -35, -91, 81, -38, 91, -66], [-116, -105, -31, 13, 66, -38, -75, -57, 126, -112, -82, 79, -45, -90, -96, -102, -1, -81, 101, 99, 114, -60, -26, -12, -50, 73, -87, 82, 66, -77, 70, -56], [-97, -28, 92, -35, 48, -72, 69, -101, -105, 86, -117, 85, 118, -40, 75, -59, -37, 25, -128, -33, 3, -45, 17, 75, 56, 14, -55, -128, -1, -68, -3, 121], [107, 44, 40, 116, 106, -90, -34, 120, 18, -57, 9, -42, -52, 96, -74, -43, -127, 53, 104, 47, -60, -23, 22, 102, 44, -57, -51, 102, 93, -48, 126, -66]];for(var i=0;i&lt;motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setByteArray('stage_session',Java.to([88, -33, -86, 55],'byte[]'));if(i==0){mem.setIntValueOf('experiment_case',13);mem.setIntValueOf('attacker_id',2);mem.setIntValueOf('authorized_work',1000);mem.setIntValueOf('attack_start',400);mem.setIntValueOf('attack_stop',700);}else{mem.setIntValueOf('pilot_policy',10);mem.setIntValueOf('pilot_case',1);mem.setIntValueOf('pilot_nodes',10);mem.setIntValueOf('pilot_relay',2);mem.setIntValueOf('pilot_fault',0);mem.setIntValueOf('pilot_start1',400);mem.setIntValueOf('pilot_end1',700);mem.setIntValueOf('pilot_start2',1000);mem.setIntValueOf('pilot_end2',1000);mem.setIntValueOf('pilot_report_period',30);mem.setIntValueOf('pilot_auth',1);mem.setIntValueOf('pilot_freshness',1);mem.setIntValueOf('pilot_monitor',1);mem.setIntValueOf('host_case',0);mem.setIntValueOf('host_work',0);}mem.setByteArray('own_key',Java.to(own[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to([51, 61, -12, 95, -78, 112, 61, 82, -99, -8, -62, 15, -40, -67, 42, 21, -66, 0, 20, -32, 95, -57, 56, -46, -54, 82, -106, 17, -58, -60, 60, -64, 56, 91, -115, 53, 97, 114, -87, 88, 117, -14, 89, -112, 16, -123, 79, -113, -20, -56, 73, -90, 18, -77, -83, -108, 34, -119, 116, 4, 97, -71, -6, 26, 69, -57, 60, -62, 84, 103, 110, 28, -54, -116, -104, -63, -29, -105, 85, 19, 126, -26, -36, -23, -63, 38, -11, 55, 77, 1, -22, -128, -67, -11, -116, 14, 38, 101, -74, 75, 35, -47, -108, 17, -55, -113, 111, 102, -23, 97, 117, -28, 103, 23, 111, 123, 17, 43, 78, -51, 63, 37, 70, -89, -127, -47, -108, -49, 10, 119, 4, 15, -61, -4, 93, -8, 86, 51, -127, 73, -77, -24, 100, 104, -57, 15, -106, 44, -90, -109, -68, -120, 112, -11, -65, -25, 32, 88, -29, 77, 82, 94, -2, -88, -96, 19, -14, 115, -80, 49, 123, 89, 39, -29, 40, -61, -56, -64, -69, 14, 17, 123, 118, 25, 97, -107, 81, -112, -98, 93, 41, -112, -53, 112, -87, -10, -28, -11, 87, -82, -94, -75, 20, -37, 92, -19, 115, -16, 87, -106, -42, -15, -12, -99, -99, 15, 0, 42, -13, -43, 4, 118, -92, 19, -19, -128, 12, 122, 87, 93, 33, -54, 20, 2, 88, 10, -117, -68, 41, -28, 79, -71, 31, -90, -107, 29, -30, -22, 60, 82, -35, -91, 81, -38, 91, -66, -116, -105, -31, 13, 66, -38, -75, -57, 126, -112, -82, 79, -45, -90, -96, -102, -1, -81, 101, 99, 114, -60, -26, -12, -50, 73, -87, 82, 66, -77, 70, -56, -97, -28, 92, -35, 48, -72, 69, -101, -105, 86, -117, 85, 118, -40, 75, -59, -37, 25, -128, -33, 3, -45, 17, 75, 56, 14, -55, -128, -1, -68, -3, 121, 107, 44, 40, 116, 106, -90, -34, 120, 18, -57, 9, -42, -52, 96, -74, -43, -127, 53, 104, 47, -60, -23, 22, 102, 44, -57, -51, 102, 93, -48, 126, -66],'byte[]'));}}
GENERATE_MSG(5000,'PROVISION');TIMEOUT(900000,log.testOK());
while(true){YIELD();if(msg=='PROVISION'){provision();continue;}var line=time+','+id+','+msg;log.log(line+'\n');if(id==1&amp;&amp;(String(msg).startsWith('TELEMETRY,')||String(msg).startsWith('AUTH_CONTEXT,')||String(msg).startsWith('ROOT_RX,')||String(msg).startsWith('GATEWAY_TICK,'))){out.println(line);var response=inp.readLine();if(response==null)throw 'gateway closed';var answer=JSON.parse(String(response));if(answer.commands&amp;&amp;answer.commands.length){var rm=new VM(sim.getMotes()[0].getMemory());var payload=[];var ns=[],ps=[],ls=[];for(var j=0;j&lt;4;j++){var command=answer.commands[j];ns.push(command?command.node:0);ps.push(command?command.port:0);ls.push(command?command.hex.length/2:0);for(var k=0;k&lt;60;k++){var b=command&amp;&amp;k&lt;command.hex.length/2?parseInt(command.hex.substr(2*k,2),16):0;payload.push(b&lt;128?b:b-256);}}rm.setByteArray('gateway_payload',Java.to(payload,'byte[]'));for(var j=0;j&lt;4;j++){rm.setIntValueOf('gateway_node',ns[0]);break;}var bytes=function(a){var b=[];for(var k=0;k&lt;a.length;k++){b.push(a[k]&amp;255);b.push((a[k]&gt;&gt;8)&amp;255);}return Java.to(b.map(function(x){return x&lt;128?x:x-256;}),'byte[]');};rm.setByteArray('gateway_node',bytes(ns));rm.setByteArray('gateway_port',bytes(ps));rm.setByteArray('gateway_len',bytes(ls));rm.setIntValueOf('gateway_count',answer.commands.length);}}}</script>
      <active>true</active>
    </plugin_config>
  </plugin>
</simconf>