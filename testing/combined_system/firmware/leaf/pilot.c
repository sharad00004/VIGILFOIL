/* Isolated CNS research rig. Oracle flags and simulator coordinates are not decisions. */
#include "contiki.h"
#include "net/netstack.h"
#include "net/routing/routing.h"
#include "net/routing/rpl-lite/rpl.h"
#include "net/routing/rpl-lite/rpl-neighbor.h"
#include "net/ipv6/simple-udp.h"
#include "net/ipv6/uip-ds6.h"
#include "net/ipv6/uipbuf.h"
#include "sys/node-id.h"
#include "sys/energest.h"
#include "lib/sha-256.h"
#include "lib/aes-128.h"
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "model.h"
#ifdef LEAF_BUILD
#define IS_ROOT 0
#else
#define IS_ROOT 1
#endif
#define NMAX 11
#define EMAX 96
#define HISTORY 8
#define DATA_BYTES 28
#define REPORT_BYTES 108
int pilot_auth=1,pilot_freshness=1,pilot_context=1,pilot_monitor=1,pilot_repair=1,pilot_observed_helpers=1;
int pilot_budget=480,pilot_report_period=0,pilot_model_action=1,pilot_action_aware=1;
int pilot_policy=0,pilot_case=0,pilot_nodes=10,pilot_relay=2,pilot_fault=0;
int pilot_start1=310,pilot_end1=370,pilot_start2=610,pilot_end2=670;
uint32_t stage_session=1;
uint8_t own_key[32];
#define peer_keys own_key
static struct simple_udp_connection app,control,repair,host_link;
int host_case=0,host_work=250,pilot_authorized=1000,host_enabled=1;
uint32_t host_alarm_mask=0,host_known_mask=0;
static uint32_t host_seq,host_last_seq[NMAX];
static uint32_t host_dis_r,host_dis_s,host_dio_r,host_dio_s,host_dao_s,host_total;
static unsigned host_next=180,host_allowed,host_allow_until,host_permit_sent;
static uint32_t host_nonce;
static volatile uint32_t host_sink=17;
static void host_workload(unsigned rounds){unsigned i;for(i=0;i<rounds;i++)host_sink=host_sink*1664525UL+1013904223UL;}

static uint32_t own_tx,transit_in,transit_out,sequence,report_seq,query_nonce,control_nonce;
static uint32_t last_query,last_control;
static unsigned source_lease_id;
static unsigned lease_nonce[NMAX][HISTORY],lease_time[NMAX][HISTORY];
static unsigned query_seen_until;
static unsigned helper_id,helper_until,helper_quota,grant_until[NMAX],grant_quota[NMAX];
static uint8_t source_cap[16],helper_cap[NMAX][16];
static unsigned root_lease[NMAX],pending[NMAX],issued[NMAX],requested[NMAX],last_report[NMAX];
static unsigned last_query_at[NMAX],round_robin=2;
static uip_ipaddr_t peers[NMAX];static uint8_t known[NMAX];
struct record {unsigned epoch;uint16_t offered,submitted,blocked,original,repair,redirect;uint32_t lease;};
static struct record work[8];
static uint16_t direct_rx[NMAX][HISTORY],union_rx[NMAX][HISTORY];
static unsigned receipt_epoch[NMAX][HISTORY],state_epoch[NMAX][HISTORY];
static uint32_t highest[NMAX];static uint64_t bitmap[NMAX];static uint8_t initialized[NMAX];
static uint16_t last_model_seq[NMAX];static uint8_t model_seen[NMAX];
static unsigned last_data_ms[NMAX];
struct arrival {uint32_t ms;uint16_t src,gaps;};static struct arrival arrivals[128];static unsigned cursor;
struct status {uint32_t current[19],previous[19];unsigned at;uint8_t pair,valid;};
static struct status status[NMAX];
static uint8_t context_state[NMAX][HISTORY];
struct facts {unsigned end,at;uint32_t packed[3];uint8_t valid;};static struct facts facts[NMAX];
static unsigned fault_once;static uint8_t saved_report[REPORT_BYTES];static unsigned saved_valid;
static uint32_t get32(const uint8_t *p){uint32_t x;memcpy(&x,p,4);return uip_ntohl(x);}
static void put32(uint8_t *p,uint32_t x){x=uip_htonl(x);memcpy(p,&x,4);}
static const uint8_t *key_for(unsigned id){return IS_ROOT?peer_keys+32*id:own_key;}
static void sign(unsigned id,uint8_t *p,unsigned n){uint8_t tag[32];sha_256_hmac(key_for(id),32,p,n,tag);memcpy(p+n,tag,8);}
static int authentic(unsigned id,const uint8_t *p,unsigned n){if(!pilot_auth)return 1;uint8_t tag[32],diff=0;unsigned i;sha_256_hmac(key_for(id),32,p,n,tag);for(i=0;i<8;i++)diff|=p[n+i]^tag[i];return !diff;}
static void cap_sign(const uint8_t *key,uint8_t *p){uint8_t tag[32];sha_256_hmac(key,16,p,28,tag);memcpy(p+28,tag,8);}
static int cap_valid(const uint8_t *key,const uint8_t *p){if(!pilot_auth)return 1;uint8_t tag[32],diff=0;unsigned i;sha_256_hmac(key,16,p,28,tag);for(i=0;i<8;i++)diff|=tag[i]^p[28+i];return !diff;}
static void cap_mask(unsigned id,const uint8_t *header,uint8_t *mask){
 static const uint8_t domain[]="lease-cap-enc";uint8_t key[32];
 sha_256_hmac(key_for(id),32,domain,sizeof(domain)-1,key);
 memcpy(mask,header+8,16); /* session,unique destination-control nonce,flow,helper */
 AES_128.set_key(key);AES_128.encrypt(mask);
}
static int active(unsigned t){return (t>=(unsigned)pilot_start1&&t<(unsigned)pilot_end1)||(t>=(unsigned)pilot_start2&&t<(unsigned)pilot_end2);}
static unsigned nbr_id(rpl_nbr_t *p){const linkaddr_t *a=p?rpl_neighbor_get_lladdr(p):NULL;return a?a->u8[LINKADDR_SIZE-1]:0;}
static unsigned sender_id(const uip_ipaddr_t *p){return p->u8[15];}
static void linklocal(uip_ipaddr_t *p,unsigned id){uip_ip6addr(p,0xfe80,0,0,0,0xc30c,0,0,id);}
static unsigned receipt(unsigned src,unsigned e,int combined){if(receipt_epoch[src][e%HISTORY]!=e)return 0;return combined?union_rx[src][e%HISTORY]:direct_rx[src][e%HISTORY];}
static uint32_t neighbors(void){rpl_nbr_t *p;uint32_t mask=0;for(p=nbr_table_head(rpl_neighbors);p;p=nbr_table_next(rpl_neighbors,p)){unsigned id=nbr_id(p);if(id<NMAX)mask|=1U<<id;}return mask;}
static struct record *record(unsigned e){struct record *r=&work[e%8];if(r->epoch!=e){memset(r,0,sizeof(*r));r->epoch=e;}return r;}
static uint32_t packed_work(unsigned e){struct record *r=&work[e%8];if(r->epoch!=e||r->offered>1023||r->submitted>1023||r->blocked>1023)return 0;return 0x80000000U|((uint32_t)r->offered<<20)|((uint32_t)r->submitted<<10)|r->blocked;}
static int fresh_packet(unsigned channel,unsigned src,uint32_t seq){
 if(!initialized[src]){initialized[src]=1;highest[src]=seq;bitmap[src]=1;return 1;}
 if(seq>highest[src]){unsigned d=seq-highest[src];bitmap[src]=d>=64?1:(bitmap[src]<<d)|1;highest[src]=seq;return 1;}
 unsigned d=highest[src]-seq;if(d>=64||(bitmap[src]&(1ULL<<d)))return 0;bitmap[src]|=1ULL<<d;return 1;
}
static enum netstack_ip_action inspect_input(void){
 uint8_t proto=0;uint8_t *h=uipbuf_get_last_header(uip_buf,uip_len,&proto);host_total++;
 if(h&&proto==UIP_PROTO_ICMP6&&h+2<=uip_buf+uip_len&&h[0]==155){if(h[1]==0)host_dis_s++;if(h[1]==1)host_dio_s++;if(h[1]==2)host_dao_s++;}
 if(h&&proto==UIP_PROTO_ICMP6&&h+2<=uip_buf+uip_len&&h[0]==155){if(h[1]==0)host_dis_r++;if(h[1]==1)host_dio_r++;}
 if(!h||proto!=UIP_PROTO_UDP||h+8+20>uip_buf+uip_len)return NETSTACK_IP_PROCESS;
 uint8_t *p=h+8;unsigned kind=get32(p);
 if(node_id==pilot_relay&&kind==2)query_seen_until=clock_seconds()+15;
 if((kind==1||kind==6)&&!uip_ds6_is_my_addr(&UIP_IP_BUF->destipaddr)){
  transit_in++;
  if(node_id==pilot_relay&&active(clock_seconds())&&pilot_case!=0&&pilot_case!=1){
   unsigned threshold=pilot_case==9?100:pilot_case==10?20:pilot_case==11?(clock_seconds()<query_seen_until?80:20):50;
   if((transit_in*37U)%100U<threshold){printf("ORACLE_DROP,%lu,%lu,%lu,%u\n",(unsigned long)get32(p+4),(unsigned long)get32(p+12),(unsigned long)get32(p+16),kind);return NETSTACK_IP_DROP;}
  }
 }
 if(node_id==pilot_relay&&pilot_case==6&&kind==3&&active(clock_seconds())){printf("ORACLE_REPORT_DROP,%lu\n",(unsigned long)get32(p+4));return NETSTACK_IP_DROP;}
 return NETSTACK_IP_PROCESS;
}
static enum netstack_ip_action inspect_output(const linkaddr_t *dest){
 uint8_t proto=0;uint8_t *h=uipbuf_get_last_header(uip_buf,uip_len,&proto);host_total++;
 if(h&&proto==UIP_PROTO_ICMP6&&h+2<=uip_buf+uip_len&&h[0]==155){if(h[1]==0)host_dis_s++;if(h[1]==1)host_dio_s++;if(h[1]==2)host_dao_s++;}
 if(h&&proto==UIP_PROTO_UDP&&h+28<=uip_buf+uip_len&&!uip_ds6_is_my_addr(&UIP_IP_BUF->srcipaddr)&&(get32(h+8)==1||get32(h+8)==6))transit_out++;
 return NETSTACK_IP_PROCESS;
}
static struct netstack_ip_packet_processor processor={NULL,inspect_input,inspect_output};
static unsigned action_expected[NMAX][3],action_end[NMAX],action_scope_valid[NMAX][3];
static void emit_report(const uip_ipaddr_t *to,unsigned nonce,unsigned end){
 uint8_t p[REPORT_BYTES];uint32_t v[25]={0};unsigned i;energest_flush();
 uint32_t a[19]={3,node_id,stage_session,++report_seq,nonce,clock_seconds(),own_tx,transit_in,transit_out,
  energest_type_time(ENERGEST_TYPE_CPU),energest_type_time(ENERGEST_TYPE_TRANSMIT),energest_type_time(ENERGEST_TYPE_LISTEN),
  curr_instance.dag.rank,nbr_id(curr_instance.dag.preferred_parent),neighbors(),end,0,0,0};
 memcpy(v,a,sizeof(a));for(i=0;i<3;i++)v[16+i]=end>=2?packed_work(end-2+i):0;
 for(i=0;i<3;i++){unsigned e=end-2+i;struct record *r=&work[e%8];if(r->epoch==e){v[19+i]=((uint32_t)r->original<<20)|((uint32_t)r->repair<<10)|r->redirect;v[22+i]=r->lease;}}
 if(node_id==pilot_relay&&pilot_case==7)v[8]=v[7]; /* truthful identity, dishonest own forwarding testimony */
 for(i=0;i<25;i++){put32(p+4*i,v[i]);}sign(node_id,p,100);
 simple_udp_sendto_port(&control,p,sizeof(p),to,8766);printf("REPORT_TX,%u,%lu,%u,%u,108\n",node_id,(unsigned long)v[3],nonce,end);
 if(node_id==pilot_relay&&!saved_valid){memcpy(saved_report,p,sizeof(p));saved_valid=1;}
}
static void query(unsigned src,unsigned end,unsigned *budget){
 uint8_t p[28];unsigned nonce=++query_nonce,i;uint32_t v[5]={2,src,stage_session,nonce,end};
 if(*budget<136||!known[src]||clock_seconds()-last_query_at[src]<10)return;
 *budget-=136;pending[src]=nonce;issued[src]=clock_seconds();requested[src]=end;last_query_at[src]=clock_seconds();
 for(i=0;i<5;i++){put32(p+4*i,v[i]);}sign(src,p,20);simple_udp_sendto_port(&control,p,sizeof(p),&peers[src],8766);
 printf("QUERY_TX,%u,%u,%u,28\n",src,nonce,end);
}
static int safe_chain(unsigned node,unsigned source){
 unsigned seen=0,step=0,now=clock_seconds();
 while(node!=1&&step++<NMAX){if(node<2||node>=NMAX||node==source||(host_enabled&&(host_alarm_mask&(1UL<<node)))||(seen&(1U<<node))||!status[node].valid||now-status[node].at>35)return 0;if(pilot_observed_helpers&&status[node].pair){uint32_t a=status[node].current[7]-status[node].previous[7],b=status[node].current[8]-status[node].previous[8];if(a>2&&b*4<a*3)return 0;}seen|=1U<<node;node=status[node].current[13];}
 return node==1;
}
static unsigned choose_helper(unsigned src){
 unsigned i,now=clock_seconds();if(!status[src].valid||now-status[src].at>35)return 0;
 for(i=2;i<=(unsigned)pilot_nodes;i++)if(i!=src&&(status[src].current[14]&(1U<<i))&&safe_chain(i,src))return i;
 return 0;
}
static void grant(unsigned src,unsigned helper,unsigned *budget,int redirect){
 uint8_t p[60],seed[16],token[32];unsigned recipients[2]={src,helper},j,i,quota=pilot_policy==12?1:2,cost=120+64*quota;
 if(*budget<cost||root_lease[src]>clock_seconds()||!known[src]||!known[helper])return;
 *budget-=cost;root_lease[src]=clock_seconds()+10;
 put32(seed,src);put32(seed+4,helper);put32(seed+8,control_nonce+1);put32(seed+12,stage_session);
 sha_256_hmac(key_for(src),32,seed,sizeof(seed),token);
 for(j=0;j<2;j++){
  uint32_t v[9]={5,recipients[j],stage_session,++control_nonce,src,helper,10,redirect?2:1,quota};
  for(i=0;i<9;i++){put32(p+4*i,v[i]);}{uint8_t mask[16];cap_mask(recipients[j],p,mask);for(i=0;i<16;i++)p[36+i]=token[i]^mask[i];}sign(recipients[j],p,52);
  simple_udp_sendto_port(&control,p,sizeof(p),&peers[recipients[j]],8766);
  if(j==0&&redirect){unsigned slot=(clock_seconds()/10)%HISTORY;lease_nonce[src][slot]=v[3];lease_time[src][slot]=clock_seconds();}
  printf("GRANT_TX,%u,%u,%u,%u,%u,60\n",recipients[j],(unsigned)v[3],src,helper,(unsigned)v[7]);
 }
}
static void model_features(double x[15]){
 unsigned nowms=clock_time(),now=clock_seconds(),i,j,total=0,covered=0,gaps=0,fresh=0,n=pilot_nodes-1;
 double count[NMAX]={0},sum=0,age_sum=0,defsum=0,defmax=0,inmax=0,ownsum=0,txsum=0,rxsum=0,rank[NMAX],ranksum=0,age_report=0;
 for(i=0;i<128;i++)if(arrivals[i].src&&arrivals[i].ms<nowms&&nowms-arrivals[i].ms<=10*CLOCK_SECOND){count[arrivals[i].src]++;gaps+=arrivals[i].gaps;total++;}
 for(i=2;i<=(unsigned)pilot_nodes;i++){
  if(count[i]){covered++;}sum+=count[i];
  double age=last_data_ms[i]?(double)(nowms-last_data_ms[i])/CLOCK_SECOND:60;if(age>60)age=60;age_sum+=age/10;
  double a=status[i].valid?now-status[i].at:120;if(a>120)a=120;age_report+=a;
  if(status[i].valid&&status[i].pair&&a<=25){
   struct status *z=&status[i];double dt=z->current[5]-z->previous[5];if(dt<1)dt=1;
   double di=z->current[7]-z->previous[7],doo=z->current[8]-z->previous[8],d=di>doo?(di-doo)/(di>1?di:1):0;
   defsum+=d;if(d>defmax)defmax=d;if(di/dt>inmax)inmax=di/dt;
   ownsum+=(z->current[6]-z->previous[6])/dt;txsum+=(z->current[10]-z->previous[10])/dt/32768.0;rxsum+=(z->current[11]-z->previous[11])/dt/32768.0;
   rank[fresh++]=z->current[12]/128.0;ranksum+=rank[fresh-1];
  }
 }
 double var=0;for(i=2;i<=(unsigned)pilot_nodes;i++)var+=(count[i]-sum/n)*(count[i]-sum/n);
 for(i=1;i<fresh;i++){double a=rank[i];j=i;while(j&&rank[j-1]>a){rank[j]=rank[j-1];j--;}rank[j]=a;}
 double rv=0;if(fresh)for(i=0;i<fresh;i++)rv+=(rank[i]-ranksum/fresh)*(rank[i]-ranksum/fresh);
 x[0]=total/(2.0*n);x[1]=(double)covered/n;x[2]=gaps/(2.0*n);x[3]=sqrt(var/n)/2;x[4]=age_sum/n;
 x[5]=defmax;x[6]=fresh?defsum/fresh:0;x[7]=inmax;x[8]=fresh?ownsum/fresh:0;
 x[9]=fresh?(fresh%2?rank[fresh/2]:(rank[fresh/2-1]+rank[fresh/2])/2):0;x[10]=fresh?sqrt(rv/fresh):0;
 x[11]=fresh?txsum/fresh:0;x[12]=fresh?rxsum/fresh:0;x[13]=(double)fresh/n;x[14]=age_report/n/40;
}
static int fact(unsigned src,unsigned e,unsigned *o,unsigned *submitted,unsigned *blocked){
 if(!facts[src].valid||e>facts[src].end||facts[src].end-e>2)return 0;
 uint32_t p=facts[src].packed[e+2-facts[src].end];if(!(p&0x80000000U))return 0;
 *o=(p>>20)&1023;*submitted=(p>>10)&1023;*blocked=p&1023;return *o==*submitted+*blocked;
}
static void decide(void){
 unsigned i,j,e=clock_seconds()/10,budget=pilot_budget;int A=pilot_policy<8?(pilot_policy&1):1,B=pilot_policy<8?(pilot_policy&2):1,J=pilot_policy<8?(pilot_policy&4):pilot_policy>=9;
 if(!pilot_context){B=0;}if(!pilot_repair){J=0;}
 double x[15],margin=model_bias;model_features(x);for(i=0;i<15;i++)margin+=model_weights[i]*x[i];int alarm=margin>model_cutoff;
 printf("MODEL,%u,%.12g,%.12g,%u",(unsigned)clock_seconds(),margin,model_cutoff,alarm);for(i=0;i<15;i++)printf(",%.12g",x[i]);printf("\n");
 if(!pilot_model_action)alarm=0;
 printf("HOST_DECISION,%u,%lu,%lu,%u\n",(unsigned)clock_seconds(),(unsigned long)host_alarm_mask,(unsigned long)host_known_mask,host_enabled);
 if(e<3||e>=EMAX){return;}e-=2;
 int deficit[NMAX]={0};unsigned unknown[NMAX]={0},action_known[NMAX]={0};
 for(i=2;i<=(unsigned)pilot_nodes;i++){
  unsigned o=0,submitted=0,blocked=0,have=fact(i,e,&o,&submitted,&blocked);
  unsigned d=receipt(i,e,pilot_policy==11),u=receipt(i,e,1);
  int base_warning=d<2;int expected=B&&have?(int)submitted:2;int gap=expected>(int)d?expected-d:0;
  unsigned clear=B&&have&&o==submitted&&submitted==d;
  unsigned support=e,so=o,ss=submitted,sb=blocked,sh=have,k;
  if(B&&!sh)for(k=1;k<=2;k++)if(e>=k&&fact(i,e-k,&so,&ss,&sb)){support=e-k;sh=1;break;}
  unsigned sd=receipt(i,support,pilot_policy==11);
  unsigned expected_original=ss;int ak=0;
  if(pilot_action_aware&&sh&&support<=action_end[i]&&action_end[i]-support<=2){unsigned j=support+2-action_end[i];if(action_scope_valid[i][j]){expected_original=action_expected[i][j];ak=1;}}
  int actiongap=B&&sh?(expected_original>sd?(int)(expected_original-sd):0):gap;
  printf("ACTION_DECISION,%u,%u,%u,%u,%u,%u,%u\n",i,support,sh,ss,expected_original,sd,ak);
  deficit[i]=actiongap;unknown[i]=!have;action_known[i]=sh;
  printf("LEDGER,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u\n",i,e,d,u,have,o,submitted,blocked,base_warning,gap,clear,alarm,support,sd,so,ss,sb,sh);
 }
 if(pilot_policy==8)return;
 if(pilot_policy==9||pilot_policy==12){
  for(j=0;j<(unsigned)pilot_nodes;j++){i=round_robin++;if(round_robin>(unsigned)pilot_nodes)round_robin=2;if(i<2||i>(unsigned)pilot_nodes)continue;unsigned h=choose_helper(i);if(h)grant(i,h,&budget,0);if(budget<(pilot_policy==12?184:248))break;}
  for(j=0;j<(unsigned)pilot_nodes&&budget>=136;j++){i=round_robin++;if(round_robin>(unsigned)pilot_nodes)round_robin=2;if(i>=2&&i<=(unsigned)pilot_nodes)query(i,e,&budget);}
 }else{
  unsigned used=0;
  for(j=2;j<=(unsigned)pilot_nodes;j++){
   unsigned best=0;int bestscore=0;
   for(i=2;i<=(unsigned)pilot_nodes;i++)if(!(used&(1U<<i))){int score=10*deficit[i]+(alarm&&unknown[i]?1:0)+(host_enabled&&(host_alarm_mask&(1UL<<i))?20:0);if(score>bestscore){best=i;bestscore=score;}}
   if(!best){break;}used|=1U<<best;
   printf("DECISION_JOB,%u,%u,%u,%u,%u\n",best,e,(unsigned)deficit[best],unknown[best],alarm);
   if(J&&deficit[best]>0&&!(B&&!action_known[best])){unsigned h=choose_helper(best);if(h)grant(best,h,&budget,pilot_policy==10);else printf("NO_SAFE_HELPER,%u,%u\n",best,e);}
   if(A&&budget>=136&&(unknown[best]||deficit[best]||(host_enabled&&(host_alarm_mask&(1UL<<best))))&&clock_seconds()-last_query_at[best]>=10)query(best,e,&budget);
  }
  if(!A)for(j=0;j<(unsigned)pilot_nodes&&budget>=136;j++){i=round_robin++;if(round_robin>(unsigned)pilot_nodes)round_robin=2;if(i>=2&&i<=(unsigned)pilot_nodes)query(i,e,&budget);}
 }
 printf("ADMISSION,%u,%u,%u\n",(unsigned)clock_seconds(),pilot_budget-budget,budget);
}
static void receive(struct simple_udp_connection *c,const uip_ipaddr_t *sender,uint16_t sport,const uip_ipaddr_t *dest,uint16_t dport,const uint8_t *data,uint16_t len){
 unsigned i,kind,src;if(len<20)return;kind=get32(data);src=get32(data+4);
 if(src<2||src>=(unsigned)NMAX||src>(unsigned)pilot_nodes||get32(data+8)!=stage_session){printf("REJECT_SESSION,%u\n",kind);return;}
 if(kind==6&&!IS_ROOT&&dport==8767&&len==36){
  if(sender_id(sender)!=src||grant_until[src]<=clock_seconds()||!grant_quota[src]){printf("HELPER_REJECT,%u\n",src);return;}
  if(!cap_valid(helper_cap[src],data)){printf("HELPER_REJECT_AUTH,%u\n",src);return;}
  if(pilot_freshness&&!fresh_packet(1,src,get32(data+12))){printf("HELPER_REJECT_REPLAY,%u\n",src);return;}
  uip_ipaddr_t root;if(NETSTACK_ROUTING.get_root_ipaddr(&root)){grant_quota[src]--;simple_udp_sendto_port(&app,data,28,&root,8765);printf("HELPER_TX,%u,%lu,%lu,28\n",src,(unsigned long)get32(data+12),(unsigned long)get32(data+16));}return;
 }
 if((kind==1||kind==6)&&IS_ROOT&&len==DATA_BYTES){
  if(!authentic(src,data,20)){printf("APP_REJECT_AUTH,%u\n",src);return;}
  unsigned e=get32(data+16);uint32_t seq=get32(data+12);
  if(e>=EMAX||e>clock_seconds()/10+1||clock_seconds()/10>e+6){printf("APP_REJECT_TIME,%u\n",src);return;}
  if(pilot_freshness&&!fresh_packet(kind==1?0:1,src,seq)){printf("APP_REJECT_REPLAY,%u,%lu,%u\n",src,(unsigned long)seq,kind);return;}
  if(receipt_epoch[src][e%HISTORY]!=e){receipt_epoch[src][e%HISTORY]=e;union_rx[src][e%HISTORY]=0;direct_rx[src][e%HISTORY]=0;}
  int unique=fresh_packet(2,src,seq);if(unique)union_rx[src][e%HISTORY]++;if(kind==1)direct_rx[src][e%HISTORY]++;
  if((pilot_policy!=11&&kind==1)||(pilot_policy==11&&unique)){
   unsigned gaps=0;if(model_seen[src]&&seq>last_model_seq[src])gaps=seq-last_model_seq[src]-1;
   if(!model_seen[src]||seq>last_model_seq[src]){last_model_seq[src]=seq;}model_seen[src]=1;
   arrivals[cursor%128]=(struct arrival){clock_time(),src,gaps};cursor++;last_data_ms[src]=clock_time();
  }
  if(kind==1&&sender_id(sender)==src){peers[src]=*sender;known[src]=1;}
  printf("DATA_RX,%u,%lu,%u,%u,%u\n",src,(unsigned long)seq,e,kind,unique);return;
 }
 if(kind==2&&!IS_ROOT&&len==28&&src==node_id){
  if(!authentic(src,data,20)){printf("QUERY_REJECT_AUTH,%u\n",src);return;}
  unsigned nonce=get32(data+12),e=get32(data+16),now=clock_seconds()/10;
  if(pilot_freshness&&(nonce<=last_query||e<2||e>=now||now-e>7)){printf("QUERY_REJECT_FRESH,%u\n",src);return;}
  last_query=nonce;emit_report(sender,nonce,e);return;
 }
 if(kind==5&&!IS_ROOT&&len==60&&src==node_id){
  if(!authentic(src,data,52)){printf("CONTROL_REJECT_AUTH,%u\n",src);return;}
  unsigned nonce=get32(data+12),flow=get32(data+16),h=get32(data+20),duration=get32(data+24),mode=get32(data+28),quota=get32(data+32);
  if(pilot_freshness&&(nonce<=last_control||duration>10||!quota||quota>2||flow<2||flow>(unsigned)pilot_nodes||h<2||h>(unsigned)pilot_nodes||(mode!=1&&mode!=2))){printf("CONTROL_REJECT_FRESH,%u\n",src);return;}
  last_control=nonce;
  {uint8_t mask[16],token[16];cap_mask(src,data,mask);for(i=0;i<16;i++)token[i]=data[36+i]^mask[i];
   if(flow==node_id){source_lease_id=nonce;helper_id=h;helper_until=clock_seconds()+duration;helper_quota=quota;memcpy(source_cap,token,16);if(mode==2)helper_id|=0x80;}
   if(h==node_id){grant_until[flow]=clock_seconds()+duration;grant_quota[flow]=quota;memcpy(helper_cap[flow],token,16);}
  }
  printf("GRANT_RX,%u,%u,%u,%u,%u,%u,%u\n",src,nonce,flow,h,duration,mode,quota);return;
 }
 if(kind==3&&IS_ROOT&&len==REPORT_BYTES){
  uint32_t v[25];for(i=0;i<25;i++)v[i]=get32(data+4*i);
  if(!authentic(src,data,100)){printf("REPORT_REJECT_AUTH,%u\n",src);return;}
  if(pilot_freshness&&(sender_id(sender)!=src||v[3]<=last_report[src]||v[5]>clock_seconds()+1||clock_seconds()>v[5]+35)){printf("REPORT_REJECT_FRESH,%u\n",src);return;}
  if(pilot_freshness&&(v[4]&&(pending[src]!=v[4]||clock_seconds()>issued[src]+20||v[15]!=requested[src]))){printf("REPORT_REJECT_NONCE,%u\n",src);return;}
  if(pilot_freshness&&(v[15]<2||v[15]>=v[5]/10)){printf("REPORT_REJECT_SCOPE,%u\n",src);return;}
  if(status[src].valid){for(i=6;i<=11;i++)if(v[i]<status[src].current[i]){printf("REPORT_REJECT_RESET,%u\n",src);return;}}
  for(i=16;i<19;i++)if((v[i]&0x40000000U)||((v[i]&0x80000000U)&&((v[i]>>20)&1023)!=((v[i]>>10)&1023)+(v[i]&1023))){printf("REPORT_REJECT_COUNTS,%u\n",src);return;}
  for(i=0;i<3;i++)if(v[16+i]&0x80000000U){unsigned p=v[19+i],o=(v[16+i]>>20)&1023,u=(v[16+i]>>10)&1023,P=(p>>20)&1023,R=(p>>10)&1023,D=p&1023;
   if((p&0xc0000000U)||P>u||R>u||P+R<u||D>u-P||u>o){printf("REPORT_REJECT_ACTION,%u\n",src);return;}}
  if(!facts[src].valid||v[15]>=facts[src].end){action_end[src]=v[15];
   for(i=0;i<3;i++){unsigned p=v[19+i],u=(v[16+i]>>10)&1023,P=(p>>20)&1023,D=p&1023,j,valid=(u==P);
    if(D&&u-P==D)for(j=0;j<HISTORY;j++)if(lease_nonce[src][j]&&lease_nonce[src][j]==v[22+i]&&clock_seconds()>=lease_time[src][j]&&clock_seconds()-lease_time[src][j]<=70)valid=1;
    action_expected[src][i]=P;action_scope_valid[src][i]=!!(valid&&(v[16+i]&0x80000000U));
    printf("ACTION_CONTEXT,%u,%lu,%u,%u,%u,%u,%lu,%u\n",src,(unsigned long)(v[15]-2+i),u,P,(p>>10)&1023,D,(unsigned long)v[22+i],action_scope_valid[src][i]);}}
  last_report[src]=v[3];if(v[4])pending[src]=0;
  if(status[src].valid){memcpy(status[src].previous,status[src].current,19*sizeof(uint32_t));status[src].pair=1;}
  memcpy(status[src].current,v,19*sizeof(uint32_t));status[src].valid=1;status[src].at=clock_seconds();
  if(!facts[src].valid||v[15]>=facts[src].end){facts[src].end=v[15];facts[src].at=clock_seconds();facts[src].valid=1;for(i=0;i<3;i++)facts[src].packed[i]=v[16+i];}
  for(i=0;i<3;i++)if(v[16+i]&0x80000000U){
   unsigned e=v[15]-2+i,p=v[16+i],o=(p>>20)&1023,submitted=(p>>10)&1023,b=p&1023;
   if(e<EMAX&&e+6>=clock_seconds()/10){unsigned d=receipt(src,e,0),u=receipt(src,e,1);
    unsigned state=1|(o==submitted&&submitted==d?2:0)|(o==submitted&&submitted==u?4:0)|(submitted>d?8:0)|(b?16:0);
    if(state_epoch[src][e%HISTORY]!=e||context_state[src][e%HISTORY]!=state){state_epoch[src][e%HISTORY]=e;context_state[src][e%HISTORY]=state;printf("CONTEXT_STATUS,%u,%u,%u,%u,%u,%u,%u,%u\n",src,e,d,u,o,submitted,b,state);}
   }
  }
  peers[src]=*sender;known[src]=1;
  printf("REPORT_RX,%u",src);for(i=2;i<25;i++)printf(",%lu",(unsigned long)v[i]);printf("\n");return;
 }
}

static void host_receive(struct simple_udp_connection*c,const uip_ipaddr_t*src,uint16_t sp,const uip_ipaddr_t*dst,uint16_t dp,const uint8_t*p,uint16_t n){
 uint8_t tag[32],diff=0;unsigned i;
 if(IS_ROOT&&n==84){uint32_t v[19];memcpy(v,p,76);unsigned who=v[0];if(who<2||who>=NMAX||v[18]!=stage_session){printf("HOST_REJECT_SCOPE\n");return;}sha_256_hmac(peer_keys+who*32,32,p,76,tag);for(i=0;i<8;i++)diff|=tag[i]^p[76+i];if(diff||v[1]<=host_last_seq[who]){printf("HOST_REJECT_AUTH_REPLAY\n");return;}host_last_seq[who]=v[1];printf("TELEMETRY");for(i=0;i<18;i++)printf(",%lu",(unsigned long)v[i]);printf("\n");return;}
 if(!IS_ROOT&&n==32){uint32_t v[6];memcpy(v,p,24);sha_256_hmac(own_key,32,p,24,tag);for(i=0;i<8;i++)diff|=tag[i]^p[24+i];if(diff||v[0]!=node_id||v[1]!=stage_session||v[2]<=host_nonce||v[3]>4000||v[4]<=clock_seconds()||v[4]>clock_seconds()+605)return;host_nonce=v[2];host_allowed=v[3];host_allow_until=v[4];printf("PERMIT,%u,%u,%u\n",node_id,host_allowed,host_allow_until);}
}
static void host_tick(unsigned t){
 if(IS_ROOT){if(pilot_authorized&&t>=300&&!host_permit_sent&&known[pilot_relay]){uint32_t v[8]={pilot_relay,stage_session,1,pilot_authorized,780,0,0,0};uint8_t tag[32];sha_256_hmac(peer_keys+32*pilot_relay,32,(uint8_t*)v,24,tag);memcpy((uint8_t*)v+24,tag,8);simple_udp_sendto(&host_link,v,32,&peers[pilot_relay]);printf("AUTH_CONTEXT,%u,%u,%u,%u\n",pilot_relay,t,780,pilot_authorized);printf("HOST_CONTROL_TX,32\n");host_permit_sent=1;}return;}
 if(t<180||t>=840)return;
 if(t<host_allow_until)host_workload(host_allowed);
 if(node_id==pilot_relay&&host_case&&active(t)){unsigned amount=host_work;if(host_case==2)amount=(uint32_t)host_work*(t-pilot_start1)/(pilot_end1-pilot_start1);if(host_case!=3||t%60<4){host_workload(amount);printf("ORACLE_HOST,%u,%u,%u\n",node_id,t,amount);}}
 if(t>=host_next){uint32_t v[21]={0};uint8_t tag[32];uip_ipaddr_t root;energest_flush();v[0]=node_id;v[1]=++host_seq;v[2]=host_sink;v[3]=energest_type_time(ENERGEST_TYPE_CPU);v[4]=energest_type_time(ENERGEST_TYPE_TRANSMIT);v[5]=energest_type_time(ENERGEST_TYPE_LISTEN);v[6]=curr_instance.dag.rank;v[7]=nbr_id(curr_instance.dag.preferred_parent);v[8]=host_dis_r;v[9]=host_dis_s;v[10]=host_dio_r;v[11]=host_dio_s;v[12]=host_dao_s;v[13]=host_total;v[14]=host_seq;v[15]=transit_in;v[16]=transit_out;v[17]=t;v[18]=stage_session;sha_256_hmac(own_key,32,(uint8_t*)v,76,tag);memcpy((uint8_t*)v+76,tag,8);if(NETSTACK_ROUTING.get_root_ipaddr(&root)){simple_udp_sendto(&host_link,v,84,&root);printf("HOST_TX,%u,%lu,84\n",node_id,(unsigned long)host_seq);}host_next=t+2+(node_id+host_seq*3)%7;}
}

PROCESS(pilot_process,"CNS joint native experiment");AUTOSTART_PROCESSES(&pilot_process);
PROCESS_THREAD(pilot_process,ev,data){
 static struct etimer timer;static uip_ipaddr_t root;static unsigned t;
 PROCESS_BEGIN();
 {uint8_t key[16],block[16];unsigned i;for(i=0;i<16;i++){key[i]=i;block[i]=i*17;}AES_128.set_key(key);AES_128.encrypt(block);printf("AES_KAT");for(i=0;i<16;i++)printf(",%02x",block[i]);printf("\n");}
 netstack_ip_packet_processor_add(&processor);simple_udp_register(&app,8765,NULL,0,receive);simple_udp_register(&control,8766,NULL,0,receive);simple_udp_register(&repair,8767,NULL,0,receive);
 simple_udp_register(&host_link,8768,NULL,8768,host_receive);if(IS_ROOT)NETSTACK_ROUTING.root_start();
 {unsigned k=0,i;for(i=0;i<sizeof(own_key);i++)k+=own_key[i]!=0;printf("BOOT,%u,%u\n",node_id,k);}
 etimer_set(&timer,CLOCK_SECOND);
 while(1){PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&timer));t=clock_seconds();host_tick(t);
  if(t==10){unsigned k=0,i;for(i=0;i<sizeof(own_key);i++)k+=own_key[i]!=0;printf("KEY_STATUS,%u,%u\n",node_id,k);}
  if(!IS_ROOT&&t>=180&&t<840){
   record(t/10); /* Zero offered work is measured evidence, not an absent cache entry. */
   unsigned due=t%5==node_id%5;
   if((pilot_case==1||pilot_case==4)&&active(t)&&node_id>=4){
    if(node_id%2==0)due=0;else due=1; /* mixed legitimate sleep/burst; attack may coexist */
   }
   if(due){
    unsigned e=t/10;struct record *r=record(e);uint32_t seq=sequence++;uint8_t packet[36];r->offered++;
    printf("APP_OFFER,%u,%lu,%u\n",node_id,(unsigned long)seq,e);
    int reachable=NETSTACK_ROUTING.node_is_reachable()&&NETSTACK_ROUTING.get_root_ipaddr(&root);
    int rescue=helper_id&&helper_until>t&&helper_quota;unsigned h=helper_id&0x7f;
    int redirect=rescue&&(helper_id&0x80);unsigned submitted=0;
    uint32_t v[5]={1,node_id,stage_session,seq,e};unsigned i;
    if(reachable&&!redirect){r->original++;for(i=0;i<5;i++){put32(packet+4*i,v[i]);}sign(node_id,packet,20);simple_udp_sendto_port(&app,packet,DATA_BYTES,&root,8765);submitted=1;printf("DATA_TX,%u,%lu,%u,1,28\n",node_id,(unsigned long)seq,e);}
    if(rescue){r->repair++;if(reachable&&redirect){r->redirect++;if(!r->lease)r->lease=source_lease_id;else if(r->lease!=source_lease_id)r->lease=0xffffffffU;printf("SOURCE_ACTION,%u,%lu,%u,%u\n",node_id,(unsigned long)seq,e,source_lease_id);}uip_ipaddr_t hop;linklocal(&hop,h);v[0]=6;for(i=0;i<5;i++){put32(packet+4*i,v[i]);}sign(node_id,packet,20);cap_sign(source_cap,packet);simple_udp_sendto_port(&repair,packet,sizeof(packet),&hop,8767);helper_quota--;submitted=1;printf("DATA_TX,%u,%lu,%u,6,36\n",node_id,(unsigned long)seq,e);}
    if(submitted){r->submitted++;own_tx++;}else{r->blocked++;printf("APP_BLOCK,%u,%lu,%u\n",node_id,(unsigned long)seq,e);}
   }
   unsigned interval=pilot_report_period?pilot_report_period:(pilot_policy==8?10:30);
   if(pilot_monitor&&t%interval==0&&NETSTACK_ROUTING.get_root_ipaddr(&root))emit_report(&root,0,t/10-2);
  }
  if(IS_ROOT&&t>=250&&t<840&&t%10==0)decide();
  if(node_id==pilot_relay&&pilot_fault&&t>=400&&!fault_once&&NETSTACK_ROUTING.get_root_ipaddr(&root)){
   uint8_t p[60];unsigned i;uint32_t v[9]={5,4,stage_session,999,4,3,10,1,2};
   for(i=0;i<9;i++){put32(p+4*i,v[i]);}memset(p+36,0,16);sign(node_id,p,52);uip_ipaddr_t victim;linklocal(&victim,4);simple_udp_sendto_port(&control,p,60,&victim,8766);printf("FORGE_CONTROL_TX,4,60\n");
   if(saved_valid){simple_udp_sendto_port(&control,saved_report,REPORT_BYTES,&root,8766);printf("REPLAY_REPORT_TX,2,108\n");}
   {uint8_t stale[REPORT_BYTES];uint32_t f[25]={3,node_id,stage_session,report_seq+1000,0,t,0,0,0,0,0,0,256,1,2,t/10-2,0,0,0};
    for(i=0;i<25;i++){put32(stale+4*i,f[i]);}sign(node_id,stale,100);simple_udp_sendto_port(&control,stale,REPORT_BYTES,&root,8766);printf("RESET_REPORT_TX,2,108\n");
    put32(stale+20,t+9999);sign(node_id,stale,100);simple_udp_sendto_port(&control,stale,REPORT_BYTES,&root,8766);printf("FUTURE_REPORT_TX,2,108\n");}
   uint32_t a[5]={1,4,stage_session,999,40};for(i=0;i<5;i++){put32(p+4*i,a[i]);}sign(node_id,p,20);simple_udp_sendto_port(&app,p,28,&root,8765);printf("FORGE_APP_TX,4,28\n");fault_once=1;
  }
  if(node_id==pilot_relay&&pilot_case==5&&active(t)&&NETSTACK_ROUTING.get_root_ipaddr(&root)){
   uint8_t p[28];unsigned i,j;uint32_t v[5]={2,4,stage_session,999, t/10-2};for(i=0;i<5;i++){put32(p+4*i,v[i]);}sign(node_id,p,20);uip_ipaddr_t victim;linklocal(&victim,4);for(j=0;j<10;j++)simple_udp_sendto_port(&control,p,28,&victim,8766);printf("FORGE_QUERY_BURST,10,28\n");
  }
  etimer_reset(&timer);
 }
 PROCESS_END();
}
