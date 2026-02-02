#ifndef _HEADERS_P4
#define _HEADERS_P4

#include "config.p4"

header ethernet_h {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    ether_type_t ether_type;
}

header ipv4_h {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffserv;
    bit<16> total_len;
    bit<16> identification;
    bit<3> flags;
    bit<13> frag_offset;
    bit<8> ttl;
    ip_protocol_t protocol;
    bit<16> hdr_checksum;
    ipv4_addr_t src_addr;
    ipv4_addr_t dst_addr;
}


header udp_h {
    bit<16> src_port;
    bit<16> dst_port;
    bit<16> hdr_length;
    bit<16> checksum;
}

// 19B + 11B = 30 Byte
header wisepifinder_t {
	ipv4_addr_t src_addr;
	ipv4_addr_t dst_addr;
    port_t src_port;
	port_t dst_port;
    ip_protocol_t protocol;
    bit<16> window;
    bit<16> fp;
    bit<16> index;

    bit<8>  recirc_flag; 
    bit<16> sketch1_N;
    bit<16> sketch2_N;
    bit<16> sketch3_N;
    bit<16> sketch4_N;
    bit<2>  fp_match_1;
    bit<2>  fp_match_2;
    bit<2>  fp_match_3;
    bit<2>  fp_match_4;
    bit<1> sketch1_last;
    bit<1> sketch2_last;
    bit<1> sketch3_last;
    bit<1> sketch4_last;
    bit<4> span;
}



struct header_t {
    ethernet_h ethernet;
    ipv4_h ipv4;
    udp_h udp;
    wisepifinder_t wisepifinder;
};


struct ingress_metadata_t {
    bit<16> tmp1;
    bit<16> tmp2;
    bit<16> tmp;
    bit<16> tmp11;
    bit<16> tmp22;
    bit<2> num1;
    bit<2> num2;
    bit<2> num;
    bit<2> padding;
    bit<16> idx;
    bit<8> mew;
};

struct egress_metadata_t {};



#endif   // HEADERS_P4
