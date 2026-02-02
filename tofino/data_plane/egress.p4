#ifndef _EGRESS_P4
#define _EGRESS_P4


#include "headers.p4"



control SwitchEgress(inout header_t hdr,
        inout egress_metadata_t eg_md,
        in    egress_intrinsic_metadata_t                 eg_intr_md,
        in    egress_intrinsic_metadata_from_parser_t     eg_prsr_md,
        inout egress_intrinsic_metadata_for_deparser_t    eg_dprsr_md,
        inout egress_intrinsic_metadata_for_output_port_t eg_oport_md) {



	action nop() {}


    apply {

	}
}

#endif
