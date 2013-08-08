`include "/misc/collaboration/382nGPS/382nG6/yhuang/misc.v"

module EX_STAGE(
	// inputs: global control
	CLK,
	CLR,
	PRE,
	
	// inputs from FE
	F2E_flush,
	
	// inputs: from MEM
	M2E_v,
	M2E_e,
	M2E_cs,
	M2E_next_eip,
	M2E_current_eip,
	M2E_rel_eip,
	M2E_dest_gpr,
	M2E_dest_segr,
	M2E_dest_mmx,
	M2E_src_gpr,
	M2E_src_segr,
	M2E_src_mmx,
	M2E_imm,
	M2E_disp,
	M2E_mem_data,
	M2E_mem_wt_addr,
	M2E_PCD,
	M2E_WR_PA1,
	M2E_WR_PA2,
	M2E_WR_PA3,
	
	// inputs: from WB
	W2E_stall,
	W2E_eflags,
	
	// outputs: to LR
	E2L_dest_gpr_sel,
	E2L_src_gpr_sel,
	E2L_dest_segr_sel,
	E2L_dest_mmx_sel,
	E2L_dest_gpr_wt,
	E2L_src_gpr_wt,
	E2L_dest_segr_wt,
	E2L_dest_mmx_wt,
	E2L_dest_gpr_type,
	E2L_src_gpr_type,
	E2L_set_cc,
	
	// outputs to PRE
	E2P_mem_wt_addr,
	E2P_mem_wt_size,
	E2P_mem_wt_en,
	
	// outputs: to MEM
	E2M_stall,
	
	// outputs: to WB
	E2W_v,
	E2W_e,
	E2W_cs,
	E2W_next_eip,
	E2W_disp,
	E2W_current_eip,
	E2W_rel_eip,
	E2W_dest_gpr,
	E2W_src_gpr,
	E2W_result,
	E2W_new_eflags,
	E2W_mem_wt_addr,
	E2W_WR_PA1,
	E2W_WR_PA2,
	E2W_WR_PA3,
	E2W_S1
);
	
	//===============================	
	//
	//	IO port definition
	//
	//===============================
	
	// inputs: global control
	input CLK;
	input CLR;
	input PRE;
	
	input F2E_flush;
	
	// inputs: from MEM
	input M2E_v;
	input[31:0] M2E_e;
	input[127:0] M2E_cs;
	input[31:0] M2E_next_eip;
	input[31:0] M2E_current_eip;
	input[31:0] M2E_rel_eip;
	input[31:0] M2E_dest_gpr;
	input[15:0] M2E_dest_segr;
	input[63:0] M2E_dest_mmx;
	input[31:0] M2E_src_gpr;
	input[15:0] M2E_src_segr;
	input[63:0] M2E_src_mmx;
	input[31:0] M2E_imm;
	input[31:0] M2E_disp;
	input[63:0] M2E_mem_data;
	input[31:0] M2E_mem_wt_addr;
	input M2E_PCD;
	input[31:0] M2E_WR_PA1;
	input[31:0] M2E_WR_PA2;
	input[31:0] M2E_WR_PA3;
	
	// inputs: from WB
	input W2E_stall;
	input[31:0] W2E_eflags;
	
	// outputs: to LR
	output[2:0] E2L_dest_gpr_sel;
	output[2:0] E2L_src_gpr_sel;
	output[2:0] E2L_dest_segr_sel;
	output[2:0] E2L_dest_mmx_sel;
	output E2L_dest_gpr_wt;
	output E2L_src_gpr_wt;
	output E2L_dest_segr_wt;
	output E2L_dest_mmx_wt;
	output[1:0] E2L_dest_gpr_type;
	output[1:0]E2L_src_gpr_type;
	output E2L_set_cc;
	
	// outputs: to PRE
	output[31:0] E2P_mem_wt_addr;
	output[1:0] E2P_mem_wt_size;
	output E2P_mem_wt_en;
	
	// outputs: to MEM
	output E2M_stall;
	
	// outputs: to WB
	output E2W_v;
	output[31:0] E2W_e;
	output[127:0] E2W_cs;
	output[31:0] E2W_next_eip;
	output[31:0] E2W_current_eip;
	output[31:0] E2W_rel_eip;
	output[31:0] E2W_dest_gpr;
	output[31:0] E2W_src_gpr;
	output[63:0] E2W_result;
	output[31:0] E2W_new_eflags;
	output[31:0] E2W_mem_wt_addr;
	output[31:0] E2W_disp;
	output[31:0] E2W_WR_PA1;
	output[31:0] E2W_WR_PA2;
	output[31:0] E2W_WR_PA3;
	output[31:0] E2W_S1;

	
	
	//===============================
	//
	//	Control Signal
	//
	//===============================
		
	// wires for control signals
	wire[2:0] s1mux_sel = {M2E_cs[94], M2E_cs[`S1MUX_SEL]};
	wire[2:0] s2mux_sel = M2E_cs[`S2MUX_SEL];
	wire mod_exist = M2E_cs[`MOD_EXIST];
	wire mem_at_src = M2E_cs[`ADDRESS_MODE_RM];
	wire mem_at_dst;
	inv1$ invMemAtDst(mem_at_dst, mem_at_src);
	wire mem_read = M2E_cs[`MEM_READ];
	wire mem_write = M2E_cs[`MEM_WRITE];
	wire std = M2E_cs[`STD];
	wire cld = M2E_cs[`CLD];


	
	wire[1:0] data_type = M2E_cs[`DATA_TYPE];
	wire[1:0] shf_op = M2E_cs[`SHF_OP];
	wire[2:0] alu_op = M2E_cs[`ALU_OP];
	wire resultmux_sel = M2E_cs[`RESULTMUX_SEL];
	
	
	
	
	//wire eflags_set_sel = M2E_cs[`EFLAGS_SET_SEL];
	//wire new_df = M2E_cs[`NEW_DF];
	
	//================================
	//
	//	Operand Select
	//
	//================================
	wire s1_is_mem, s2_is_mem;
	wire[2:0] s1mux_sel_adj, s2mux_sel_adj; 
	wire[63:0] s1mux_out, s2mux_out, s1, s2;
	
	and3$ andS1IsMem(s1_is_mem, mod_exist, mem_at_dst, mem_write);
	and3$ andS2IsMem(s2_is_mem, mod_exist, mem_at_src, mem_read);
	//and2$ andS1IsMem(s1_is_mem, mod_exist, mem_at_dst, mem_write);
	//and2$ andS2IsMem(s2_is_mem, mod_exist, mem_at_src, mem_read);
	
	
	mux2$ muxS1SelAdj[2:0](s1mux_sel_adj, s1mux_sel, 3'b011, s1_is_mem);
	mux2$ muxS2SelAdj[2:0](s2mux_sel_adj, s2mux_sel, 3'b011, s2_is_mem);
	
	wire[2:0] s1mux_sel_adj2, s2mux_sel_adj2;
	wire is_shuf_and_mem;
	and3$ and_is_shuf(is_shuf_and_mem, shf_op[1], shf_op[0], s2_is_mem);
	mux2$ muxS1SelAdj2[2:0](s1mux_sel_adj2, s1mux_sel_adj, 3'b011, is_shuf_and_mem);
	mux2$ muxS2SelAdj2[2:0](s2mux_sel_adj2, s2mux_sel_adj, 3'b100, is_shuf_and_mem);
	
	
	
	
	mux8_32$ muxS1[1:0](
		s1mux_out, 
		{32'h0, M2E_dest_gpr}, 
		{48'h0, M2E_dest_segr}, 
		M2E_dest_mmx, 
		M2E_mem_data, 
		M2E_src_mmx, 
		, 
		, 
		, 
		s1mux_sel_adj2);
		
	mux8_32$ muxS2[1:0](
		s2mux_out, 
		{32'h0, M2E_src_gpr}, 
		{48'h0, M2E_src_segr}, 
		M2E_src_mmx, 
		M2E_mem_data, 
		{32'h0, M2E_imm}, 
		64'h1, 
		-64'h1, 
		, 
		s2mux_sel_adj2);
	
	SEXT64$ sextS1(s1mux_out, data_type, s1, );
	SEXT64$ sextS2(s2mux_out, data_type, s2, );
	
	
	//=================================
	//
	//	Functional Units
	//
	//=================================
	wire[63:0] shf_result, alu_result;
	wire[31:0] alu_cout;
	wire[3:0] shf_out;
	
	SHF shf(s1, s2[7:0], shf_op, shf_result, shf_out);
	ALU alu(s1, s2, alu_op, W2E_eflags, alu_result, alu_cout);
	
	//=================================
	//
	//	Result Select
	//
	//=================================
	wire[63:0] resultmux_out, result;
	mux2_32$ muxResult[1:0](resultmux_out, alu_result, shf_result, resultmux_sel);
	SEXT64$ sextResult(resultmux_out, data_type, result, );
	
	//===================================
	//
	//	EFLAGS Logic
	//
	//===================================
	wire[31:0] new_eflags;
	EX_EFLAGS_Logic logic0(
		.new_eflags(new_eflags),
		.old_eflags(W2E_eflags),
		.alu_result(alu_result[31:0]),
		.alu_cout(alu_cout),
		.shf_result(shf_result[31:0]),
		.shf_out(shf_out),
		.source1(s1[31:0]),
		.source2(s2[31:0]),
		.data_type(data_type),
		.std(std),
		.cld(cld),
		.resultmux_sel(resultmux_sel)
	);
	
	//====================================
	//
	//	Pipeline Logic
	//
	//====================================
    wire v;
	EX_Pipeline_Logic logic1(
		.W2E_stall(W2E_stall),
		.F2E_flush(F2E_flush),
		.M2E_v(M2E_v),
		.E2M_stall(E2M_stall),
		.E2W_v(v),
		.E2W_ld(ex_ld)
	);
	
	//==================================
	//
	//	Pipeline Registers
	//
	//==================================

    wire[30:0] v_padd;
	
	reg32e$ reg_v(CLK, {31'h0, v}, {v_padd, E2W_v}, , CLR, PRE, ex_ld);
	reg32e$ reg_e(CLK, M2E_e, E2W_e, , CLR, PRE, ex_ld);
	reg32e$ reg_cs[3:0](CLK, M2E_cs, E2W_cs, , CLR, PRE, ex_ld);
	reg32e$ reg_next_eip(CLK, M2E_next_eip, E2W_next_eip, , CLR, PRE, ex_ld);
	reg32e$ reg_current_eip(CLK, M2E_current_eip, E2W_current_eip, , CLR, PRE, ex_ld);
	reg32e$ reg_rel_eip(CLK, M2E_rel_eip, E2W_rel_eip, , CLR, PRE, ex_ld);
	reg32e$ reg_dest_gpr(CLK, M2E_dest_gpr, E2W_dest_gpr, , CLR, PRE, ex_ld);
	reg32e$ reg_src_gpr(CLK, M2E_src_gpr, E2W_src_gpr, , CLR, PRE, ex_ld);
	reg32e$ reg_result[1:0](CLK, result, E2W_result, , CLR, PRE, ex_ld);
	reg32e$ reg_new_eflags(CLK, new_eflags, E2W_new_eflags, , CLR, PRE, ex_ld);
	reg32e$ reg_mem_wt_addr(CLK, M2E_mem_wt_addr, E2W_mem_wt_addr, , CLR, PRE, ex_ld);
	reg32e$ reg_disp(CLK, M2E_disp, E2W_disp, , CLR, PRE, ex_ld);
	reg32e$ reg_pa1(CLK, M2E_WR_PA1, E2W_WR_PA1, , CLR, PRE, ex_ld);
	reg32e$ reg_pa2(CLK, M2E_WR_PA2, E2W_WR_PA2, , CLR, PRE, ex_ld);
	reg32e$ reg_pa3(CLK, M2E_WR_PA3, E2W_WR_PA3, , CLR, PRE, ex_ld);
	reg32e$ reg_s1(CLK, s1[31:0], E2W_S1, , CLR, PRE, ex_ld);
	
	
	
	//============================
	//
	//	CS Forwarding
	//
	//============================
	assign E2L_dest_gpr_sel = M2E_cs[`DEST_GPR_SEL];
	assign E2L_src_gpr_sel = M2E_cs[`SRC_GPR_SEL];
	assign E2L_dest_segr_sel = M2E_cs[`DEST_SEGR_SEL];
	assign E2L_dest_mmx_sel = M2E_cs[`DEST_MMX_SEL];
	and2$ andDestGprWt(E2L_dest_gpr_wt, M2E_v, M2E_cs[`DEST_GPR_WT]);
	and2$ andSrcGprWt(E2L_src_gpr_wt, M2E_v, M2E_cs[`SRC_GPR_WT]);
	and2$ andDestSegrWt(E2L_dest_segr_wt, M2E_v, M2E_cs[`DEST_SEGR_WT]);
	and2$ andDestMmxWt(E2L_dest_mmx_wt, M2E_v, M2E_cs[`DEST_MMX_WT]);
	assign E2L_dest_gpr_type = M2E_cs[`DEST_GPR_TYPE];
	assign E2L_src_gpr_type = M2E_cs[`SRC_GPR_TYPE];
	
	assign E2P_mem_wt_addr = M2E_mem_wt_addr;
	assign E2P_mem_wt_size = M2E_cs[`DATA_TYPE];
	and2$ andMemWtEn(E2P_mem_wt_en, M2E_v, M2E_cs[`MEM_WRITE]);
	and2$ andSetCC(E2L_set_cc, M2E_v, M2E_cs[`LOAD_CC]);
	

endmodule


module EX_Pipeline_Logic(
	W2E_stall,
	F2E_flush,
	M2E_v,
	E2M_stall,
	E2W_v,
	E2W_ld
);

	input W2E_stall, F2E_flush, M2E_v;
	output E2W_ld, E2M_stall, E2W_v;
	
	
	wire w0, w1, w2;
	wire flush_bar;
	
	inv1$ inv0(E2W_ld, W2E_stall);
	inv1$ inv1(flush_bar, F2E_flush);
	and2$ and2(E2W_v, M2E_v, flush_bar);
	and3$ and3(E2M_stall, W2E_stall, M2E_v, flush_bar);

endmodule

module EX_EFLAGS_Logic(
	new_eflags,
	old_eflags,
	alu_result,
	alu_cout,
	shf_result,
	shf_out,
	source1,
	source2,
	data_type,
	std,
	cld,
	resultmux_sel
);
	output[31:0] new_eflags;
	input[31:0] old_eflags;
	input[31:0] alu_result;
	input[31:0] alu_cout;
	input[31:0] shf_result;
	input[3:0] shf_out;
	input[31:0] source1;
	input[31:0] source2;
	input[1:0] data_type;
	input std, cld;
	input resultmux_sel;

	
	wire new_zf, new_pf, new_sf, new_cf, new_af, new_of;
	wire eflags_set_sel;
	wire new_df;
	
	or2$ orESS(eflags_set_sel, std, cld);
	assign new_df = std;
	
	
	wire[31:0] result, result_temp;
	
	
	
	mux2_32$ resultMux(result_temp, alu_result, shf_result, resultmux_sel);
	mux4_32$ resultExtMux(
		result, 
		{{24{result_temp[7]}}, result_temp[7:0]},
		{{16{result_temp[15]}}, result_temp[15:0]},
		result_temp,
		result_temp,
		data_type
	);
	
	
	
	//==============================
	//	ZF
	//==============================
	wire[15:0] zf0, zf1, zf2, zf3, zf4;
	or2$ orZF1[15:0](zf0, result[31:16], result[15:0]);
	or2$ orZF2[7:0](zf1[7:0], zf0[15:8], zf0[7:0]);
	or2$ orZF3[3:0](zf2[3:0], zf1[7:4], zf1[3:0]);
	or2$ orZF4[1:0](zf3[1:0], zf2[3:2], zf2[1:0]);
	nor2$ norZF(new_zf, zf3[1], zf3[0]);
	
	//id_comp32$ compZero(result, 32'h0, new_zf, );
	
	//==============================
	//	PF
	//==============================
	parity8$ parity(result[7:0], , new_pf);
	
	//==============================
	//	SF
	//==============================
	mux4$ signMux(new_sf, result[7], result[15], result[31], 1'b0, data_type[0], data_type[1]);
	
	//==============================
	//	CF
	//==============================
	wire alu_cf, shf_cf;
	mux4$ alucarryMux(alu_cf, alu_cout[7], alu_cout[15], alu_cout[31], 1'b0, data_type[0], data_type[1]);
	mux4$ shfcarryMux(shf_cf, shf_out[0], shf_out[1], shf_out[2], shf_out[3], data_type[0], data_type[1]);
	mux2$ carryMux(new_cf, alu_cf, shf_cf, resultmux_sel);
	
	//TODO: special case of shifting 0
	
	//==============================
	//	AF
	//==============================
	assign new_af = alu_cout[3];
	
	//==============================
	//	OF
	//==============================
	wire alu_of, shf_of;
	wire s1_sign, s2_sign, res_sign;
	mux4$ s1signMux(s1_sign, source1[7], source1[15], source1[31], 1'b0, data_type[0], data_type[1]),
		  s2signMux(s2_sign, source2[7], source2[15], source2[31], 1'b0, data_type[0], data_type[1]);
	assign res_sign = new_sf;
	overflow$ aluOver(res_sign, s1_sign, s2_sign, alu_of),
			  shfOver(res_sign, s1_sign, s1_sign, shf_of);
	mux2$ overflowMux(new_of, alu_of, shf_of, resultmux_sel);
	
		
	
	
	//==============================
	//	New CC
	//==============================
	wire[31:0] arith_eflags, setclear_eflags;
	
	assign arith_eflags = {old_eflags[31:12], new_of, old_eflags[10:8], new_sf, new_zf, old_eflags[5], new_af, old_eflags[3], new_pf, old_eflags[1], new_cf};
	assign setclear_eflags = {old_eflags[31:11], new_df, old_eflags[9:0]};
	
	mux2$ eflagsMux[31:0](new_eflags, arith_eflags, setclear_eflags, eflags_set_sel);
	
		
endmodule

module parity8$(s, odd, even);
	input[7:0] s;
	output odd, even;
	
	wire[3:0] w0;
	wire[1:0] w1;
	
	xor2$ xor0[3:0](w0, s[7:4], s[3:0]),
		  xor1[1:0](w1, w0[3:2], w0[1:0]),
		  xor2(odd, w1[1], w1[0]);
	
	inv1$ inv0(even, odd);
	  
		
		  
endmodule


module overflow$(res_neg, s1_neg, s2_neg, overflow);
	input res_neg, s1_neg, s2_neg;
	output overflow;
		
	wire res_pos;
	wire both_neg, both_pos;
	wire neg_over, pos_over;
	
	inv1$ inv0(res_pos, res_neg);
	and2$ and0(both_neg, s1_neg, s2_neg);
	and2$ and1(neg_over, both_neg, res_pos);
	
	nor2$ nor0(both_pos, s1_neg, s2_neg);
	and2$ and2(pos_over, both_pos, res_neg);
	
	or2$ or0(overflow, neg_over, pos_over);	
endmodule


