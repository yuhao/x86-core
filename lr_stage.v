`include "/misc/collaboration/382nGPS/382nG6/yhuang/misc.v"
/*
module TOP;
	reg CLK;
	reg F2L_flush;
	reg D2L_v;
	reg[127:0] D2L_cs;
	reg A2L_stall;
	
	
	

	wire L2D_stall;
	wire L2A_v;
	
	
	LR_Stage lr_stage(
		.CLK(CLK),
		.CLR(1'b1),
		.PRE(1'b1),
		
		.F2L_flush(F2L_flush),
		.D2L_v(D2L_v),
		.D2L_cs(D2L_cs),
		.A2L_stall(A2L_stall),
		
		.A2L_dest_gpr_wt(1'b0),
		.A2L_src_gpr_wt(1'b0),
		.A2L_dest_segr_wt(1'b0),
		.A2L_dest_mmx_wt(1'b0),
		.P2L_dest_gpr_wt(1'b0),
		.P2L_src_gpr_wt(1'b0),
		.P2L_dest_segr_wt(1'b0),
		.P2L_dest_mmx_wt(1'b0),
		.M2L_dest_gpr_wt(1'b0),
		.M2L_src_gpr_wt(1'b0),
		.M2L_dest_segr_wt(1'b0),
		.M2L_dest_mmx_wt(1'b0),
		.E2L_dest_gpr_wt(1'b0),
		.E2L_src_gpr_wt(1'b0),
		.E2L_dest_segr_wt(1'b0),
		.E2L_dest_mmx_wt(1'b0),
		.W2L_src_gpr_wt(1'b0),
		.W2L_dest_segr_wt(1'b0),
		.W2L_dest_mmx_wt(1'b0),
		
		.W2L_dest_gpr_wt(W2L_dest_gpr_wt),
		.W2L_dest_gpr_sel(W2L_dest_gpr_sel),
		.W2L_dest_gpr_type(W2L_dest_gpr_type),
		.W2L_dest_gpr(W2L_dest_gpr)
		
		
);
	
	
	initial
	begin
	   $dumpfile ("./lr_stage.dump");
	   $dumpvars (0, TOP);
	end
	
endmodule
*/

module LR_Stage(
	// global signal
	CLK, 
	CLR, 
	PRE,
	
	// from FE stage
	F2L_flush,
		
	// from DE stage
	D2L_v,
	D2L_cs,
	D2L_e,
	D2L_next_eip,
	D2L_current_eip,
	D2L_disp,
	D2L_imm,
	D2L_vector,
	
	
	// to DE stage
	L2D_stall,
	L2D_count_zero,
	
	// to AG stage
	L2A_v,
	L2A_e,
	L2A_cs,
	L2A_next_eip,
	L2A_current_eip,
	L2A_disp,
	L2A_imm,
	L2A_dest_gpr,
	L2A_dest_gpr_old,
	L2A_src_gpr,
	L2A_src_gpr_old,
	L2A_base_gpr,
	L2A_index_gpr,
	L2A_dest_segr,
	L2A_src_segr,
	L2A_segment_segr,
	L2A_dest_mmx,
	L2A_src_mmx,
	L2A_vector,
	
	// to WB
	L2W_code_segment,
	
	// from AG, for stall check
	A2L_stall,
	
	// from AG, for dep check
	A2L_dest_gpr_sel,
	A2L_src_gpr_sel,
	A2L_dest_segr_sel,
	A2L_dest_mmx_sel,
	A2L_dest_gpr_wt,
	A2L_src_gpr_wt,
	A2L_dest_segr_wt,
	A2L_dest_mmx_wt,
	A2L_dest_gpr_type,
	A2L_src_gpr_type,
	A2L_set_cc,
	
	// from PRE, for dep check
	P2L_dest_gpr_sel,
	P2L_src_gpr_sel,
	P2L_dest_segr_sel,
	P2L_dest_mmx_sel,
	P2L_dest_gpr_wt,
	P2L_src_gpr_wt,
	P2L_dest_segr_wt,
	P2L_dest_mmx_wt,
	P2L_dest_gpr_type,
	P2L_src_gpr_type,	
	P2L_set_cc,
		
	// from MEM, for dep check
	M2L_dest_gpr_sel,
	M2L_src_gpr_sel,
	M2L_dest_segr_sel,
	M2L_dest_mmx_sel,
	M2L_dest_gpr_wt,
	M2L_src_gpr_wt,
	M2L_dest_segr_wt,
	M2L_dest_mmx_wt,	
	M2L_dest_gpr_type,
	M2L_src_gpr_type,
	M2L_set_cc,
	
	// from EX, for dep check
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
	
	// from WB, for dep check
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
	
	// from WB, for register write back
	W2L_dest_gpr,
	W2L_src_gpr,
	W2L_dest_segr,
	W2L_dest_mmx,
	
	// from WB, for increment direction
	W2L_eflags,
	
	gpr0, 
	gpr1, 
	gpr2, 
	gpr3, 
	gpr4, 
	gpr5, 
	gpr6, 
	gpr7,
	
	segr0, 
	segr1, 
	segr2, 
	segr3, 
	segr4, 
	segr5, 
	segr6, 
	segr7,
	
	mmx0, 
	mmx1, 
	mmx2, 
	mmx3, 
	mmx4, 
	mmx5, 
	mmx6, 
	mmx7
	
	
	
);

	// global signal
	input CLK, CLR, PRE;
	
	// from FE stage
	input F2L_flush;
	
	
	
	// from DE stage
	input D2L_v;
	input[127:0] D2L_cs;
	input[31:0] D2L_e;
	input[31:0] D2L_next_eip;
	input[31:0] D2L_current_eip;
	input[31:0] D2L_disp;
	input[31:0] D2L_imm;
	input[3:0] D2L_vector;
	
	

	
	// to DE stage
	output L2D_stall;
	output L2D_count_zero;
	
	// to AG stage
	output L2A_v;
	output[127:0] L2A_cs;
	output[31:0] L2A_e;
	output[31:0] L2A_next_eip;
	output[31:0] L2A_current_eip;
	output[31:0] L2A_disp;
	output[31:0] L2A_imm;
	output[31:0] L2A_dest_gpr;
	output[31:0] L2A_dest_gpr_old;
	output[31:0] L2A_src_gpr;
	output[31:0] L2A_src_gpr_old;
	output[31:0] L2A_base_gpr;
	output[31:0] L2A_index_gpr;
	output[15:0] L2A_dest_segr;
	output[15:0] L2A_src_segr;
	output[15:0] L2A_segment_segr;
	output[63:0] L2A_dest_mmx;
	output[63:0] L2A_src_mmx;
	output[3:0] L2A_vector;
	
	// to WB stage
	output[15:0] L2W_code_segment;
	
	// from AG; for stall check
	input A2L_stall;
	
	// from AG; for dep check
	input[2:0] A2L_dest_gpr_sel;
	input[2:0] A2L_src_gpr_sel;
	input[2:0] A2L_dest_segr_sel;
	input[2:0] A2L_dest_mmx_sel;
	input A2L_dest_gpr_wt;
	input A2L_src_gpr_wt;
	input A2L_dest_segr_wt;
	input A2L_dest_mmx_wt;
	input[1:0] A2L_dest_gpr_type;
	input[1:0] A2L_src_gpr_type;
	input A2L_set_cc;
	
	// from PRE; for dep check
	input[2:0] P2L_dest_gpr_sel;
	input[2:0] P2L_src_gpr_sel;
	input[2:0] P2L_dest_segr_sel;
	input[2:0] P2L_dest_mmx_sel;
	input P2L_dest_gpr_wt;
	input P2L_src_gpr_wt;
	input P2L_dest_segr_wt;
	input P2L_dest_mmx_wt;	
	input[1:0] P2L_dest_gpr_type;
	input[1:0] P2L_src_gpr_type;
	input P2L_set_cc;
	
	// from MEM; for dep check
	input[2:0] M2L_dest_gpr_sel;
	input[2:0] M2L_src_gpr_sel;
	input[2:0] M2L_dest_segr_sel;
	input[2:0] M2L_dest_mmx_sel;
	input M2L_dest_gpr_wt;
	input M2L_src_gpr_wt;
	input M2L_dest_segr_wt;
	input M2L_dest_mmx_wt;	
	input[1:0] M2L_dest_gpr_type;
	input[1:0] M2L_src_gpr_type;
	input M2L_set_cc;
	
	// from EX; for dep check
	input[2:0] E2L_dest_gpr_sel;
	input[2:0] E2L_src_gpr_sel;
	input[2:0] E2L_dest_segr_sel;
	input[2:0] E2L_dest_mmx_sel;
	input E2L_dest_gpr_wt;
	input E2L_src_gpr_wt;
	input E2L_dest_segr_wt;
	input E2L_dest_mmx_wt;
	input[1:0] E2L_dest_gpr_type;
	input[1:0] E2L_src_gpr_type;
	input E2L_set_cc;
	
	// from WB; for dep check
	input[2:0] W2L_dest_gpr_sel;
	input[2:0] W2L_src_gpr_sel;
	input[2:0] W2L_dest_segr_sel;
	input[2:0] W2L_dest_mmx_sel;
	input W2L_dest_gpr_wt;
	input W2L_src_gpr_wt;
	input W2L_dest_segr_wt;
	input W2L_dest_mmx_wt;
	input[1:0] W2L_dest_gpr_type;
	input[1:0] W2L_src_gpr_type;	
	
	// from WB, for register write back
	input[31:0] W2L_dest_gpr;
	input[31:0] W2L_src_gpr;
	input[15:0] W2L_dest_segr;
	input[63:0] W2L_dest_mmx;
	
	// from WB, for increment direction
	input[31:0] W2L_eflags;
	
	output[31:0]gpr0, gpr1, gpr2, gpr3, gpr4, gpr5, gpr6, gpr7;
	output[15:0] segr0, segr1, segr2, segr3, segr4, segr5, segr6, segr7;
	output[63:0] mmx0, mmx1, mmx2, mmx3, mmx4, mmx5, mmx6, mmx7;
	
	//============================
	//
	//	Internal Connections
	//
	//============================
	
	wire[127:0] cs;
	assign cs[127:23] = D2L_cs[127:23];
	assign cs[18:0]	= D2L_cs[18:0];
	mux2$ muxDstDataType[1:0](cs[`DST_DATA_TYPE], D2L_cs[`DST_DATA_TYPE], D2L_cs[`DATA_TYPE], D2L_cs[`FORCE_DST_DATA]);
	mux2$ muxSrcDataType[1:0](cs[`SRC_DATA_TYPE], D2L_cs[`SRC_DATA_TYPE], D2L_cs[`DATA_TYPE], D2L_cs[`FORCE_SRC_DATA]);
	mux2$ muxDstMMXSel[1:0](cs[`DST_DATA_TYPE], D2L_cs[`DST_DATA_TYPE], D2L_cs[`DATA_TYPE], D2L_cs[`FORCE_DST_DATA]);
	mux2$ muxSrcMMXSel[1:0](cs[`SRC_DATA_TYPE], D2L_cs[`SRC_DATA_TYPE], D2L_cs[`DATA_TYPE], D2L_cs[`FORCE_SRC_DATA]);
	
	
	// data
	wire[31:0] dest_gpr, src_gpr, base_gpr, index_gpr;
	wire[31:0] dest_gpr_old, src_gpr_old, base_gpr_old;
	wire[15:0] dest_segr, src_segr, segment_segr;
	wire[63:0] dest_mmx, src_mmx;
	wire[31:0] df_inc, auto_inc, auto_inc_scaled;
	
	
	// control signals
	wire[2:0] dest_gpr_sel = D2L_cs[`DEST_GPR_SEL];
	wire[2:0] src_gpr_sel = D2L_cs[`SRC_GPR_SEL];
	wire[2:0] base_gpr_sel = D2L_cs[`BASE_GPR_SEL];
	wire[2:0] index_gpr_sel = D2L_cs[`INDEX_GPR_SEL];
	wire[2:0] dest_segr_sel = D2L_cs[`DEST_SEGR_SEL];
	wire[2:0] src_segr_sel = D2L_cs[`SRC_SEGR_SEL];
	wire[2:0] segment_segr_sel = D2L_cs[`SEGMENT_SEGR_SEL];
	wire[2:0] dest_mmx_sel = D2L_cs[`DEST_MMX_SEL];
	wire[2:0] src_mmx_sel = D2L_cs[`SRC_MMX_SEL];
	
	wire dest_gpr_rd = D2L_cs[`DEST_GPR_RD];
	wire src_gpr_rd = D2L_cs[`SRC_GPR_RD];
	wire base_gpr_rd = D2L_cs[`BASE_GPR_RD];
	wire index_gpr_rd = D2L_cs[`INDEX_GPR_RD];
	wire dest_segr_rd = D2L_cs[`DEST_SEGR_RD];
	wire src_segr_rd = D2L_cs[`SRC_SEGR_RD];
	wire segment_segr_rd = D2L_cs[`SEGMENT_SEGR_RD];
	wire dest_mmx_rd = D2L_cs[`DEST_MMX_RD];
	wire src_mmx_rd = D2L_cs[`SRC_MMX_RD];
	
	wire[1:0] dest_gpr_type = cs[`DEST_GPR_TYPE];
	wire[1:0] src_gpr_type = cs[`SRC_GPR_TYPE];
	wire[1:0] data_type = D2L_cs[`DATA_TYPE];
	
	wire[2:0] auto_inc_sel = {D2L_cs[`AUTO_INC_SEL2], D2L_cs[`AUTO_INC_SEL1], D2L_cs[`AUTO_INC_SEL0]};
	
	wire[1:0] ppmm = D2L_cs[`PPMM];
	
	wire df = W2L_eflags[10];

	wire lr_ld;
	
	
	wire base_is_dest_gpr, base_is_esp;
	wire[13:0] stall;
	wire dep_stall;
	
	
	
	
	
	
	
	
	
	
	//============================
	//
	//	Registe Files
	//
	//============================

	wire[31:0] count_gpr;
	GPR$ gpr(dest_gpr_old, src_gpr_old, base_gpr_old, index_gpr, W2L_src_gpr, W2L_dest_gpr, 
			dest_gpr_sel, src_gpr_sel, base_gpr_sel, index_gpr_sel, W2L_src_gpr_sel, W2L_dest_gpr_sel, 
			dest_gpr_type, src_gpr_type, 2'b10, 2'b10, W2L_src_gpr_type, W2L_dest_gpr_type, 
			W2L_src_gpr_wt, W2L_dest_gpr_wt,  			
			CLK, CLR, PRE,
			gpr0, gpr1, gpr2, gpr3, gpr4, gpr5, gpr6, gpr7);
			
	SegR$ segr(dest_segr, src_segr, segment_segr, L2W_code_segment, W2L_dest_segr, ,
			   dest_segr_sel, src_segr_sel, segment_segr_sel, 3'b001, W2L_dest_segr_sel, ,
			   W2L_dest_segr_wt, 1'b0, 			
			   CLK, CLR, PRE,
			   segr0, segr1, segr2, segr3, segr4, segr5, segr6, segr7);
			   
	MMX$ mmx(dest_mmx, src_mmx, W2L_dest_mmx,
			 dest_mmx_sel, src_mmx_sel, W2L_dest_mmx_sel,
			 W2L_dest_mmx_wt,
			 CLK, CLR, PRE,
			 mmx0, mmx1, mmx2, mmx3, mmx4, mmx5, mmx6, mmx7);

	//=============================
	//
	//	See if ECX is zero
	//
	//=============================
	// Adder32$ adderCount123(count_gpr, -32'h1, 1'b0, L2A_count_gpr, );
	
	
	// wire[31:0] w0, w1, w2, w3;
	// or2$ or0[15:0](w0, count_gpr[31:16], count_gpr[15:0]);
	// or2$ or1[7:0](w1, w0[15:8], w0[7:0]);
	// or2$ or2[3:0](w2, w1[7:4], w1[3:0]);
	// or2$ or3[1:0](w3, w2[3:2], w2[1:0]);
	// nor2$ nor4(L2D_count_zero, w3[1], w3[0]);
	
	
	
			 
	//=============================
	//
	//	Auto Increment/Decrement
	//
	//=============================
	mux2_32$ muxDfInc(df_inc, 32'h1, -32'h1, df);
	mux8_32$ muxAutoInc(auto_inc, 32'h0, 32'h1, -32'h1, df_inc, D2L_imm[15:0], D2L_imm[15:0], D2L_imm[15:0], D2L_imm[15:0], auto_inc_sel);
	mux4_32$ muxAutoIncScaled(auto_inc_scaled, auto_inc, {auto_inc[30:0], 1'b0}, {auto_inc[29:0], 2'b0}, {auto_inc[28:0], 3'b0}, data_type);
	
	Adder32$ adderDestGPR(dest_gpr_old, auto_inc_scaled, 1'b0, dest_gpr, );
	Adder32$ adderSrcGPR(src_gpr_old, auto_inc_scaled, 1'b0, src_gpr, );
	
	//==============================
	//
	//	Special Case: base_gpr is ESP during PUSH
	//
	//==============================
	id_comp4$ compBaseGrpSel({1'b0, base_gpr_sel}, {1'b0, dest_gpr_sel}, base_is_dest_gpr, );
	wire is_push;
	id_comp4$ compIsPush({2'b0, ppmm}, {4'b0001}, is_push, );
	and2$ andBaseIsEsp(base_is_esp, base_is_dest_gpr, is_push);
	mux2_32$ muxBaseGpr(base_gpr, base_gpr_old, dest_gpr, base_is_esp);
	
	//================================
	// 
	//	Displacement and Immediate SEXT
	//
	//================================
	wire[31:0] imm, disp;
	wire[1:0] imm_sel = D2L_cs[`IMM_SEL];
	wire[1:0] disp_sel = D2L_cs[`DISP_SEL];
	mux4_32$ muxImm(
		imm, 
		32'b0, 
		{{24{D2L_imm[7]}}, D2L_imm[7:0]}, 
		{{16{D2L_imm[15]}}, D2L_imm[15:0]},
		D2L_imm,
		imm_sel
	);
	
	mux4_32$ muxDisp(
		disp, 
		32'b0, 
		{{24{D2L_disp[8]}}, D2L_disp[7:0]}, 
		{{16{D2L_disp[16]}}, D2L_disp[15:0]},
		D2L_disp,
		disp_sel
	);
	
	//=============================
	//	
	//	Special case: REP MOVS
	//
	//=============================
	wire countmux_sel, count_ld, rep;
	wire[15:0] countmux_out, count, count_dec, count_padd;
	wire count_zero, rep_stall;
	
	assign rep = D2L_cs[`CS_REP];
	assign countmux_sel = D2L_cs[`COUNT_SEL];
	assign count_ld = D2L_cs[`COUNT_LD];
	
	mux2_16$ muxCount(countmux_out, src_gpr_old, count_dec, countmux_sel);
	reg16e$	regCount(CLK, countmux_out, count, , CLR, PRE, count_ld);
	Adder32$ adderCount({16'h0, count}, -32'h1, 1'b0, {count_padd, count_dec}, );
	id_comp16$ compCount(count_dec, 16'h0, count_zero, );
	and3$ andRepStall(rep_stall, W2L_eflags[0], rep, D2L_cs[`CC_ZF_CHECK]);
	
	
	
	
	//=============================
	//
	//	Pipeline Registers
	//
	//=============================
	reg32e$	reg_cs[3:0](CLK, cs, L2A_cs, , CLR, PRE, lr_ld);
	reg1e$ reg_v(CLK, v, L2A_v, , CLR, PRE, lr_ld);
	reg32e$	reg_e(CLK, D2L_e, L2A_e, , CLR, PRE, lr_ld);
	reg32e$	reg_dest_gpr_old(CLK, dest_gpr_old, L2A_dest_gpr_old, , CLR, PRE, lr_ld);
	reg32e$	reg_src_gpr_old(CLK, src_gpr_old, L2A_src_gpr_old, , CLR, PRE, lr_ld);
	reg32e$	reg_dest_gpr(CLK, dest_gpr, L2A_dest_gpr, , CLR, PRE, lr_ld);
	reg32e$	reg_src_gpr(CLK, src_gpr, L2A_src_gpr, , CLR, PRE, lr_ld);
	reg32e$	reg_base_gpr(CLK, base_gpr, L2A_base_gpr, , CLR, PRE, lr_ld);
	reg32e$	reg_index_gpr(CLK, index_gpr, L2A_index_gpr, , CLR, PRE, lr_ld);
	reg16e$	reg_src_segr(CLK, src_segr, L2A_src_segr, , CLR, PRE, lr_ld);
	reg16e$	reg_dest_segr(CLK, dest_segr, L2A_dest_segr, , CLR, PRE, lr_ld);
	reg16e$	reg_segment_segr(CLK, segment_segr, L2A_segment_segr, , CLR, PRE, lr_ld);
	reg64e$	reg_dest_mmx(CLK, dest_mmx, L2A_dest_mmx, , CLR, PRE, lr_ld);
	reg64e$	reg_src_mmx(CLK, src_mmx, L2A_src_mmx, , CLR, PRE, lr_ld);
	reg32e$ reg_imm(CLK, imm, L2A_imm, , CLR, PRE, lr_ld);
	reg32e$ reg_disp(CLK, disp, L2A_disp, , CLR, PRE, lr_ld);
    reg32e$ reg_next_eip(CLK, D2L_next_eip, L2A_next_eip, , CLR, PRE, lr_ld);
	reg32e$ reg_current_eip(CLK, D2L_current_eip, L2A_current_eip, , CLR, PRE, lr_ld);
	
	reg1e$ reg_vector[3:0](CLK, D2L_vector, L2A_vector, , CLR, PRE, lr_ld);


	
	//=============================
	//
	//	Pipeline Logic
	//
	//=============================
	

	

	
	LR_Dep_Logic dep_logic1[3:0](
		.src_sel({dest_gpr_sel, src_gpr_sel, base_gpr_sel, index_gpr_sel}),
		.A2L_dest_sel(A2L_dest_gpr_sel),
		.P2L_dest_sel(P2L_dest_gpr_sel),
		.M2L_dest_sel(M2L_dest_gpr_sel),
		.E2L_dest_sel(E2L_dest_gpr_sel),
		.W2L_dest_sel(W2L_dest_gpr_sel),
		.src_rd({dest_gpr_rd, src_gpr_rd, base_gpr_rd, index_gpr_rd}),
		.A2L_dest_wt(A2L_dest_gpr_wt),
		.P2L_dest_wt(P2L_dest_gpr_wt),
		.M2L_dest_wt(M2L_dest_gpr_wt),
		.E2L_dest_wt(E2L_dest_gpr_wt),
		.W2L_dest_wt(W2L_dest_gpr_wt),
		.src_type({dest_gpr_type, src_gpr_type, 2'b10, 2'b10}),
		.A2L_dest_type(A2L_dest_gpr_type),
		.P2L_dest_type(P2L_dest_gpr_type),
		.M2L_dest_type(M2L_dest_gpr_type),
		.E2L_dest_type(E2L_dest_gpr_type),
		.W2L_dest_type(W2L_dest_gpr_type),
		.dep_stall(stall[3:0])
	);
		
	LR_Dep_Logic dep_logic2[3:0](
		.src_sel({dest_gpr_sel, src_gpr_sel, base_gpr_sel, index_gpr_sel}),
		.A2L_dest_sel(A2L_src_gpr_sel),
		.P2L_dest_sel(P2L_src_gpr_sel),
		.M2L_dest_sel(M2L_src_gpr_sel),
		.E2L_dest_sel(E2L_src_gpr_sel),
		.W2L_dest_sel(W2L_src_gpr_sel),
		.src_rd({dest_gpr_rd, src_gpr_rd, base_gpr_rd, index_gpr_rd}),
		.A2L_dest_wt(A2L_src_gpr_wt),
		.P2L_dest_wt(P2L_src_gpr_wt),
		.M2L_dest_wt(M2L_src_gpr_wt),
		.E2L_dest_wt(E2L_src_gpr_wt),
		.W2L_dest_wt(W2L_src_gpr_wt),
		.src_type({dest_gpr_type, src_gpr_type, 2'b10, 2'b10}),
		.A2L_dest_type(A2L_src_gpr_type),
		.P2L_dest_type(P2L_src_gpr_type),
		.M2L_dest_type(M2L_src_gpr_type),
		.E2L_dest_type(E2L_src_gpr_type),
		.W2L_dest_type(W2L_src_gpr_type),
		.dep_stall(stall[7:4])
	);
	
	LR_Dep_Logic dep_logic3[2:0](
		.src_sel({dest_segr_sel, src_segr_sel, segment_segr_sel}),
		.A2L_dest_sel(A2L_dest_segr_sel),
		.P2L_dest_sel(P2L_dest_segr_sel),
		.M2L_dest_sel(M2L_dest_segr_sel),
		.E2L_dest_sel(E2L_dest_segr_sel),
		.W2L_dest_sel(W2L_dest_segr_sel),
		.src_rd({dest_segr_rd, src_segr_rd, segment_segr_rd}),
		.A2L_dest_wt(A2L_dest_segr_wt),
		.P2L_dest_wt(P2L_dest_segr_wt),
		.M2L_dest_wt(M2L_dest_segr_wt),
		.E2L_dest_wt(E2L_dest_segr_wt),
		.W2L_dest_wt(W2L_dest_segr_wt),
		.src_type({2'b01, 2'b01, 2'b01}),
		.A2L_dest_type(2'b01),
		.P2L_dest_type(2'b01),
		.M2L_dest_type(2'b01),
		.E2L_dest_type(2'b01),
		.W2L_dest_type(2'b01),
		.dep_stall(stall[10:8])
	);
		
	LR_Dep_Logic dep_logic4[1:0](
		.src_sel({dest_mmx_sel, src_mmx_sel}),
		.A2L_dest_sel(A2L_dest_mmx_sel),
		.P2L_dest_sel(P2L_dest_mmx_sel),
		.M2L_dest_sel(M2L_dest_mmx_sel),
		.E2L_dest_sel(E2L_dest_mmx_sel),
		.W2L_dest_sel(W2L_dest_mmx_sel),
		.src_rd({dest_mmx_rd, src_mmx_rd}),
		.A2L_dest_wt(A2L_dest_mmx_wt),
		.P2L_dest_wt(P2L_dest_mmx_wt),
		.M2L_dest_wt(M2L_dest_mmx_wt),
		.E2L_dest_wt(E2L_dest_mmx_wt),
		.W2L_dest_wt(W2L_dest_mmx_wt),
		.src_type({2'b11, 2'b11}),
		.A2L_dest_type(2'b11),
		.P2L_dest_type(2'b11),
		.M2L_dest_type(2'b11),
		.E2L_dest_type(2'b11),
		.W2L_dest_type(2'b11),
		.dep_stall(stall[12:11])
	);
	
	LR_Dep_Logic dep_logic5(
		.src_sel(3'b000),
		.A2L_dest_sel(3'b000),
		.P2L_dest_sel(3'b000),
		.M2L_dest_sel(3'b000),
		.E2L_dest_sel(3'b000),
		.W2L_dest_sel(3'b000),
		.src_rd(D2L_cs[`NEED_DF]),
		.A2L_dest_wt(A2L_set_cc),
		.P2L_dest_wt(P2L_set_cc),
		.M2L_dest_wt(M2L_set_cc),
		.E2L_dest_wt(E2L_set_cc),
		.W2L_dest_wt(1'b0),
		.src_type(2'b11),
		.A2L_dest_type(2'b11),
		.P2L_dest_type(2'b11),
		.M2L_dest_type(2'b11),
		.E2L_dest_type(2'b11),
		.W2L_dest_type(2'b11),
		.dep_stall(stall[13])
	);
		
	id_comp16$ compDep({2'b0, stall}, 16'b0, dep_stall, );
	

	LR_Pipeline_Logic stall_logic(
		.dep_stall(dep_stall),
		.rep_stall(1'b0),
		.next_stall(A2L_stall),
		.flush(F2L_flush),
		.v(D2L_v), 
		
		.ld(lr_ld), 
		.prev_stall(L2D_stall),
		.next_v(v)
		
		
	);
	
	

endmodule

module LR_Pipeline_Logic(
	dep_stall, 
	rep_stall,
	next_stall, 
	flush,
	v, 
	
	ld, 
	prev_stall,
	next_v
	
);
	input dep_stall, rep_stall, next_stall, flush, v;
	output ld, prev_stall, next_v;
	
	
	inv1$ invAgLd(ld, next_stall);
	
	wire flush_bar;
	inv1$ invFlushBar(flush_bar, flush);
	
	wire stall;
	or3$ orStall(stall, dep_stall, rep_stall, next_stall);
	and3$ andDeStall(prev_stall, stall, v, flush_bar);
	
	wire dep_stall_bar;
	inv1$ invDepStallBar(dep_stall_bar, dep_stall);
	and3$ andV(next_v, v, flush_bar, dep_stall_bar);
	
endmodule

module LR_Dep_Logic(
	src_sel, A2L_dest_sel, P2L_dest_sel, M2L_dest_sel, E2L_dest_sel, W2L_dest_sel, 
	src_rd, A2L_dest_wt, P2L_dest_wt, M2L_dest_wt, E2L_dest_wt, W2L_dest_wt,
	src_type, A2L_dest_type, P2L_dest_type, M2L_dest_type, E2L_dest_type, W2L_dest_type,
	dep_stall);
	
	input[2:0] src_sel, A2L_dest_sel, P2L_dest_sel, M2L_dest_sel, E2L_dest_sel, W2L_dest_sel;
	input src_rd, A2L_dest_wt, P2L_dest_wt, M2L_dest_wt, E2L_dest_wt, W2L_dest_wt;
	input[1:0] src_type, A2L_dest_type, P2L_dest_type, M2L_dest_type, E2L_dest_type, W2L_dest_type;
	output dep_stall;
	
	wire[5:0] isNotByte;
	wire[2:0] src_eff_sel, A2L_dest_eff_sel, P2L_dest_eff_sel, M2L_dest_eff_sel, E2L_dest_eff_sel, W2L_dest_eff_sel;  
	
	wire[4:0] cmpMatch, wtMatch;
	wire w0, w1;
	
	or2$ orIsNotByte[5:0](
		isNotByte, 
		{src_type[0], A2L_dest_type[0], P2L_dest_type[0], M2L_dest_type[0], E2L_dest_type[0], W2L_dest_type[0]},
		{src_type[1], A2L_dest_type[1], P2L_dest_type[1], M2L_dest_type[1], E2L_dest_type[1], W2L_dest_type[1]}
	);
	
	
	and2$ andEffSel[17:0](
		{src_eff_sel, A2L_dest_eff_sel, P2L_dest_eff_sel, M2L_dest_eff_sel, E2L_dest_eff_sel, W2L_dest_eff_sel},
		{src_sel, A2L_dest_sel, P2L_dest_sel, M2L_dest_sel, E2L_dest_sel, W2L_dest_sel},
		{isNotByte[5], 2'b11, isNotByte[4], 2'b11, isNotByte[3], 2'b11, isNotByte[2], 2'b11, isNotByte[1], 2'b11, isNotByte[0], 2'b11}
	);
	
	
	id_comp4$ compSel[4:0](
		{1'b0, src_eff_sel}, 
		{1'b0, A2L_dest_eff_sel, 1'b0, P2L_dest_eff_sel, 1'b0, M2L_dest_eff_sel, 1'b0, E2L_dest_eff_sel, 1'b0, W2L_dest_eff_sel}, 
		cmpMatch, );
		
	and2$ andMatch[4:0](wtMatch, cmpMatch, {A2L_dest_wt, P2L_dest_wt, M2L_dest_wt, E2L_dest_wt, W2L_dest_wt});
	or2$ orMatch0(w0, wtMatch[0], wtMatch[1]);
	or4$ orMatch1(w1, w0, wtMatch[2], wtMatch[3], wtMatch[4]);
	and2$ andDep(dep_stall, src_rd, w1);
	
	
endmodule

module LR_Rep_Logic(
	rep,
	ecx,
	rep_stall
);
	input rep;
	input[31:0] ecx;
	output rep_stall;
	
	wire ecx_is_zero;
	id_comp32$ compEcx(ecx, 32'h0, ecx_is_zero, );
	and2$ andRepStall(rep_stall, rep, ecx_is_zero);


endmodule



