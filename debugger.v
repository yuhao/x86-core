module Debugger(
	CLK,

	F2D_current_eip,
	D2L_current_eip,
	L2A_current_eip,
	A2P_current_eip,
	P2M_current_eip,
	M2E_current_eip,
	E2W_current_eip,
	
	F2D_v,
	D2L_v,
	L2A_v,
	A2P_v,
	P2M_v,
	M2E_v,
	E2W_v,	
	
	D2F_stall,
	L2D_stall,
	A2L_stall,
	P2A_stall,
	M2P_stall,
	E2M_stall,
	W2E_stall,

	GPR_out0,
	GPR_out1,
	GPR_out2,
	GPR_out3,
	GPR_out4,
	GPR_out5,
	GPR_out6,
	GPR_out7,

	SEGR_out0,
	SEGR_out1,
	SEGR_out2,
	SEGR_out3,
	SEGR_out4,
	SEGR_out5,
	
	MMX_out0,
	MMX_out1,
	MMX_out2,
	MMX_out3,
	MMX_out4,
	MMX_out5,
	MMX_out6,
	MMX_out7,
	
	D2L_cs,
	L2A_cs,
	A2P_cs,
	P2M_cs,
	M2E_cs,
	E2W_cs,
	
	E2W_result,
	
	A2P_mem_rd_addr,
	M2E_mem_rd_data,
	
	W2M_mem_wt_addr,
	W2M_mem_wt_data,
	

	EFLAGS,
	
	F_flush,
	BUS_address,
	BUS_data,
	W2F_br_taken,
	
	D2L_e,
	L2A_e,
	A2P_e,
	P2M_e,
	M2E_e,
	E2W_e,
	
	
	
	out
);

	input CLK;

	input[31:0] F2D_current_eip;
	input[31:0] D2L_current_eip;
	input[31:0] L2A_current_eip;
	input[31:0] A2P_current_eip;
	input[31:0] P2M_current_eip;
	input[31:0] M2E_current_eip;
	input[31:0] E2W_current_eip;
	
	input F2D_v;
	input D2L_v;
	input L2A_v;
	input A2P_v;
	input P2M_v;
	input M2E_v;
	input E2W_v;
	
	input D2F_stall;
	input L2D_stall;
	input A2L_stall;
	input P2A_stall;
	input M2P_stall;
	input E2M_stall;
	input W2E_stall;

	input[31:0] GPR_out0;
	input[31:0] GPR_out1;
	input[31:0] GPR_out2;
	input[31:0] GPR_out3;
	input[31:0] GPR_out4;
	input[31:0] GPR_out5;
	input[31:0] GPR_out6;
	input[31:0] GPR_out7;

	input[15:0] SEGR_out0;
	input[15:0] SEGR_out1;
	input[15:0] SEGR_out2;
	input[15:0] SEGR_out3;
	input[15:0] SEGR_out4;
	input[15:0] SEGR_out5;

	input[63:0] MMX_out0;
	input[63:0] MMX_out1;
	input[63:0] MMX_out2;
	input[63:0] MMX_out3;
	input[63:0] MMX_out4;
	input[63:0] MMX_out5;
	input[63:0] MMX_out6;
	input[63:0] MMX_out7;
	
	input[127:0] D2L_cs;
	input[127:0] L2A_cs;
	input[127:0] A2P_cs;
	input[127:0] P2M_cs;
	input[127:0] M2E_cs;
	input[127:0] E2W_cs;
	
	input[63:0] E2W_result;
	
	input[31:0] A2P_mem_rd_addr;
	input[63:0] M2E_mem_rd_data;
	
	input[31:0] W2M_mem_wt_addr;
	input[63:0] W2M_mem_wt_data;

	input[31:0] EFLAGS;
	
	input F_flush;
	input[31:0] BUS_address;
	input[31:0] BUS_data;
	input W2F_br_taken;
	
	
	input[31:0] D2L_e;
	input[31:0] L2A_e;
	input[31:0] A2P_e;
	input[31:0] P2M_e;
	input[31:0] M2E_e;
	input[31:0] E2W_e;
	
	
	output[31:0] out;
	
	reg[9:0] cycle;
	initial begin
		cycle = 0;
	end
	always @ (posedge CLK) begin
		cycle = cycle + 1;
	end


	//================================
	//
	//	Debugging Wires
	//	
	//================================

	wire[7:0] __01_DE_upc,
			  __02_LR_upc,
		      __03_AG_upc,
			  __04_PRE_upc,
 			  __05_MEM_upc,
			  __06_EX_upc,
			  __07_WB_upc;

	wire[31:0] _01_DE_eip, 
			   _02_LR_eip, 
			   _03_AG_eip, 
			   _04_PRE_eip, 
			   _05_MEM_eip, 
			   _06_EXC_eip, 
			   _07_WB_eip;
			   
	wire[31:0] _08_EAX, 
			   _09_ECX, 
			   _10_EDX, 
			   _11_EBX, 
			   _12_ESP, 
			   _13_EBP, 
			   _14_ESI, 
			   _15_EDI;
			   
	wire[15:0] _16_ES, 
			   _17_CS, 
			   _18_SS, 
			   _19_DS, 
			   _20_FS, 
			   _21_GS;
			   
		   
	wire[63:0] _22_MM0, 
			   _23_MM1, 
			   _24_MM2, 
			   _25_MM3, 
			   _26_MM4, 
			   _27_MM5, 
			   _28_MM6, 
			   _29_MM7;
			   
	wire _30_CF, 
		 _31_PF, 
		 _32_AF, 
		 _33_ZF, 
		 _34_SF, 
		 _35_DF, 
		 _36_OF;
		 
	wire _37_DE_stall,
		 _38_LR_stall,
		 _39_AG_stall,
		 _40_PRE_stall,
		 _41_MEM_stall,
		 _42_EXC_stall,
		 _43_WB_stall;
		 
	wire[2:0] _44_LR_dest_gpr_sel,		
			  _45_AG_dest_gpr_sel,
			  _46_PRE_dest_gpr_sel,
			  _47_MEM_dest_gpr_sel,
			  _48_EX_dest_gpr_sel,
			  _49_WB_dest_gpr_sel;
	
	wire[2:0] _50_LR_src_gpr_sel,		
			  _51_AG_src_gpr_sel,
			  _52_PRE_src_gpr_sel,
			  _53_MEM_src_gpr_sel,
			  _54_EX_src_gpr_sel,
			  _55_WB_src_gpr_sel; 
	

	wire[63:0] _56_WB_result;
	wire[31:0] _57_PRE_mem_rd_addr;
	wire[63:0] _58_EX_mem_rd_data;
	
	wire[31:0] _59_WB_mem_wt_addr;
	wire[63:0] _60_WB_mem_wt_data;

	

	Debugger_EIP debugger_eip(
		(F2D_v) ? F2D_current_eip : 32'hz,
		(D2L_v) ? D2L_current_eip : 32'hz,
		(L2A_v) ? L2A_current_eip : 32'hz,
		(A2P_v) ? A2P_current_eip : 32'hz,
		(P2M_v) ? P2M_current_eip : 32'hz,
		(M2E_v) ? M2E_current_eip : 32'hz,
		(E2W_v) ? E2W_current_eip : 32'hz
	);
	
			   
	//assign __01_DE_upc = (F2D_v) ? F2D_e[31:24] : 8'hz;
	assign __02_LR_upc = (D2L_v) ? D2L_e[31:24] : 8'hz;
	assign __03_AG_upc = (L2A_v) ? L2A_e[31:24] : 8'hz;
	assign __04_PRE_upc = (A2P_v) ? A2P_e[31:24] : 8'hz;
	assign __05_MEM_upc = (P2M_v) ? P2M_e[31:24] : 8'hz;
	assign __06_EX_upc = (M2E_v) ? M2E_e[31:24] : 8'hz;
	assign __07_WB_upc = (E2W_v) ? E2W_e[31:24] : 8'hz;

	assign _01_DE_eip = (F2D_v) ? F2D_current_eip : 32'hz;
	assign _02_LR_eip = (D2L_v) ? D2L_current_eip : 32'hz;
	assign _03_AG_eip = (L2A_v) ? L2A_current_eip : 32'hz;
	assign _04_PRE_eip = (A2P_v) ? A2P_current_eip : 32'hz;
	assign _05_MEM_eip = (P2M_v) ? P2M_current_eip : 32'hz;
	assign _06_EXC_eip = (M2E_v) ? M2E_current_eip : 32'hz;
	assign _07_WB_eip = (E2W_v) ? E2W_current_eip : 32'hz;

	assign _08_EAX = GPR_out0;
	assign _09_ECX = GPR_out1;
	assign _10_EDX = GPR_out2;
	assign _11_EBX = GPR_out3;
	assign _12_ESP = GPR_out4;
	assign _13_EBP = GPR_out5;
	assign _14_ESI = GPR_out6;
	assign _15_EDI = GPR_out7;

	assign _16_ES = SEGR_out0;
	assign _17_CS = SEGR_out1;
	assign _18_SS = SEGR_out2;
	assign _19_DS = SEGR_out3;
	assign _20_FS = SEGR_out4;
	assign _21_GS = SEGR_out5;

	assign _22_MM0 = MMX_out0;
	assign _23_MM1 = MMX_out1;
	assign _24_MM2 = MMX_out2;
	assign _25_MM3 = MMX_out3;
	assign _26_MM4 = MMX_out4;
	assign _27_MM5 = MMX_out5;
	assign _28_MM6 = MMX_out6;
	assign _29_MM7 = MMX_out7;

	assign _30_CF = EFLAGS[0];
	assign _31_PF = EFLAGS[2];
	assign _32_AF = EFLAGS[4];
	assign _33_ZF = EFLAGS[6];
	assign _34_SF = EFLAGS[7];
	assign _35_DF = EFLAGS[10];
	assign _36_OF = EFLAGS[11];

	assign _37_DE_stall = D2F_stall;
	assign _38_LR_stall = L2D_stall;
	assign _39_AG_stall = A2L_stall;
	assign _40_PRE_stall = P2A_stall;
	assign _41_MEM_stall = M2P_stall;
	assign _42_EXC_stall = E2M_stall;
	assign _43_WB_stall = W2E_stall;
	
	assign _44_LR_dest_gpr_sel = (D2L_v && D2L_cs[`READ_DST_GPR]) ? D2L_cs[`DST_GPR_SEL] : 3'hz;
	assign _45_AG_dest_gpr_sel = (L2A_v && L2A_cs[`WRITE_DST_GPR]) ? L2A_cs[`DST_GPR_SEL] : 3'hz;
	assign _46_PRE_dest_gpr_sel = (A2P_v && A2P_cs[`WRITE_DST_GPR]) ? A2P_cs[`DST_GPR_SEL] : 3'hz;
	assign _47_MEM_dest_gpr_sel = (P2M_v && P2M_cs[`WRITE_DST_GPR]) ? P2M_cs[`DST_GPR_SEL] : 3'hz;
	assign _48_EX_dest_gpr_sel = (M2E_v && M2E_cs[`WRITE_DST_GPR]) ? M2E_cs[`DST_GPR_SEL] : 3'hz;
	assign _49_WB_dest_gpr_sel = (E2W_v && E2W_cs[`WRITE_DST_GPR]) ? E2W_cs[`DST_GPR_SEL] : 3'hz;
	
	assign _50_LR_src_gpr_sel = (D2L_v && D2L_cs[`READ_SRC_GPR]) ? D2L_cs[`SRC_GPR_SEL] : 3'hz;
	assign _51_AG_src_gpr_sel = (L2A_v && L2A_cs[`WRITE_SRC_GPR]) ? L2A_cs[`SRC_GPR_SEL] : 3'hz;
	assign _52_PRE_src_gpr_sel = (A2P_v && A2P_cs[`WRITE_SRC_GPR]) ? A2P_cs[`SRC_GPR_SEL] : 3'hz;
	assign _53_MEM_src_gpr_sel = (P2M_v && P2M_cs[`WRITE_SRC_GPR]) ? P2M_cs[`SRC_GPR_SEL] : 3'hz;
	assign _54_EX_src_gpr_sel = (M2E_v && M2E_cs[`WRITE_SRC_GPR]) ? M2E_cs[`SRC_GPR_SEL] : 3'hz;
	assign _55_WB_src_gpr_sel = (E2W_v && E2W_cs[`WRITE_SRC_GPR]) ? E2W_cs[`SRC_GPR_SEL] : 3'hz;
	
	
	assign _56_WB_result = E2W_result;
	assign _57_PRE_mem_rd_addr = (A2P_v && A2P_cs[`MEM_READ]) ? A2P_mem_rd_addr : 32'hz;
	assign _58_EX_mem_rd_data = (M2E_v && M2E_cs[`MEM_READ]) ? M2E_mem_rd_data : 64'hz;
	
	assign _59_WB_mem_wt_addr = (E2W_v && E2W_cs[`MEM_WRITE]) ? W2M_mem_wt_addr : 32'hz;
	assign _60_WB_mem_wt_data = (E2W_v && E2W_cs[`MEM_WRITE]) ? W2M_mem_wt_data : 64'hz;
	
	
	
	
	//assign _58_MEM_mem_rd_addr = (P2M_v && P2M_cs[`MEM_WRITE]) ? P2M_mem_rd_addr : 32'hz;
	//assign _59_MEM_mem_wt_addr = (P2M_v && P2M_cs[`MEM_WRITE]) ? P2M_mem_wt_addr : 32'hz;
	//assign _60_EX_mem_wt_addr = (M2E_v && M2E_cs[`MEM_WRITE]) ? M2E_mem_wt_addr : 32'hz;
	
endmodule

module Debugger_EIP(DE_eip, LR_eip, AG_eip, PRE_eip, MEM_eip, EX_eip, WB_eip);
	input[31:0] DE_eip, LR_eip, AG_eip, PRE_eip, MEM_eip, EX_eip, WB_eip;
endmodule
