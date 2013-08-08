`include "/misc/collaboration/382nGPS/382nG6/yhuang/misc.v"

module WB_STAGE(
	// input: global control signals
	CLK, 
	CLR, 
	PRE,
	
	// input: from LR
	L2W_code_segment,
	
	// input: from MEM
	M2W_mem_wt_r,
	
	// input: from EX
	E2W_v,
	E2W_e,
	E2W_cs,
	E2W_next_eip,
	E2W_current_eip,
	E2W_rel_eip,
	E2W_abs_eip,
	E2W_dest_gpr,
	E2W_src_gpr,
	E2W_result,
	E2W_new_eflags,
	E2W_mem_wt_addr,
	E2W_WR_PA1,
	E2W_WR_PA2,
	E2W_WR_PA3,
	E2W_S1,
	
	
	// output: to FE
	W2F_current_eip,
	W2F_exception_id,
	
	W2F_new_eip,
	W2F_eip_ld,	
	W2F_code_segment,
	W2F_br_taken,
	W2F_atomic,
	W2F_halt,
	W2F_load_code_segment,
	
	// outputs: to LR
	W2L_dest_gpr,
	W2L_src_gpr,
	W2L_dest_segr,
	W2L_dest_mmx,	
	W2L_dest_gpr_sel,
	W2L_src_gpr_sel,
	W2L_dest_segr_sel,
	W2L_dest_mmx_sel,
	W2L_dest_gpr_wt,
	W2L_src_gpr_wt,
	W2L_dest_segr_wt,
	W2L_dest_mmx_wt,
	W2L_dest_gpr_type,
	W2L_src_gpr_type,
	
	// outputs to PRE
	W2P_mem_wt_addr,
	W2P_mem_wt_size,
	W2P_mem_wt_en,
	
	// outputs: to MEM
	W2M_mem_wt_data,
	W2M_mem_wt_addr,
	W2M_mem_wt_size,
	W2M_mem_wt_en,
	W2M_WR_PA1,
	W2M_WR_PA2,
	W2M_WR_PA3,

	
	// output: to EX
	W2E_stall,
	W2E_eflags	
);
	
	//============================
	//
	//	IO Port Definition
	//
	//============================
		
	// input: global control signals
	input CLK; 
	input CLR; 
	input PRE;
	
	// input: from LR
	input[15:0] L2W_code_segment;
	
	// input: from MEM
	input M2W_mem_wt_r;
	
	// input: from EX
	input E2W_v;
	input[31:0] E2W_e;
	input[127:0] E2W_cs;
	input[31:0] E2W_next_eip;
	input[31:0] E2W_current_eip;
	input[31:0] E2W_rel_eip;
	input[31:0] E2W_abs_eip;
	input[31:0] E2W_dest_gpr;
	input[31:0] E2W_src_gpr;
	input[63:0] E2W_result;
	input[31:0] E2W_new_eflags;
	input[31:0] E2W_mem_wt_addr;
	input[31:0] E2W_WR_PA1;
	input[31:0] E2W_WR_PA2;
	input[31:0] E2W_WR_PA3;
	input[31:0] E2W_S1;
	
	
	// output: to FE
	output W2F_eip_ld;
	output W2F_br_taken;
	output[31:0] W2F_new_eip;
	output[31:0] W2F_current_eip;
	output[31:0] W2F_exception_id;
	output[15:0] W2F_code_segment;
	output W2F_atomic;
	output W2F_halt;
	output W2F_load_code_segment;
	
	
	
	

	// outputs: to LR
	output[31:0] W2L_dest_gpr;
	output[31:0] W2L_src_gpr;
	output[15:0] W2L_dest_segr;
	output[63:0] W2L_dest_mmx;
	output[2:0] W2L_dest_gpr_sel;
	output[2:0] W2L_src_gpr_sel;
	output[2:0] W2L_dest_segr_sel;
	output[2:0] W2L_dest_mmx_sel;
	output W2L_dest_gpr_wt;
	output W2L_src_gpr_wt;
	output W2L_dest_segr_wt;
	output W2L_dest_mmx_wt;
	output[1:0] W2L_dest_gpr_type;
	output[1:0] W2L_src_gpr_type;
	
	// outputs to PRE
	output[31:0] W2P_mem_wt_addr;
	output[31:0] W2P_mem_wt_size;
	output W2P_mem_wt_en;
	
	// outputs: to MEM
	output[63:0] W2M_mem_wt_data;
	output[31:0] W2M_mem_wt_addr;
	output[1:0] W2M_mem_wt_size;
	output W2M_mem_wt_en;
	output[31:0] W2M_WR_PA1;
	output[31:0] W2M_WR_PA2;
	output[31:0] W2M_WR_PA3;
	
	// output: to EX
	output W2E_stall;
	output[31:0] W2E_eflags;	
	
	
	//=============================
	//
	//	Control Signals
	//
	//=============================
	
	wire[2:0] eipmux_sel = {E2W_cs[`EIPMUX_SEL2], E2W_cs[`EIPMUX_SEL1], E2W_cs[`EIPMUX_SEL0]};
	wire[1:0] memmux_sel = E2W_cs[`MEMMUX_SEL];
	wire eflagsmux_sel = E2W_cs[`EFLAGSMUX_SEL];
	wire[1:0] data_type = E2W_cs[`DATA_TYPE];
	
	wire[1:0] ppmm = E2W_cs[`PPMM];

	
	wire dest_gpr_wt = E2W_cs[`DEST_GPR_WT];
	wire src_gpr_wt = E2W_cs[`SRC_GPR_WT];
	wire dest_segr_wt = E2W_cs[`DEST_SEGR_WT];
	wire dest_mmx_wt = E2W_cs[`DEST_MMX_WT];
	wire eflags_ld = E2W_cs[`LOAD_CC];
	wire eip_ld = E2W_cs[`EIP_LOAD];
	wire take_br = E2W_cs[`TAKE_BR];
	wire mem_wt_en = E2W_cs[`MEM_WRITE];
	wire cc_check_cf = E2W_cs[`CC_CF_CHECK];
	wire cc_check_zf = E2W_cs[`CC_ZF_CHECK];
	wire cc_cf = E2W_cs[`CC_CF];
	wire cc_zf = E2W_cs[`CC_ZF];
	wire load_code_segment = E2W_cs[`LOAD_CODE_SEGMENT];
	
	and2$ andHalt(W2F_halt, E2W_cs[`HLT], E2W_v);
	
	
	

	
	
	
	
	
	//=============================
	//
	//	Write Back Signal
	//
	//=============================	
	wire[31:0] eflags;
	wire eflags_ld_en;
	wire wb_en;
	wire has_exception;
	or2$ orHasException(has_exception, E2W_e[1], E2W_e[0]);
	WB_Condition_Logic logic0(	
		.cc_check_zf(cc_check_zf),
		.cc_zf(cc_zf),
		.zf(eflags[`ZF]),
		.cc_check_cf(cc_check_cf),
		.cc_cf(cc_cf),
		.cf(eflags[`CF]),
		.v(E2W_v),
		.e(has_exception),
		.wb_en(wb_en)
	);
	
	
	and2$ andWt[8:0](
		{W2L_dest_gpr_wt, W2L_src_gpr_wt, W2L_dest_segr_wt, W2L_dest_mmx_wt, W2M_mem_wt_en, eflags_ld_en, W2F_eip_ld, W2F_br_taken, W2F_load_code_segment},
		{dest_gpr_wt, src_gpr_wt, dest_segr_wt, dest_mmx_wt, mem_wt_en, eflags_ld, eip_ld, take_br, load_code_segment},
		wb_en
	);
	
	
	// to FE stage for control flow change
	mux2_16$ muxCodeSegment(W2F_code_segment, L2W_code_segment, W2L_dest_segr, W2F_load_code_segment);
	wire flow_change;
	or2$ orFlowChange(flow_change, W2F_load_code_segment, W2F_eip_ld);
	and2$ andAtomic(W2F_atomic, flow_change, E2W_cs[`SPLIT_INSTR]);
	
	and2$ andStall(W2E_stall, M2W_mem_wt_r, W2M_mem_wt_en);
	
	
	
	//mux4$ muxDestGprSel[1:0](W2L_dest_gpr_type, data_type, 2'b01, data_type, 2'b01, ppmm);
	//mux4$ muxSrcGprSel[1:0](W2L_src_gpr_type, data_type, data_type, 2'b01, 2'b01, ppmm);
	
	assign W2L_dest_gpr_sel = E2W_cs[`DEST_GPR_SEL];
	assign W2L_src_gpr_sel = E2W_cs[`SRC_GPR_SEL];
	assign W2L_dest_segr_sel = E2W_cs[`DEST_SEGR_SEL];
	assign W2L_dest_mmx_sel = E2W_cs[`DEST_MMX_SEL];
	
	assign W2L_dest_gpr_type = E2W_cs[`DEST_GPR_TYPE];
	assign W2L_src_gpr_type = E2W_cs[`SRC_GPR_TYPE];
	
	
	assign W2M_mem_wt_addr = E2W_mem_wt_addr;
	assign W2M_mem_wt_size = E2W_cs[`DATA_TYPE];
	
	
	
	assign W2P_mem_wt_addr = W2M_mem_wt_addr;
	assign W2P_mem_wt_size = W2M_mem_wt_size;
	and2$ andMemWtEn(W2P_mem_wt_en, W2M_mem_wt_en, M2W_mem_wt_r);
	
	
	
	
	//=============================
	//
	//	Registers
	//
	//=============================
	reg32e$ reg_eflags(CLK, E2W_new_eflags, eflags, , CLR, PRE, eflags_ld_en);
	
	
	//=============================
	//
	//	Data Select
	//
	//=============================
	wire is_normal, is_push, is_pop, is_movs;
	wire is_normal_bar, is_push_bar, is_pop_bar, is_movs_bar;
	decoder2_4$ decPPMM(ppmm, {is_movs, is_pop, is_push, is_normal}, {is_movs_bar, is_pop_bar, is_push_bar, is_normal_bar});
	
	mux4_32$ muxDestGpr(W2L_dest_gpr, E2W_result[31:0], E2W_dest_gpr, E2W_result[31:0], E2W_dest_gpr, ppmm);
	mux4_32$ muxSrcGpr(W2L_src_gpr, E2W_S1, E2W_S1, E2W_src_gpr, E2W_src_gpr, ppmm);
	mux4_16$ muxDestSegr(W2L_dest_segr, E2W_result[15:0], E2W_result[15:0], E2W_result[47:32], E2W_result[31:16], E2W_cs[`IDTR], eipmux_sel[2]);
	//assign W2L_dest_segr = E2W_result[15:0];
	assign W2L_dest_mmx = E2W_result;
	
	assign W2F_current_eip = E2W_current_eip;
	wire[31:0] eip_temp;
	mux8_32$ muxEip(
		W2F_new_eip, 
		E2W_next_eip, 
		E2W_rel_eip, 
		E2W_abs_eip, 
		E2W_result[31:0], 
		E2W_result[31:0], 
		{E2W_result[63:48], E2W_result[15:0]}, 
		eip_temp, 
		, 
		eipmux_sel);
	
	reg32e$ regEipTemp(CLK, W2F_new_eip, eip_temp, , CLR, PRE, W2F_eip_ld);
	
	//mux4_32$ muxEip(W2F_new_eip, E2W_next_eip, E2W_rel_eip, E2W_abs_eip, E2W_result[31:0], eipmux_sel);
	and2$ andExceptionId[1:0](W2F_exception_id[1:0], E2W_e[1:0], E2W_v);
	
	
	wire is_int;
	wire[1:0] new_memmux_sel;
	and2$ andMemmux(is_int, E2W_cs[`IDTR], E2W_e[`INT_OR_EXP]);
	mux2$ muxNewMemmux0(new_memmux_sel[0], memmux_sel[0], 1'b1, is_int),
		  muxNewMemmux1(new_memmux_sel[1], memmux_sel[1], 1'b0, is_int);
	
	mux8_32$ muxMem[1:0](W2M_mem_wt_data, 
		E2W_result, 
		{16'h0, E2W_result[15:0], E2W_next_eip}, 
		{32'h0, eflags}, 
		{16'h0, E2W_result[15:0], E2W_current_eip}, 
		{32'h0, 16'h0, E2W_result[15:0]},
		{32'h0, 16'h0, E2W_result[15:0]},
		{32'h0, 16'h0, E2W_result[15:0]},
		{32'h0, 16'h0, E2W_result[15:0]},
		{E2W_cs[102], new_memmux_sel});
	
	mux4_32$ muxEflags(W2E_eflags, eflags, eflags, E2W_new_eflags, E2W_result[31:0], {eflags_ld_en, eflagsmux_sel});
	
	assign W2M_WR_PA1 = E2W_WR_PA1;
	assign W2M_WR_PA2 = E2W_WR_PA2;
	assign W2M_WR_PA3 = E2W_WR_PA3;
	

	
				
endmodule

module WB_Condition_Logic(
	cc_check_zf,
	cc_zf,
	zf,
	cc_check_cf,
	cc_cf,
	cf,
	v,
	e,
	wb_en
);

	input zf, cf, cc_check_zf, cc_check_cf, cc_zf, cc_cf;
	input v, e;
	output wb_en;
	
	/*wire zf_match, cf_match, zf_en_bar, cf_en_bar, uncond_en_bar, flag_en;
	wire check_cf_bar, check_zf_bar;
	wire e_bar;*/

	wire zf_match_bar, cf_match_bar;
	xor2$ xorCfMatchBar(cf_match_bar, cc_cf, cf);
	xor2$ xorZfMatchBar(zf_match_bar, cc_zf, zf);
	
	wire zf_en_bar, cf_en_bar, exp_en_bar, v_en_bar;
	nand2$ nandZfEnBar(zf_en_bar, cc_check_zf, zf_match_bar);
	nand2$ nandCfEnBar(cf_en_bar, cc_check_cf, cf_match_bar);
	inv1$ invExpEnBar(exp_en_bar, e);
	//inv1$ invVEnBar(v_en_bar, v);
	and4$ andWbEn(wb_en, zf_en_bar, cf_en_bar, exp_en_bar, v);
	
	/*
	inv1$ invCheckCfBar(check_cf_bar, cc_check_cf);
	inv1$ invCheckZfBar(check_zf_bar, cc_check_zf);
	xnor2$ xnorZfMatch(zf_match, cc_zf, zf);
	xnor2$ xnorCfMatch(cf_match, cc_cf, cf);
	nand2$ nandZfEn(zf_en_bar, zf_match, cc_check_zf);
	nand2$ nandCfEn(cf_en_bar, cf_match, cc_check_cf);
	nand2$ nandUncondEn(uncond_en_bar, check_cf_bar, check_zf_bar);
	nand3$ nandFlgaEn(flag_en, uncond_en_bar, zf_en_bar, cf_en_bar);
	inv1$ invEBar(e_bar, e);
	and3$ andWbEn(wb_en, flag_en, v, e_bar);*/
	
endmodule

module WB_Pipeline_Logic(mem_wt_en, mem_wt_r, v, ld, stall);
	input mem_wt_en, mem_wt_r, v;
	output ld, stall;
	
	wire not_v, not_mem_wt_en;
	inv1$ inv0(not_v, v);
	inv1$ inv1(not_mem_wt_en, mem_wt_en);
	nor3$ nor2(stall, mem_wt_r, not_v, not_mem_wt_en);
	inv1$ inv3(ld, stall);
endmodule




