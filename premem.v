`include "/misc/collaboration/382nGPS/382nG6/yhuang/macro.v"
`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_constants.v"
`uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/yzhu_gates.v
`uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/mem.v

// very ugly interface... especially the PRE_needW and PRE_WR logic...
module premem(
	/******************input******************/
	//from IF stage
	IF_vpn,
	IF_flush,
	//from AG stage
	AG_CS,
	AG_EXP,
	AG_WR_VA,  // the virtual address to write to
	AG_RD_VA,  // the virtual address to read from
	//AG_WR,  // does this instruction require write?
	//AG_RD,  // does this isntruction require read?
	//AG_size, // the size of read/write operation, should be same; 00-Byte, 01-Word, 10-DWord, 11-QWord
	AG_Valid, // are AG stage registers valid?
	AG_CURRENT_EIP,
	AG_NEXT_EIP,
	AG_REL_EIP,
	AG_DISP,
	AG_IMM,
	AG_DEST_GPR,
	AG_SRC_GPR,
	AG_DEST_SEGR,
	AG_SRC_SEGR,
	AG_DEST_MMX,
	AG_SRC_MMX,
	//from MEM stage
	MEM2Pre_stall, // is the memory stage stalled?
	M2P_MEM_WR, // does the memory stage want to write to memory
	MEM_WR_VA,
	MEM_WR_SIZE,
	//from EXE stage
	E2P_MEM_WR,
	EXE_WR_VA,
	EXE_WR_SIZE,
	//from WB stage
	W2P_MEM_WR,
	WB_WR_VA,
	WB_WR_SIZE,

	/******************output******************/
	//output to IF stage
	IF_pfn,
	IF_tlbmiss,
	IF_present,
	IF_rw,
	//output to MEM stage
	PRE_CS,
	PRE_EXP,
	PRE_WR, // does this instruction require an immediate write(1) or read(0) in the following cycle. note that for instructions like /add [addr], reg/, PRE_WR will be set to 0, meaning read, and PRE_needW will be set for eventual write
	PRE_RD_PA, // the physical address to be load from
	PRE_WR_VA, // the virtual address to be written to, used to decide how many chunks a write to be splited to in memory stage
	PRE_WR_PA1, // the physical address to be written to (1)
	PRE_WR_PA2, // the physical address to be written to (2)
	PRE_WR_PA3, // the physical address to be written to (3)
	PRE_size, // the size of data to be written, essentially just AG_size;
	PRE_MEM_Valid, // are the values in PRE_WR and PRE_needW valid?  this is the bit that will play in the cache controller state machine; note the difference from PRE_Valid
	//PRE_needW, // will this instruction finally require a write? AG_WR
	PRE_Valid, // are PRE stage registers valid?
	PRE_unalign, // the unaligned id of current read operation 
	PRE_effsize, // the effective size of the current read operation; 00-1 byte; 01-2 bytes; 10-3 bytes; 11-4 bytes; note that this encoding is different from PRE_size
	PRE_uaSSE, // is the current read operation unaligned SSE?
	PRE_PCD, // page-level cache disable bit, indicating a MMIO operation
	PRE_CURRENT_EIP,
	PRE_NEXT_EIP,
	PRE_REL_EIP,
	PRE_DISP,
	PRE_IMM,
	PRE_DEST_GPR,
	PRE_SRC_GPR,
	PRE_DEST_SEGR,
	PRE_SRC_SEGR,
	PRE_DEST_MMX,
	PRE_SRC_MMX,
	//output to AG stage
	PRE_stall, // does the PRE stage need to be stalled
	//output to LR stage
	PRE_dest_gpr_sel,
	PRE_src_gpr_sel,
	PRE_dest_segr_sel,
	PRE_dest_mmx_sel,
	PRE_dest_gpr_wt,
	PRE_src_gpr_wt,
	PRE_dest_segr_wt,
	PRE_dest_mmx_wt,
	PRE_dest_gpr_type,
	PRE_src_gpr_type,
    PRE_set_cc,
	clk,
	clr);

	//AG_WR, AG_RD | PRE_WR, PRE_needW, PRE_MEM_Valid
	//    0       0    |  x(1)       x(0)        0
	//    0       1    |   0          0          1
	//    1       0    |   1          1          1
	//    1       1    |   0          1          1

	input[`CS_NUM] AG_CS;
	input[19:0] IF_vpn;
	input[31:0] AG_CURRENT_EIP, AG_NEXT_EIP, AG_REL_EIP, AG_DISP, AG_IMM, AG_DEST_GPR, AG_SRC_GPR;
	input[15:0] AG_DEST_SEGR, AG_SRC_SEGR;
	input[63:0] AG_DEST_MMX, AG_SRC_MMX;
	input[31:0] AG_RD_VA, AG_WR_VA, AG_EXP;
	input MEM2Pre_stall, AG_Valid, IF_flush;
	input M2P_MEM_WR, E2P_MEM_WR, W2P_MEM_WR;
	input[1:0] MEM_WR_SIZE, EXE_WR_SIZE, WB_WR_SIZE;
	input[31:0] MEM_WR_VA, EXE_WR_VA, WB_WR_VA;
	input clk, clr;
	output[`CS_NUM] PRE_CS;
	output[31:0] PRE_CURRENT_EIP, PRE_NEXT_EIP, PRE_REL_EIP, PRE_DISP, PRE_IMM, PRE_DEST_GPR, PRE_SRC_GPR;
	output[15:0] PRE_DEST_SEGR, PRE_SRC_SEGR;
	output[63:0] PRE_DEST_MMX, PRE_SRC_MMX;
	output[31:0] PRE_EXP, PRE_RD_PA, PRE_WR_VA, PRE_WR_PA1, PRE_WR_PA2, PRE_WR_PA3;
	output[1:0] PRE_unalign, PRE_effsize, PRE_size;
	output PRE_WR, PRE_PCD;
	output PRE_uaSSE, PRE_stall, PRE_Valid, PRE_MEM_Valid/*, PRE_needW*/;
	output[19:0] IF_pfn;
	output IF_tlbmiss, IF_present, IF_rw;
	output[2:0] PRE_dest_gpr_sel;
	output[2:0] PRE_src_gpr_sel;
	output[2:0] PRE_dest_segr_sel;
	output[2:0] PRE_dest_mmx_sel;
	output PRE_dest_gpr_wt;
	output PRE_src_gpr_wt;
	output PRE_dest_segr_wt;
	output PRE_dest_mmx_wt;
	output[1:0] PRE_dest_gpr_type;
	output[1:0] PRE_src_gpr_type;
    output PRE_set_cc;

	wire[31:0] VA_RD_inc1, VA_RD_inc2, va_rd_aligned;
	wire[31:0] tlb_cs, PRE_EXP_temp;
	wire[19:0] vpn_rd, vpn_rd_inc1, vpn_rd_inc2, vpn_rd_temp, pfn_rd_temp, vpn_rd_temp_normal;
	wire[31:0] PA_RD_temp;
	wire[4:0] J, J_temp, tlbpc_temp, tlbpc, logicpc;
	wire next_sel, uaSSE_temp, next_sel_temp, next_sel_normal, nextupc_sel;
	wire[1:0] size_temp, uaNormal, va_sel;
	wire ld_premem_en, tlb_miss_rd, present_rd, rw_rd, pcd_rd, PRE_pf_exp_rd, tlb_stall, ld_nextupc, PRE_Valid_temp;
	wire[31:0] premem_cs;
	wire AG_WR, AG_RD;
	wire[1:0] AG_size; //00-Byte, 01-Word, 10-DWord, 11-Qword
	wire isEXCEPTION;
	wire mem_dep, exe_dep, wb_dep;
	wire memory_raw;

	//control signal
	assign AG_WR = AG_CS[`MEM_WRITE];
	assign AG_RD = AG_CS[`MEM_READ];
	assign AG_size = AG_CS[`DATA_TYPE];

	//memory dependency checking
	MemoryDepCheck mem_dep_chk(AG_RD_VA, AG_size, MEM_WR_VA, MEM_WR_SIZE, mem_dep);
	MemoryDepCheck exe_dep_chk(AG_RD_VA, AG_size, EXE_WR_VA, EXE_WR_SIZE, exe_dep);
	MemoryDepCheck wb_dep_chk(AG_RD_VA, AG_size, WB_WR_VA, WB_WR_SIZE, wb_dep);

	//assign memory_raw = (mem_dep & M2P_MEM_WR) | (exe_dep & E2P_MEM_WR) | (wb_dep & W2P_MEM_WR);
	wire memory_raw0, memory_raw1, memory_raw2;
	and2$ and1_1(memory_raw0, mem_dep, M2P_MEM_WR);
	and2$ and1_2(memory_raw1, exe_dep, E2P_MEM_WR);
	and2$ and1_3(memory_raw2, wb_dep, W2P_MEM_WR);
	or3$ or1(memory_raw, memory_raw0, memory_raw1, memory_raw2);

	//read
	and2_32 and1(va_rd_aligned, AG_RD_VA, 32'hfffffffc);
	add2_32 add1(va_rd_aligned, 32'h4, VA_RD_inc1, , );
	add2_32 add2(va_rd_aligned, 32'h8, VA_RD_inc2, , );

	assign vpn_rd = AG_RD_VA[31:12];
	assign vpn_rd_inc1 = VA_RD_inc1[31:12];
	assign vpn_rd_inc2 = VA_RD_inc2[31:12];

	//assign PRE_pf_exp_rd = tlb_miss_rd | ~present_rd;
	wire present_rd_inv;
	inv1$ inv1(present_rd_inv, present_rd);
	or2$ or2(PRE_pf_exp_rd, tlb_miss_rd, present_rd_inv);

	mux3_32 mux4(PA_RD_temp, {pfn_rd_temp, AG_RD_VA[11:0]}, {pfn_rd_temp, VA_RD_inc2[11:0]}, {pfn_rd_temp, VA_RD_inc1[11:0]}, va_sel);

	mux2_5 mux1(tlbpc_temp, {1'b0, AG_RD_VA[1:0], AG_size[1:0]}, J, next_sel);
	mux3_20 mux2(vpn_rd_temp_normal, vpn_rd, vpn_rd_inc2, vpn_rd_inc1, va_sel);
	mux2_20 mux5(vpn_rd_temp, 20'b0, vpn_rd_temp_normal, AG_Valid);
	mux2_5 mux3(tlbpc, tlbpc_temp, 5'b00000, (~AG_RD | IF_flush)); // tlb control signal structure only deals with valid & non exception cases.  premem logic deals with non valid cases and exceptions.

	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/tlbucode", TLB_ControlStore.mem);
	rom32b32w$ TLB_ControlStore(tlbpc, 1'b1, tlb_cs); //OE: high-level enabled

	assign next_sel_normal = tlb_cs[0];
	assign J_temp = tlb_cs[5:1];
	assign tlb_stall = tlb_cs[6];
	assign size_temp = tlb_cs[8:7];
	assign uaNormal = tlb_cs[10:9];
	assign uaSSE_temp = tlb_cs[11];
	assign va_sel = tlb_cs[13:12];

	assign logicpc = {memory_raw, isEXCEPTION, AG_Valid, MEM2Pre_stall, tlb_stall};
	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/prememlogic", PreMEM_CS.mem);
	rom32b32w$ PreMEM_CS(logicpc, 1'b1, premem_cs);

	wire IF_flush_inv;
	inv1$ inv2(IF_flush_inv, IF_flush);
	assign nextupc_sel = premem_cs[4];
	//assign PRE_stall = premem_cs[3] & ~IF_flush; // upon flush, accepts invalid from previous stage
    and2$ and1_5(PRE_stall, premem_cs[3], IF_flush_inv);
	//assign PRE_Valid_temp = premem_cs[2] & ~IF_flush; // upon flush, sends invalid to next stage
	and2$ and1_4(PRE_Valid_temp, premem_cs[2], IF_flush_inv);
	//assign ld_premem_en = premem_cs[1] | IF_flush; // upon flush, enables pipeline reg
	or2$ or3(ld_premem_en, premem_cs[1], IF_flush);
	assign ld_nextupc = premem_cs[0];

	mux2$ mux6(next_sel_temp, next_sel_normal, 1'b0, nextupc_sel);
	dff_1 dff1(clk, next_sel_temp, next_sel, clr, ld_nextupc);
	dff_5 dff2(clk, J_temp, J, clr, ld_nextupc);

	wire[31:0] va_wr_aligned, VA_WR_inc1, VA_WR_inc2, pa_wr_temp1, pa_wr_temp2, pa_wr_temp3;
	wire[19:0] vpn_wr, vpn_wr_inc1, vpn_wr_inc2, pfn_wr_temp1, pfn_wr_temp2, pfn_wr_temp3;
	wire tlb_miss1, present1, rw1, pcd1, tlb_miss2, present2, rw2, pcd2, tlb_miss3, present3, rw3, pcd3;
	wire PRE_pf_exp_wr_temp1, PRE_prot_exp_wr_temp1, PRE_pf_exp_wr_temp2, PRE_prot_exp_wr_temp2, PRE_pf_exp_wr_temp3, PRE_prot_exp_wr_temp3;
	wire PRE_pf_exp_wr, PRE_prot_exp_temp, PRE_pf_exp_temp;
	wire[1:0] count;

	//write
	and2_32 and2(va_wr_aligned, AG_WR_VA, 32'hfffffffc);
	add2_32 add3(va_wr_aligned, 32'h4, VA_WR_inc1, , );
	add2_32 add4(va_wr_aligned, 32'h8, VA_WR_inc2, , );

	assign vpn_wr = AG_WR_VA[31:12];
	assign vpn_wr_inc1 = VA_WR_inc1[31:12];
	assign vpn_wr_inc2 = VA_WR_inc2[31:12];

	tlb utlb(IF_vpn, IF_pfn, IF_tlbmiss, IF_present, IF_rw, ,
			 vpn_rd_temp, pfn_rd_temp, tlb_miss_rd, present_rd, rw_rd, pcd_rd,
			 vpn_wr, pfn_wr_temp1, tlb_miss1, present1, rw1, pcd1,
			 vpn_wr_inc1, pfn_wr_temp2, tlb_miss2, present2, rw2, pcd2,
			 vpn_wr_inc2, pfn_wr_temp3, tlb_miss3, present3, rw3, pcd3);

	assign pa_wr_temp1 = {pfn_wr_temp1, AG_WR_VA[11:0]};
	assign pa_wr_temp2 = {pfn_wr_temp2, VA_WR_inc1[11:0]};
	assign pa_wr_temp3 = {pfn_wr_temp3, VA_WR_inc2[11:0]};

	wire present1_inv, present2_inv, present3_inv;
	wire rw1_inv, rw2_inv, rw3_inv;
	wire PRE_pf_exp_wr_temp1_inv, PRE_pf_exp_wr_temp2_inv, PRE_pf_exp_wr_temp3_inv;
	inv1$ inv2_1(present1_inv, present1);
	inv1$ inv2_2(present2_inv, present2);
	inv1$ inv2_3(present3_inv, present3);
	inv1$ inv2_4(rw1_inv, rw1);
	inv1$ inv2_5(rw2_inv, rw2);
	inv1$ inv2_6(rw3_inv, rw3);
	inv1$ inv2_7(PRE_pf_exp_wr_temp1_inv, PRE_pf_exp_wr_temp1);
	inv1$ inv2_8(PRE_pf_exp_wr_temp2_inv, PRE_pf_exp_wr_temp2);
	inv1$ inv2_9(PRE_pf_exp_wr_temp3_inv, PRE_pf_exp_wr_temp3);

	//assign PRE_pf_exp_wr_temp1 = tlb_miss1 | ~present1;
	//assign PRE_prot_exp_wr_temp1 = ~PRE_pf_exp_wr_temp1 & AG_WR & ~rw1;
	or2$ or4(PRE_pf_exp_wr_temp1, tlb_miss1, present1_inv);
	and3$ and2_1(PRE_prot_exp_wr_temp1, PRE_pf_exp_wr_temp1_inv, AG_WR, rw1_inv);

	//assign PRE_pf_exp_wr_temp2 = tlb_miss2 | ~present2;
	//assign PRE_prot_exp_wr_temp2 = ~PRE_pf_exp_wr_temp2 & AG_WR & ~rw2;
	or2$ or5(PRE_pf_exp_wr_temp2, tlb_miss2, present2_inv);
	and3$ and2_2(PRE_prot_exp_wr_temp2, PRE_pf_exp_wr_temp2_inv, AG_WR, rw2_inv);

	//assign PRE_pf_exp_wr_temp3 = tlb_miss3 | ~present3;
	//assign PRE_prot_exp_wr_temp3 = ~PRE_pf_exp_wr_temp3 & AG_WR & ~rw3;
	or2$ or6(PRE_pf_exp_wr_temp3, tlb_miss3, present3_inv);
	and3$ and2_3(PRE_prot_exp_wr_temp3, PRE_pf_exp_wr_temp3_inv, AG_WR, rw3_inv);

	wire count0_0, count0_1, count0_2, count0_3, count0_4;
	wire count1_0, count1_1, count1_2;
	inv1$ inv3_1(AG_WR_VA0_inv, AG_WR_VA[0]);
	inv1$ inv3_2(AG_WR_VA1_inv, AG_WR_VA[1]);
	inv1$ inv3_3(AG_size1_inv, AG_size[1]);
	inv1$ inv3_4(AG_size0_inv, AG_size[0]);

	and4$ and3_1(count0_0, AG_WR_VA1_inv, AG_WR_VA0_inv, AG_size[1], AG_size[0]);
	and4$ and3_2(count0_1, AG_WR_VA1_inv, AG_WR_VA[0], AG_size[1], AG_size0_inv);
	and4$ and3_3(count0_2, AG_WR_VA[1], AG_WR_VA0_inv, AG_size[1], AG_size0_inv);
	and4$ and3_4(count0_3, AG_WR_VA[1], AG_WR_VA[0], AG_size1_inv, AG_size[0]);
	and4$ and3_5(count0_4, AG_WR_VA[1], AG_WR_VA[0], AG_size[1], AG_size0_inv);
	or5$ or7(count[0], count0_0, count0_1, count0_2, count0_3, count0_4);

	//assign count[0] = (~AG_WR_VA[1] & ~AG_WR_VA[0] & AG_size[1] & AG_size[0]) |
	//				  (~AG_WR_VA[1] & AG_WR_VA[0] & AG_size[1] & ~AG_size[0]) |
	//				  (AG_WR_VA[1] & ~AG_WR_VA[0] & AG_size[1] & ~AG_size[0]) |
	//				  (AG_WR_VA[1] & AG_WR_VA[0] & ~AG_size[1] & AG_size[0]) |
	//				  (AG_WR_VA[1] & AG_WR_VA[0] & AG_size[1] & ~AG_size[0]);

	and4$ and4_1(count1_0, AG_WR_VA1_inv, AG_WR_VA[0], AG_size[1], AG_size[0]);
	and4$ and4_2(count1_1, AG_WR_VA[1], AG_WR_VA0_inv, AG_size[1], AG_size[0]);
	and4$ and4_3(count1_2, AG_WR_VA[1], AG_WR_VA[0], AG_size[1], AG_size[0]);
	or3$ or8(count[1], count1_0, count1_1, count1_2);

	//assign count[1] = (~AG_WR_VA[1] & AG_WR_VA[0] & AG_size[1] & AG_size[0]) |
	//				  (AG_WR_VA[1] & ~AG_WR_VA[0] & AG_size[1] & AG_size[0]) |
	//				  (AG_WR_VA[1] & AG_WR_VA[0] & AG_size[1] & AG_size[0]);

	wire count1_inv, count0_inv;
	inv1$ inv4_1(count1_inv, count[1]);
	inv1$ inv4_2(count0_inv, count[0]);

	//assign PRE_pf_exp_wr = (~count[1] & ~count[0] & PRE_pf_exp_wr_temp1) | (~count[1] & count[0] & (PRE_pf_exp_wr_temp1 | PRE_pf_exp_wr_temp2)) | (count[1] & ~count[0] & (PRE_pf_exp_wr_temp1 | PRE_pf_exp_wr_temp2 | PRE_pf_exp_wr_temp3));
	wire PRE_pf_exp_wr_0, PRE_pf_exp_wr_1, PRE_pf_exp_wr_2, PRE_pf_exp_wr_3, PRE_pf_exp_wr_4;
	and3$ and5_1(PRE_pf_exp_wr_0, count1_inv, count0_inv, PRE_pf_exp_wr_temp1);
	or2$ or9(PRE_pf_exp_wr_1, PRE_pf_exp_wr_temp1, PRE_pf_exp_wr_temp2);
	and3$ and5_2(PRE_pf_exp_wr_2, count1_inv, count[0], PRE_pf_exp_wr_1);
	or3$ or10(PRE_pf_exp_wr_3, PRE_pf_exp_wr_temp1, PRE_pf_exp_wr_temp2, PRE_pf_exp_wr_temp3);
	and3$ and5_3(PRE_pf_exp_wr_4, count[1], count0_inv, PRE_pf_exp_wr_3);
	or3$ or11(PRE_pf_exp_wr, PRE_pf_exp_wr_0, PRE_pf_exp_wr_2, PRE_pf_exp_wr_4);

	//assign PRE_prot_exp_temp = (~count[1] & ~count[0] & PRE_prot_exp_wr_temp1) | (~count[1] & count[0] & (PRE_prot_exp_wr_temp1 | PRE_prot_exp_wr_temp2)) | (count[1] & count[0] & (PRE_prot_exp_wr_temp1 & PRE_prot_exp_wr_temp2 & PRE_prot_exp_wr_temp3));
	wire PRE_prot_exp_temp0, PRE_prot_exp_temp1, PRE_prot_exp_temp2, PRE_prot_exp_wr_0;
	and3$ and8_1(PRE_prot_exp_temp0, count1_inv, count0_inv, PRE_prot_exp_wr_temp1);
	or2$ or16(PRE_prot_exp_wr_0, PRE_prot_exp_wr_temp1, PRE_prot_exp_wr_temp2);
	and3$ and8_2(PRE_prot_exp_temp1, count1_inv, count[0], PRE_prot_exp_wr_0);
	and5$ and8_3(PRE_prot_exp_temp2, count[1], count[0], PRE_prot_exp_wr_temp1, PRE_prot_exp_wr_temp2, PRE_prot_exp_wr_temp3);
	or3$ or17(PRE_prot_exp_temp_real, PRE_prot_exp_temp0, PRE_prot_exp_temp1, PRE_prot_exp_temp2);
    and2$ andz_3(PRE_prot_exp_temp, PRE_prot_exp_temp_real, AG_WR);

	//assign PRE_pf_exp_temp = PRE_pf_exp_wr | PRE_pf_exp_rd;
    wire PRE_pf_exp_wr_real, PRE_pf_exp_rd_real, pcd1_inv, pcd_rd_inv;
    //inv1$ invz_1(pcd1_inv, pcd1);
    //inv1$ invz_2(pcd_rd_inv, pcd_rd);
    and2$ andz_1(PRE_pf_exp_wr_real, PRE_pf_exp_wr, AG_WR);
    and2$ andz_2(PRE_pf_exp_rd_real, PRE_pf_exp_rd, AG_RD);
	or2$ or12(PRE_pf_exp_temp, PRE_pf_exp_wr_real, PRE_pf_exp_rd_real);

	// only one type of exception can be raised, based on which one happens first.  In the same stage, prot can only happen if pf is not raised
	//assign PRE_EXP_temp[0] = AG_EXP[0] | (~AG_EXP[1] & ~AG_EXP[0] & PRE_pf_exp_temp); // page fault exception
	wire PRE_EXP_temp0_1, AG_EXP1_inv, AG_EXP0_inv;
	inv1$ inv5_1(AG_EXP1_inv, AG_EXP[1]);
	inv1$ inv5_2(AG_EXP0_inv, AG_EXP[0]);
	and3$ and6_1(PRE_EXP_temp0_1, AG_EXP1_inv, AG_EXP0_inv, PRE_pf_exp_temp);
	or2$ or13(PRE_EXP_temp[0], AG_EXP[0], PRE_EXP_temp0_1);

	//assign PRE_EXP_temp[1] = AG_EXP[1] | (~AG_EXP[1] & ~AG_EXP[0] & PRE_prot_exp_temp); // protection exception
	wire PRE_EXP_temp1_1;
	and3$ and6_2(PRE_EXP_temp1_1, AG_EXP1_inv, AG_EXP0_inv, PRE_prot_exp_temp);
	or2$ or14(PRE_EXP_temp[1], AG_EXP[1], PRE_EXP_temp1_1);

    assign PRE_EXP_temp[31:2] = AG_EXP[31:2];

	//assign isEXCEPTION = PRE_EXP_temp[0] | PRE_EXP_temp[1]; //is any exception generated at or passed to premem stage?
	or2$ or15(isEXCEPTION, PRE_EXP_temp[0], PRE_EXP_temp[1]);

	/***load pipeline register***/
	dff_2 dff3(clk, size_temp, PRE_effsize, clr, ld_premem_en);
	dff_2 dff4(clk, uaNormal, PRE_unalign, clr, ld_premem_en); //note that normal MMX access will also set uaNormal to be 2'b01 and 2'b10 respectively for the simplicity of the design...
	dff_1 dff5(clk, uaSSE_temp, PRE_uaSSE, clr, ld_premem_en); // uaSSE indicates 3 possible scenarios of unaligned MMX memory access (excluding the normal one)
	dff_32 dff6(clk, PA_RD_temp, PRE_RD_PA, clr, ld_premem_en);
	dff_2 dff11(clk, AG_size, PRE_size, clr, ld_premem_en);
	//dff_1 dff13(clk, AG_WR, PRE_needW, clr, ld_premem_en);
	dff_1 dff14(clk, ~AG_RD, PRE_WR, clr, ld_premem_en);
	dff_1 dff15(clk, AG_WR | AG_RD, PRE_MEM_Valid, clr, ld_premem_en);
	dff_1 dff17(clk, pcd_rd, PRE_PCD, clr, ld_premem_en);
	dff_32 dff18(clk, AG_WR_VA, PRE_WR_VA, clr, ld_premem_en);
	// not all three are necessarily to be used.  the memory stage will be pick based on addr[1:0] and size
	dff_32 dff10(clk, pa_wr_temp1, PRE_WR_PA1, clr, ld_premem_en);
	dff_32 dff12(clk, pa_wr_temp2, PRE_WR_PA2, clr, ld_premem_en);
	dff_32 dff16(clk, pa_wr_temp3, PRE_WR_PA3, clr, ld_premem_en);
	dff_1 dff19(clk, PRE_Valid_temp, PRE_Valid, clr, ld_premem_en);
	//saturate_dff_32 dff20(clk, PRE_EXP_temp, PRE_EXP, clr, ld_premem_en);
	dff_32 dff20(clk, PRE_EXP_temp, PRE_EXP, clr, ld_premem_en);
	dff_32 dff21(clk, AG_CURRENT_EIP, PRE_CURRENT_EIP, clr, ld_premem_en);
	dff_32 dff22(clk, AG_NEXT_EIP, PRE_NEXT_EIP, clr, ld_premem_en);
	dff_32 dff23(clk, AG_REL_EIP, PRE_REL_EIP, clr, ld_premem_en);
	dff_32 dff24(clk, AG_DISP, PRE_DISP, clr, ld_premem_en);
	dff_32 dff25(clk, AG_IMM, PRE_IMM, clr, ld_premem_en);
	dff_32 dff26(clk, AG_DEST_GPR, PRE_DEST_GPR, clr, ld_premem_en);
	dff_32 dff27(clk, AG_SRC_GPR, PRE_SRC_GPR, clr, ld_premem_en);
	dff_16 dff28(clk, AG_DEST_SEGR, PRE_DEST_SEGR, clr, ld_premem_en);
	dff_16 dff29(clk, AG_SRC_SEGR, PRE_SRC_SEGR, clr, ld_premem_en);
	dff_64 dff30(clk, AG_DEST_MMX, PRE_DEST_MMX, clr, ld_premem_en);
	dff_64 dff31(clk, AG_SRC_MMX, PRE_SRC_MMX, clr, ld_premem_en);
	dff_128 dff32(clk, AG_CS, PRE_CS, clr, ld_premem_en);

	// CS forwarding
	assign PRE_dest_gpr_sel = AG_CS[`DEST_GPR_SEL];
	assign PRE_src_gpr_sel = AG_CS[`SRC_GPR_SEL];
	assign PRE_dest_segr_sel = AG_CS[`DEST_SEGR_SEL];
	assign PRE_dest_mmx_sel = AG_CS[`DEST_MMX_SEL];
	assign PRE_dest_gpr_type = AG_CS[`DEST_GPR_TYPE];
	assign PRE_src_gpr_type = AG_CS[`SRC_GPR_TYPE];
	//assign PRE_dest_gpr_wt = AG_CS[`DEST_GPR_WT] & AG_Valid;
	//assign PRE_src_gpr_wt = AG_CS[`SRC_GPR_WT] & AG_Valid;
	//assign PRE_dest_segr_wt = AG_CS[`DEST_SEGR_WT] & AG_Valid;
	//assign PRE_dest_mmx_wt = AG_CS[`DEST_MMX_WT] & AG_Valid;
	and2$ and7_1(PRE_dest_gpr_wt, AG_CS[`DEST_GPR_WT], AG_Valid);
	and2$ and7_2(PRE_src_gpr_wt , AG_CS[`SRC_GPR_WT], AG_Valid);
	and2$ and7_3(PRE_dest_segr_wt , AG_CS[`DEST_SEGR_WT], AG_Valid);
	and2$ and7_4(PRE_dest_mmx_wt , AG_CS[`DEST_MMX_WT], AG_Valid);
    and2$ and7_5(PRE_set_cc, AG_CS[`LOAD_CC], AG_Valid);
endmodule

