`include "/misc/collaboration/382nGPS/382nG6/yhuang/misc.v"

module AG_Stage(
	// global control signals
	CLK, 
	CLR, 
	PRE,
	
	// from FE stage
	F2A_flush,
	
	A2F_code_segment_limit,
	
	// from LR stage
	L2A_v,
	L2A_e,
	L2A_cs,
	L2A_current_eip,
	L2A_next_eip,
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
	
	// to LR stage, for stall check
	A2L_stall,
	
	// to LR stage, for dep check
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
	
	// from PRE stage, for stall check
	P2A_stall,
	
	// to PRE stage
	A2P_v,
	A2P_e,
	A2P_cs,
	A2P_current_eip,
	A2P_next_eip,
	A2P_rel_eip,
	A2P_disp,
	A2P_imm,
	A2P_dest_gpr,
	A2P_src_gpr,
	A2P_dest_segr,
	A2P_src_segr,
	A2P_dest_mmx,
	A2P_src_mmx,
	A2P_mem_rd_addr,
	A2P_mem_wt_addr
);

	//=========================================
	//
	//	IO Port Definition
	//
	//=========================================

	input CLK; 
	input CLR; 
	input PRE;
	
	// from FE stage
	input F2A_flush;

	// from LR stage
	input L2A_v;
	input[127:0] L2A_cs;
	input[31:0] L2A_e;
	input[31:0] L2A_next_eip;
	input[31:0] L2A_current_eip;
	input[31:0] L2A_disp;
	input[31:0] L2A_imm;
	input[31:0] L2A_dest_gpr;
	input[31:0] L2A_dest_gpr_old;
	input[31:0] L2A_src_gpr;
	input[31:0] L2A_src_gpr_old;
	input[31:0] L2A_base_gpr;
	input[31:0] L2A_index_gpr;
	input[15:0] L2A_dest_segr;
	input[15:0] L2A_src_segr;
	input[15:0] L2A_segment_segr;
	input[63:0] L2A_dest_mmx;
	input[63:0] L2A_src_mmx;
	
	// to FE stage
	output[31:0] A2F_code_segment_limit;

	// to LR stage; for stall check
	output A2L_stall;

	// to LR stage; for dep check
	output[2:0] A2L_dest_gpr_sel;
	output[2:0] A2L_src_gpr_sel;
	output[2:0] A2L_dest_segr_sel;
	output[2:0] A2L_dest_mmx_sel;
	output A2L_dest_gpr_wt;
	output A2L_src_gpr_wt;
	output A2L_dest_segr_wt;
	output A2L_dest_mmx_wt;
	output[1:0] A2L_dest_gpr_type;
	output[1:0] A2L_src_gpr_type;

	// from PRE stage; for stall check
	input P2A_stall;

	// to PRE stage
	output A2P_v;
	output[31:0] A2P_e;
	output[127:0] A2P_cs;
	output[31:0] A2P_next_eip;
	output[31:0] A2P_current_eip;
	output[31:0] A2P_rel_eip;
	output[31:0] A2P_disp;
	output[31:0] A2P_imm;
	output[31:0] A2P_dest_gpr;
	output[31:0] A2P_src_gpr;
	output[15:0] A2P_dest_segr;
	output[15:0] A2P_src_segr;
	output[63:0] A2P_dest_mmx;
	output[63:0] A2P_src_mmx;
	output[31:0] A2P_mem_rd_addr;
	output[31:0] A2P_mem_wt_addr;
	
	//===================================
	//
	//	Control Signals
	//
	//===================================
	wire base_gpr_rd = L2A_cs[`BASE_GPR_RD];
	wire[1:0] disp_sel = L2A_cs[`DISP_SEL];
	wire index_gpr_rd = L2A_cs[`INDEX_GPR_RD];
	wire[1:0] index_scale_sel = L2A_cs[`INDEX_SCALE_SEL];
	wire[2:0] dest_segr_sel = L2A_cs[`DEST_SEGR_SEL];
	wire[2:0] src_segr_sel = L2A_cs[`SRC_SEGR_SEL];
	wire[2:0] segment_segr_sel = L2A_cs[`SEGMENT_SEGR_SEL];
	wire[1:0] data_type = L2A_cs[`DATA_TYPE];
	wire[1:0] ppmm = L2A_cs[`PPMM];
	wire segment_segr_rd = L2A_cs[`SEGMENT_SEGR_RD];
	
	

	
	//===================================
	//	
	//	Access Segment Limit Registers
	//
	//===================================
	wire[31:0] modrm_segment_limit, stack_segment_limit;
	wire[2:0] stack_segment_sel;
	wire[31:0] addr_offset;
	wire[31:0] modrm_limit_adj, stack_limit_adj;
	
	mux4$ muxStackSegmentSel[2:0](stack_segment_sel, 3'h0, dest_segr_sel, src_segr_sel, dest_segr_sel, ppmm[0], ppmm[1]);
	LimitRegisters$ limitReg(modrm_segment_limit, stack_segment_limit, A2F_code_segment_limit, ,
							 segment_segr_sel, stack_segment_sel, 3'b001, );
		
	mux4_32$ muxAddrOffset(addr_offset, 32'h0, -32'h1, -32'h3, -32'h7, data_type);
	Adder32$ adderModrmLimit(modrm_segment_limit, addr_offset, 1'b0, modrm_limit_adj, ),
			 adderStackLimit(stack_segment_limit, addr_offset, 1'b0, stack_limit_adj, );
	
	
	
	//===================================
	//
	//	ModR/M Address Calcuation
	//
	//===================================
	
	wire[31:0] base, index, index_scaled, disp, base_index, disp_segment, base_index_disp, modrm_addr;
	
	mux2_32$ muxBase(base, 32'h0, L2A_base_gpr, base_gpr_rd);
	mux2_32$ muxIndex(index, 32'h0, L2A_index_gpr, index_gpr_rd);
	mux4_32$ muxIndexScaled(index_scaled, index, {index[30:0], 1'b0}, {index[29:0], 2'b0}, {index[27:0], 4'b0}, index_scale_sel);
	
	mux4_32$ muxDisp(disp, 32'h0, {{24{L2A_disp[7]}}, L2A_disp[7:0]}, {{16{L2A_disp[15]}}, L2A_disp[15:0]}, L2A_disp, disp_sel);
	
	Adder32$ adderBaseIndex(base, index_scaled, 1'b0, base_index, );	
	Adder32$ adderDispSegment(disp, {L2A_segment_segr, 16'h0}, 1'b0, disp_segment, );
	Adder32$ adderBaseIndexDisp(base_index, disp, 1'b0, base_index_disp, );
	Adder32$ adderModrmAddr(base_index, disp_segment, 1'b0, modrm_addr, );
	
	
	//===================================
	//
	//	Stack Address Calculation
	//
	//====================================
	wire[31:0] stack_base;
	wire[15:0] stack_segment;
	wire[31:0] stack_addr;
	mux4_32$ muxStackBase(stack_base, 32'h0, L2A_dest_gpr, L2A_src_gpr_old, L2A_dest_gpr_old, ppmm);
	mux4_16$ muxStackSegment(stack_segment, 16'h0, L2A_dest_segr, L2A_src_segr, L2A_dest_segr, ppmm[0], ppmm[1]);
	Adder32$ adderStackAddr(stack_base, {stack_segment, 16'h0}, 1'b0, stack_addr, );
	 
	//===================================
	//	
	//	Segment Limit Check
	//
	//===================================
	wire modrm_exceed_limit, stack_exceed_limit;
	wire modrm_exception_bar, stack_exception_bar;
	wire stack_check_limit;
	wire pg_ex;
	wire[31:0] exception;
	mag_comp32$ compModrm(base_index_disp, modrm_limit_adj, modrm_exceed_limit, ),
				compStack(stack_base, stack_limit_adj, stack_exceed_limit, );
	
	or2$ or2(stack_check_limit, ppmm[0], ppmm[1]);
	nand3$ nandModrmExceptionBar(modrm_exception_bar, modrm_exceed_limit, segment_segr_rd, base_index_disp[31]),
		   nandStackExceptionBar(stack_exception_bar, stack_exceed_limit, stack_check_limit, stack_base[31]);
	nand2$ nandExcpetion(pg_ex, modrm_exception_bar, stack_exception_bar);
	mux2$ muxException(exception[1], pg_ex, L2A_e[1], 1'b0);
	assign exception[31:2] = L2A_e[31:2];
	assign exception[0] = 1'b0;
	
	//===================================
	//
	//	Memory Read/Write Address
	//
	//===================================
	wire[31:0] mem_rd_addr, mem_wt_addr;
	//wire mem_rd_addr_sel, mem_wt_addr_sell
	
	mux4_32$ muxMemRdAddr(mem_rd_addr, modrm_addr, modrm_addr, stack_addr, modrm_addr, ppmm),
			 muxMemWtAddr(mem_wt_addr, modrm_addr, stack_addr, modrm_addr, stack_addr, ppmm);
	
	
	//=================================
	//
	//	EIP-Relative Target Address
	//
	//=================================
	wire[31:0] rel_eip;
	//wire[31:0] rel;
	Adder32$ adderRelEip(L2A_next_eip, disp, 1'b0, rel_eip, );
	
	
	//===================================
	//	GPR selection
	//===================================
	wire[31:0] src_gpr, dest_gpr;
	mux4_32$ muxSrcGpr(src_gpr, L2A_src_gpr_old, L2A_src_gpr_old, L2A_src_gpr, L2A_src_gpr_old, ppmm);
	mux4_32$ muxDestGpr(dest_gpr, L2A_dest_gpr_old, L2A_dest_gpr, L2A_dest_gpr_old, L2A_dest_gpr_old, ppmm);
	
	//===================================
	//
	//	Pipeline Logic
	//
	//===================================
	wire ag_ld, v;
	wire flush_bar;
	inv1$ invAgLd(ag_ld, P2A_stall);
	inv1$ invFlushBar(flush_bar, F2A_flush);
	and3$ andStall(A2L_stall, P2A_stall, L2A_v, flush_bar);
	and2$ andV(v, L2A_v, flush_bar);

	//===================================
	//
	//	Pipeline Registers
	//
	//===================================
	reg1e$ reg_v(CLK, v, A2P_v, , CLR, PRE, ag_ld);
	reg32e$ reg_e(CLK, exception, A2P_e, , CLR, PRE, ag_ld);
	reg32e$	reg_cs[3:0](CLK, L2A_cs, A2P_cs, , CLR, PRE, ag_ld);
	reg32e$ reg_next_eip(CLK, L2A_next_eip, A2P_next_eip, , CLR, PRE, ag_ld);
	reg32e$ reg_current_eip(CLK, L2A_current_eip, A2P_current_eip, , CLR, PRE, ag_ld);
	reg32e$ reg_rel_eip(CLK, rel_eip, A2P_rel_eip, , CLR, PRE, ag_ld);
	reg32e$ reg_imm(CLK, L2A_imm, A2P_imm, , CLR, PRE, ag_ld);
	reg32e$ reg_disp(CLK, L2A_disp, A2P_disp, , CLR, PRE, ag_ld);
	reg32e$ reg_dest_gpr(CLK, dest_gpr, A2P_dest_gpr, , CLR, PRE, ag_ld);
	reg32e$ reg_src_reg(CLK, src_gpr, A2P_src_gpr, , CLR, PRE, ag_ld);
	reg16e$ reg_dest_segr(CLK, L2A_dest_segr, A2P_dest_segr, , CLR, PRE, ag_ld);
	reg16e$ reg_src_segr(CLK, L2A_src_segr, A2P_src_segr, , CLR, PRE, ag_ld);
	reg64e$ reg_dest_mmx(CLK, L2A_dest_mmx, A2P_dest_mmx, , CLR, PRE, ag_ld);
	reg64e$ reg_src_mmx(CLK, L2A_src_mmx, A2P_src_mmx, , CLR, PRE, ag_ld);
	reg32e$ reg_mem_rd_addr(CLK, mem_rd_addr, A2P_mem_rd_addr, , CLR, PRE, ag_ld);
	reg32e$ reg_mem_wt_addr(CLK, mem_wt_addr, A2P_mem_wt_addr, , CLR, PRE, ag_ld);
	
	//==================================
	//
	//	Signal Forwarding
	//
	//===================================
	assign A2L_dest_gpr_sel = L2A_cs[`DEST_GPR_SEL];
	assign A2L_src_gpr_sel = L2A_cs[`SRC_GPR_SEL];
	assign A2L_dest_segr_sel = L2A_cs[`DEST_SEGR_SEL];
	assign A2L_dest_mmx_sel = L2A_cs[`DEST_MMX_SEL];
	and2$ andDestGprWt(A2L_dest_gpr_wt, L2A_cs[`DEST_GPR_WT], L2A_v);
	and2$ andSrcGprWt(A2L_src_gpr_wt, L2A_cs[`SRC_GPR_WT], L2A_v);
	and2$ andDestSegrWt(A2L_dest_segr_wt, L2A_cs[`DEST_SEGR_WT], L2A_v);
	and2$ andDestMmxWt(A2L_dest_mmx_wt, L2A_cs[`DEST_MMX_WT], L2A_v);
	
	assign A2L_dest_gpr_type = L2A_cs[`DEST_GPR_TYPE];
	assign A2L_src_gpr_type = L2A_cs[`SRC_GPR_TYPE];
	
	
	

endmodule
