/* Instruction-level observation rig; attack diagnostics never enter detector features. */
#include "contiki.h"
#include "net/netstack.h"
#include "net/routing/routing.h"
#include "net/routing/rpl-lite/rpl.h"
#include "net/routing/rpl-lite/rpl-icmp6.h"
#include "net/routing/rpl-lite/rpl-neighbor.h"
#include "net/ipv6/simple-udp.h"
#include "net/ipv6/uipbuf.h"
#include "sys/node-id.h"
#include "sys/energest.h"
#include "lib/random.h"
#include "cfs/cfs.h"
#include "lib/sha-256.h"
#include <stdio.h>
#include <stdint.h>
#include <string.h>
int experiment_case=0,attack_start=300,attack_stop=600,attacker_id=2,extra_work=100,authorized_work=1000;
uint8_t own_key[32],peer_keys[11*32];uint32_t stage_session=1;
static struct simple_udp_connection app,control,data_link,report_link;
uint8_t gateway_payload[4*60];unsigned gateway_node[4],gateway_port[4],gateway_len[4],gateway_count;
static unsigned gateway_index;
static uint32_t be32(const uint8_t*p){uint32_t v;memcpy(&v,p,4);return uip_ntohl(v);}
static void gateway_receive(struct simple_udp_connection*c,const uip_ipaddr_t*src,uint16_t sp,const uip_ipaddr_t*dst,uint16_t dp,const uint8_t*p,uint16_t n){
 if(node_id!=1||n<28)return;unsigned who=be32(p+4),kind=be32(p);if(who<2||who>10||be32(p+8)!=stage_session)return;
 unsigned body=n-8;if((kind==1||kind==6)&&n!=28)return;if(kind==3&&n!=108)return;
 uint8_t tag[32],diff=0;sha_256_hmac(peer_keys+32*who,32,p,body,tag);unsigned i;for(i=0;i<8;i++)diff|=tag[i]^p[body+i];if(diff){printf("GATEWAY_REJECT_AUTH\n");return;}
 printf("ROOT_RX,%u",n);for(i=0;i<n;i++)printf("%s%02x",i?"":",",p[i]);printf("\n");
}

static uip_ipaddr_t peers[11];static uint8_t known[11];static uint32_t last_seq[11],control_nonce;
static unsigned permitted_work,permit_until;static uint32_t hidden_cpu_ticks;
static int verify(unsigned who,const uint8_t *p,unsigned n){uint8_t h[32],diff=0;unsigned i;sha_256_hmac(node_id==1?peer_keys+32*who:own_key,32,p,n,h);for(i=0;i<8;i++)diff|=h[i]^p[n+i];return !diff;}
static void sign(unsigned who,uint8_t *p,unsigned n){uint8_t h[32];sha_256_hmac(node_id==1?peer_keys+32*who:own_key,32,p,n,h);memcpy(p+n,h,8);}
static void ctrl_receive(struct simple_udp_connection *c,const uip_ipaddr_t *src,uint16_t sp,const uip_ipaddr_t *dst,uint16_t dp,const uint8_t *p,uint16_t n){
 if(node_id==1||n!=32)return;uint32_t v[6];memcpy(v,p,24);if(v[0]!=node_id||v[1]!=stage_session||!verify(node_id,p,24)||v[2]<=control_nonce||v[3]>4000||v[4]<=clock_seconds()||v[4]>clock_seconds()+605)return;control_nonce=v[2];permitted_work=v[3];permit_until=v[4];printf("PERMIT,%u,%lu,%u,%u\n",node_id,(unsigned long)control_nonce,permitted_work,permit_until);
}

static unsigned long sequence,received,offered,dis_s,dis_r,dio_s,dio_r,dao_s,dao_r,total_s,transit_in,transit_out;
static volatile uint32_t work_sink=17;
static unsigned next_offer;static unsigned poison_dio;static rpl_of_t *original_of;
static uint16_t checksum=0;
static unsigned attack_active(void){return node_id==attacker_id&&clock_seconds()>=(unsigned)attack_start&&clock_seconds()<(unsigned)attack_stop;}
static unsigned id(const uip_ipaddr_t *addr){return addr->u8[15];}
static void workload(unsigned rounds){unsigned i;for(i=0;i<rounds;i++){work_sink=work_sink*1664525UL+1013904223UL;checksum^=work_sink>>16;}}
static enum netstack_ip_action inspect_in(void){
 uint8_t proto=0,*h=uipbuf_get_last_header(uip_buf,uip_len,&proto);
 if(!h)return NETSTACK_IP_PROCESS;
 if(proto==UIP_PROTO_ICMP6&&h+2<=uip_buf+uip_len&&h[0]==155){if(h[1]==0)dis_r++;if(h[1]==1)dio_r++;if(h[1]==2)dao_r++;}
 if(proto==UIP_PROTO_UDP&&h+8<=uip_buf+uip_len){
  printf("PACKET,%u,%u,%u,%u,%u,%u,%lu\n",node_id,id(&UIP_IP_BUF->srcipaddr),id(&UIP_IP_BUF->destipaddr),uip_len,(h[0]<<8)|h[1],(h[2]<<8)|h[3],(unsigned long)clock_time());
  if(!uip_ds6_is_my_addr(&UIP_IP_BUF->destipaddr))transit_in++;
  if(attack_active()&&(experiment_case==3||experiment_case==7)&&!uip_ds6_is_my_addr(&UIP_IP_BUF->destipaddr)&&random_rand()%100<50){printf("ORACLE_DROP,%u,%u,%lu\n",node_id,id(&UIP_IP_BUF->srcipaddr),(unsigned long)clock_seconds());return NETSTACK_IP_DROP;}
 }
 return NETSTACK_IP_PROCESS;
}
static enum netstack_ip_action inspect_out(const linkaddr_t *dest){
 uint8_t proto=0,*h=uipbuf_get_last_header(uip_buf,uip_len,&proto);total_s++;
 if(h&&proto==UIP_PROTO_UDP&&!uip_ds6_is_my_addr(&UIP_IP_BUF->srcipaddr))transit_out++;
 if(h&&poison_dio&&proto==UIP_PROTO_ICMP6&&h+8<=uip_buf+uip_len&&h[0]==155&&h[1]==1){struct uip_icmp_hdr *hdr=(struct uip_icmp_hdr *)h;h[6]=255;h[7]=255;hdr->icmpchksum=0;hdr->icmpchksum=~uip_icmp6chksum();}
 if(h&&proto==UIP_PROTO_ICMP6&&h+2<=uip_buf+uip_len&&h[0]==155){if(h[1]==0)dis_s++;if(h[1]==1)dio_s++;if(h[1]==2)dao_s++;}
 return NETSTACK_IP_PROCESS;
}
static struct netstack_ip_packet_processor processor={NULL,inspect_in,inspect_out};
static void receive(struct simple_udp_connection *c,const uip_ipaddr_t *src,uint16_t sp,const uip_ipaddr_t *dest,uint16_t dp,const uint8_t *p,uint16_t n){
 if(node_id==1&&n==84){uint32_t words[19];unsigned i;memcpy(words,p,76);unsigned who=words[0];if(who<2||who>10||words[18]!=stage_session||!verify(who,p,76)){printf("MONITOR_REJECT_AUTH\n");return;}if(words[1]<=last_seq[who]){printf("MONITOR_REJECT_REPLAY\n");return;}last_seq[who]=words[1];peers[who]=*src;known[who]=1;received++;printf("TELEMETRY");for(i=0;i<18;i++)printf(",%lu",(unsigned long)words[i]);printf("\n");}

}
PROCESS(observe_process,"Paper reproduction observatory");AUTOSTART_PROCESSES(&observe_process);
PROCESS_THREAD(observe_process,ev,data){
 static struct etimer timer;static uip_ipaddr_t root;static unsigned t;static uint32_t payload[21];static unsigned permit_sent;
 PROCESS_BEGIN();
 netstack_ip_packet_processor_add(&processor);simple_udp_register(&app,8768,NULL,8768,receive);simple_udp_register(&control,8769,NULL,8769,ctrl_receive);simple_udp_register(&data_link,8765,NULL,0,gateway_receive);simple_udp_register(&report_link,8766,NULL,0,gateway_receive);if(node_id==1)NETSTACK_ROUTING.root_start();
 original_of=curr_instance.of;next_offer=180+node_id%5;printf("BOOT,%u,%lu\n",node_id,(unsigned long)clock_time());etimer_set(&timer,CLOCK_SECOND/8);
 while(1){PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&timer));t=clock_seconds();
  if(node_id==1&&gateway_count){if(gateway_index<gateway_count){unsigned j=gateway_index++,who=gateway_node[j];if(who>=2&&who<=10&&known[who]&&gateway_len[j]<=60){simple_udp_sendto_port(&report_link,gateway_payload+60*j,gateway_len[j],&peers[who],gateway_port[j]);printf("GATEWAY_TX,%u,%u,%u\n",who,gateway_port[j],gateway_len[j]);}}if(gateway_index>=gateway_count){gateway_count=0;gateway_index=0;}}
  if(node_id==1&&t>=250&&t<840&&t%10==0){static unsigned last_tick;if(t!=last_tick){last_tick=t;printf("GATEWAY_TICK,%u\n",t);}}

  if(node_id==1&&(experiment_case==13||experiment_case==14)&&t>=300&&t<600&&!permit_sent&&known[attacker_id]){uint32_t v[8]={attacker_id,stage_session,1,authorized_work,780,0,0,0};sign(attacker_id,(uint8_t *)v,24);simple_udp_sendto_port(&app,v,32,&peers[attacker_id],8768);printf("AUTH_CONTEXT,%u,%u,%u,%u\n",attacker_id,t,780,authorized_work);permit_sent=1;}
  etimer_reset(&timer);
 }
 PROCESS_END();
}
