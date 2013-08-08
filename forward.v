module DataForwardUnit(
	CLK, CLR, PRE,

	AG_sr1_sel, 
	AG_sr2_sel, 
	AG_sr3_sel,
	AG_segment_sel, 
	AG_ssegr_sel,
	AG_smmx1_sel, 
	AG_smmx2_sel,
	AG_sr1_type, 
	AG_sr2_type, 
	AG_sr3_type,
	
	DFU_sr1, 
	DFU_sr2, 
	DFU_sr3,
	DFU_segment, 
	DFU_ssegr,
	DFU_smmx1, 
	DFU_smmx2,
	DFU_dep_stall,
		
	WB_v, 
	WB_dr1,
	WB_dr2, 
	WB_dsegr,
	WB_dmmx, 
	WB_dr1_sel,
	WB_dr2_sel,
	WB_dsegr_sel,
	WB_dmmx_sel,
	WB_dr1_ld,
	WB_dr2_ld,
	WB_dsegr_ld,
	WB_dmmx_ld, 
	WB_dr1_v, 
	WB_dr2_v, 
	WB_dsegr_v,
	WB_dmmx_v, 
	WB_dr1_type,
	WB_dr2_type,
	
	EX_v, 
	EX_dr1,
	EX_dr2, 
	EX_dsegr,
	EX_dmmx, 
	EX_dr1_sel,
	EX_dr2_sel,
	EX_dsegr_sel,
	EX_dmmx_sel,
	EX_dr1_ld,
	EX_dr2_ld,
	EX_dsegr_ld,
	EX_dmmx_ld, 
	EX_dr1_v, 
	EX_dr2_v, 
	EX_dsegr_v,
	EX_dmmx_v, 
	EX_dr1_type,
	EX_dr2_type,
	
	MEM_v, 
	MEM_dr1,
	MEM_dr2, 
	MEM_dsegr,
	MEM_dmmx, 
	MEM_dr1_sel,
	MEM_dr2_sel,
	MEM_dsegr_sel,
	MEM_dmmx_sel,
	MEM_dr1_ld,
	MEM_dr2_ld,
	MEM_dsegr_ld,
	MEM_dmmx_ld, 
	MEM_dr1_v, 
	MEM_dr2_v, 
	MEM_dsegr_v,
	MEM_dmmx_v, 
	MEM_dr1_type,
	MEM_dr2_type,
	
	PREMEM_v, 
	PREMEM_dr1,
	PREMEM_dr2, 
	PREMEM_dsegr,
	PREMEM_dmmx, 
	PREMEM_dr1_sel,
	PREMEM_dr2_sel,
	PREMEM_dsegr_sel,
	PREMEM_dmmx_sel,
	PREMEM_dr1_ld,
	PREMEM_dr2_ld,
	PREMEM_dsegr_ld,
	PREMEM_dmmx_ld, 
	PREMEM_dr1_v, 
	PREMEM_dr2_v, 
	PREMEM_dsegr_v,
	PREMEM_dmmx_v, 
	PREMEM_dr1_type,
	PREMEM_dr2_type
);

	//==========================================
	//	IO Ports Definition
	//==========================================
	
	input CLK, CLR, PRE;
	
	// inputs from DE stage
	input[2:0] AG_sr1_sel, AG_sr2_sel, AG_sr3_sel;
	input[2:0] AG_segment_sel, AG_ssegr_sel;
	input[2:0] AG_smmx1_sel, AG_smmx2_sel;
	input[1:0] AG_sr1_type, AG_sr2_type, AG_sr3_type;
	
	output[31:0] DFU_sr1, DFU_sr2, DFU_sr3;
	output[15:0] DFU_segment, DFU_ssegr;
	output[63:0] DFU_smmx1, DFU_smmx2;
	output DFU_dep_stall;
	
	// inputs: from WB; EX; MEM stages
	input WB_v, EX_v, MEM_v, PREMEM_v;
	
	input[31:0] WB_dr1, EX_dr1, MEM_dr1, PREMEM_dr1;
	input[31:0] WB_dr2, EX_dr2, MEM_dr2, PREMEM_dr2;
	input[15:0] WB_dsegr, EX_dsegr, MEM_dsegr, PREMEM_dsegr;
	input[63:0] WB_dmmx, EX_dmmx, MEM_dmmx, PREMEM_dmmx;
	
	input[2:0] WB_dr1_sel, EX_dr1_sel, MEM_dr1_sel, PREMEM_dr1_sel;
	input[2:0] WB_dr2_sel, EX_dr2_sel, MEM_dr2_sel, PREMEM_dr2_sel;
	input[2:0] WB_dsegr_sel, EX_dsegr_sel, MEM_dsegr_sel, PREMEM_dsegr_sel;
	input[2:0] WB_dmmx_sel, EX_dmmx_sel, MEM_dmmx_sel, PREMEM_dmmx_sel;
	
	input WB_dr1_ld, EX_dr1_ld, MEM_dr1_ld, PREMEM_dr1_ld;
	input WB_dr2_ld, EX_dr2_ld, MEM_dr2_ld, PREMEM_dr2_ld;
	input WB_dsegr_ld, EX_dsegr_ld, MEM_dsegr_ld, PREMEM_dsegr_ld;
	input WB_dmmx_ld, EX_dmmx_ld, MEM_dmmx_ld, PREMEM_dmmx_ld;
	
	input WB_dr1_v, EX_dr1_v, MEM_dr1_v, PREMEM_dr1_v;
	input WB_dr2_v, EX_dr2_v, MEM_dr2_v, PREMEM_dr2_v;
	input WB_dsegr_v, EX_dsegr_v, MEM_dsegr_v, PREMEM_dsegr_v;
	input WB_dmmx_v, EX_dmmx_v, MEM_dmmx_v, PREMEM_dmmx_v;
	
	input[1:0] WB_dr1_type, EX_dr1_type, MEM_dr1_type, PREMEM_dr1_type;
	input[1:0] WB_dr2_type, EX_dr2_type, MEM_dr2_type, PREMEM_dr2_type;
	
	
	
	GPR$ gpr(
		DFU_sr1, DFU_sr2, DFU_sr3, , WB_dr1, WB_dr2,
		AG_sr1_sel, AG_sr2_sel, AG_sr3_sel, , WB_dr1_sel, WB_dr2_sel,
		AG_sr1_type, AG_sr2_type, AG_sr3_type, , WB_dr1_type, WB_dr2_type,
		WB_dr1_ld, WB_dr2_ld, 			
		CLK, CLR, PRE
	);
	
	SegR$ segr(
		DFU_segment, DFU_ssegr, WB_dsegr, ,
		AG_segment_sel, AG_ssegr_sel, WB_dsegr_sel, ,
		WB_dsegr_ld, 1'b0, 			
		CLK, CLR, PRE
	);
	
	MMX$ mmx(
		DFU_smmx1, DFU_smmx2, WB_dmmx,
		AG_smmx1_sel, AG_smmx2_sel, WB_dmmx_sel,
		WB_dmmx_ld,
		CLK, CLR, PRE
	);
	
		 
	
	
	
endmodule
