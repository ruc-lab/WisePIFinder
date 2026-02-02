#ifndef _PARSERS_P4
#define _PARSERS_P4

#include "headers.p4"

parser TofinoIngressParser(
        packet_in pkt,
        out ingress_intrinsic_metadata_t ig_intr_md) {
    
    state start {
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
        transition accept;
    }
}

parser TofinoEgressParser(
        packet_in pkt,
        out egress_intrinsic_metadata_t eg_intr_md) {
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}


parser SwitchIngressParser(packet_in pkt,
        out header_t hdr,
        out ingress_metadata_t ig_md,
        out ingress_intrinsic_metadata_t ig_intr_md) {
    TofinoIngressParser() tofino_ingress_parser;

    state start {
		tofino_ingress_parser.apply(pkt, ig_intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type){
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol){
            IP_PROTOCOLS_UDP  : parse_udp;
            default           : accept;
        }
    }

	state parse_udp {
		pkt.extract(hdr.udp);
        transition select(hdr.udp.dst_port) {
            HYBRID_PORT : parse_wisepifinder;
            default: accept;
        }
	}

	state parse_wisepifinder {
	    pkt.extract(hdr.wisepifinder);
		transition accept;
	}

}


parser SwitchEgressParser(packet_in pkt,
        out header_t hdr,
        out egress_metadata_t eg_md,
        out egress_intrinsic_metadata_t eg_intr_md) {

    TofinoEgressParser() tofino_egress_parser;

    state start {
        tofino_egress_parser.apply(pkt, eg_intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type){
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol){
            IP_PROTOCOLS_UDP  : parse_udp;
            default           : accept;
        }
    }

    state parse_udp {
        pkt.extract(hdr.udp);
        transition select(hdr.udp.dst_port) {
            HYBRID_PORT : parse_wisepifinder;
            default: accept;
        }
    }

    state parse_wisepifinder {
        pkt.extract(hdr.wisepifinder);
        transition accept;
    }

}


#endif     // PARSERS_P4
