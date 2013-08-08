`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_constants.v"
`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_gates.v"
//`uselib file=/home/projects/courses/spring_12/ee382n-16905/lib/lib1
//`uselib file=/home/projects/courses/spring_12/ee382n-16905/lib/lib2
//`uselib file=/home/projects/courses/spring_12/ee382n-16905/lib/lib3
//`uselib file=/home/projects/courses/spring_12/ee382n-16905/lib/lib4
//`uselib file=/home/projects/courses/spring_12/ee382n-16905/lib/lib5
//`uselib file=/home/projects/courses/spring_12/ee382n-16905/lib/lib6



//`uselib file=yjl_gates.v
//  Fetch
//===============================================
// Fetch


module fetch_stage(
    clk,
    reset,
    set,

    I2F_instruction,
    icache_miss,
    tlb_page_fault,

    F_prefetch_addr,
    F_flush_other_stages,
    F_kill_prefetch_n,
    

    //X2F_stall,
    X2F_flush,
    
    W2F_current_eip,
    W2F_exception,
    W2F_br_eip,
    W2F_branch_taken,
    W2F_ld_eip,
    W2F_cs_segr_value,
    A2F_cs_segr_value,
    A2F_cs_segr_limit,
    A2F_uncond_branch,
    A2F_new_eip,

    D2F_instr_length,
    D2F_stall,
    hlt_signal,
    //D2F_instr_gt_16,
    D2F_decode_failed,
    F2D_instruction,
    F2D_upc,
    F2D_upc_valid,
    F2D_current_eip,
    F2D_next_eip,
    F2D_instr_valid_gt_16,
    F2D_stall_n,
    F2D_valid,
    F2D_exception,      // might have exception
    F2D_exp_vector,

    DMA_interrupt

);
    //------------------
    // Input Ports
    //------------------
    input           clk;
    input           reset;
    input           set;
    //input           X2F_stall;      // stall signal from unknown stages.
    input           X2F_flush;
    input           icache_miss;
    input [127:0]   I2F_instruction;
    input           tlb_page_fault;


    // From WriteBack Stage
    input [31:0]    W2F_exception;
    input [31:0]    W2F_current_eip;
    input [31:0]    W2F_br_eip;
    input           W2F_branch_taken;
    input [15:0]    W2F_cs_segr_value;      // when WB stage write back cs and eip, no need to first store in the register and then get cs from segr regfile. 
    input           W2F_ld_eip;
    // From AG/LR stage
    input           A2F_uncond_branch;
    input [31:0]    A2F_new_eip;   // supported???
    input [19:0]    A2F_cs_segr_value;
    input [19:0]    A2F_cs_segr_limit;
    // From Decode stage
    input [3:0]     D2F_instr_length;
    input           D2F_stall;
    input           D2F_decode_failed;
    input           DMA_interrupt;
    input           hlt_signal;

    //-----------------
    // Output Ports
    //-----------------
    // -> Decode Stage
    output [127:0]  F2D_instruction;
    output [7:0]    F2D_upc;
    output          F2D_upc_valid;
    output [31:0]   F2D_current_eip;
    output [31:0]   F2D_next_eip;
    output [31:0]   F_prefetch_addr;
    output          F2D_instr_valid_gt_16;
    output          F2D_stall_n;
    output          F2D_valid;
    output [31:0]   F2D_exception;
    output [3:0]    F2D_exp_vector;
    
    // -> all other stages
    output          F_flush_other_stages;
    output          F_kill_prefetch_n;

    
    //-----------------------------
    //  Conditional Status
    //-----------------------------
    // 1. control_flow_change
    //      branch taken
    //      CS written 
    wire control_flow_change;
    wire control_flow_change_n;
    wire icache_read_hit;
    inv1$ inv_read_hit(icache_read_hit, icache_miss);

    wire [31:0] target_address;
    wire [31:0] exp_address;
    
    
    //------------------------
    //  All Wires
    //------------------------
    // Instruction Buffer
    wire [127:0]    instruction_buffer_in;
    wire [127:0]    instruction_buffer_out;
    wire instr_buf_empty;
    wire instr_buf_not_full;
    wire         instr_buf_next_row_valid;

    //  Stall Logic
    wire interrupt;
    wire pipe_reg_stall;
    wire pipe_reg_stall_n;
    wire pipe_reg_valid;
    wire eip_stall;
    
    //  EIP 
    wire [31:0] next_eip;           // mux out of eip_no_branch, and branch new_eip
    wire [31:0] eip_no_branch;      // eip if no branch occur
    wire        ld_eip;             // load eip at the posedge of next cycle
    wire        stall, stall_n;
    wire [31:0] eip_value;          // output of eip_reg

    // CS segr limit checker
    wire            cs_limit_violate;
    wire            cs_limit_violate_n;

    // Prefetch Logic
    wire [31:0] prefetch_addr_no_branch;        // + 16 
    wire [31:0] next_prefetch_addr;             // choose between no branch and branch
    wire [31:0] prefetch_addr;                  // saved in register
    wire        ld_prefetch_addr;               // modify prefetch address next cycle 

    // Interrupt/Exception
    wire        pg_exp_flag;       // page fault
    wire        ge_exp_flag;       // general exception
    wire        int_exp_occur;
    wire [1:0]  int_exp_vector;
    wire [7:0]  int_exp_upc;
    wire        int_exp_upc_valid;
    wire        flush_other_stages;
    wire        int_occur;
    wire        exp_occur;
    
    //******************************************************** 
    //******************************************************** 
    //******************************************************** 
    // Control Status Signals
    //  control_flow_change (H/L)
    //  target_addr
    //  exception addr
    or2$ or_cf(control_flow_change, W2F_branch_taken, exp_occur);
    nor2$ nor_cf(control_flow_change_n, W2F_branch_taken, exp_occur);

    assign target_address = {W2F_cs_segr_value, W2F_br_eip[15:0]}; 
    assign exp_address = {W2F_cs_segr_value, W2F_current_eip[15:0]};

    //-------------------------------
    //  Interrupt/Exception Logic
    //-------------------------------
    assign pg_exp_flag = W2F_exception[`PG];
    assign ge_exp_flag = W2F_exception[`GE];

    int_exp_logic fetch_intexp(
        .pg_exp_flag(pg_exp_flag),
        .ge_exp_flag(ge_exp_flag),
        .int_flag(DMA_interrupt),
        .mask_int(D2F_stall),
        
        .exp_occur(exp_occur),
        .int_occur(int_occur),
        .vector_num(F2D_exp_vector),
        .serving_int_exp(int_exp_occur),
        .upc(int_exp_upc),
        .upc_valid(int_exp_upc_valid)
    );
    
    
    fetch_stall_logic stall_logic(
        .control_flow_change(control_flow_change),
        .icache_miss(icache_miss),
        .instr_buf_empty(instr_buf_empty),
        .other_stage_stall(D2F_stall),
        .other_stage_flush(X2F_flush),
        .exp_flag(exp_occur),

        .F2D_stall(pipe_reg_stall),
        .F2D_stall_n(pipe_reg_stall_n),
        .F2D_valid(pipe_reg_valid),
        .F_flush(flush_other_stages),
        .eip_stall(eip_stall)
    );
 
    //---------------------------
    // check CS *LIMIT*
    //---------------------------
    check_cs_limit beha_check_cs_limit(.cs_limit(A2F_cs_segr_limit), .violate(cs_limit_violate), .next_eip(F2D_next_eip));


    //-------------------------------------
    //  Prefetch Address
    //-------------------------------------
    //...........................................
    //  Normally, prefetch += 16;
    //  If control_flow Change, prefetch <- target_address[31:4]
    //  if there is *control flow change*, the prefetch_address should be 
    //  changed, and *kill* the previous prefetch.
    //  -----------------------------------------------
    //  things need to think about for prefetch  
    //     1. instr_buf_full        // if instr buffer is full, stop prefetch because there is not place to store them.
    //     2. read_miss             // if read miss, stop updating prefetch addr
    //     3. hlt                   // hlt will stall the pipeline, so fetch needn't to take special care of it
    //     4. exception/interrupt   // when it occurs, we should kill prefetch so that it won't stall pipeline.
    //............................................
    
    //  load prefetch
    //  when read_hit & buffer isn't full, load prefetch_addr
    and4$ and_ld_prefetch_addr(ld_prefetch_addr, icache_read_hit, instr_buf_not_full, !hlt_signal, !int_exp_occur);

    // compute next prefetch addr 
    assign prefetch_addr_no_branch = prefetch_addr + 5'b10000;   // TBD

    // choose between *normal* and *branch* prefetch
    mux2_32 mux_prefetch_addr(next_prefetch_addr, prefetch_addr_no_branch, target_address, control_flow_change);
    
    // update prefetch addr
        //  if there is contrl_flow change, prefetch_addr should be set to the target address 
        //  which is feed back from Wb stage.
    reg32e$ prefetch_addr_reg(.CLK(clk), .Din(next_prefetch_addr), .Q(prefetch_addr), .CLR(reset), .PRE(set), .en(ld_prefetch_addr | control_flow_change));

    // kill/pause prefetch addr
    assign F_kill_prefetch_n = control_flow_change_n;



    //::::::::::::::::::::::::::::::::::::::::::
    //::::::::::::::::::::::::::::::::::::::::::
    //::::::::::::::::::::::::::::::::::::::::::
    
    //--------------------------------
    //
    //  EIP 
    //  
    //-------------------------------
   
    // select next eip
        // if exp occur,    sel W2F_current_eip
        // if branch taken, sel W2F_br_eip
        // if neither occur,sel eip_no_branch
    mux4_32 mux_next_eip(next_eip, eip_no_branch, W2F_br_eip, W2F_current_eip, W2F_current_eip, W2F_branch_taken, exp_occur);

    // update eip
        // no stall 
        // OR there is branch taken
    wire branch_taken_n;
    inv1$ inv1$(branch_taken_n, W2F_branch_taken);
    nand2$ inv_ld_eip(ld_eip, eip_stall, branch_taken_n);
    reg32e$ eip(.CLK(clk), .Din(next_eip), .Q(eip_value), .CLR(reset), .PRE(set), .en(ld_eip));

    // decide next eip if there is no branch (just use D2F_instruction_length info)
        // assume that prefix can be most 2, opcode 2, disp 4, imm 4, so the max length is 12
    wire [31:0] eip_no_br0;
    wire [31:0] eip_no_br1;
    wire [31:0] eip_no_br2;
    wire [31:0] eip_no_br3;
    wire [31:0] eip_no_br4;
    wire [31:0] eip_no_br5;
    wire [31:0] eip_no_br6;
    wire [31:0] eip_no_br7;
    wire [31:0] eip_no_br8;
    wire [31:0] eip_no_br9;
    wire [31:0] eip_no_bra;
    wire [31:0] eip_no_brb;
    wire [31:0] eip_no_brc;
    wire [31:0] eip_no_brd;
    wire [31:0] eip_no_bre;
    wire [31:0] eip_no_brf;
    assign eip_no_br0 = eip_value;
    adder16b eip_adder_1(eip_no_br1[15:0], eip_value[15:0], 16'b0001, 1'b0);
    adder16b eip_adder_2(eip_no_br2[15:0], eip_value[15:0], 16'b0010, 1'b0);
    adder16b eip_adder_3(eip_no_br3[15:0], eip_value[15:0], 16'b0011, 1'b0);
    adder16b eip_adder_4(eip_no_br4[15:0], eip_value[15:0], 16'b0100, 1'b0);
    adder16b eip_adder_5(eip_no_br5[15:0], eip_value[15:0], 16'b0101, 1'b0);
    adder16b eip_adder_6(eip_no_br6[15:0], eip_value[15:0], 16'b0110, 1'b0);
    adder16b eip_adder_7(eip_no_br7[15:0], eip_value[15:0], 16'b0111, 1'b0);
    adder16b eip_adder_8(eip_no_br8[15:0], eip_value[15:0], 16'b1000, 1'b0);
    adder16b eip_adder_9(eip_no_br9[15:0], eip_value[15:0], 16'b1001, 1'b0);
    adder16b eip_adder_a(eip_no_bra[15:0], eip_value[15:0], 16'b1010, 1'b0);
    adder16b eip_adder_b(eip_no_brb[15:0], eip_value[15:0], 16'b1011, 1'b0);
    adder16b eip_adder_c(eip_no_brc[15:0], eip_value[15:0], 16'b1100, 1'b0);
    adder16b eip_adder_d(eip_no_brd[15:0], eip_value[15:0], 16'b1101, 1'b0);
    adder16b eip_adder_e(eip_no_bre[15:0], eip_value[15:0], 16'b1110, 1'b0);
    adder16b eip_adder_f(eip_no_brf[15:0], eip_value[15:0], 16'b1111, 1'b0);
    
    assign eip_no_br1[31:16] = eip_value[31:16];
    assign eip_no_br2[31:16] = eip_value[31:16];
    assign eip_no_br3[31:16] = eip_value[31:16];
    assign eip_no_br4[31:16] = eip_value[31:16];
    assign eip_no_br5[31:16] = eip_value[31:16];
    assign eip_no_br6[31:16] = eip_value[31:16];
    assign eip_no_br7[31:16] = eip_value[31:16];
    assign eip_no_br8[31:16] = eip_value[31:16];
    assign eip_no_br9[31:16] = eip_value[31:16];
    assign eip_no_bra[31:16] = eip_value[31:16];
    assign eip_no_brb[31:16] = eip_value[31:16];
    assign eip_no_brc[31:16] = eip_value[31:16];
    assign eip_no_brd[31:16] = eip_value[31:16];
    assign eip_no_bre[31:16] = eip_value[31:16];
    assign eip_no_brf[31:16] = eip_value[31:16];
    
    // delay < adder
    mux16_32 mux_eip_no_br(
        eip_no_branch, 
        eip_no_br0,
        eip_no_br1,
        eip_no_br2,
        eip_no_br3,
        eip_no_br4,
        eip_no_br5,
        eip_no_br6,
        eip_no_br7,
        eip_no_br8,
        eip_no_br9,
        eip_no_bra,
        eip_no_brb,
        eip_no_brc,
        eip_no_brd,
        eip_no_bre,
        eip_no_brf,
        D2F_instr_length[0],
        D2F_instr_length[1],
        D2F_instr_length[2],
        D2F_instr_length[3]
    );

    //------------------------------
    //
    //  Instruction Buffer
    //
    //------------------------------

    // Modify Instruction due to Little Endian
    assign instruction_buffer_in[16*`BYTE-1:15*`BYTE] = I2F_instruction[1*`BYTE-1:0*`BYTE]; 
    assign instruction_buffer_in[15*`BYTE-1:14*`BYTE] = I2F_instruction[2*`BYTE-1:1*`BYTE]; 
    assign instruction_buffer_in[14*`BYTE-1:13*`BYTE] = I2F_instruction[3*`BYTE-1:2*`BYTE]; 
    assign instruction_buffer_in[13*`BYTE-1:12*`BYTE] = I2F_instruction[4*`BYTE-1:3*`BYTE]; 
    assign instruction_buffer_in[12*`BYTE-1:11*`BYTE] = I2F_instruction[5*`BYTE-1:4*`BYTE]; 
    assign instruction_buffer_in[11*`BYTE-1:10*`BYTE] = I2F_instruction[6*`BYTE-1:5*`BYTE]; 
    assign instruction_buffer_in[10*`BYTE-1:9*`BYTE] = I2F_instruction[7*`BYTE-1:6*`BYTE]; 
    assign instruction_buffer_in[9*`BYTE-1:8*`BYTE] = I2F_instruction[8*`BYTE-1:7*`BYTE]; 
    assign instruction_buffer_in[8*`BYTE-1:7*`BYTE] = I2F_instruction[9*`BYTE-1:8*`BYTE]; 
    assign instruction_buffer_in[7*`BYTE-1:6*`BYTE] = I2F_instruction[10*`BYTE-1:9*`BYTE]; 
    assign instruction_buffer_in[6*`BYTE-1:5*`BYTE] = I2F_instruction[11*`BYTE-1:10*`BYTE]; 
    assign instruction_buffer_in[5*`BYTE-1:4*`BYTE] = I2F_instruction[12*`BYTE-1:11*`BYTE]; 
    assign instruction_buffer_in[4*`BYTE-1:3*`BYTE] = I2F_instruction[13*`BYTE-1:12*`BYTE]; 
    assign instruction_buffer_in[3*`BYTE-1:2*`BYTE] = I2F_instruction[14*`BYTE-1:13*`BYTE]; 
    assign instruction_buffer_in[2*`BYTE-1:1*`BYTE] = I2F_instruction[15*`BYTE-1:14*`BYTE]; 
    assign instruction_buffer_in[1*`BYTE-1:0*`BYTE] = I2F_instruction[16*`BYTE-1:15*`BYTE]; 
    
    // Instr Buf
    instruction_buffer fetch_instruction_buffer(
        .clk(clk),
        .flush(control_flow_change), 
        .reset(reset),
        .set(set), 
        .next_row_valid(instr_buf_next_row_valid), 
        .data_in(instruction_buffer_in), 
        .data_out(instruction_buffer_out), 
        .not_full_flag(instr_buf_not_full), 
        .empty_flag(instr_buf_empty),
        //.row_addr(), 
        .grab_addr(F2D_next_eip),     
        .prefetch_addr(prefetch_addr),
        .read_hit(icache_read_hit),
        .write()
    );




    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    // Output Wires
    //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


    assign F_prefetch_addr          = prefetch_addr; 
    assign F2D_instr_valid_gt_16    = instr_buf_next_row_valid;
    assign F2D_instruction          = instruction_buffer_out; 
    assign F2D_current_eip          = next_eip;
    assign F2D_next_eip             = next_eip;
    assign F2D_stall_n              = pipe_reg_stall_n;
    assign F2D_valid                = pipe_reg_valid;
    assign F2D_exception[`GE]       = cs_limit_violate; 
    assign F2D_exception[`PG]       = tlb_page_fault; 
    assign F2D_upc                  = int_exp_upc; 
    assign F2D_upc_valid            = int_exp_upc_valid; 
    assign F_flush_other_stages     = flush_other_stages;
    assign F2D_exception[`VECTOR_NUM] = F2D_exp_vector;         // exp_vector are passed as part of the 32bit exception wire
    assign F2D_exception[`INT_OR_EXP] = int_occur;         // exp_vector are passed as part of the 32bit exception wire
   
endmodule



// When icache is written, you cannot read.
module icache(
    clk,
    reset,
    set, 
    out,
    wr_addr,
    rd_addr,
    kill_prefetch_n,
    din, 
    read_miss,
    read_hit,
    update, 
    fill_signal,
    icache_fill,
    icache_pfn_tag,
    read_valid
);
    //-------------------------------------- 
    //  Input Ports
    //--------------------------------------    
    input           clk;            
    input           reset;
    input           set;

    input [14:0]    rd_addr;        // generated by fetch stage 
    input [14:0]    wr_addr;        // generated by icache controller (write from memory)
    input [31:0]    din;            // new instruction data from memory
    input           update;        // update is AMLOST write.
    input           fill_signal;
    input           icache_fill;        // the icache is being filled
    input           kill_prefetch_n;         // unused...
    
    //-------------------------------------- 
    //  Output Ports
    //--------------------------------------
    output [127:0]  out;            // output instruction
    output          read_miss;      // read_miss, if the data referenced by the OFFSET of the virtual address isn't in the cache.
    output          read_hit;
    output          read_valid;     // read is valid
    output [2:0]    icache_pfn_tag;
    
    //--------------------------------------
    //  Immediate Representation
    //--------------------------------------
    //  virtual address format:
    //  |31 : 12|11    :    0      | 
    //    vfn   |offt within page  |
    //                      | 3 : 0|
    //  physical address format:
    //  |14 : 12|           11    :    0       |
    //          |11 : 8 |  7 : 4   | 3 : 0     |
    //    pfn   |
    //  |   offset_part |index_part|offset within 16 byte of the cache_line
    //----------------------------------------------------------------------------------
    //  since only one address can be used to reference the icache, we need to decide whether it is read addr (from fetch) or write address (from memory)
    wire [14:0]     addr;           // either rd_address or wr_address

    wire [3:0]      index_part;     // 4 bit of offset within page are used to select way of cache
    // since pfn can be known until accessing tlb, so we do partial comparison. 
    wire [7:0]      tag;            
    wire [3:0]      partial_tag;    // 8 bit of offset within page are used to do partial comparison
    wire [7:0]      addr_tag_part;  // though tag is only 7 bit, I use a 8 bit tag. 
    
    assign index_part = addr[7:4];  // select the 16 cachelines
    assign partial_tag  = addr[11:8];   // pfn isn't available at the moment.
    assign addr_tag_part[6:0] = addr[14:8]; //partial_tag + pvn
    assign addr_tag_part[7]   = 1'b0;
    assign icache_pfn_tag = tag[6:4];       // tag[0] is a dummy bit 

    wire write_signal;
    
    // if kill_prefetch_n = 0, then 
    nand2$ nand_write_signal(write_signal, fill_signal, kill_prefetch_n);

   
    //-------------------------------------- 
    //  Condition Status
    //-------------------------------------- 
    //1. read not_valid: 
    //   read_miss
    //   OR is updating (write)
    wire read_valid;
    wire loading_flag;      // when the icache is being updated by memory
    assign loading_flag = icache_fill;

    //nor2$ nor_read_valid(read_valid, read_miss, update);
    inv1$ inv_read_hit(read_hit, read_miss);
    
    //2. address
    //   rd_address: used for fetch stage
    //   wr_address: used for memory updating cache_line
    wire dummy_wire;
    mux2_16$ mux_addr({dummy_wire, addr}, {1'b0, rd_addr}, {1'b0, wr_addr}, icache_fill);

    //--------------------------------------
    //  Tag Match or NOT 
    //--------------------------------------
    // icache_miss
    wire tag_match;
    cmp4b cmp_1(tag_match, partial_tag, tag[3:0]);        // tag[3:0] is partial part of the tag, tag[7:4] is pfn part.
    
    //-------------------------------------
    //  Read Miss
    //--------------------------------------
    wire    tag_match_and_valid;
    wire    valid_bit;
    wire    read_miss_tmp;
    // if tag_match && valid 
    nand2$ and_1(read_miss_tmp, tag_match, valid_bit);

    // if icache is receiving data from memory, we should always generate a read_miss
    // however when kill prefetch comes, we should kill the read_miss signal
    mux2$ mux_read_miss(read_miss, read_miss_tmp , kill_prefetch_n, loading_flag);
   
   

    //--------------------------------------
    //  COMPONENTS OF ICACHE
    //-------------------------------------- 
    //-------------------------------------- 
    // 1. Valid Bit
    //--------------------------------------
    // row: 16,  all initialized to 0
    // update: set to 1 if relevant cache_line is updated
    valid_column icache_valid(.clk(clk), .addr(index_part), .out(valid_bit), .update(update), .reset(reset), .set(set));
    
    //-------------------------------------- 
    // 2. Tag
    //-------------------------------------- 
    //  |14 : 8| -- 7bit
    //  for convenience, fixing the tag[7] to 0
    icache_ram8 icache_tag(.addr(index_part), .out(tag), .din(addr_tag_part), .write(write_signal));
    
    //-------------------------------------- 
    // 3. Data 
    //-------------------------------------- 
    wire [127:0] data_out;
    icache_ram128 icache_data(.addr(addr[7:0]), .out(data_out), .din(din), .write(write_signal));


    //--------------------------------------
    //  Output Instruction 
    //-------------------------------------- 
    // only enable output when no read_miss && not updating
    mux2_128 mux_out(out, data_out, 128'b0, read_miss);
    //tristate128L tri_out(read_miss, data_out, out);     // when no read miss, output

endmodule


//-----------------------------
//
//  Valid Column
//
//-----------------------------
module valid_column(out, update, addr, reset, set, clk);
    input [3:0] addr;
    input       clk;
    input       reset;
    input       set;
    input       update;
    output      out;
    
    wire        part_sel, part_sel_n;
    wire [2:0]  part_addr;
    wire [7:0]  part_addr_bitmap, part_addr_bitmap_n;

    assign part_sel = addr[3]; 
    inv1$ inv_0(part_sel_n, part_sel);

    assign part_addr = addr[2:0];

    decoder3_8$ decode_part_addr(part_addr, part_addr_bitmap, part_addr_bitmap_n);
    
    wire [7:0]  part_bitmap0, part_bitmap0_n;
    wire [7:0]  part_bitmap1, part_bitmap1_n;
    wire [7:0]  part_bitmap0_wr, part_bitmap1_wr;
    
    and8_1 and_part_bitmap0(part_bitmap0, part_addr_bitmap, part_sel_n);
    and8_1 and_part_bitmap1(part_bitmap1, part_addr_bitmap, part_sel);
    and8_1 and_0_(part_bitmap0_wr, part_bitmap0, update);
    and8_1 and_1(part_bitmap1_wr, part_bitmap1, update);
    nand8_1 nand_part_bitmap0(part_bitmap0_n, part_addr_bitmap, part_sel_n);
    nand8_1 nand_part_bitmap1(part_bitmap1_n, part_addr_bitmap, part_sel);
    
    wire out0;
    wire out1;
    wire out2;
    wire out3;
    wire out4;
    wire out5;
    wire out6;
    wire out7;
    wire out8;
    wire out9;
    wire outa;
    wire outb;
    wire outc;
    wire outd;
    wire oute;
    wire outf;
    //  row0
    //  row1
    //  row2
    //  ...
    //  row7    part_sel = 0
    //  row8
    //  ...
    //  row15   part_sel = 1

    // part0
    reg1e row0(.CLK(clk), .Din(1'b1), .Q(out0), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[0]));
    reg1e row1(.CLK(clk), .Din(1'b1), .Q(out1), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[1]));
    reg1e row2(.CLK(clk), .Din(1'b1), .Q(out2), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[2]));
    reg1e row3(.CLK(clk), .Din(1'b1), .Q(out3), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[3]));
    reg1e row4(.CLK(clk), .Din(1'b1), .Q(out4), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[4]));
    reg1e row5(.CLK(clk), .Din(1'b1), .Q(out5), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[5]));
    reg1e row6(.CLK(clk), .Din(1'b1), .Q(out6), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[6]));
    reg1e row7(.CLK(clk), .Din(1'b1), .Q(out7), .PRE(set), .CLR(reset), .en(part_bitmap0_wr[7]));
    //dff$ row0(.clk(clk), .d(1'b1), .q(out0), .r(reset), .s(set), .en(part_bitmap0_wr[0]));
    //dff$ row1(.clk(clk), .d(1'b1), .q(out1), .r(reset), .s(set), .en(part_bitmap0_wr[1]));
    //dff$ row2(.clk(clk), .d(1'b1), .q(out2), .r(reset), .s(set), .en(part_bitmap0_wr[2]));
    //dff$ row3(.clk(clk), .d(1'b1), .q(out3), .r(reset), .s(set), .en(part_bitmap0_wr[3]));
    //dff$ row4(.clk(clk), .d(1'b1), .q(out4), .r(reset), .s(set), .en(part_bitmap0_wr[4]));
    //dff$ row5(.clk(clk), .d(1'b1), .q(out5), .r(reset), .s(set), .en(part_bitmap0_wr[5]));
    //dff$ row6(.clk(clk), .d(1'b1), .q(out6), .r(reset), .s(set), .en(part_bitmap0_wr[6]));
    //dff$ row7(.clk(clk), .d(1'b1), .q(out7), .r(reset), .s(set), .en(part_bitmap0_wr[7]));

    // part1
    reg1e row8(.CLK(clk), .Din(1'b1), .Q(out8), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[0]));
    reg1e row9(.CLK(clk), .Din(1'b1), .Q(out9), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[1]));
    reg1e rowa(.CLK(clk), .Din(1'b1), .Q(outa), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[2]));
    reg1e rowb(.CLK(clk), .Din(1'b1), .Q(outb), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[3]));
    reg1e rowc(.CLK(clk), .Din(1'b1), .Q(outc), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[4]));
    reg1e rowd(.CLK(clk), .Din(1'b1), .Q(outd), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[5]));
    reg1e rowe(.CLK(clk), .Din(1'b1), .Q(oute), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[6]));
    reg1e rowf(.CLK(clk), .Din(1'b1), .Q(outf), .PRE(set), .CLR(reset), .en(part_bitmap1_wr[7]));

    // select the relevant row
    tristateL$ tri_out0(part_bitmap0_n[0], out0, out);  
    tristateL$ tri_out1(part_bitmap0_n[1], out1, out);  
    tristateL$ tri_out2(part_bitmap0_n[2], out2, out);  
    tristateL$ tri_out3(part_bitmap0_n[3], out3, out);  
    tristateL$ tri_out4(part_bitmap0_n[4], out4, out);  
    tristateL$ tri_out5(part_bitmap0_n[5], out5, out);  
    tristateL$ tri_out6(part_bitmap0_n[6], out6, out);  
    tristateL$ tri_out7(part_bitmap0_n[7], out7, out);  

    
    tristateL$ tri_out8(part_bitmap1_n[0], out8, out);  
    tristateL$ tri_out9(part_bitmap1_n[1], out9, out);  
    tristateL$ tri_outa(part_bitmap1_n[2], outa, out);  
    tristateL$ tri_outb(part_bitmap1_n[3], outb, out);  
    tristateL$ tri_outc(part_bitmap1_n[4], outc, out);  
    tristateL$ tri_outd(part_bitmap1_n[5], outd, out);  
    tristateL$ tri_oute(part_bitmap1_n[6], oute, out);  
    tristateL$ tri_outf(part_bitmap1_n[7], outf, out);  

endmodule


//------------------------------
//
//  TAG Column
//  
//------------------------------
// row: 16 
// column: 8  [6:0] is valid tag part, [7] is fixed to 0 for convenience
module icache_ram8(addr, out, din, write);
    input [3:0]     addr;
    input           write;
    input [7:0]    din;
    output [7:0]   out;
    
    //--------------------------------------
    //  Condition Status
    //--------------------------------------

    // 2. select ram0
    // if addr in (0-7) select ram0 0000 - 0111
    // if addr in (8-7) select ram1 1000 - 1111
    wire ram0_sel_n, ram0_sel;
    wire [7:0] ram0_out;
    wire [7:0] ram1_out;
    assign ram0_sel_n = addr[3];        // addr[3] = 1==> addr > 8 ==> ram1
    inv1$ inv_0(ram0_sel, addr[3]);

    // 3. when update the ram, you let OE be 1 ==> output is HIGH Z
    // OE = ram0_sel and !update
    wire ram0_OE, ram1_OE;
    and2$ and_0(ram0_OE, ram0_sel, write);
    and2$ and_1(ram1_OE, ram0_sel_n, write);           
    
    //--------------------------------------
    //  Select RAM and OUTPUT
    //-------------------------------------- 
    ram8b8w$ ram0(addr[2:0], din, ram0_OE, write, ram0_out);       // ram's OE is low-active
    ram8b8w$ ram1(addr[2:0], din, ram1_OE, write, ram1_out);       // ram's OE is low-active
    wire [7:0] ram_out;     
    mux2_8$ mux_out(ram_out, ram1_out, ram0_out, ram0_sel_n);

    assign out = ram_out;
endmodule


//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
// ICache RAM Building Blocks
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
module icache_ram16(addr, out, din, update);
    input [3:0]     addr;
    input           update;
    input [15:0]    din;
    output [15:0]   out;

    icache_ram8 ram_0(addr, out[7:0], din[7:0], update);
    icache_ram8 ram_1(addr, out[15:8], din[15:8], update);
endmodule

module icache_ram32(addr, out, din, update);
    input [4:0]     addr;
    input           update;
    input [31:0]    din;
    output [31:0]   out;

    icache_ram16 ram_0(addr, out[15:0], din[15:0], update);
    icache_ram16 ram_1(addr, out[31:16], din[31:16], update);
endmodule

// OE is Low active!!!
module ram32b16w(A, DIN, OE, WR, DOUT);
    input [3:0] A;
    input [31:0] DIN;
    input OE;
    input WR;
    output [31:0] DOUT;
    
    wire row_sel;
    wire row_sel_n;
    wire W0, W1;

    // A[2:0] 000 --- 111 
    assign row_sel = A[3];  // sel 8-15
    inv1$ inv_0(row_sel_n, row_sel);
    
    or2$ or_0(W0, WR, row_sel);
    or2$ or_1(W1, WR, row_sel_n);   // if wr = 0, and row_sel_n = 0, write row1.
    
    //ram16b8w$ ram00(A, DIN, , WR, WR, DOUT);
    // row 0
    ram16b8w$ ram00(A[2:0], DIN[15:0], row_sel, W0, W0, DOUT[15:0]);
    ram16b8w$ ram01(A[2:0], DIN[31:16], row_sel, W0, W0, DOUT[31:16]);
    
    // row 1
    ram16b8w$ ram10(A[2:0], DIN[15:0], row_sel_n, W1, W1, DOUT[15:0]);
    ram16b8w$ ram11(A[2:0], DIN[31:16], row_sel_n, W1, W1, DOUT[31:16]);
endmodule 



//-----------------------------------
//  I-Cache RAM128
//-----------------------------------
// ram128, used for stall instruction (128bit)
// when memory send data to I cache, just replace the old data
// feature: bank# 4
//          width# 128
module icache_ram128(addr, out, din, write);
    input [7:0]     addr;
    //  |7 6 5 4 | 3 2 |1 0|  
    //  0000_00_00 => bank0, row = 000
    //  0110_00_11 => bank0, row = 110 
    input           write;
    input [31:0]    din;
    output [127:0]  out;
    
    wire [3:0]  set_index;
    wire [1:0]  bank_index;
    assign set_index = addr[7:4];           // set within the back
    assign bank_index = addr[3:2];
    // if addr = 00, sel ram0
    //  01 -> ram1
    //  10 -> ram2
    //  11 -> ram3
    wire [3:0] bank_sel;
    wire [3:0] bank_sel_n;
    wire write_bank0; 
    wire write_bank1; 
    wire write_bank2; 
    wire write_bank3; 
    decoder2_4$ decoder_bank_sel(bank_index, bank_sel, bank_sel_n);
    or2$ or_write_signal0(write_bank0, write, bank_sel_n[0]);
    or2$ or_write_signal1(write_bank1, write, bank_sel_n[1]);
    or2$ or_write_signal2(write_bank2, write, bank_sel_n[2]);
    or2$ or_write_signal3(write_bank3, write, bank_sel_n[3]);
    // 00
    ram32b16w bank0(.A(set_index), .DIN(din), .OE(bank_sel[0]), .WR(write_bank0), .DOUT(out[31:00]));
    ram32b16w bank1(.A(set_index), .DIN(din), .OE(bank_sel[1]), .WR(write_bank1), .DOUT(out[63:32]));
    ram32b16w bank2(.A(set_index), .DIN(din), .OE(bank_sel[2]), .WR(write_bank2), .DOUT(out[95:64]));
    ram32b16w bank3(.A(set_index), .DIN(din), .OE(bank_sel[3]), .WR(write_bank3), .DOUT(out[127:96]));

endmodule


//-------------------------------
//
//  Instruction Buffer
//
//-------------------------------
// 0 column of instruction, 16Byte
// 1. write instruction into the buffer
// 2. read instruction from the buffer at the end of the cycle
module instruction_buffer(
    clk,
    flush, 
    reset,
    set, 
    next_row_valid, 
    data_in, 
    data_out, 
    not_full_flag, 
    empty_flag,
    prefetch_addr,
    grab_addr, 
    read_hit,
    write
);
    input           clk;
    input [127:0]   data_in;
    input           write;
    input           reset;
    input           set;
    input           flush;
    input [31:0]    prefetch_addr;
    input [31:0]    grab_addr;
    input           read_hit;
    
    output [127:0]  data_out;
    output          not_full_flag;
    output          next_row_valid;
    output          empty_flag;
    
    wire [3:0] v_bit;
    wire [1:0] write_addr;
    wire [3:0] column_addr; // used to shift the buffer line 
    wire [1:0] row_addr;    // used to select the buffer row
    assign column_addr  = grab_addr[3:0];  // eip_no_branch which is comupted by add eip_value and D2F instr_length
    assign row_addr     = grab_addr[5:4];
    assign write_addr = prefetch_addr[5:4]; // [3:0] means 16 byte

    

    // get the mask according to write_addr, which is actually a 2-bit number. |pc|0 - 15 |
    // write_addr <- prefetch_addr[1:0]
    // if write_addr = 00 -> fill 0 line
    // 01 -> line1, ... 11 -> line3
    // only fill empty lines
    wire [3:0] write_addr_mask;
    wire [3:0] write_addr_mask_neg;
    decoder2_4$ decoder_wr_mask(write_addr, write_addr_mask, write_addr_mask_neg);
    
    // get write_bitmap
    // if write_bitmap[i] == 1, this line will be written if read hit
    wire [3:0] write_bitmap;

    // if write_addr_mask_neg[i] == 0 && that line is empty
    // take a shotnap of the valid bit of the instruction buffer and use this snapshot to decide which line to fill during the cycle. This is important because at the same cycle, I will chang ethe valid bit, which will have a feed back effect. So this snapshot ensures that every cycle, only one line is choosed to be changed.

    // v_bef_cyc: snapshot of valie_bit
    dff$ valid_before_cycle0(.clk(clk), .d(v_bit[0]), .q(v_bef_cyc0), .r(reset), .s(set));
    dff$ valid_before_cycle1(.clk(clk), .d(v_bit[1]), .q(v_bef_cyc1), .r(reset), .s(set));
    dff$ valid_before_cycle2(.clk(clk), .d(v_bit[2]), .q(v_bef_cyc2), .r(reset), .s(set));
    dff$ valid_before_cycle3(.clk(clk), .d(v_bit[3]), .q(v_bef_cyc3), .r(reset), .s(set));

    // write_bitmap according to the beginning status of buffer lines, and the prefetch_addr
    nor3$ nor_write_bitmap0(write_bitmap[0], v_bef_cyc0, write_addr_mask_neg[0], !reset);
    nor3$ nor_write_bitmap1(write_bitmap[1], v_bef_cyc1, write_addr_mask_neg[1], !reset);
    nor3$ nor_write_bitmap2(write_bitmap[2], v_bef_cyc2, write_addr_mask_neg[2], !reset);
    nor3$ nor_write_bitmap3(write_bitmap[3], v_bef_cyc3, write_addr_mask_neg[3], !reset);

    // when control flow changes, the queue need to be flushed
    // then at the next cycle, queue are filled from nothing in it.


    wire [127:0] data0_out;
    wire [127:0] data1_out;
    wire [127:0] data2_out;
    wire [127:0] data3_out;
    //wire [3:0]   write_enable;

    //and2$ and_write_enable_3(write_enable[3], write_bitmap[3], read_hit);
    //and2$ and_write_enable_2(write_enable[2], write_bitmap[2], read_hit);
    //and2$ and_write_enable_1(write_enable[1], write_bitmap[1], read_hit);
    //and2$ and_write_enable_0(write_enable[0], write_bitmap[0], read_hit);

    latch128 data0(.CLR(reset), .D(data_in), .EN(write_bitmap[0]), .PRE(set), .Q(data0_out));
    latch128 data1(.CLR(reset), .D(data_in), .EN(write_bitmap[1]), .PRE(set), .Q(data1_out));
    latch128 data2(.CLR(reset), .D(data_in), .EN(write_bitmap[2]), .PRE(set), .Q(data2_out));
    latch128 data3(.CLR(reset), .D(data_in), .EN(write_bitmap[3]), .PRE(set), .Q(data3_out));
    
    // set valid bit is strict
    //  a. the line is selected
    //  b. it's a READ HIT!!!
    // asyc reset are used to CONSUME the buffer line.
    // if the read_address changed by one bit, say from line 00 to line 01, or from line 11 to line 00, then clear the vlaid bit of the previous line. so there is need to record the CURRENT/PREVIOIUS position of the read_address
    wire [1:0] prev_position;
    wire       position_change;
    wire [3:0] position_change_bitmap;       
    wire [3:0] consume_neg;
    reg2e previous_position_reg(.CLK(clk), .Din(row_addr), .Q(prev_position), .CLR(reset), .PRE(set), .en(1'b1));
    //  at the later cycle of fetch stage, the read address will be added amount of the instruction length, so the read_addr will change, which will be different 


    // if row_addr (for read) of instr buffer changes, then the previous row should be cleared.
    xor2$ xor_pos_change(position_change, prev_position[0], row_addr[0]);    
    decoder2_4$ decoder_pos_change(.SEL(prev_position), .Y(position_change_bitmap));        // position of prev 
    

    // consume_neg[N] = 0 means that v_bit[N] should be change into 0
    nand2$ nand_consume0(consume_neg[0], position_change_bitmap[0], position_change);
    nand2$ nand_consume1(consume_neg[1], position_change_bitmap[1], position_change);
    nand2$ nand_consume2(consume_neg[2], position_change_bitmap[2], position_change);
    nand2$ nand_consume3(consume_neg[3], position_change_bitmap[3], position_change);

    // set the valid bit of buffer line to be zero
    //  a. init
    //  b. after moving data from it.
    //  d. flush

    wire       flush_n;
    wire [3:0] modify_valid; 
    wire [3:0] fill_valid_n;    //read_hit and selected by the buffer
    //wire [3:0] fill_v_bit_n;      
    inv1$ inv_0(flush_n, flush);

    // if write_bitmap = 1, and read_hit ==> valid -> 1
    // if consume_neg
    latch$ valid_bit0(.d((read_hit & write_bitmap[0] | v_bef_cyc0) & consume_neg[0]), .q(v_bit[0]), .en(1'b1), .r(reset & flush_n), .s(set));
    latch$ valid_bit1(.d((read_hit & write_bitmap[1] | v_bef_cyc1) & consume_neg[1]), .q(v_bit[1]), .en(1'b1), .r(reset & flush_n), .s(set));
    latch$ valid_bit2(.d((read_hit & write_bitmap[2] | v_bef_cyc2) & consume_neg[2]), .q(v_bit[2]), .en(1'b1), .r(reset & flush_n), .s(set));
    latch$ valid_bit3(.d((read_hit & write_bitmap[3] | v_bef_cyc3) & consume_neg[3]), .q(v_bit[3]), .en(1'b1), .r(reset & flush_n), .s(set));



    //----------------------------------
    //  Output of Instruction Buffer 
    //      shifters
    //----------------------------------
    // read out from buffer  
    // assemble the data using two rows of data 
    wire [127:0] assem_data0;       // row0 ^^ row1
    wire [127:0] assem_data1;       // row1 ^^ row2
    wire [127:0] assem_data2;       // row2 ^^ row3
    wire [127:0] assem_data3;       // row3 ^^ row0

    wire [127:0] data0_left;        // left shift row0      data0 <<
    wire [127:0] data0_right;       // right shift row0     data0 >>
    wire [127:0] data1_left;
    wire [127:0] data1_right;
    wire [127:0] data2_left;
    wire [127:0] data2_right;
    wire [127:0] data3_left;
    wire [127:0] data3_right;


    //// {data0_left, data1_right}
    //assign data0_left   = data0_out << 8*(column_addr);
    //assign data1_right  = data1_out >> 8*(16-column_addr);
    //assign assem_data0  = data0_left | data1_right;

    //assign data1_left   = data1_out << 8*(column_addr);
    //assign data2_right  = data2_out >> 8*(16-column_addr);
    //assign assem_data1  = data1_left | data2_right;

    //assign data2_left   = data2_out << 8*(column_addr);
    //assign data3_right  = data3_out >> 8*(16-column_addr);
    //assign assem_data2  = data2_left | data3_right;

    //assign data3_left   = data3_out << 8*(column_addr);
    //assign data0_right  = data0_out >> 8*(16-column_addr);
    //assign assem_data3  = data3_left | data0_right;

    assem_logic assem_0(assem_data0, data0_out, data1_out, column_addr);
    assem_logic assem_1(assem_data1, data1_out, data2_out, column_addr);
    assem_logic assem_2(assem_data2, data2_out, data3_out, column_addr);
    assem_logic assem_3(assem_data3, data3_out, data0_out, column_addr);
    

    
    mux4_128 mux_output(data_out, assem_data0, assem_data1, assem_data2, assem_data3, row_addr[0], row_addr[1]);


    
    //-----------------------------
    //  Contional Status
    //-----------------------------
    // full: if so, stop prefetch 
    // empty: if so, stall Fetch Stage
    nand4$ and_full(not_full_flag, v_bit[0], v_bit[1], v_bit[2], v_bit[3]);
    nor4$ nor_empty(empty_flag, v_bit[0], v_bit[1], v_bit[2], v_bit[3]);    

    // next_row_valid  
    //  if no, the decoding stage might fail when it consume more than one row of instruction buffer
    mux4$ mux_next_valid(next_row_valid, v_bit[1], v_bit[2], v_bit[3], v_bit[0], row_addr[0], row_addr[1]);


endmodule

//-------------------------------
// Stall Logic for Fetch Stage
//-------------------------------
        // reasons for stall
        //    a. read_invalid (icache_miss)
        //    b. decode_failed
        //    c. instruction_buffer empty (if cache read hit, than before the end of this cycle, 
        //          the buffer will be filled, thus this situation is implied in #a)
        //    d. stall signal from other stages
        //    e. W2F_exception: 
        //    f. interrupt
module fetch_stall_logic(
    control_flow_change,
    icache_miss,
    other_stage_stall,
    other_stage_flush,
    instr_buf_empty,
    exp_flag,

    F2D_valid,
    F2D_stall,
    F2D_stall_n,
    eip_stall,
    F_flush
);
    input control_flow_change;
    input icache_miss;
    input other_stage_stall;
    input other_stage_flush;
    input instr_buf_empty;
    input exp_flag;

    
    output F2D_stall;
    output F2D_stall_n;
    output F2D_valid;
    output eip_stall;
    output F_flush;

    wire other_stage_flush_n;
    wire other_stage_stall_n;
    wire F_valid;
    inv1$ inv_flush(other_stage_flush_n, other_stage_flush);
    inv1$ inv_stall(other_stage_stall_n, other_stage_stall);

    
    //------------------------------
    // Fetch valid
    //------------------------------
    //  no instr_buf_empty  ==> stall eip  
    //inv1$ inv_F_valid(F_valid, instr_buf_empty);
    assign F_valid = ~instr_buf_empty | exp_flag;

    //------------------------------
    // stall
    //------------------------------
    // only right stages can stall the pipeline_reg, decode itself cannot
    // if flush is active, it cannot stall
    // other_stall_n = 0, && flush == 0 
    // OR other_stall = 1 && flush_n = 1
    nor2$ nor_stall(F2D_stall, other_stage_stall_n, other_stage_flush);
    nand2$ nand_stall(F2D_stall_n, other_stage_stall, other_stage_flush_n);


    //------------------------------
    // stall eip
    //------------------------------
    // 3, instr_buf_empty
    // 4. stall_from_other stage
    or2$ or_stall_eip(eip_stall, other_stage_stall, instr_buf_empty);
    
    // flush 
    // 1. branch misprediction (flush), not stall
    // 2. all stall logic  
    and2$ nor_fetch_valid(F2D_valid, F_valid, other_stage_flush_n);
    or2$ or_F_flush(F_flush, control_flow_change, exp_flag);

endmodule


//--------------------------------------
// Interrupt, Exception
//--------------------------------------
// 1. generate correct upc, upc_valid
// 2. flush all stages on the right. (D - EXE)
// 3. select int/ext vector
// 4. pass the int_ext_flag to decode stage and let it stall the fetch stage.
// 5. interrupt is maskable because when some control_flow change occurs or exception occurs, the interrupt will be flushed. but exception is unmaskable because it has already flush all previous instructions, thus no VALID instruction occur can flush it.
module int_exp_logic(
    pg_exp_flag,
    ge_exp_flag,
    int_flag,
    
    mask_int,
    serving_int_exp,
    vector_num,
    exp_occur,
    int_occur,
    upc,
    upc_valid
);

    input pg_exp_flag;
    input ge_exp_flag;
    input int_flag;
    input mask_int;                // when fetch is stalled, the instruction cannot be interrupted.

    output          serving_int_exp;
    output [7:0]    upc;
    output          upc_valid;
    output          exp_occur;
    output          int_occur;
    output [3:0]    vector_num;

    parameter INT_EXP_UPC = 8'b0010_1000;   // f0 - ff


    wire [1:0]      int_exp_vector;
    wire [2:0]      int_exp_req;
    assign int_exp_req[2] = int_flag;
    assign int_exp_req[1] = ge_exp_flag;
    assign int_exp_req[0] = pg_exp_flag;

    // vector
    // 2 for interrupt --> NMI : 2 * 8 => XXX10
    // 13 FOR GE --> 13 * 8 => XXX 68
    // 14 for PG --> 14 * 8 => XXX 70
    // 0, 1, 2, 3 (NO, INT, GE, PG)
    // 000 -> 00
    // 100 -> 01
    // 010 -> 10
    // 001 -> 11
    xor2$ xor_0(int_exp_vector[1], int_exp_req[1], int_exp_req[0]);
    xor2$ xor_1(int_exp_vector[0], int_exp_req[2], int_exp_req[0]);

    // interrupt:   maskable
    // exception:   unmaskable
    wire exp_occur_n;

    //----------------------
    //  Interrupt Handler
    //----------------------
    //  DMA interrupt can be masked when the Fetch stage is stalled 
    //  when Fetch isn't valid, we can still generate DMA because DMA don't need any further help of Fetch
    wire int_occur_n;
    wire mask_int_n;
    inv1$ inv_0(mask_int_n, mask_int);      // D2F_stall is the mask signal

    nand2$ nand_0(int_occur_n, int_flag, mask_int_n);
    and2$ and_int_occur(int_occur, int_flag, mask_int_n); 

    //-----------------------
    //  Condition Status
    //-----------------------
    nor2$ nor_0(exp_occur_n, pg_exp_flag, ge_exp_flag);
    or2$ or_0(exp_occur, pg_exp_flag, ge_exp_flag);
    nand2$ nand_1(serving_int_exp, exp_occur_n, int_occur_n);

    // upc
    assign upc_valid    = serving_int_exp; 
    assign upc          = INT_EXP_UPC;   

    mux4_4 mux_vector(vector_num, 4'b0, 4'd2, 4'd13, 4'd14, int_exp_vector[0], int_exp_vector[1]);

endmodule



//------------------------------
//  Check CS Limit
//------------------------------
module check_cs_limit(
    cs_limit, 
    violate,
    violate_n,
    next_eip
);

input  [19:0]   cs_limit;
input  [31:0]   next_eip;
output          violate;
output          violate_n;
    
    // if next_eip > cs_limit ==> limit violate
    mag_comp32$ checker(next_eip, cs_limit, violate, violate_n);

endmodule
