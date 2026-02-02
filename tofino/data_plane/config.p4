#ifndef _CONFIG_P4
#define _CONFIG_P4

#define BUCKET_NUM 65536

typedef bit<8>   pkt_type_t;
typedef bit<8>   ip_protocol_t;
typedef bit<12>  vlan_id_t;
typedef bit<16>  port_t;
typedef bit<16>  ether_type_t;
typedef bit<32>  seq_num_t;
typedef bit<32>  ack_num_t;
typedef bit<32>  ipv4_addr_t;
typedef bit<48>  mac_addr_t;
typedef bit<128> ipv6_addr_t;

// for mirror
const pkt_type_t PKT_TYPE_NORMAL = 1;
const pkt_type_t PKT_TYPE_MIRROR = 2;

typedef bit<3> mirror_type_t;
const mirror_type_t MIRROR_TYPE_I2E = 1;
const mirror_type_t MIRROR_TYPE_E2E = 2;

/* special reserved port for NetCache */
const ether_type_t  ETHERTYPE_IPV4        = 16w0x0800;
const ether_type_t  ETHERTYPE_ARP         = 16w0x0806;
const ether_type_t  ETHERTYPE_IPV6        = 16w0x86dd;
const ether_type_t  ETHERTYPE_VLAN        = 16w0x8100;
const ip_protocol_t IP_PROTOCOLS_ICMP     = 1;
const ip_protocol_t IP_PROTOCOLS_TCP      = 6;
const ip_protocol_t IP_PROTOCOLS_UDP      = 17;
const bit<16>       MSS_VALUE             = 1460;
const bit<8>        WINDOW_SCALE          = 7;


const bit<16>   HYBRID_PORT        = 50000;



#endif