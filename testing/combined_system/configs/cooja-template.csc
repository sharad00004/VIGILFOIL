<?xml version='1.0' encoding='utf-8'?>
<simconf version="2022112801">
  <simulation>
    <title>host3-c0-w1000-s1017</title>
    <randomseed>1017</randomseed>
    <motedelay_us>1000000</motedelay_us>
    <radiomedium>org.contikios.cooja.radiomediums.UDGM<transmitting_range>50</transmitting_range>
      <interference_range>70</interference_range>
      <success_ratio_tx>1</success_ratio_tx>
      <success_ratio_rx>1</success_ratio_rx>
    </radiomedium>
    <motetype>org.contikios.cooja.mspmote.Z1MoteType<identifier>z1obs</identifier>
      <description>Trusted monitor, application selective forwarding</description>
      <source>[CONFIG_DIR]/../firmware/host-monitor-v3/observe.c</source>
      <commands />
      <firmware>[CONFIG_DIR]/../firmware/host-monitor-v3/build/z1/observe.z1</firmware><moteinterface>org.contikios.cooja.interfaces.Position</moteinterface><moteinterface>org.contikios.cooja.interfaces.IPAddress</moteinterface><moteinterface>org.contikios.cooja.interfaces.Mote2MoteRelations</moteinterface><moteinterface>org.contikios.cooja.interfaces.MoteAttributes</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspClock</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspMoteID</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.Msp802154Radio</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspDefaultSerial</moteinterface><moteinterface>org.contikios.cooja.mspmote.interfaces.MspLED</moteinterface><mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="0" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>1</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="0" y="28" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>2</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="35" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>3</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="35" y="28" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>4</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="70" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>5</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="70" y="28" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>6</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="105" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>7</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="105" y="28" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>8</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="140" y="0" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>9</id>
        </interface_config>
      </mote>
      <mote>
        <interface_config>org.contikios.cooja.interfaces.Position<pos x="140" y="28" />
        </interface_config>
        <interface_config>org.contikios.cooja.mspmote.interfaces.MspMoteID<id>10</id>
        </interface_config>
      </mote>
      </motetype>
  </simulation>
  <plugin>org.contikios.cooja.plugins.ScriptRunner<plugin_config>
      <script>var VM=Java.type('org.contikios.cooja.mote.memory.VarMemory');var keys=[[-6, -41, 93, 21, -10, 88, -66, 53, -55, 44, 77, 90, 4, -18, -71, 55, -83, 96, 26, -82, 79, -106, 7, 75, 27, 10, 25, -122, -78, -119, 105, 45], [30, -28, -110, 101, -39, -58, -42, 55, -62, -99, 44, -19, 111, -91, 14, 33, -59, -71, 43, -16, 27, 124, -15, 13, 78, 59, 31, -39, 120, 42, 119, 4], [40, 53, -88, -124, -27, 110, 96, -103, 17, 117, -101, 28, 18, 110, -6, 91, 95, 124, -7, -53, -20, 82, 30, 1, 39, 65, -81, 105, -43, 112, -54, 11], [25, -117, -47, -127, 113, 90, 51, 99, -55, 10, 13, -104, -47, 64, -22, -105, -100, 97, -90, -64, 1, 48, -119, 109, -112, -107, 28, 27, 30, -1, 108, -77], [115, -114, -73, -71, 61, 11, -20, -100, 87, -65, 98, -93, -33, 6, -52, -67, -67, 48, 0, 95, -76, -28, -72, 24, 115, 105, -124, 36, 106, -70, -108, -112], [16, 34, -45, 54, 111, -26, -113, 101, -114, -30, -27, -4, 26, -115, -3, -107, -38, -8, -40, 39, 76, -88, 58, -107, -109, 63, 68, -23, -36, 119, -110, -26], [-24, 66, -48, 94, -23, 84, 115, -25, 80, -73, 37, 109, -1, -50, -84, 77, 91, 88, 102, 70, -76, 69, 6, 43, 78, -75, 57, -123, 110, -64, 122, 38], [-38, 46, -29, -113, 4, 88, 55, 101, 11, -117, -65, 101, 24, -70, 41, 66, 49, 50, 79, 37, -106, -8, -4, -125, 45, 39, -75, 76, 11, -94, -78, -116], [-35, 118, -113, 15, 91, -89, 45, 126, -59, -78, 11, -93, 17, 25, -127, 33, -124, -104, -45, -49, 39, 124, -92, 60, -1, 0, 24, 17, 117, -77, -16, 68], [-110, 109, 112, 107, -19, 50, 107, 60, 28, 12, 98, -76, -26, 121, 79, -34, 18, -79, 57, 12, 52, 71, -83, -88, -24, -73, 121, -128, 44, -59, -23, -112], [98, -66, -84, -117, 118, -106, 47, -121, 102, -11, -128, -16, -56, 36, 58, 103, 71, 88, 31, 108, 103, -68, -52, 37, 39, -34, -77, -6, -73, -44, 94, -25]];GENERATE_MSG(5000,'CONFIG');
TIMEOUT(1200000,log.testOK());
while(true){YIELD();if(msg=='CONFIG'){var motes=sim.getMotes();for(var i=0;i&lt;motes.length;i++){var mem=new VM(motes[i].getMemory());mem.setInt32ValueOf('stage_session',2036276120);mem.setByteArray('own_key',Java.to(keys[i+1],'byte[]'));if(i==0)mem.setByteArray('peer_keys',Java.to([-6, -41, 93, 21, -10, 88, -66, 53, -55, 44, 77, 90, 4, -18, -71, 55, -83, 96, 26, -82, 79, -106, 7, 75, 27, 10, 25, -122, -78, -119, 105, 45, 30, -28, -110, 101, -39, -58, -42, 55, -62, -99, 44, -19, 111, -91, 14, 33, -59, -71, 43, -16, 27, 124, -15, 13, 78, 59, 31, -39, 120, 42, 119, 4, 40, 53, -88, -124, -27, 110, 96, -103, 17, 117, -101, 28, 18, 110, -6, 91, 95, 124, -7, -53, -20, 82, 30, 1, 39, 65, -81, 105, -43, 112, -54, 11, 25, -117, -47, -127, 113, 90, 51, 99, -55, 10, 13, -104, -47, 64, -22, -105, -100, 97, -90, -64, 1, 48, -119, 109, -112, -107, 28, 27, 30, -1, 108, -77, 115, -114, -73, -71, 61, 11, -20, -100, 87, -65, 98, -93, -33, 6, -52, -67, -67, 48, 0, 95, -76, -28, -72, 24, 115, 105, -124, 36, 106, -70, -108, -112, 16, 34, -45, 54, 111, -26, -113, 101, -114, -30, -27, -4, 26, -115, -3, -107, -38, -8, -40, 39, 76, -88, 58, -107, -109, 63, 68, -23, -36, 119, -110, -26, -24, 66, -48, 94, -23, 84, 115, -25, 80, -73, 37, 109, -1, -50, -84, 77, 91, 88, 102, 70, -76, 69, 6, 43, 78, -75, 57, -123, 110, -64, 122, 38, -38, 46, -29, -113, 4, 88, 55, 101, 11, -117, -65, 101, 24, -70, 41, 66, 49, 50, 79, 37, -106, -8, -4, -125, 45, 39, -75, 76, 11, -94, -78, -116, -35, 118, -113, 15, 91, -89, 45, 126, -59, -78, 11, -93, 17, 25, -127, 33, -124, -104, -45, -49, 39, 124, -92, 60, -1, 0, 24, 17, 117, -77, -16, 68, -110, 109, 112, 107, -19, 50, 107, 60, 28, 12, 98, -76, -26, 121, 79, -34, 18, -79, 57, 12, 52, 71, -83, -88, -24, -73, 121, -128, 44, -59, -23, -112, 98, -66, -84, -117, 118, -106, 47, -121, 102, -11, -128, -16, -56, 36, 58, 103, 71, 88, 31, 108, 103, -68, -52, 37, 39, -34, -77, -6, -73, -44, 94, -25],'byte[]'));mem.setIntValueOf('experiment_case',0);mem.setIntValueOf('attack_start',400);mem.setIntValueOf('attack_stop',1000);mem.setIntValueOf('authorized_work',1000);mem.setIntValueOf('extra_work',1000);mem.setIntValueOf('attacker_id',7);}}else log.log(time+','+id+','+msg+'\n');}</script>
      <active>true</active>
    </plugin_config>
  </plugin>
</simconf>