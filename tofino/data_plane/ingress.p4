#ifndef _INGRESS_P4
#define _INGRESS_P4


#include "headers.p4"

control SwitchIngress(inout header_t hdr,
        inout ingress_metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_intr_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_intr_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_intr_tm_md) {

    action nop() {}

	action drop() {
        ig_intr_dprsr_md.drop_ctl = 0x1;
	}

	action action_set_egress_port(PortId_t port) {
		ig_intr_tm_md.ucast_egress_port = port;
	}

	action action_set_recir_port() {
		ig_intr_tm_md.ucast_egress_port = 140;
	}

	action action_set_dst_port() {
		ig_intr_tm_md.ucast_egress_port = 133;
	}

	action action_send_back() {
		ig_intr_tm_md.ucast_egress_port = 134;
	}

	// table table_l3_forward {

	// 	key = {
	// 		hdr.ipv4.dst_addr: exact;
	// 	}

	// 	actions = {
	// 		action_set_egress_port;
	// 		action_send_back;
	// 		nop;
	// 	}

	// 	size = 1024;
	// 	const default_action = nop;
	// 	const entries = {
	// 		(0xA0A0402) : action_set_egress_port(133);
	// 		(0xA0A0401) : action_set_egress_port(134);
	// 	}

	// }


	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch1_fp;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch1_last;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch1_N;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch1_fpart;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch1_fsum;

	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch2_fp;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch2_last;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch2_N;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch2_fpart;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch2_fsum;

	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch3_fp;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch3_last;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch3_N;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch3_fpart;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch3_fsum;

	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch4_fp;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch4_last;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch4_N;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch4_fpart;
	Register<bit<16>, bit<16>> (BUCKET_NUM) sketch4_fsum;
	
//============================ READ FP ===================================

	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch1_fp) read_sketch1_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = 0;
			if(hdr.wisepifinder.fp == value) {
				output = 1;
			}
			else if(value == 0) {
				output = 2;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch2_fp) read_sketch2_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = 0;
			if(hdr.wisepifinder.fp == value) {
				output = 1;
			}
			else if(value == 0) {
				output = 2;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch3_fp) read_sketch3_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = 0;
			if(hdr.wisepifinder.fp == value) {
				output = 1;
			}
			else if(value == 0) {
				output=2;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch4_fp) read_sketch4_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = 0;
			if(hdr.wisepifinder.fp == value) {
				output = 1;
			}
			else if(value == 0) {
				output = 2;
			}
		}
	};

	action action_read_fp1() {
		hdr.wisepifinder.fp_match_1 = (bit<2>)read_sketch1_fp.execute(hdr.wisepifinder.index);
	}
	action action_read_fp2() {
		hdr.wisepifinder.fp_match_2 = (bit<2>)read_sketch2_fp.execute(hdr.wisepifinder.index);
	}
	action action_read_fp3() {
		hdr.wisepifinder.fp_match_3 = (bit<2>)read_sketch3_fp.execute(hdr.wisepifinder.index);
	}
	action action_read_fp4() {
		hdr.wisepifinder.fp_match_4 = (bit<2>)read_sketch4_fp.execute(hdr.wisepifinder.index);
	}

	table table_read_fp1 {
		actions = { action_read_fp1; }
		const default_action = action_read_fp1;
		size = 1;
	}

	table table_read_fp2 {
		actions = { action_read_fp2; }
		const default_action = action_read_fp2;
		size = 1;
	}

	table table_read_fp3 {
		actions = { action_read_fp3; }
		const default_action = action_read_fp3;
		size = 1;
	}

	table table_read_fp4 {
		actions = { action_read_fp4; }
		const default_action = action_read_fp4;
		size = 1;
	}
//============================ WRITE FP ==================================

	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch1_fp) write_sketch1_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			value = hdr.wisepifinder.fp;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch2_fp) write_sketch2_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			value = hdr.wisepifinder.fp;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch3_fp) write_sketch3_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			value = hdr.wisepifinder.fp;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch4_fp) write_sketch4_fp = {
		void apply(inout bit<16> value, out bit<16> output) {
			value = hdr.wisepifinder.fp;
		}
	};
	action action_write_sketch1_fp() {
		write_sketch1_fp.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch2_fp() {
		write_sketch2_fp.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch3_fp() {
		write_sketch3_fp.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch4_fp() {
		write_sketch4_fp.execute(hdr.wisepifinder.index);
	}

	table table_write_fp1 {
		actions = { action_write_sketch1_fp; }
		const default_action = action_write_sketch1_fp;
		size = 1;
	}

	table table_write_fp2 {
		actions = { action_write_sketch2_fp; }
		const default_action = action_write_sketch2_fp;
		size = 1;
	}

	table table_write_fp3 {
		actions = { action_write_sketch3_fp; }
		const default_action = action_write_sketch3_fp;
		size = 1;
	}

	table table_write_fp4 {
		actions = { action_write_sketch4_fp; }
		const default_action = action_write_sketch4_fp;
		size = 1;
	}

	

//============================ READ LAST ===================================
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch1_last) read_sketch1_last = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.window == value) {
				output = 1;
			}
			value = hdr.wisepifinder.window;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch2_last) read_sketch2_last = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.window == value) {
				output = 1;
			}
			value = hdr.wisepifinder.window;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch3_last) read_sketch3_last = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.window == value) {
				output = 1;
			}
			value = hdr.wisepifinder.window;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch4_last) read_sketch4_last = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.window == value) {
				output = 1;
			}
			value = hdr.wisepifinder.window;
		}
	};
	action action_read_sketch1_last() {
		hdr.wisepifinder.sketch1_last = read_sketch1_last.execute(hdr.wisepifinder.index);
	}
	action action_read_sketch2_last() {
		hdr.wisepifinder.sketch2_last = read_sketch2_last.execute(hdr.wisepifinder.index);
	}
	action action_read_sketch3_last() {
		hdr.wisepifinder.sketch3_last = read_sketch3_last.execute(hdr.wisepifinder.index);
	}
	action action_read_sketch4_last() {
		hdr.wisepifinder.sketch4_last = read_sketch4_last.execute(hdr.wisepifinder.index);
	}

	table table_read_sketch1_last {
		actions = { action_read_sketch1_last; }
		const default_action = action_read_sketch1_last;
		size = 1;	
	}
	table table_read_sketch2_last {
		actions = { action_read_sketch2_last; }
		const default_action = action_read_sketch2_last;
		size = 1;	
	}
	table table_read_sketch3_last {
		actions = { action_read_sketch3_last; }
		const default_action = action_read_sketch3_last;
		size = 1;	
	}
	table table_read_sketch4_last {
		actions = { action_read_sketch4_last; }
		const default_action = action_read_sketch4_last;
		size = 1;	
	}	
	
//============================ READ N ===================================
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch1_N) read_sketch1_N = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = value;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch2_N) read_sketch2_N = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = value;
		}
		
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch3_N) read_sketch3_N = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = value;
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<16>>(sketch4_N) read_sketch4_N = {
		void apply(inout bit<16> value, out bit<16> output) {
			output = value;
		}
	};
	action action_read_sketch1_N() {
        hdr.wisepifinder.sketch1_N = read_sketch1_N.execute(hdr.wisepifinder.index);
    }
    action action_read_sketch2_N() {
        hdr.wisepifinder.sketch2_N = read_sketch2_N.execute(hdr.wisepifinder.index);
    }
    action action_read_sketch3_N() {
        hdr.wisepifinder.sketch3_N = read_sketch3_N.execute(hdr.wisepifinder.index);
    }
    action action_read_sketch4_N() {
        hdr.wisepifinder.sketch4_N = read_sketch4_N.execute(hdr.wisepifinder.index);
    }
	table table_read_sketch1_N {
		actions = { action_read_sketch1_N; }
		const default_action = action_read_sketch1_N;
		size = 1;	
	}
	table table_read_sketch2_N {
		actions = { action_read_sketch2_N; }
		const default_action = action_read_sketch2_N;
		size = 1;	
	}
	table table_read_sketch3_N {
		actions = { action_read_sketch3_N; }
		const default_action = action_read_sketch3_N;
		size = 1;	
	}
	table table_read_sketch4_N {
		actions = { action_read_sketch4_N; }
		const default_action = action_read_sketch4_N;
		size = 1;	
	}



//============================ WRITE N ===================================
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch1_N) write_sketch1_N = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_1 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
			
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch2_N) write_sketch2_N = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_2 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
		
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch3_N) write_sketch3_N = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_3 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch4_N) write_sketch4_N = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_4 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	action action_write_sketch1_N() {
        write_sketch1_N.execute(hdr.wisepifinder.index);
    }
    action action_write_sketch2_N() {
        write_sketch2_N.execute(hdr.wisepifinder.index);
    }
    action action_write_sketch3_N() {
        write_sketch3_N.execute(hdr.wisepifinder.index);
    }
    action action_write_sketch4_N() {
        write_sketch4_N.execute(hdr.wisepifinder.index);
    }
	table table_write_sketch1_N {
		actions = { action_write_sketch1_N; }
		const default_action = action_write_sketch1_N;
		size = 1;	
	}
	
	table table_write_sketch2_N {
		actions = { action_write_sketch2_N; }
		const default_action = action_write_sketch2_N;
		size = 1;	
	}
	
	table table_write_sketch3_N {
		actions = { action_write_sketch3_N; }
		const default_action = action_write_sketch3_N;
		size = 1;	
	}
	 
	table table_write_sketch4_N {
		actions = { action_write_sketch4_N; }
		const default_action = action_write_sketch4_N;
		size = 1;	
	}


//============================ WRITE FPART ===================================
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch1_fpart) write_sketch1_fpart = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_1 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}		
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch2_fpart) write_sketch2_fpart = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_2 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch3_fpart) write_sketch3_fpart = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_3 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch4_fpart) write_sketch4_fpart = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_4 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	action action_write_sketch1_fpart() {
		write_sketch1_fpart.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch2_fpart() {
		write_sketch2_fpart.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch3_fpart() {
		write_sketch3_fpart.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch4_fpart() {
		write_sketch4_fpart.execute(hdr.wisepifinder.index);
	}
	 
	table table_write_sketch1_fpart {
		actions = { action_write_sketch1_fpart; }
		const default_action = action_write_sketch1_fpart;
		size = 1;
	}
	 
	table table_write_sketch2_fpart {
		actions = { action_write_sketch2_fpart; }
		const default_action = action_write_sketch2_fpart;
		size = 1;
	}
	
	table table_write_sketch3_fpart {
		actions = { action_write_sketch3_fpart; }
		const default_action = action_write_sketch3_fpart;
		size = 1;
	}
	 
	table table_write_sketch4_fpart {
		actions = { action_write_sketch4_fpart; }
		const default_action = action_write_sketch4_fpart;
		size = 1;
	}


//============================ WRITE FSUM ===================================
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch1_fsum) write_sketch1_fsum = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_1 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch2_fsum) write_sketch2_fsum = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_2 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch3_fsum) write_sketch3_fsum = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_3 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	RegisterAction<bit<16>, bit<16>, bit<1>>(sketch4_fsum) write_sketch4_fsum = {
		void apply(inout bit<16> value, out bit<1> output) {
			output = 0;
			if(hdr.wisepifinder.fp_match_4 == 1) {
				value = value + 1;
			}
			else {
				value = 1;
			}
		}
	};
	action action_write_sketch1_fsum() {
		write_sketch1_fsum.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch2_fsum() {
		write_sketch2_fsum.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch3_fsum() {
		write_sketch3_fsum.execute(hdr.wisepifinder.index);
	}
	action action_write_sketch4_fsum() {
		write_sketch4_fsum.execute(hdr.wisepifinder.index);
	}
	
	table table_write_sketch1_fsum {
		actions = { action_write_sketch1_fsum; }
		const default_action = action_write_sketch1_fsum;
		size = 1;
	}
	 
	table table_write_sketch2_fsum {
		actions = { action_write_sketch2_fsum; }
		const default_action = action_write_sketch2_fsum;
		size = 1;
	}
	
	table table_write_sketch3_fsum {
		actions = { action_write_sketch3_fsum; }
		const default_action = action_write_sketch3_fsum;
		size = 1;
	}
	
	table table_write_sketch4_fsum {
		actions = { action_write_sketch4_fsum; }
		const default_action = action_write_sketch4_fsum;
		size = 1;
	}
	

	Register<bit<16>, bit<16>>(1) reg_1;
	RegisterAction<bit<16>, bit<1>, bit<16>>(reg_1) judge_reg_1 = {
		void apply(inout bit<16> value, out bit<16> output) {
			if(ig_md.tmp1[15:15] == 1)	{
				output = 1;	
			}
			else {
				output = 0;
			}
		}
	};
	action action_judge_reg_1() {
		ig_md.tmp1 = judge_reg_1.execute(0);
	}
	table table_judge_reg_1 {
		actions = {
			action_judge_reg_1;
		}
		size = 1;
		const default_action = action_judge_reg_1;
	}

	Register<bit<16>, bit<16>>(1) reg_2;
	RegisterAction<bit<16>, bit<1>, bit<16>>(reg_2) judge_reg_2 = {
		void apply(inout bit<16> value, out bit<16> output) {
			if(ig_md.tmp2[15:15] == 1)	{
				output = 1;	
			}
			else {
				output = 0;
			}
		}
	};
	action action_judge_reg_2() {
		ig_md.tmp2 = judge_reg_2.execute(0);
	}    
	table table_judge_reg_2 {
		actions = {
			action_judge_reg_2;
		}
		size = 1;
		const default_action = action_judge_reg_2;
	}

	Register<bit<16>, bit<16>>(1) reg_3;
	RegisterAction<bit<16>, bit<1>, bit<16>>(reg_3) judge_reg_3 = {
		void apply(inout bit<16> value, out bit<16> output) {
			if(ig_md.tmp[15:15] == 1)	{
				output = 1;	
			}
			else {
				output = 0;
			}
		}
	};
	action action_judge_reg_3() {
		ig_md.tmp = judge_reg_3.execute(0);
	}
	table table_judge_reg_3 {
		actions = {
			action_judge_reg_3;
		}
		size = 1;
		const default_action = action_judge_reg_3;
	}



	apply {
		if(hdr.wisepifinder.isValid()) {

			action_set_dst_port();

			if(hdr.wisepifinder.recirc_flag == 0)  {

				table_read_fp1.apply();
				table_read_fp2.apply();
				table_read_fp3.apply();
				table_read_fp4.apply();

				table_read_sketch1_N.apply();
				table_read_sketch2_N.apply();
				table_read_sketch3_N.apply();
				table_read_sketch4_N.apply();

				action_set_recir_port();
				hdr.wisepifinder.recirc_flag = 1;

			}
			else {
				ig_md.tmp1 = hdr.wisepifinder.sketch2_N - hdr.wisepifinder.sketch1_N;
				ig_md.tmp2 = hdr.wisepifinder.sketch4_N - hdr.wisepifinder.sketch3_N;
				table_judge_reg_1.apply();
				table_judge_reg_2.apply();
				if(ig_md.tmp1 == 1) {
					// 1 > 2
					ig_md.num1 = 1;
					ig_md.tmp11 = hdr.wisepifinder.sketch2_N;
				}
				else {
					// 1 <= 2
					ig_md.num1 = 0;
					ig_md.tmp11 = hdr.wisepifinder.sketch1_N;
				}
				if(ig_md.tmp2 == 1) {
					// 3 > 4
					ig_md.num2 = 3;
					ig_md.tmp22 = hdr.wisepifinder.sketch4_N;
				}
				else {
					// 3 <= 4
					ig_md.num2 = 2;
					ig_md.tmp22 = hdr.wisepifinder.sketch3_N;
				}
				ig_md.tmp = ig_md.tmp22 - ig_md.tmp11;
				table_judge_reg_3.apply();
				if(ig_md.tmp == 1) {
					ig_md.num = ig_md.num2;
				}
				else {
					ig_md.num = ig_md.num1;
				}

				if (hdr.wisepifinder.fp_match_1 == 1) { ig_md.mew = 1; }
				else if(hdr.wisepifinder.fp_match_2 == 1) { ig_md.mew = 4; }
				else if(hdr.wisepifinder.fp_match_3 == 1) { ig_md.mew = 7; }
				else if(hdr.wisepifinder.fp_match_4 == 1) { ig_md.mew = 10; }
				else if(hdr.wisepifinder.fp_match_1 == 2) { ig_md.mew = 2; }
				else if(hdr.wisepifinder.fp_match_2 == 2) { ig_md.mew = 5; }
				else if(hdr.wisepifinder.fp_match_3 == 2) { ig_md.mew = 8; }
				else if(hdr.wisepifinder.fp_match_4 == 2) { ig_md.mew = 11; }
				else if(ig_md.num == 0) { ig_md.mew = 3; }
				else if(ig_md.num == 1) { ig_md.mew = 6; }
				else if(ig_md.num == 2) { ig_md.mew = 9; }
				else if(ig_md.num == 3) { ig_md.mew = 12; }

				if(ig_md.mew < 4) {
					table_write_fp1.apply();
					table_read_sketch1_last.apply();
					if(hdr.wisepifinder.sketch1_last == 0 || ig_md.mew > 1) {
						table_write_sketch1_N.apply();
					}
					table_write_sketch1_fsum.apply();
					table_write_sketch1_fpart.apply();
				}
				else if(ig_md.mew < 7) {
					table_write_fp2.apply();
					table_read_sketch2_last.apply();
					if(hdr.wisepifinder.sketch2_last == 0 || ig_md.mew > 4) {
						table_write_sketch2_N.apply();
					}
					table_write_sketch2_fsum.apply();
					table_write_sketch2_fpart.apply();
				}
				else if(ig_md.mew < 10) {
					table_write_fp3.apply();
					table_read_sketch3_last.apply();
					if(hdr.wisepifinder.sketch3_last == 0 || ig_md.mew > 7) {
						table_write_sketch3_N.apply();
					}
					table_write_sketch3_fsum.apply();
					table_write_sketch3_fpart.apply();
				}
				else if(ig_md.mew < 13) {
					table_write_fp4.apply();
					table_read_sketch4_last.apply();
					if(hdr.wisepifinder.sketch4_last == 0 || ig_md.mew > 10) {
						table_write_sketch4_N.apply();
					}
					table_write_sketch4_fsum.apply();
					table_write_sketch4_fpart.apply();
				}

			}
		}
	}
}

#endif
