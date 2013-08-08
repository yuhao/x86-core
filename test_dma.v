// extended version of basic gates
`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_constants.v"
`include "/misc/collaboration/382nGPS/382nG6/yjl/cmu.v"
//`include "/misc/collaboration/382nGPS/382nG6/yjl/fetch.v"
//`include "/misc/collaboration/382nGPS/382nG6/yjl/decode.v"
//`include "/misc/collaboration/382nGPS/382nG6/yjl/tlb.v"
//`include "/misc/collaboration/382nGPS/382nG6/yzhu/mem.v"

module TOP();
    parameter CLK = 22;
    parameter HALF = 11;

    reg reset;
    reg set;
    reg clk_in;
    wire clk;
    reg [127:0] data_in;
    reg [1:0]   write_addr;
    reg [1:0]   read_addr;
    reg         read_hit;
    reg         stop;


    always #(HALF) clk_in = ~clk_in;



    
	initial
	begin
	   $dumpfile ("./test.vcd");
	   $dumpvars (0, TOP);
       
	end
	
    // Test Part
    initial
    begin
        reset = 0;
        stop = 0;
        set = 1;
        clk_in = 0;
        write_addr = 0;
        data_in = 0;
        read_hit = 0;
        #CLK
        write_addr = 0;
        read_hit = 1;
        reset = 1;
        set = 1;
        #CLK
        write_addr = 1;
        read_addr = 0;
        #CLK
        #200
        stop = 1;
        #100
        stop = 0;
        
        //#HALF 
        //#CLK 
        #10000
        $finish;
    end
   
   //---------------------------
    // Test for Basic Logics
    //---------------------------
    reg             A2F_uncond_branch;
    reg [3:0]       tb_instr_length;
    reg             D2F_instr_gt_16;
    reg             X2F_stall;
    reg [31:0]      mem_data;
    //reg             kill_prefetch;
    

    initial
    begin
        X2F_stall = 0;
        tb_instr_length = 0;
        A2F_uncond_branch = 0;

        //kill_prefetch = 0;
        #1000
        //W2F_branch_taken = 1;
        //W2F_br_eip = 32'h0;
        tb_instr_length = 4;
        //W2F_exception = 1;
        //#CLK
        //#CLK
        //W2F_branch_taken = 0;

        //W2F_exception = 0;
    end
   
    /*
    reg             W2F_exception;
    reg [31:0]      W2F_new_eip;
    reg             W2F_branch_taken;
    reg             A2F_uncond_branch;
    reg [3:0]       D2F_instr_length;
    reg             D2F_instr_gt_16;
    reg             X2F_stall;
    */

    

    //--------------------------------------
    //  Debug Dump Wires
    //--------------------------------------
    wire [3:0] dp_instr_length;
    wire [127:0] dp_ir;

	//-------------------------------------
	//	Icache <-> F
	//-------------------------------------
	wire [31:0]     F_prefetch_addr;
	wire 			F_kill_prefetch_n;
    wire [127:0]    I2F_instruction;
    wire            icache_miss;

	//------------------------------------
	//	TLB -> ICache
	//-----------------------------------
    wire [31:0] instr_phy_addr;
    wire        icache_read_miss;
    wire        icache_read_hit;
    wire [19:0] icache_vfn;
    wire [19:0] icache_pfn;
    wire        icache_tlb_miss;
    wire        icache_tlb_present;
    wire        icache_tlb_rw;
    wire [2:0]  icache_pfn_tag;

    //-------------------------------------
    // X -> F 
    //-------------------------------------
    // 1. D->F
    wire [3:0]      D2F_instr_length;
    wire            D2F_decode_failed;
    wire            D2F_split_instr;
    wire            D2F_atomic;
    wire            D2F_stall;
    // 2. W -> F
    wire [31:0]      W2F_exception;
    wire [31:0]      W2F_br_eip;
    wire [31:0]      W2F_current_eip;
    wire             W2F_branch_taken;
    wire [15:0]      W2F_cs_segr_value;
	wire 			 W2F_ld_eip;
    // 3. TLB -> F
    wire             IF_pf;          // tlb page fault
    wire [19:0]      A2F_cs_segr_limit;


    //-------------------------------------
    // F -> D 
    //-------------------------------------
    wire [127:0]    F2D_instruction_in;
    wire [7:0]      F2D_upc_in;
    wire            F2D_upc_valid_in;
    wire [31:0]     F2D_current_eip_in;
    wire [31:0]     F2D_next_eip_in;
    wire            F2D_instr_valid_gt_16_in;
    wire [31:0]     F2D_exception_in;
    wire [3:0]      F2D_exp_vector_in;
    wire            F2D_stall_n;
    wire            F2D_valid_in;

    wire [127:0]    F2D_instruction_out;
    wire [7:0]      F2D_upc_out;
    wire            F2D_upc_valid_out;
    wire [31:0]     F2D_current_eip_out;
    wire [31:0]     F2D_next_eip_out;
    wire [31:0]     F2D_exception_out;
    wire [3:0]      F2D_exp_vector_out;
    wire            F2D_outstr_valid_gt_16_out;
    wire            F2D_valid_out;
    
    wire            mem_data_finish;
    wire [31:0]     icache_write_addr;
    wire            receiving_data; 


    //-------------------------------------
    // F -> X
    //-------------------------------------
    wire F_flush;           // flush other stges when control flow change occur
    


    //-------------------------------------
    // L -> D 
    //-------------------------------------
    wire            L2D_stall;
    
    
    //-------------------------------------
    // D -> X
    //-------------------------------------
    wire            hlt_signal;

    //-----------------------------------
    //  D -> L 
    //-----------------------------------
    wire [`CS_NUM]    D2L_control_signal_in;
    wire [31:0]       D2L_next_eip_in;
    wire [31:0]       D2L_current_eip_in;
    wire [1:0]        D2L_scale_in;
    wire [2:0]        D2L_base_gpr_id_in;
    wire [2:0]        D2L_index_gpr_id_in;
    wire              D2L_need_base_gpr_in;
    wire              D2L_need_index_gpr_in;
    wire [2:0]        D2L_addr_segr_id_in;
    wire [31:0]       D2L_imm_in;
    wire [31:0]       D2L_disp_in;
    wire [31:0]       D2L_exception_in;
    wire              D2L_valid_in;
    wire              D2L_stall_n;

    wire [`CS_NUM]    D2L_control_signal_out;
    wire [31:0]       D2L_next_eip_out;
    wire [31:0]       D2L_current_eip_out;
    wire [1:0]        D2L_scale_out;
    wire [2:0]        D2L_base_gpr_id_out;
    wire [2:0]        D2L_outdex_reg_id_out;
    wire              D2L_need_base_gpr_out;
    wire              D2L_need_outdex_reg_out;
    wire [2:0]        D2L_addr_segr_id_out;
    wire [31:0]       D2L_imm_out;
    wire [31:0]       D2L_disp_out;
    wire              D2L_valid_out;
    wire [31:0]       D2L_exception_out;

    wire              D2L_flush;


    //---------------------------------
    // P -> A 
    //---------------------------------
	// to AG
	wire P2A_stall;

    //---------------------------------
    //  A -> L
    //---------------------------------
	// to LR
	wire A2L_stall;
	wire[2:0] A2L_dest_gpr_sel;
	wire[2:0] A2L_src_gpr_sel;
	wire[2:0] A2L_dest_segr_sel;
	wire[2:0] A2L_dest_mmx_sel;
	wire A2L_dest_gpr_wt;
	wire A2L_src_gpr_wt;
	wire A2L_dest_segr_wt;
	wire A2L_dest_mmx_wt;
	wire[1:0] A2L_dest_gpr_type;
	wire[1:0] A2L_src_gpr_type;
	
	
    //---------------------------------
    //  P -> L
    //---------------------------------
	// to LR
	wire[2:0] P2L_dest_gpr_sel;
	wire[2:0] P2L_src_gpr_sel;
	wire[2:0] P2L_dest_segr_sel;
	wire[2:0] P2L_dest_mmx_sel;
	wire P2L_dest_gpr_wt;
	wire P2L_src_gpr_wt;
	wire P2L_dest_segr_wt;
	wire P2L_dest_mmx_wt;
	wire[1:0] P2L_dest_gpr_type;
	wire[1:0] P2L_src_gpr_type;	
	



    //-----------------------------------
    //  L <- W
    //-----------------------------------
    // to LR
	wire[2:0] W2L_dest_gpr_sel;
	wire[2:0] W2L_src_gpr_sel;
	wire[2:0] W2L_dest_segr_sel;
	wire[2:0] W2L_dest_mmx_sel;
	wire W2L_dest_gpr_wt;
	wire W2L_src_gpr_wt;
	wire W2L_dest_segr_wt;
	wire W2L_dest_mmx_wt;
	wire[1:0] W2L_dest_gpr_type;
	wire[1:0] W2L_src_gpr_type;
	wire[31:0] W2L_dest_gpr;
	wire[31:0] W2L_src_gpr;
	wire[15:0] W2L_dest_segr;
	wire[63:0] W2L_dest_mmx;
	wire[31:0] W2L_eflags;


    //-----------------------------------
    //  L -> A 
    //-----------------------------------
	
	// to AG 
	wire L2A_v;
	wire[127:0] L2A_cs;
    wire[31:0] L2A_e;
	wire[31:0] L2A_current_eip;
	wire[31:0] L2A_next_eip;
	wire[31:0] L2A_disp;
	wire[31:0] L2A_imm;
	wire[31:0] L2A_dest_gpr;
	wire[31:0] L2A_dest_gpr_old;
	wire[31:0] L2A_src_gpr;
	wire[31:0] L2A_src_gpr_old;
	wire[31:0] L2A_base_gpr;
	wire[31:0] L2A_index_gpr;
	wire[15:0] L2A_dest_segr;
	wire[15:0] L2A_src_segr;
	wire[15:0] L2A_segment_segr;
	wire[63:0] L2A_dest_mmx;
	wire[63:0] L2A_src_mmx;
	
	wire[15:0] L2W_code_segment;

    //---------------------------------------
    // A -> P
    //---------------------------------------

	// to PRE
	wire A2P_v;
	wire[31:0] A2P_e;
	wire[127:0] A2P_cs;
	wire[31:0] A2P_next_eip;
	wire[31:0] A2P_current_eip;
	wire[31:0] A2P_rel_eip;
	wire[31:0] A2P_disp;
	wire[31:0] A2P_imm;
	wire[31:0] A2P_dest_gpr;
	wire[31:0] A2P_src_gpr;
	wire[15:0] A2P_dest_segr;
	wire[15:0] A2P_src_segr;
	wire[63:0] A2P_dest_mmx;
	wire[63:0] A2P_src_mmx;
	wire[31:0] A2P_mem_rd_addr;
	wire[31:0] A2P_mem_wt_addr;

    //-----------------------------------
    //  P -> M
    //-----------------------------------

	wire[127:0] pre_cs;
	wire[31:0] pre_current_eip, pre_next_eip, pre_rel_eip, pre_disp, pre_imm, pre_dest_gpr, pre_src_gpr, pre_exp;
	wire[15:0] pre_dest_segr, pre_src_segr;
	wire[63:0] pre_dest_mmx, pre_src_mmx;
	wire[31:0] pre_rd_pa, pre_wr_pa1, pre_wr_pa2, pre_wr_pa3, pre_wr_va;
	wire[1:0] pre_unalign, pre_effsize, pre_size;
	wire pre_pf_exp, pre_prot_exp, pre_wr;
	wire pre_uasse, pre_stall, pre_valid, pre_mem_valid, pre_needw;


    //-----------------------------------
    //  M -> E
    //-----------------------------------

	wire[127:0] mem_cs;
	wire[31:0] mem_current_eip, mem_next_eip, mem_rel_eip, mem_disp, mem_imm, mem_dest_gpr, mem_src_gpr, mem_exp;
	wire[15:0] mem_dest_segr, mem_src_segr;
	wire[63:0] mem_dest_mmx, mem_src_mmx;
	wire[63:0] mem_rd_data;
	wire[31:0] mem_wr_va, mem_wr_pa1, mem_wr_pa2, mem_wr_pa3;
	wire[1:0] mem_size;
	wire mem2pre_stall, mem2cmt_stall, mem_pcd, mem_valid;
	wire m2p_mem_wr;
	wire[1:0] m2p_wr_size;
	wire[31:0] m2p_wr_va;
	
    //-----------------------------------
    //  W -> M
    //-----------------------------------

	wire cmt, cmt_valid, exe_stall;
	wire[1:0] cmt_size;
	wire[31:0] cmt_addr, cmt_pa1, cmt_pa2, cmt_pa3;
	wire[63:0] cmt_data;

	//--------------------------
	//	
	//--------------------------
	// inputs: from WB
	wire W2E_stall;
	wire[31:0] W2E_eflags;

	
	


	//--------------------------
	//	
	//--------------------------
	// outputs: to WB
	wire E2W_v;
	wire[31:0] E2W_e;
	wire[127:0] E2W_cs;
	wire[31:0] E2W_next_eip;
	wire[31:0] E2W_current_eip;
	wire[31:0] E2W_rel_eip;
	wire[31:0] E2W_dest_gpr;
	wire[31:0] E2W_src_gpr;
	wire[63:0] E2W_result;
	wire[31:0] E2W_new_eflags;
	wire[31:0] E2W_mem_wt_addr;
	wire[31:0] E2W_disp;
	wire[31:0] E2W_wr_pa1;
	wire[31:0] E2W_wr_pa2;
	wire[31:0] E2W_wr_pa3;

	//------------------------------------
	//	E -> P
	//------------------------------------
	wire[31:0] E2P_mem_wt_addr;
	wire[1:0] E2P_mem_wt_size;
	wire E2P_mem_wt_en;

	//------------------------------------
	//	W -> P
	//------------------------------------
	wire[31:0] W2P_mem_wt_addr;
	wire[1:0] W2P_mem_wt_size;
	wire W2P_mem_wt_en;
	

	//--------------------------------
    // Bus Interface
	//--------------------------------
 
    wire [3:0]  gnt;
    wire [3:0]  req;
    wire [15:0] bus_cntl;
    wire [31:0] bus_addr;
    wire [31:0] bus_data;
    wire        hsk_valid;
    wire        hsk_ack;
    

    //----------------------------------
    //  DMA <-> Bus-Station
    //----------------------------------
    wire[31:0]  dma_bus_data;
    wire[31:0]  dma_bus_addr;
    wire[31:0]  dma_bus_cntl;
    wire        dma_bus_valid;
    wire        dma_grant;
    wire        dma_req;   // req bus to wirte to memory
    wire        dma_intr_flag;     // dma finish 
    wire        dma_intr_clear;    // dma clear intr flag  
    wire        dma_finish;        // bus station notify dma data transfer has finished.

    //-----------------------------------
    //  Icache-Station <-> Memory-Station
    //-----------------------------------

    wire [31:0]     M2I_mem_addr;
    wire [31:0]     M2I_mem_data;

	//-------------------------------
	// ICache-Station -> I-Cache
	//-------------------------------
    wire icache_write_signal;

	//-----------------------------
	//	Memory-Station <-> Memory
	//-----------------------------
	wire [3:0]  mem_we; 
	wire        mem_write_signal;   // different from mem_wr, for it is used to fill the memory, it need to generate negative pulse
	wire        mem_wr;     // read memory or write memory
	wire [31:0] mem_dataIO;

    //-----------------------------------
    //  DCache <-> Memory-Station 
    //-----------------------------------
	wire[31:0] dc_req_address, dc_wb_data, dc_memory_data_lrb;
    wire[3:0] dc_we;
	wire dc_memory_ready, dc_read_req, dc_write_req;



	//=============================
	//	from MEM
	//=============================
	
	// to LR
	wire[2:0] M2L_dest_gpr_sel;
	wire[2:0] M2L_src_gpr_sel;
	wire[2:0] M2L_dest_segr_sel;
	wire[2:0] M2L_dest_mmx_sel;
	wire M2L_dest_gpr_wt;
	wire M2L_src_gpr_wt;
	wire M2L_dest_segr_wt;
	wire M2L_dest_mmx_wt;
	wire[1:0] M2L_dest_gpr_type;
	wire[1:0] M2L_src_gpr_type;	

	//=============================
	//	from EX
	//=============================
	
	// to LR
	wire[2:0] E2L_dest_gpr_sel;
	wire[2:0] E2L_src_gpr_sel;
	wire[2:0] E2L_dest_segr_sel;
	wire[2:0] E2L_dest_mmx_sel;
	wire E2L_dest_gpr_wt;
	wire E2L_src_gpr_wt;
	wire E2L_dest_segr_wt;
	wire E2L_dest_mmx_wt;
	wire[1:0] E2L_dest_gpr_type;
	wire[1:0] E2L_src_gpr_type;







    //-----------------------------------
	//
    // Fetch Stage
    //
    //------------------------------------
    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/fetch.v
    fetch_stage fetch_tb(
        .clk(clk),
        .reset(reset),
        .set(set),
        .icache_miss(icache_miss),
        .I2F_instruction(I2F_instruction),

        .tlb_page_fault(IF_pf),

        .F_prefetch_addr(F_prefetch_addr),
        .F_flush_other_stages(F_flush),
        .F_kill_prefetch_n(F_kill_prefetch_n),

        .DMA_interrupt(1'b0),
        //.X2F_stall(X2F_stall),            // if other stage might stall fetch
        .X2F_flush(1'b0),

        .W2F_exception(W2F_exception),
        .W2F_br_eip(W2F_br_eip),
        .W2F_current_eip(W2F_current_eip),
        .W2F_branch_taken(W2F_branch_taken),
		.W2F_ld_eip(W2F_ld_eip),
        .W2F_cs_segr_value(W2F_cs_segr_value),
        
        .A2F_uncond_branch(A2F_uncond_branch),
        .A2F_cs_segr_limit(A2F_cs_segr_limit),
        //.A2F_cs_segr_value(A2F_cs_segr_value),
        
        .D2F_instr_length(D2F_instr_length),
        .D2F_stall(D2F_stall),
        .D2F_decode_failed(D2F_decode_failed),

        .hlt_signal(hlt_signal),
        
        .F2D_instruction(F2D_instruction_in),
        .F2D_upc(F2D_upc_in),
        .F2D_upc_valid(F2D_upc_valid_in),
        .F2D_current_eip(F2D_current_eip_in),
        .F2D_next_eip(F2D_next_eip_in),
        .F2D_instr_valid_gt_16(F2D_instr_valid_gt_16_in),
        .F2D_exception(F2D_exception_in),
        .F2D_exp_vector(F2D_exp_vector_in),
        .F2D_valid(F2D_valid_in),
        .F2D_stall_n(F2D_stall_n)
    );
    `uselib
 
 



    //-----------------------------------
	//
    // TLB to ICache interface
    //
    //------------------------------------
    assign icache_vfn = F_prefetch_addr[31:12];
 
    assign instr_phy_addr = {icache_pfn, F_prefetch_addr[11:0]};     // offset within in page is 12 bits(4KB)
    // icache miss might be caused by read miss or tag mismatch or tlb miss
    //or2$ or_icache_miss(icache_miss, icache_tlb_miss, icache_read_miss);
	wire tag_not_match;
    `uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/yzhu_gates.v

    // PAGE FAULT || ICACHE_MISS
	wire tag_not_match;
    mag_comp4 comp1(icache_pfn[3:0], {1'b0, icache_pfn_tag}, tag_not_match);
    `uselib
    // tag not match or icache read not hit ===> icache_miss
    nand2$ nand_icache_miss(icache_miss, icache_read_hit, tag_not_match);
	inv1$ inv2(icache_tlb_present_inv, icache_tlb_present);
	or2$ or2(IF_pf, icache_tlb_miss, icache_tlb_present_inv);

	//-------------------------------
	//
	//	I-Cache
	//
	//------------------------------
    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/fetch.v
    icache datapath_icache(
        .clk(clk),
        .reset(reset),
        .set(set), 
        .out(I2F_instruction),
        .rd_addr(F_prefetch_addr[14:0]),//[`ICACHE_LINE_SIZE+14:`ICACHE_LINE_SIZE]), // [3:0] is index within cacheline.
        .wr_addr(M2I_mem_addr[14:0]),
        .icache_pfn_tag(icache_pfn_tag), //3 extra bits from tag array, to be compared with real pfn coming back from TLB
        // this is a state flag
        .icache_fill(receiving_data),   // a signal to tell the i cache to select wr_addr or rd_addr
        .din(M2I_mem_data),
        .read_miss(icache_read_miss), 
        .read_hit(icache_read_hit),

        .update(mem_data_finish),
        .fill_signal(icache_write_signal),//hsk_valid),
        .kill_prefetch_n(F_kill_prefetch_n)
    );
    `uselib

    //-----------------------------------
    // Bus Arbitrator 
    //-----------------------------------
    assign req[`MEM] = 0;
    assign req[`IO] = 0;

    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/bus_interface.v
    bus_arbitrator bus_arbiter(
        .clk(clk),
        .reset(reset),
        .set(set),
        .req(req),
        .gnt(gnt),
        .bus_data(bus_data),
        .bus_addr(bus_addr),
        .bus_cntl(bus_cntl),
        .hsk_ack(hsk_ack),
        .hsk_valid(hsk_valid)
    );
    `uselib

   
	//----------------------------------------------
	//
	//  DCache to Bus interface
	//
	//----------------------------------------------

    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/bus_interface.v
    dcache_station bs_dcache(
        .clk(clk),
        .reset(reset),
        .set(set),

        .bus_data(bus_data),
        .bus_addr(bus_addr), 
        .bus_cntl(bus_cntl),
        .device_id(`DCACHE),
        .dst_device_id(`MEM),
        
        .req_signal(dc_read_req),//icache_read_miss),  // request signal from device
        .write_memory_signal(dc_write_req),
        .req(req[`DCACHE]),             // request signal to bus interface.
        .gnt(gnt[`DCACHE]),

        .hsk_valid(hsk_valid),
        .hsk_ack(hsk_ack),

        .ready_bit(1'b0),
        .receiving_data(),
        .addr_in(dc_req_address),
        .cntl_signal(),
        .finish(dc_memory_ready),

        .data_in(dc_wb_data),
        .data_out(dc_memory_data_lrb),
        .addr_out(),
        .cntl_out(),
		.device_we_in(dc_we),

        .write_signal(),
        .counter_in(8'b1)      // counter should be from 4 to zero.
    );
    `uselib

	//----------------------------------------------
	//
	//  ICache to Bus interface
	//
	//----------------------------------------------

    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/bus_interface.v
    icache_station bs_icache(
        .clk(clk),
        .reset(reset),
        .set(set),

        .bus_data(bus_data),
        .bus_addr(bus_addr), 
        .bus_cntl(bus_cntl),
        .device_id(`ICACHE),
        .dst_device_id(`MEM),
        
        .req_signal(icache_miss),//icache_read_miss),  // request signal from device
        .write_memory_signal(1'b0),
        .req(req[`ICACHE]),             // request signal to bus interface.
        .gnt(gnt[`ICACHE]),

        .hsk_valid(hsk_valid),
        .hsk_ack(hsk_ack),

        .receiving_data(receiving_data),
        .addr_in(instr_phy_addr),
        .finish(mem_data_finish),

        .data_in(32'hffff),
        .data_out(M2I_mem_data),
        .addr_out(M2I_mem_addr),
        .cntl_out(),

        .write_signal(icache_write_signal),
        .counter_in(8'b100)      // counter should be from 4 to zero.
    );
    `uselib
   
    initial
    begin
       
    end



    
    assign dma_grant = gnt[`IO]; // when bs_dma get the bus, dma can write whatever it likes
    assign dma_intr_clear = 1'b0;
	`uselib file=/misc/collaboration/382nGPS/382nG6/yhuang/dma.v
    DMA dma(
        .CLK(clk), 
        .CLR(reset), 
        .PRE(set),
        
        .bus_address(dma_bus_addr), 
        .bus_control(dma_bus_cntl), 
        .bus_data(dma_bus_data),
        
        .bus_valid(dma_bus_valid),
        .bus_grant(dma_grant),
        .bus_request(dma_req),
        .bus_finish(dma_finish),
        
        .interrupt_clear(dma_intr_clear),
        .interrupt_flag(dma_intr_flag)
    );
    `uselib
    



    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/bus_interface.v
    dma_station bs_dma(
        .clk(clk),
        .reset(reset),
        .set(set),
        .device_id(`IO),      // 
        .dst_device_id(`MEM),  //
        .bus_data(bus_data),   
        .bus_addr(bus_addr), 
        .bus_cntl(bus_cntl),
        .req(req[`IO]),
        .gnt(gnt[`IO]),
        .hsk_ack(hsk_ack),
        .hsk_valid(hsk_valid),      // 

        .receiving_data(dma_bus_valid), // 
        .finish(dma_finish),         // 

        .req_signal(1'b0), // no mem read 
        .write_memory_signal(dma_req),

        .data_in(dma_bus_data),
        .data_out(dma_bus_data),
        .addr_in(dma_bus_addr),
        .addr_out(dma_bus_addr),

        .counter_in(8'b001),        // read 4 byte each time
        .mem_we_signal(dma_bus_cntl[3:0]),

        .write_signal()   // generate negative puslses to write the Cache/Memory
    ); 
    `uselib

     
	//----------------------------------------------
	//
	//  Main Memory
	//
	//----------------------------------------------
	
	`uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/dram.v
	    Memory memory(
	        .Address(bus_addr[14:0]),
	        .DataIO(mem_dataIO),
	        .write_signal(mem_write_signal),
	        .OE(mem_wr),
	        .we(mem_we)
	    );
	`uselib

    initial 
    begin
        // init 0x0000 - 0x1fff
        //$readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/tc1_3.list", memory.dram0.dram0_0.mem);
        //$readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/tc1_2.list", memory.dram0.dram0_1.mem);
        //$readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/tc1_1.list", memory.dram0.dram0_2.mem);
        //$readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/tc1_0.list", memory.dram0.dram0_3.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_0_0.list", memory.dram0.dram0_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_0_1.list", memory.dram0.dram0_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_0_2.list", memory.dram0.dram0_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_0_3.list", memory.dram0.dram0_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_1_0.list", memory.dram0.dram1_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_1_1.list", memory.dram0.dram1_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_1_2.list", memory.dram0.dram1_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_1_3.list", memory.dram0.dram1_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_2_0.list", memory.dram0.dram2_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_2_1.list", memory.dram0.dram2_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_2_2.list", memory.dram0.dram2_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_2_3.list", memory.dram0.dram2_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_3_0.list", memory.dram0.dram3_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_3_1.list", memory.dram0.dram3_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_3_2.list", memory.dram0.dram3_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_3_3.list", memory.dram0.dram3_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_4_0.list", memory.dram0.dram4_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_4_1.list", memory.dram0.dram4_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_4_2.list", memory.dram0.dram4_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_4_3.list", memory.dram0.dram4_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_5_0.list", memory.dram0.dram5_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_5_1.list", memory.dram0.dram5_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_5_2.list", memory.dram0.dram5_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_5_3.list", memory.dram0.dram5_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_6_0.list", memory.dram0.dram6_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_6_1.list", memory.dram0.dram6_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_6_2.list", memory.dram0.dram6_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_6_3.list", memory.dram0.dram6_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_7_0.list", memory.dram0.dram7_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_7_1.list", memory.dram0.dram7_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_7_2.list", memory.dram0.dram7_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_7_3.list", memory.dram0.dram7_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_8_0.list", memory.dram0.dram8_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_8_1.list", memory.dram0.dram8_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_8_2.list", memory.dram0.dram8_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_8_3.list", memory.dram0.dram8_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_9_0.list", memory.dram0.dram9_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_9_1.list", memory.dram0.dram9_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_9_2.list", memory.dram0.dram9_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_9_3.list", memory.dram0.dram9_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_10_0.list", memory.dram0.drama_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_10_1.list", memory.dram0.drama_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_10_2.list", memory.dram0.drama_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_10_3.list", memory.dram0.drama_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_11_0.list", memory.dram0.dramb_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_11_1.list", memory.dram0.dramb_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_11_2.list", memory.dram0.dramb_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_11_3.list", memory.dram0.dramb_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_12_0.list", memory.dram0.dramc_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_12_1.list", memory.dram0.dramc_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_12_2.list", memory.dram0.dramc_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_12_3.list", memory.dram0.dramc_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_13_0.list", memory.dram0.dramd_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_13_1.list", memory.dram0.dramd_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_13_2.list", memory.dram0.dramd_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_13_3.list", memory.dram0.dramd_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_14_0.list", memory.dram0.drame_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_14_1.list", memory.dram0.drame_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_14_2.list", memory.dram0.drame_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_14_3.list", memory.dram0.drame_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_15_0.list", memory.dram0.dramf_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_15_1.list", memory.dram0.dramf_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_15_2.list", memory.dram0.dramf_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img0_15_3.list", memory.dram0.dramf_3.mem);

        // init 0x2000 - 0x3fff
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_0_0.list", memory.dram1.dram0_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_0_1.list", memory.dram1.dram0_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_0_2.list", memory.dram1.dram0_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_0_3.list", memory.dram1.dram0_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_1_0.list", memory.dram1.dram1_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_1_1.list", memory.dram1.dram1_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_1_2.list", memory.dram1.dram1_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_1_3.list", memory.dram1.dram1_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_2_0.list", memory.dram1.dram2_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_2_1.list", memory.dram1.dram2_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_2_2.list", memory.dram1.dram2_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_2_3.list", memory.dram1.dram2_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_3_0.list", memory.dram1.dram3_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_3_1.list", memory.dram1.dram3_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_3_2.list", memory.dram1.dram3_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_3_3.list", memory.dram1.dram3_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_4_0.list", memory.dram1.dram4_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_4_1.list", memory.dram1.dram4_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_4_2.list", memory.dram1.dram4_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_4_3.list", memory.dram1.dram4_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_5_0.list", memory.dram1.dram5_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_5_1.list", memory.dram1.dram5_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_5_2.list", memory.dram1.dram5_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_5_3.list", memory.dram1.dram5_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_6_0.list", memory.dram1.dram6_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_6_1.list", memory.dram1.dram6_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_6_2.list", memory.dram1.dram6_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_6_3.list", memory.dram1.dram6_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_7_0.list", memory.dram1.dram7_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_7_1.list", memory.dram1.dram7_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_7_2.list", memory.dram1.dram7_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_7_3.list", memory.dram1.dram7_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_8_0.list", memory.dram1.dram8_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_8_1.list", memory.dram1.dram8_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_8_2.list", memory.dram1.dram8_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_8_3.list", memory.dram1.dram8_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_9_0.list", memory.dram1.dram9_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_9_1.list", memory.dram1.dram9_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_9_2.list", memory.dram1.dram9_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_9_3.list", memory.dram1.dram9_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_10_0.list", memory.dram1.drama_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_10_1.list", memory.dram1.drama_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_10_2.list", memory.dram1.drama_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_10_3.list", memory.dram1.drama_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_11_0.list", memory.dram1.dramb_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_11_1.list", memory.dram1.dramb_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_11_2.list", memory.dram1.dramb_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_11_3.list", memory.dram1.dramb_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_12_0.list", memory.dram1.dramc_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_12_1.list", memory.dram1.dramc_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_12_2.list", memory.dram1.dramc_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_12_3.list", memory.dram1.dramc_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_13_0.list", memory.dram1.dramd_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_13_1.list", memory.dram1.dramd_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_13_2.list", memory.dram1.dramd_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_13_3.list", memory.dram1.dramd_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_14_0.list", memory.dram1.drame_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_14_1.list", memory.dram1.drame_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_14_2.list", memory.dram1.drame_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_14_3.list", memory.dram1.drame_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_15_0.list", memory.dram1.dramf_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_15_1.list", memory.dram1.dramf_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_15_2.list", memory.dram1.dramf_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img1_15_3.list", memory.dram1.dramf_3.mem);

        // init 0x4000 - 0x5fff
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_0_0.list", memory.dram2.dram0_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_0_1.list", memory.dram2.dram0_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_0_2.list", memory.dram2.dram0_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_0_3.list", memory.dram2.dram0_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_1_0.list", memory.dram2.dram1_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_1_1.list", memory.dram2.dram1_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_1_2.list", memory.dram2.dram1_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_1_3.list", memory.dram2.dram1_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_2_0.list", memory.dram2.dram2_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_2_1.list", memory.dram2.dram2_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_2_2.list", memory.dram2.dram2_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_2_3.list", memory.dram2.dram2_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_3_0.list", memory.dram2.dram3_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_3_1.list", memory.dram2.dram3_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_3_2.list", memory.dram2.dram3_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_3_3.list", memory.dram2.dram3_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_4_0.list", memory.dram2.dram4_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_4_1.list", memory.dram2.dram4_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_4_2.list", memory.dram2.dram4_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_4_3.list", memory.dram2.dram4_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_5_0.list", memory.dram2.dram5_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_5_1.list", memory.dram2.dram5_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_5_2.list", memory.dram2.dram5_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_5_3.list", memory.dram2.dram5_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_6_0.list", memory.dram2.dram6_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_6_1.list", memory.dram2.dram6_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_6_2.list", memory.dram2.dram6_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_6_3.list", memory.dram2.dram6_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_7_0.list", memory.dram2.dram7_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_7_1.list", memory.dram2.dram7_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_7_2.list", memory.dram2.dram7_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_7_3.list", memory.dram2.dram7_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_8_0.list", memory.dram2.dram8_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_8_1.list", memory.dram2.dram8_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_8_2.list", memory.dram2.dram8_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_8_3.list", memory.dram2.dram8_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_9_0.list", memory.dram2.dram9_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_9_1.list", memory.dram2.dram9_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_9_2.list", memory.dram2.dram9_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_9_3.list", memory.dram2.dram9_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_10_0.list", memory.dram2.drama_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_10_1.list", memory.dram2.drama_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_10_2.list", memory.dram2.drama_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_10_3.list", memory.dram2.drama_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_11_0.list", memory.dram2.dramb_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_11_1.list", memory.dram2.dramb_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_11_2.list", memory.dram2.dramb_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_11_3.list", memory.dram2.dramb_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_12_0.list", memory.dram2.dramc_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_12_1.list", memory.dram2.dramc_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_12_2.list", memory.dram2.dramc_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_12_3.list", memory.dram2.dramc_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_13_0.list", memory.dram2.dramd_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_13_1.list", memory.dram2.dramd_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_13_2.list", memory.dram2.dramd_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_13_3.list", memory.dram2.dramd_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_14_0.list", memory.dram2.drame_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_14_1.list", memory.dram2.drame_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_14_2.list", memory.dram2.drame_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_14_3.list", memory.dram2.drame_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_15_0.list", memory.dram2.dramf_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_15_1.list", memory.dram2.dramf_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_15_2.list", memory.dram2.dramf_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img2_15_3.list", memory.dram2.dramf_3.mem);

        // init 0x6000 - 0x7fff
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_0_0.list", memory.dram3.dram0_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_0_1.list", memory.dram3.dram0_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_0_2.list", memory.dram3.dram0_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_0_3.list", memory.dram3.dram0_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_1_0.list", memory.dram3.dram1_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_1_1.list", memory.dram3.dram1_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_1_2.list", memory.dram3.dram1_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_1_3.list", memory.dram3.dram1_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_2_0.list", memory.dram3.dram2_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_2_1.list", memory.dram3.dram2_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_2_2.list", memory.dram3.dram2_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_2_3.list", memory.dram3.dram2_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_3_0.list", memory.dram3.dram3_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_3_1.list", memory.dram3.dram3_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_3_2.list", memory.dram3.dram3_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_3_3.list", memory.dram3.dram3_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_4_0.list", memory.dram3.dram4_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_4_1.list", memory.dram3.dram4_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_4_2.list", memory.dram3.dram4_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_4_3.list", memory.dram3.dram4_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_5_0.list", memory.dram3.dram5_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_5_1.list", memory.dram3.dram5_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_5_2.list", memory.dram3.dram5_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_5_3.list", memory.dram3.dram5_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_6_0.list", memory.dram3.dram6_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_6_1.list", memory.dram3.dram6_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_6_2.list", memory.dram3.dram6_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_6_3.list", memory.dram3.dram6_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_7_0.list", memory.dram3.dram7_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_7_1.list", memory.dram3.dram7_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_7_2.list", memory.dram3.dram7_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_7_3.list", memory.dram3.dram7_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_8_0.list", memory.dram3.dram8_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_8_1.list", memory.dram3.dram8_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_8_2.list", memory.dram3.dram8_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_8_3.list", memory.dram3.dram8_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_9_0.list", memory.dram3.dram9_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_9_1.list", memory.dram3.dram9_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_9_2.list", memory.dram3.dram9_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_9_3.list", memory.dram3.dram9_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_10_0.list", memory.dram3.drama_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_10_1.list", memory.dram3.drama_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_10_2.list", memory.dram3.drama_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_10_3.list", memory.dram3.drama_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_11_0.list", memory.dram3.dramb_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_11_1.list", memory.dram3.dramb_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_11_2.list", memory.dram3.dramb_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_11_3.list", memory.dram3.dramb_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_12_0.list", memory.dram3.dramc_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_12_1.list", memory.dram3.dramc_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_12_2.list", memory.dram3.dramc_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_12_3.list", memory.dram3.dramc_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_13_0.list", memory.dram3.dramd_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_13_1.list", memory.dram3.dramd_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_13_2.list", memory.dram3.dramd_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_13_3.list", memory.dram3.dramd_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_14_0.list", memory.dram3.drame_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_14_1.list", memory.dram3.drame_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_14_2.list", memory.dram3.drame_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_14_3.list", memory.dram3.drame_3.mem);

        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_15_0.list", memory.dram3.dramf_0.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_15_1.list", memory.dram3.dramf_1.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_15_2.list", memory.dram3.dramf_2.mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yjl/dump_code/img/img3_15_3.list", memory.dram3.dramf_3.mem);

    end

    //-----------------------------------
    //
    // PreMemory Stage
    //
    //------------------------------------
    `uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/premem.v
	premem prememory_stage(
		.IF_vpn(icache_vfn),
		.IF_flush(F_flush),
		.AG_CS(A2P_cs),
		.AG_EXP(A2P_e), //0-page fault; 1-prot
		.AG_WR_VA(A2P_mem_wt_addr),
		.AG_RD_VA(A2P_mem_rd_addr),
		.AG_Valid(A2P_v),
		.AG_CURRENT_EIP(A2P_current_eip),
		.AG_NEXT_EIP(A2P_next_eip),
		.AG_REL_EIP(A2P_rel_eip),
		.AG_DISP(A2P_disp),
		.AG_IMM(A2P_imm),
		.AG_DEST_GPR(A2P_dest_gpr),
		.AG_SRC_GPR(A2P_src_gpr),
		.AG_DEST_SEGR(A2P_dest_segr),
		.AG_SRC_SEGR(A2P_src_segr),
		.AG_DEST_MMX(A2P_dest_mmx),
		.AG_SRC_MMX(A2P_src_mmx),
		.MEM2Pre_stall(mem2pre_stall),
		.M2P_MEM_WR(m2p_mem_wr),
		.MEM_WR_VA(m2p_wr_va),
		.MEM_WR_SIZE(m2p_wr_size),
		.E2P_MEM_WR(E2P_mem_wt_en),
		.EXE_WR_VA(E2P_mem_wt_addr),
		.EXE_WR_SIZE(E2P_mem_wt_size),
		.W2P_MEM_WR(W2P_mem_wt_en),
		.WB_WR_VA(W2P_mem_wt_addr),
		.WB_WR_SIZE(W2P_mem_wt_size),
		.IF_pfn(icache_pfn),
		.IF_tlbmiss(icache_tlb_miss),
		.IF_present(icache_tlb_present),
		.IF_rw(icache_tlb_rw),
		.PRE_CS(pre_cs),
		.PRE_EXP(pre_exp),
		.PRE_WR(pre_wr),
		.PRE_RD_PA(pre_rd_pa),
		.PRE_WR_VA(pre_wr_va),
		.PRE_WR_PA1(pre_wr_pa1),
		.PRE_WR_PA2(pre_wr_pa2),
		.PRE_WR_PA3(pre_wr_pa3),
		.PRE_size(pre_size),
		.PRE_MEM_Valid(pre_mem_valid),
		//.PRE_needW(pre_needw),
		.PRE_Valid(pre_valid),
		.PRE_unalign(pre_unalign),
		.PRE_effsize(pre_effsize),
		.PRE_uaSSE(pre_uasse),
		.PRE_PCD(pre_pcd),
		.PRE_CURRENT_EIP(pre_current_eip),
		.PRE_NEXT_EIP(pre_next_eip),
		.PRE_REL_EIP(pre_rel_eip),
		.PRE_DISP(pre_disp),
		.PRE_IMM(pre_imm),
		.PRE_DEST_GPR(pre_dest_gpr),
		.PRE_SRC_GPR(pre_src_gpr),
		.PRE_DEST_SEGR(pre_dest_segr),
		.PRE_SRC_SEGR(pre_src_segr),
		.PRE_DEST_MMX(pre_dest_mmx),
		.PRE_SRC_MMX(pre_src_mmx),
		.PRE_stall(pre_stall),
		.PRE_dest_gpr_sel(P2L_dest_gpr_sel),
		.PRE_src_gpr_sel(P2L_src_gpr_sel),
		.PRE_dest_segr_sel(P2L_dest_segr_sel),
		.PRE_dest_mmx_sel(P2L_dest_mmx_sel),
		.PRE_dest_gpr_wt(P2L_dest_gpr_wt),
		.PRE_src_gpr_wt(P2L_src_gpr_wt),
		.PRE_dest_segr_wt(P2L_dest_segr_wt),
		.PRE_dest_mmx_wt(P2L_dest_mmx_wt),
		.PRE_dest_gpr_type(P2L_dest_gpr_type),
		.PRE_src_gpr_type(P2L_src_gpr_type),
		
	
		
		.clk(clk),
		.clr(reset)
     );           
	`uselib

    //-----------------------------------
    //
    // Memory Stage
    //
    //------------------------------------
	
    `uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/mem.v
	mem memory_stage(
		.IF_flush(F_flush),
		.PRE_CS(pre_cs),
		.PRE_EXP(pre_exp),
		.PRE_RD_PA(pre_rd_pa),
		.PRE_WR_VA(pre_wr_va),
		.PRE_WR_PA1(pre_wr_pa1),
		.PRE_WR_PA2(pre_wr_pa2),
		.PRE_WR_PA3(pre_wr_pa3),
		.PRE_size(pre_size),
		.PRE_effsize(pre_effsize),
		.PRE_WR(pre_wr),
		.PRE_MEM_Valid(pre_mem_valid),
		//.PRE_needW(pre_needw),
		.PRE_unalign(pre_unalign),
		.PRE_uaSSE(pre_uasse),
		.PRE_PCD(pre_pcd),
		.PRE_Valid(pre_valid),
		//.PRE_pf_exp(pre_pf_exp),
		//.PRE_prot_exp(pre_prot_exp),
		.PRE_CURRENT_EIP(pre_current_eip),
		.PRE_NEXT_EIP(pre_next_eip),
		.PRE_REL_EIP(pre_rel_eip),
		.PRE_DISP(pre_disp),
		.PRE_IMM(pre_imm),
		.PRE_DEST_GPR(pre_dest_gpr),
		.PRE_SRC_GPR(pre_src_gpr),
		.PRE_DEST_SEGR(pre_dest_segr),
		.PRE_SRC_SEGR(pre_src_segr),
		.PRE_DEST_MMX(pre_dest_mmx),
		.PRE_SRC_MMX(pre_src_mmx),
		.EXE_stall(E2M_stall),
		.CMT(cmt),
		.CMT_PA1(cmt_pa1),
		.CMT_PA2(cmt_pa2),
		.CMT_PA3(cmt_pa3),
		.CMT_addr(cmt_addr),
		.CMT_Data(cmt_data),
		.CMT_size(cmt_size),
		.MEM_CS(mem_cs),
		.MEM_EXP(mem_exp),
		.MEM2Pre_stall(mem2pre_stall),
		.MEM2CMT_stall(mem2cmt_stall),
		.MEM_RD_data(mem_rd_data),
		.MEM_Valid(mem_valid),
		//.MEM_size(mem_size),
		.MEM_PCD(mem_pcd),
		.MEM_RReq(dc_read_req),
		.MEM_WReq(dc_write_req),
		.MEM_WR_VA(mem_wr_va),
		.MEM_WR_PA1(mem_wr_pa1),
		.MEM_WR_PA2(mem_wr_pa2),
		.MEM_WR_PA3(mem_wr_pa3),
		.MEM_CURRENT_EIP(mem_current_eip),
		.MEM_NEXT_EIP(mem_next_eip),
		.MEM_REL_EIP(mem_rel_eip),
		.MEM_DISP(mem_disp),
		.MEM_IMM(mem_imm),
		.MEM_DEST_GPR(mem_dest_gpr),
		.MEM_SRC_GPR(mem_src_gpr),
		.MEM_DEST_SEGR(mem_dest_segr),
		.MEM_SRC_SEGR(mem_src_segr),
		.MEM_DEST_MMX(mem_dest_mmx),
		.MEM_SRC_MMX(mem_src_mmx),
		.M2P_MEM_WR(m2p_mem_wr),
		.M2P_WR_VA(m2p_wr_va),
		.M2P_WR_SIZE(m2p_wr_size),
		.MEM_dest_gpr_sel(M2L_dest_gpr_sel),
		.MEM_src_gpr_sel(M2L_src_gpr_sel),
		.MEM_dest_segr_sel(M2L_dest_segr_sel),
		.MEM_dest_mmx_sel(M2L_dest_mmx_sel),
		.MEM_dest_gpr_wt(M2L_dest_gpr_wt),
		.MEM_src_gpr_wt(M2L_src_gpr_wt),
		.MEM_dest_segr_wt(M2L_dest_segr_wt),
		.MEM_dest_mmx_wt(M2L_dest_mmx_wt),
		.MEM_dest_gpr_type(M2L_dest_gpr_type),
		.MEM_src_gpr_type(M2L_src_gpr_type),
		.Bus_Req_address(dc_req_address),
		.memory_data_wb(dc_wb_data),
		.memory_we_wb(dc_we),
		.memory_ready(dc_memory_ready),
		.memory_data_lrb(dc_memory_data_lrb),
		
		.clk(clk),
		.clr(reset));
	`uselib

    //-----------------------------------
    //
    // Bus to Main Memory interface
    //
    //------------------------------------
    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/bus_interface.v
    memory_station bs_mem(
        .clk(clk),
        .reset(reset),
        .set(set),
        //.data_in(mem_data),
        .bus_data(bus_data),
        .bus_addr(bus_addr), 
        .bus_cntl(bus_cntl),
        .mem_data(mem_dataIO),
        .device_id(`MEM),
        .ready_bit(1'b1),
        //.dst_device_id(`ICACHE),
        .req(req[`MEM]),
        .gnt(1'b0),
        .hsk_valid(hsk_valid),
        .hsk_ack(hsk_ack),
        .req_signal(1'b0),
        .write_memory_signal(1'b0),
        .device_wr(mem_wr),
        .device_we_out(mem_we),
        .write_signal(mem_write_signal)
        //.addr_in(instr_phy_addr),
        //.cntl_signal(),
        //.finish(mem_data_finish),
        //.data_out(M2I_mem_data),
        //.addr_out(M2I_mem_addr),
        //.cntl_out()
    );
    `uselib
  
    
    
    reg [127:0] tb_instruction;
    reg [7:0]   upc;
    reg         upc_valid;

    initial
    begin
        #CLK
            upc_valid = 0;
            tb_instruction = 128'hb800_020c_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h668e_d800_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'hbb00_0b00_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h668e_d300_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'hc1f8_1000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h7505_0000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'hbbff_ffff_ff00_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h6681_c350_f500_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h89dc_0000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h5000_0000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'hff30_0000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'hfec4_0000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h5800_0000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h9a3f_0000_0000_0400_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'h5c00_0000_0000_0000_0000_0000_0000_0000;
        #CLK
            tb_instruction = 128'hf400_0000_0000_0000_0000_0000_0000_0000;
            upc_valid = 1;
            upc = 8'h05;
    end

    //---------------------------------------
    //  Decode Stage
    //---------------------------------------
    // decode

    F2D_pipeline_register F2D_reg(
        .clk(clk),
        .reset(reset),
        .set(set),
        .stall_n(F2D_stall_n),
        .valid(F2D_valid_in),

        .F2D_instruction_in(F2D_instruction_in),
        .F2D_upc_in(F2D_upc_in),
        .F2D_upc_valid_in(F2D_upc_valid_in),
        .F2D_current_eip_in(F2D_current_eip_in),
        .F2D_next_eip_in(F2D_next_eip_in),
        .F2D_instr_valid_gt_16_in(F2D_instr_valid_gt_16_in),
        .F2D_exception_in(F2D_exception_in),
        .F2D_exp_vector_in(F2D_exp_vector_in),
        .F2D_valid_in(F2D_valid_in),

        .F2D_instruction_out(F2D_instruction_out),
        .F2D_upc_out(F2D_upc_out),
        .F2D_upc_valid_out(F2D_upc_valid_out),
        .F2D_current_eip_out(F2D_current_eip_out),
        .F2D_next_eip_out(F2D_next_eip_out),
        .F2D_instr_valid_gt_16_out(F2D_instr_valid_gt_16_out),
        .F2D_exception_out(F2D_exception_out),
        .F2D_exp_vector_out(F2D_exp_vector_out),
        .F2D_valid_out(F2D_valid_out)
    );


    `uselib file=/misc/collaboration/382nGPS/382nG6/yjl/decode_now.v
    decode_stage decode_tb(
        .clk(clk),
        .reset(reset),
        .set(set),
        //.F2D_instruction(F2D_instruction_out),
        .F2D_instruction(F2D_instruction_out),
        .F2D_valid(F2D_valid_out),
        .F2D_upc(F2D_upc_out),
        .F2D_upc_valid(F2D_upc_valid_out),
        .F2D_current_eip(F2D_current_eip_out),
        .F2D_next_eip(F2D_next_eip_out),
        .F2D_instr_valid_gt_16(F2D_instr_valid_gt_16_out),
        .F2D_exception(F2D_exception_out),
        //.F2D_icache_addr_part(),

        .L2D_stall(L2D_stall),
        .X2D_flush(F_flush),

        .D2L_control_signal(D2L_control_signal_in),
        .D2L_exception(D2L_exception_in),
        .D2L_next_eip(D2L_next_eip_in),
        .D2L_current_eip(D2L_current_eip_in),
        // sib
        //.D2L_scale(D2L_scale_in),
        //.D2L_base_gpr_id(D2L_base_gpr_id_in),
        //.D2L_index_gpr_id(D2L_index_gpr_id_in),
        //.D2L_need_base_gpr(D2L_need_base_gpr_in),
        //.D2L_need_index_gpr(D2L_need_index_gpr_in),
        //.D2L_addr_segr_id(D2L_addr_segr_id_in),
        // literal
        .D2L_imm(D2L_imm_in),
        .D2L_disp(D2L_disp_in),
        .D2L_stall_n(D2L_stall_n),
        .D2L_valid(D2L_valid_in),
        .D2F_instr_length(D2F_instr_length),
        .D2F_decode_failed(D2F_decode_failed),
        .D2F_atomic(D2F_atomic),
        .D2F_stall(D2F_stall),
        .D2F_split_instr(D2F_split_instr)
     );
     `uselib
    
    D2L_pipeline_register D2L_reg(
        .clk(clk), 
        .reset(reset), 
        .set(set),
        .stall_n(D2L_stall_n), 
        .flush(D2L_flush),
        .valid(D2L_valid_in),
        
        .D2L_control_signal_in(D2L_control_signal_in),
        .D2L_next_eip_in(D2L_next_eip_in),
        .D2L_current_eip_in(D2L_current_eip_in),
        .D2L_imm_in(D2L_imm_in),
        .D2L_valid_in(D2L_valid_in),    // propagate valid signal
        .D2L_disp_in(D2L_disp_in),
        .D2L_exception_in(D2L_exception_in),

        .D2L_control_signal_out(D2L_control_signal_out),
        .D2L_next_eip_out(D2L_next_eip_out),
        .D2L_current_eip_out(D2L_current_eip_out),
        .D2L_imm_out(D2L_imm_out),
        .D2L_disp_out(D2L_disp_out),
        .D2L_valid_out(D2L_valid_out),
        .D2L_exception_out(D2L_exception_out),
        //.D2L_scale_out(D2L_scale_out),              //
        //.D2L_base_gpr_id_out(D2L_base_gpr_id_out),        //
        //.D2L_index_gpr_id_out(D2L_index_gpr_id_out),       //
        //.D2L_need_base_gpr_out(D2L_need_base_gpr_out),      //
        //.D2L_need_index_gpr_out(D2L_need_index_gpr_out),     //
        //.D2L_addr_segr_id_out(D2L_addr_segr_id_out),        //

        // not necessary 
        .D2L_base_gpr_id_in(D2L_control_signal_in[`BASE_GPR_SEL]),        //
        .D2L_index_gpr_id_in(D2L_control_signal_in[`INDEX_GPR_SEL]),       //
        .D2L_need_base_gpr_in(D2L_control_signal_in[`READ_BASE_GPR]),      //
        .D2L_need_index_gpr_in(D2L_control_signal_in[`READ_INDEX_GPR]),     //
        .D2L_addr_segr_id_in(D2L_control_signal_in[`ADDR_SEGR_SEL]),        //
        .D2L_scale_in(D2L_control_signal_in[`SCALE]),
        .D2L_disp_sel_in(D2L_control_signal_in[`DISP_SEL]),
        .D2L_imm_sel_in(D2L_control_signal_in[`IMM_SEL])

    );
	
	//=============================
	//	from WB
	//=============================
	
    /*
		initial
		begin	
                A2L_stall = 0;
		
		#CLK	

		//		D2L_next_eip = CYCLE;
				//D2L_v = 1;
				//D2L_cs = 128'b0;
				
				P2A_stall = 0;
				
				E2L_dest_gpr_wt = 0;
				E2L_src_gpr_wt = 0;
				E2L_dest_segr_wt = 0;

				A2L_dest_gpr_wt = 0;
				A2L_src_gpr_wt = 0;
				A2L_dest_segr_wt = 0;


				M2L_dest_gpr_wt = 0;
				M2L_src_gpr_wt = 0;
				M2L_dest_segr_wt = 0;
				P2L_dest_gpr_wt = 0;
				P2L_src_gpr_wt = 0;
				P2L_dest_segr_wt = 0;
				
				//W2L_dest_gpr = 32'h00004000;
				//W2L_dest_gpr_sel = 0;
				//W2L_dest_gpr_wt = 1;
				//W2L_dest_gpr_type = 2;
				//
				//W2L_src_gpr = 32'h00000101;
				//W2L_src_gpr_sel = 1;
				//W2L_src_gpr_wt = 1;
				//W2L_src_gpr_type = 2;
				//
				//W2L_dest_segr = 16'h0808;
				//W2L_dest_segr_sel = 0;
				//W2L_dest_segr_wt = 1;
				//
				//
				//
		#CLK	//W2L_dest_gpr = 32'h00000202;
				//W2L_dest_gpr_sel = 2;
				//W2L_dest_gpr_wt = 1;
				//W2L_dest_gpr_type = 2;
				//
				//W2L_src_gpr = 32'h00000303;
				//W2L_src_gpr_sel = 3;
				//W2L_src_gpr_wt = 1;
				//W2L_src_gpr_type = 2;
				//
				//W2L_dest_segr = 16'h0909;
				//W2L_dest_segr_sel = 1;
				//W2L_dest_segr_wt = 1;
				//
		#CLK	//W2L_dest_gpr = 32'h00000404;
				//W2L_dest_gpr_sel = 4;
				//W2L_dest_gpr_wt = 1;
				//W2L_dest_gpr_type = 2;
				//
				//W2L_src_gpr = 32'h00000505;
				//W2L_src_gpr_sel = 5;
				//W2L_src_gpr_wt = 1;
				//W2L_src_gpr_type = 2;
				//
				//W2L_dest_segr = 16'h0A0A;
				//W2L_dest_segr_sel = 2;
				//W2L_dest_segr_wt = 1;
				//
		#CLK	//W2L_dest_gpr = 32'h00000606;
				//W2L_dest_gpr_sel = 6;
				//W2L_dest_gpr_wt = 1;
				//W2L_dest_gpr_type = 2;
				//
				//W2L_src_gpr = 32'h00000707;
				//W2L_src_gpr_sel = 7;
				//W2L_src_gpr_wt = 1;
				//W2L_src_gpr_type = 2;
				//
				//W2L_dest_segr = 16'h0B0B;
				//W2L_dest_segr_sel = 3;
				//W2L_dest_segr_wt = 1;
				//
		#CLK	//W2L_dest_segr = 16'h0C0C;
				//W2L_dest_segr_sel = 4;
				//W2L_dest_segr_wt = 1;		
				//
		#CLK	//W2L_dest_segr = 16'h0D0D;
				//W2L_dest_segr_sel = 5;
				//W2L_dest_segr_wt = 1;
				//
		//======//===================================				
				//
		#CLK	//W2L_dest_gpr_wt = 0;
				//W2L_src_gpr_wt = 0;
				//W2L_dest_segr_wt = 0;
		
				//D2L_next_eip = CYCLE;
				//D2L_v = 1;					
				//D2L_cs[`DEST_GPR_RD] = 1;
				//D2L_cs[`SRC_GPR_RD] = 1;
				//D2L_cs[`BASE_GPR_RD] = 1;
				//D2L_cs[`INDEX_GPR_RD] = 1;
				//D2L_cs[`DEST_SEGR_RD] = 1;
				//D2L_cs[`SRC_SEGR_RD] = 1;
				//D2L_cs[`SEGMENT_SEGR_RD] = 1;
				//D2L_cs[`DEST_MMX_RD] = 0;
				//D2L_cs[`SRC_MMX_RD] = 0;
				//
				//D2L_cs[`DEST_GPR_WT] = 0;
				//D2L_cs[`SRC_GPR_WT] = 0;
				//D2L_cs[`DEST_SEGR_WT] = 0;
				//D2L_cs[`DEST_MMX_WT] = 0;
				//
				//D2L_cs[`DEST_GPR_SEL] = 0;
				//D2L_cs[`SRC_GPR_SEL] = 1;
				//D2L_cs[`BASE_GPR_SEL] = 2;
				//D2L_cs[`INDEX_GPR_SEL] = 3;
				//D2L_cs[`DEST_SEGR_SEL] = 2;
				//D2L_cs[`SRC_SEGR_SEL] = 1;
				//D2L_cs[`SEGMENT_SEGR_SEL] = 2;
				//
				//D2L_cs[`DEST_GPR_TYPE] = 0;
				//D2L_cs[`SRC_GPR_TYPE] = 0;
				//
				//D2L_cs[`DATA_TYPE] = 0;
				//D2L_cs[`AUTO_INC_SEL] = 1;
				//D2L_cs[`PPMM] = 1;
				//D2L_cs[`INDEX_SCALE_SEL] = 1;
				//D2L_cs[`DISP_SEL] = 1;
				//D2L_disp = 32'h00000002;
		
		
				
		//#CLK	D2L_next_eip = CYCLE;
				
				
		//#CLK	D2L_next_eip = CYCLE;
		
		//#CLK	
				
		
		//#CLK
		//#CLK	$finish;		
				
		
			
	    data_in = 0;
				
			
		end
        */	
	
	
	






    //-----------------------------------
    //
    // LoadReg Stage
    //
    //------------------------------------

	wire[31:0] gpr0, gpr1, gpr2, gpr3, gpr4, gpr5, gpr6, gpr7;
	wire[15:0] segr0, segr1, segr2, segr3, segr4, segr5;
	
    `uselib file=/misc/collaboration/382nGPS/382nG6/yhuang/lr_stage.v
    LR_Stage lr_stage(
        // global signal
        .CLK(clk), 
        .CLR(reset), 
        .PRE(set),
        
        .F2L_flush(F_flush),

        // from DE stage
        .D2L_v(D2L_valid_out),
        .D2L_cs(D2L_control_signal_out),
        .D2L_next_eip(D2L_next_eip_out),
		.D2L_current_eip(D2L_current_eip_out),
        .D2L_disp(D2L_disp_out),
        .D2L_imm(D2L_imm_out),
        .D2L_e(D2L_exception_out),
        .D2L_vector(),
        
        // to DE stage
        .L2D_stall(L2D_stall),
       
        // to AG stage
		.L2A_v(L2A_v),
		.L2A_cs(L2A_cs),
        .L2A_e(L2A_e),
		.L2A_next_eip(L2A_next_eip),
		.L2A_current_eip(L2A_current_eip),
		.L2A_disp(L2A_disp),
		.L2A_imm(L2A_imm),
		.L2A_dest_gpr(L2A_dest_gpr),
		.L2A_dest_gpr_old(L2A_dest_gpr_old),
		.L2A_src_gpr(L2A_src_gpr),
		.L2A_src_gpr_old(L2A_src_gpr_old),
		.L2A_base_gpr(L2A_base_gpr),
		.L2A_index_gpr(L2A_index_gpr),
		.L2A_dest_segr(L2A_dest_segr),
		.L2A_src_segr(L2A_src_segr),
		.L2A_segment_segr(L2A_segment_segr),
		.L2A_dest_mmx(L2A_dest_mmx),
		.L2A_src_mmx(L2A_src_mmx),
		
		.L2W_code_segment(L2W_code_segment),
		
		// from AG, for stall check
		.A2L_stall(A2L_stall),
		
		// from AG, for dep check
		.A2L_dest_gpr_sel(A2L_dest_gpr_sel),
		.A2L_src_gpr_sel(A2L_src_gpr_sel),
		.A2L_dest_segr_sel(A2L_dest_segr_sel),
		.A2L_dest_mmx_sel(A2L_dest_mmx_sel),
		.A2L_dest_gpr_wt(A2L_dest_gpr_wt),
		.A2L_src_gpr_wt(A2L_src_gpr_wt),
		.A2L_dest_segr_wt(A2L_dest_segr_wt),
		.A2L_dest_mmx_wt(A2L_dest_mmx_wt),
		.A2L_dest_gpr_type(A2L_dest_gpr_type),
		.A2L_src_gpr_type(A2L_src_gpr_type),
		
		// from PRE, for dep check
		.P2L_dest_gpr_sel(P2L_dest_gpr_sel),
		.P2L_src_gpr_sel(P2L_src_gpr_sel),
		.P2L_dest_segr_sel(P2L_dest_segr_sel),
		.P2L_dest_mmx_sel(P2L_dest_mmx_sel),
		.P2L_dest_gpr_wt(P2L_dest_gpr_wt),
		.P2L_src_gpr_wt(P2L_src_gpr_wt),
		.P2L_dest_segr_wt(P2L_dest_segr_wt),
		.P2L_dest_mmx_wt(P2L_dest_mmx_wt),
		.P2L_dest_gpr_type(P2L_dest_gpr_type),
		.P2L_src_gpr_type(P2L_src_gpr_type),
		
		// from MEM, for dep check
		.M2L_dest_gpr_sel(M2L_dest_gpr_sel),
		.M2L_src_gpr_sel(M2L_src_gpr_sel),
		.M2L_dest_segr_sel(M2L_dest_segr_sel),
		.M2L_dest_mmx_sel(M2L_dest_mmx_sel),
		.M2L_dest_gpr_wt(M2L_dest_gpr_wt),
		.M2L_src_gpr_wt(M2L_src_gpr_wt),
		.M2L_dest_segr_wt(M2L_dest_segr_wt),
		.M2L_dest_mmx_wt(M2L_dest_mmx_wt),
		.M2L_dest_gpr_type(M2L_dest_gpr_type),
		.M2L_src_gpr_type(M2L_src_gpr_type),	
		
		// from EX, for dep check
		.E2L_dest_gpr_sel(E2L_dest_gpr_sel),
		.E2L_src_gpr_sel(E2L_src_gpr_sel),
		.E2L_dest_segr_sel(E2L_dest_segr_sel),
		.E2L_dest_mmx_sel(E2L_dest_mmx_sel),
		.E2L_dest_gpr_wt(E2L_dest_gpr_wt),
		.E2L_src_gpr_wt(E2L_src_gpr_wt),
		.E2L_dest_segr_wt(E2L_dest_segr_wt),
		.E2L_dest_mmx_wt(E2L_dest_mmx_wt),
		.E2L_dest_gpr_type(E2L_dest_gpr_type),
		.E2L_src_gpr_type(E2L_src_gpr_type),
		
		// from WB, for dep check
		.W2L_dest_gpr_sel(W2L_dest_gpr_sel),
		.W2L_src_gpr_sel(W2L_src_gpr_sel),
		.W2L_dest_segr_sel(W2L_dest_segr_sel),
		.W2L_dest_mmx_sel(W2L_dest_mmx_sel),
		.W2L_dest_gpr_wt(W2L_dest_gpr_wt),
		.W2L_src_gpr_wt(W2L_src_gpr_wt),
		.W2L_dest_segr_wt(W2L_dest_segr_wt),
		.W2L_dest_mmx_wt(W2L_dest_mmx_wt),
		.W2L_dest_gpr_type(W2L_dest_gpr_type),
		.W2L_src_gpr_type(W2L_src_gpr_type),
		
		// from WB, for register write back
		.W2L_dest_gpr(W2L_dest_gpr),
		.W2L_src_gpr(W2L_src_gpr),
		.W2L_dest_segr(W2L_dest_segr),
		.W2L_dest_mmx(W2L_dest_mmx),
		
		// from WB, for auto inc/dec direction
		.W2L_eflags(W2L_eflags),
		
		.gpr0(gpr0), 
		.gpr1(gpr1), 
		.gpr2(gpr2), 
		.gpr3(gpr3), 
		.gpr4(gpr4), 
		.gpr5(gpr5), 
		.gpr6(gpr6), 
		.gpr7(gpr7),
		
		.segr0(segr0),
		.segr1(segr1),
		.segr2(segr2),
		.segr3(segr3),
		.segr4(segr4),
		.segr5(segr5)
    );

    `uselib


    //-----------------------------------
    //
    // AddressGeneration Stage
    //
    //------------------------------------


    `uselib file=/misc/collaboration/382nGPS/382nG6/yhuang/ag_stage.v
    AG_Stage ag_stage(
		// global control signals
		.CLK(clk), 
		.CLR(reset), 
		.PRE(set),
		
        .F2A_flush(F_flush),

		// from LR stage
		.L2A_v(L2A_v),
		.L2A_cs(L2A_cs),
        .L2A_e(L2A_e),
		.L2A_next_eip(L2A_next_eip),
		.L2A_current_eip(L2A_current_eip),
		.L2A_disp(L2A_disp),
		.L2A_imm(L2A_imm),
		.L2A_dest_gpr(L2A_dest_gpr),
		.L2A_dest_gpr_old(L2A_dest_gpr_old),
		.L2A_src_gpr(L2A_src_gpr),
		.L2A_src_gpr_old(L2A_src_gpr_old),
		.L2A_base_gpr(L2A_base_gpr),
		.L2A_index_gpr(L2A_index_gpr),
		.L2A_dest_segr(L2A_dest_segr),
		.L2A_src_segr(L2A_src_segr),
		.L2A_segment_segr(L2A_segment_segr),
		.L2A_dest_mmx(L2A_dest_mmx),
		.L2A_src_mmx(L2A_src_mmx),
		
		//to LR stage, for stall chek
        .A2F_code_segment_limit(A2F_cs_segr_limit),
		.A2L_stall(A2L_stall),
		
		// to LR stage, for dep check
		.A2L_dest_gpr_sel(A2L_dest_gpr_sel),
		.A2L_src_gpr_sel(A2L_src_gpr_sel),
		.A2L_dest_segr_sel(A2L_dest_segr_sel),
		.A2L_dest_mmx_sel(A2L_dest_mmx_sel),
		.A2L_dest_gpr_wt(A2L_dest_gpr_wt),
		.A2L_src_gpr_wt(A2L_src_gpr_wt),
		.A2L_dest_segr_wt(A2L_dest_segr_wt),
		.A2L_dest_mmx_wt(A2L_dest_mmx_wt),
		.A2L_dest_gpr_type(A2L_dest_gpr_type),
		.A2L_src_gpr_type(A2L_src_gpr_type),
		
		// from PRE stage, for stall check
		.P2A_stall(pre_stall),
		
		// to PRE stage
		.A2P_v(A2P_v),
		.A2P_e(A2P_e),
		.A2P_cs(A2P_cs),
		.A2P_next_eip(A2P_next_eip),
		.A2P_current_eip(A2P_current_eip),
		.A2P_rel_eip(A2P_rel_eip),
		.A2P_disp(A2P_disp),
		.A2P_imm(A2P_imm),
		.A2P_dest_gpr(A2P_dest_gpr),
		.A2P_src_gpr(A2P_src_gpr),
		.A2P_dest_segr(A2P_dest_segr),
		.A2P_src_segr(A2P_src_segr),
		.A2P_dest_mmx(A2P_dest_mmx),
		.A2P_src_mmx(A2P_src_mmx),
		.A2P_mem_rd_addr(A2P_mem_rd_addr),
		.A2P_mem_wt_addr(A2P_mem_wt_addr)
	);
`uselib



    //-----------------------------------
    //
    // Execution Stage
    //
    //------------------------------------


		
    `uselib file=/misc/collaboration/382nGPS/382nG6/yhuang/ex_stage.v
		EX_STAGE ex_stage(
			// inputs: global control
			.CLK(clk),
			.CLR(reset),
			.PRE(set),

            // inputs: from FETCH
            .F2E_flush(F_flush),
			
			// inputs: from MEM
			.M2E_v(mem_valid),
			.M2E_e(mem_exp),
			.M2E_cs(mem_cs),
			.M2E_next_eip(mem_next_eip),
			.M2E_current_eip(mem_current_eip),
			.M2E_rel_eip(mem_rel_eip),
			.M2E_dest_gpr(mem_dest_gpr),
			.M2E_dest_segr(mem_dest_segr),
			.M2E_dest_mmx(mem_dest_mmx),
			.M2E_src_gpr(mem_src_gpr),
			.M2E_src_segr(mem_src_segr),
			.M2E_src_mmx(mem_src_mmx),
			.M2E_disp(mem_disp),
			.M2E_imm(mem_imm),
			.M2E_mem_data(mem_rd_data),
			.M2E_mem_wt_addr(mem_wr_va),
			.M2E_PCD(mem_pcd),
			.M2E_WR_PA1(mem_wr_pa1),
			.M2E_WR_PA2(mem_wr_pa2),
			.M2E_WR_PA3(mem_wr_pa3),
			
			// inputs: from WB
			.W2E_stall(W2E_stall),
			.W2E_eflags(W2E_eflags),
			
			// outputs: to LR
			.E2L_dest_gpr_sel(E2L_dest_gpr_sel),
			.E2L_src_gpr_sel(E2L_src_gpr_sel),
			.E2L_dest_segr_sel(E2L_dest_segr_sel),
			.E2L_dest_mmx_sel(E2L_dest_mmx_sel),
			.E2L_dest_gpr_wt(E2L_dest_gpr_wt),
			.E2L_src_gpr_wt(E2L_src_gpr_wt),
			.E2L_dest_segr_wt(E2L_dest_segr_wt),
			.E2L_dest_mmx_wt(E2L_dest_mmx_wt),
			.E2L_dest_gpr_type(E2L_dest_gpr_type),
			.E2L_src_gpr_type(E2L_src_gpr_type),
			
			// outputs to PRE
			.E2P_mem_wt_addr(E2P_mem_wt_addr),
			.E2P_mem_wt_size(E2P_mem_wt_size),
			.E2P_mem_wt_en(E2P_mem_wt_en),

			// outputs: to MEM
			.E2M_stall(E2M_stall),
			
			// outputs: to WB
			.E2W_v(E2W_v),
			.E2W_e(E2W_e),
			.E2W_cs(E2W_cs),
			.E2W_next_eip(E2W_next_eip),
			.E2W_current_eip(E2W_current_eip),
			.E2W_disp(E2W_disp),
			.E2W_rel_eip(E2W_rel_eip),
			.E2W_dest_gpr(E2W_dest_gpr),
			.E2W_src_gpr(E2W_src_gpr),
			.E2W_result(E2W_result),
			.E2W_new_eflags(E2W_new_eflags),
			.E2W_mem_wt_addr(E2W_mem_wt_addr),
			.E2W_WR_PA1(E2W_wr_pa1),
			.E2W_WR_PA2(E2W_wr_pa2),
			.E2W_WR_PA3(E2W_wr_pa3)
		);
		`uselib


    //-----------------------------------
    //
    // WriteBack(Commit) Stage
    //
    //------------------------------------

    	`uselib file=/misc/collaboration/382nGPS/382nG6/yhuang/wb_stage.v
		WB_STAGE wb_stage(
			// input: global control signals
			.CLK(clk), 
			.CLR(reset), 
			.PRE(set),
			
			.L2W_code_segment(L2W_code_segment),
			
			// input: from MEM
			.M2W_mem_wt_r(mem2cmt_stall),
			//.M2W_mem_wt_r(1'b0),
			
			// input: from EX
			.E2W_v(E2W_v),
			.E2W_e(E2W_e),
			.E2W_cs(E2W_cs),
			.E2W_next_eip(E2W_next_eip),
			.E2W_current_eip(E2W_current_eip),
			.E2W_abs_eip(E2W_disp),
			.E2W_rel_eip(E2W_rel_eip),
			.E2W_dest_gpr(E2W_dest_gpr),
			.E2W_src_gpr(E2W_src_gpr),
			.E2W_result(E2W_result),
			.E2W_new_eflags(E2W_new_eflags),
			.E2W_mem_wt_addr(E2W_mem_wt_addr),
			.E2W_WR_PA1(E2W_wr_pa1),
			.E2W_WR_PA2(E2W_wr_pa2),
			.E2W_WR_PA3(E2W_wr_pa3),

        
			// output: to FE
	        .W2F_exception_id(W2F_exception),
			.W2F_new_eip(W2F_br_eip),
			.W2F_br_taken(W2F_branch_taken),
			.W2F_eip_ld(W2F_ld_eip),
			.W2F_current_eip(W2F_current_eip),
            .W2F_code_segment(W2F_cs_segr_value),
            .W2F_halt(hlt_signal),
			
			// outputs: to LR
		    .W2L_dest_gpr_sel(W2L_dest_gpr_sel),
		    .W2L_src_gpr_sel(W2L_src_gpr_sel),
		    .W2L_dest_segr_sel(W2L_dest_segr_sel),
		    .W2L_dest_mmx_sel(W2L_dest_mmx_sel),
		    .W2L_dest_gpr_wt(W2L_dest_gpr_wt),
		    .W2L_src_gpr_wt(W2L_src_gpr_wt),
		    .W2L_dest_segr_wt(W2L_dest_segr_wt),
		    .W2L_dest_mmx_wt(W2L_dest_mmx_wt),
		    .W2L_dest_gpr_type(W2L_dest_gpr_type),
		    .W2L_src_gpr_type(W2L_src_gpr_type),
		    
		    // from WB, for register write back
		    .W2L_dest_gpr(W2L_dest_gpr),
		    .W2L_src_gpr(W2L_src_gpr),
		    .W2L_dest_segr(W2L_dest_segr),
		    .W2L_dest_mmx(W2L_dest_mmx),
		    
		    // from WB, for auto inc/dec direction
		    //.W2L_eflags(W2L_eflags)

			// outputs to PRE
			.W2P_mem_wt_addr(W2P_mem_wt_addr),
			.W2P_mem_wt_size(W2P_mem_wt_size),
			.W2P_mem_wt_en(W2P_mem_wt_en),


			// outputs: to MEM
			.W2M_mem_wt_data(cmt_data),
			.W2M_mem_wt_addr(cmt_addr),
			.W2M_mem_wt_size(cmt_size),
			.W2M_mem_wt_en(cmt),
			.W2M_WR_PA1(cmt_pa1),
			.W2M_WR_PA2(cmt_pa2),
			.W2M_WR_PA3(cmt_pa3),
			
			// output: to EX
			.W2E_stall(W2E_stall),
			.W2E_eflags(W2E_eflags)
		);
		`uselib
			

    //------------------------------------
    //  Dump Debug Information
    //------------------------------------
    assign dp_instr_length  = D2F_instr_length;
    assign dp_ir            = F2D_instruction_out;
    wire [127:0]    dp_cs;
    assign dp_cs            = D2L_control_signal_out;


    //-------------------------------------
    // D -> CMU 
    //-------------------------------------
    // clock management unit
    cmu cmu_tb(.clk_in(clk_in), .clk_out(clk), .stop(hlt_signal), .resume_n(1'b1));


	//==================================
	//	DEBUGGER
	//==================================

    `uselib file=/misc/collaboration/382nGPS/382nG6/yhuang/debugger.v
	Debugger debugger(
		.CLK(clk),

		.F2D_current_eip(F2D_current_eip_out),
		.D2L_current_eip(D2L_current_eip_out),
		.L2A_current_eip(L2A_current_eip),
		.A2P_current_eip(A2P_current_eip),
		.P2M_current_eip(pre_current_eip),
		.M2E_current_eip(mem_current_eip),
		.E2W_current_eip(E2W_current_eip),
		
		.F2D_v(F2D_valid_out),
		.D2L_v(D2L_valid_out),
		.L2A_v(L2A_v),
		.A2P_v(A2P_v),
		.P2M_v(pre_valid),
		.M2E_v(mem_valid),
		.E2W_v(E2W_v),
		
		.D2F_stall(D2F_stall),
		.L2D_stall(L2D_stall),
		.A2L_stall(A2L_stall),
		.P2A_stall(pre_stall),
		.M2P_stall(mem2pre_stall),
		.E2M_stall(E2M_stall),
		.W2E_stall(W2E_stall),
		
		.GPR_out0(gpr0),
		.GPR_out1(gpr1),
		.GPR_out2(gpr2),
		.GPR_out3(gpr3),
		.GPR_out4(gpr4),
		.GPR_out5(gpr5),
		.GPR_out6(gpr6),
		.GPR_out7(gpr7),
		
		.SEGR_out0(segr0),
		.SEGR_out1(segr1),
		.SEGR_out2(segr2),
		.SEGR_out3(segr3),
		.SEGR_out4(segr4),
		.SEGR_out5(segr5),
	    
        .D2L_cs(D2L_control_signal_out),
        .L2A_cs(L2A_cs),
        .A2P_cs(A2P_cs),
        .P2M_cs(pre_cs),
        .M2E_cs(mem_cs),
        .E2W_cs(E2W_cs),
	
    
        .A2P_mem_rd_addr(A2P_mem_rd_addr),
	    .P2M_mem_rd_addr(pre_rd_pa),
	    	
	    .A2P_mem_wt_addr(A2P_mem_wt_addr),
	    .P2M_mem_wt_addr(pre_wt_va),
	    .M2E_mem_wt_addr(mem_wt_va),
	    .E2W_mem_wt_addr(E2W_mem_wt_addr),

		.EFLAGS(W2E_eflags),
		
		.F_flush(F_flush),
		
		.D2L_e(D2L_exception_out),
		.L2A_e(L2A_e),
		.A2P_e(A2P_e),
		.P2M_e(pre_exp),
		.M2E_e(mem_exp),
		.E2W_e(E2W_e),
		
		.out()
	);
    `uselib


	
endmodule

`uselib file=/misc/collaboration/382nGPS/382nG6/yjl/yjl_gates.v
module F2D_pipeline_register(
    clk, reset, set,
    stall_n, 
    valid,

    F2D_instruction_in,
    F2D_upc_in,
    F2D_upc_valid_in,
    F2D_current_eip_in,
    F2D_next_eip_in,
    F2D_instr_valid_gt_16_in,
    F2D_valid_in,
    F2D_exception_in,
    F2D_exp_vector_in,

    F2D_instruction_out,
    F2D_upc_out,
    F2D_upc_valid_out,
    F2D_current_eip_out,
    F2D_next_eip_out,
    F2D_instr_valid_gt_16_out,
    F2D_exception_out,
    F2D_exp_vector_out,
    F2D_valid_out
);
    //------------------------------
    // Input Ports
    //-----------------------------
    input clk, reset, set; 
    input valid;
    input stall_n;

    input [127:0]  F2D_instruction_in;
    input [7:0]    F2D_upc_in;
    input          F2D_upc_valid_in;
    input [31:0]   F2D_current_eip_in;
    input [31:0]   F2D_next_eip_in;
    input [31:0]   F2D_exception_in;
    input [3:0]    F2D_exp_vector_in;
    input          F2D_instr_valid_gt_16_in;
    input          F2D_valid_in;
    
    //------------------------------
    // Output Ports 
    //------------------------------

    output [127:0]  F2D_instruction_out;
    output [7:0]    F2D_upc_out;
    output          F2D_upc_valid_out;
    output [31:0]   F2D_current_eip_out;
    output [31:0]   F2D_next_eip_out;
    output [31:0]   F2D_exception_out;
    output [3:0]    F2D_exp_vector_out;
    output          F2D_instr_valid_gt_16_out;
    output          F2D_valid_out;
    
    reg128e instr_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(F2D_instruction_in),
        .Q(F2D_instruction_out),
        .en(stall_n)
    );

    reg8e upc_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(F2D_upc_in),
        .Q(F2D_upc_out),
        .en(stall_n)
    );

    reg1e upc_valid_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(F2D_upc_valid_in),
        .Q(F2D_upc_valid_out),
        .en(stall_n)
    );

    reg32e current_eip_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(F2D_current_eip_in),
        .Q(F2D_current_eip_out),
        .en(stall_n)
    );

    assign F2D_next_eip_out = F2D_next_eip_in;

    reg32e exception_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(F2D_exception_in),
        .Q(F2D_exception_out),
        .en(stall_n)
    );

    reg1e instr_valid_16_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(F2D_instr_valid_gt_16_in),
        .Q(F2D_instr_valid_gt_16_out),
        .en(stall_n)
    );
    
    
    // stall => not valid. 
    reg1e valid_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(F2D_valid_in),
        .Q(F2D_valid_out),
        .en(stall_n)
    ); 

endmodule


module D2L_pipeline_register(
    clk, reset, set,
    stall_n, 
    flush,
    valid,
    
    D2L_control_signal_in,
    D2L_next_eip_in,
    D2L_current_eip_in,
    D2L_imm_in,
    D2L_valid_in,
    D2L_disp_in,
    D2L_scale_in,              //
    D2L_base_gpr_id_in,        //
    D2L_index_gpr_id_in,       //
    D2L_need_base_gpr_in,      //
    D2L_need_index_gpr_in,     //
    D2L_exception_in,
    D2L_addr_segr_id_in,        //
    D2L_imm_sel_in,    //
    D2L_disp_sel_in,   //
    
    D2L_control_signal_out,
    D2L_next_eip_out,
    D2L_current_eip_out,
    D2L_imm_out,
    D2L_valid_out,
    D2L_exception_out,
    D2L_disp_out

    //D2L_scale_out,              //
    //D2L_base_gpr_id_out,        //
    //D2L_index_gpr_id_out,       //
    //D2L_need_base_gpr_out,      //
    //D2L_need_index_gpr_out,     //
    //D2L_addr_segr_id_out,        //
    //D2L_imm_sel_out,    //
    //D2L_disp_sel_out   //
);
    //------------------------------
    // Input Ports
    //-----------------------------
    input clk, reset, set; 
    input flush, valid;
    input stall_n;

    input [127:0]   D2L_control_signal_in;
    input [31:0]    D2L_next_eip_in;
    input [31:0]    D2L_current_eip_in;
    input [31:0]    D2L_imm_in;
    input           D2L_valid_in;
    input [31:0]    D2L_disp_in;
    input [1:0]     D2L_scale_in;              //
    input [2:0]     D2L_base_gpr_id_in;        //
    input [2:0]     D2L_index_gpr_id_in;       //
    input           D2L_need_base_gpr_in;      //
    input           D2L_need_index_gpr_in;     //
    input [2:0]     D2L_addr_segr_id_in;        //
    input [1:0]     D2L_imm_sel_in;    //
    input [1:0]     D2L_disp_sel_in;   //
    input [31:0]    D2L_exception_in;
    


    //------------------------------
    // Output Ports 
    //------------------------------

    output [127:0]   D2L_control_signal_out;
    output [31:0]    D2L_next_eip_out;
    output [31:0]    D2L_current_eip_out;
    output [31:0]    D2L_imm_out;
    output [31:0]    D2L_disp_out;
    output           D2L_valid_out;
    output [31:0]    D2L_exception_out;

    //output           D2L_scale_out;              //
    //output [2:0]     D2L_base_gpr_id_out;        //
    //output [2:0]     D2L_index_gpr_id_out;       //
    //output           D2L_need_base_gpr_out;      //
    //output           D2L_need_index_gpr_out;     //
    //output [2:0]     D2L_addr_segr_id_out;        //
    //output [1:0]     D2L_imm_sel_out;    //
    //output [1:0]     D2L_disp_sel_out;   //
   
    reg128e control_signal_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(D2L_control_signal_in),
        .Q(D2L_control_signal_out),
        .en(stall_n)
    );

    reg32e current_eip_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(D2L_current_eip_in),
        .Q(D2L_current_eip_out),
        .en(stall_n)
    );

    reg32e next_eip_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(D2L_next_eip_in),
        .Q(D2L_next_eip_out),
        .en(stall_n)
    );

    reg32e exception_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(D2L_exception_in),
        .Q(D2L_exception_out),
        .en(stall_n)
    );

    reg32e imm_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(D2L_imm_in),
        .Q(D2L_imm_out),
        .en(stall_n)
    );

    reg32e disp_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(D2L_disp_in),
        .Q(D2L_disp_out),
        .en(stall_n)
    );

    
    // stall => not valid. 
    wire flush_n;
    and2$ and_flush(flush_n, reset, stall_n); 
    reg1e valid_reg(
        .CLK(clk),
        .CLR(reset),
        .PRE(set),
        .Din(D2L_valid_in),
        .Q(D2L_valid_out),
        .en(stall_n)
    );

endmodule
