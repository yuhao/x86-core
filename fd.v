`include "yjl_constants.v"
`include "yjl_gates.v"
`include "bus_interface.v"

//  Fetch
//===============================================
// Fetch
module fetch_stage(
    clk,
    icache_read_valid,
    icache_out,
    icache_miss,
    F_icache_addr,
    reset,
    set,
    X2F_stall,
    W2F_exception,
    W2F_new_eip,
    W2F_branch_taken,
    W2F_cs_segr_value,
    A2F_cs_segr_value,
    A2F_cs_segr_limit,
    A2F_uncond_branch,
    A2F_new_eip,
    D2F_instr_length,
    D2F_stall,
    D2F_instr_gt_16,
    F2D_instruction,
    F2D_upc,
    F2D_upc_valid,
    F2D_current_eip,
    F2D_instr_valid_lt_8
);
    //------------------
    // Input Ports
    //------------------
    input           clk;
    input           reset;
    input           set;
    input           X2F_stall;      // stall signal from unknown stages.
    input           icache_read_valid;
    input           icache_miss;
    input [127:0]   icache_out;
    // From WriteBack Stage
    input           W2F_exception;
    input [31:0]    W2F_new_eip;
    input           W2F_branch_taken;
    input [15:0]    W2F_cs_segr_value;      // when WB stage write back cs and eip, no need to first store in the register and then get cs from segr regfile. 
    // From AG/LR stage
    input           A2F_uncond_branch;
    input [31:0]    A2F_new_eip;   // supported???
    input [19:0]    A2F_cs_segr_value;
    input [19:0]    A2F_cs_segr_limit;
    // From Decode stage
    input [3:0]     D2F_instr_length;
    input           D2F_stall;
    input           D2F_decode_failed;

    //-----------------
    // Output Ports
    //-----------------
    // -> Decode Stage
    output [127:0]  F2D_instruction;
    output [7:0]    F2D_upc;
    output          F2D_upc_valid;
    output [31:0]   F2D_current_eip;
    output [31:0]   F_icache_addr;
    output          F2D_instr_valid_lt_8;

    

    //-----------------------------=
    //  Conditional Status
    //------------------------------
    // 1. control_flow_change
    //      branch taken
    //      CS written 
    wire control_flow_change;
    // branch taken or NT
    wire        branch_taken;
    wire [31:0] target_address;
    or2$ or_br(branch_taken, W2F_branch_taken, A2F_uncond_branch);
    assign target_address = W2F_branch_taken;   // assume no forwarding of branch target address 
  
    
    //------------------------------------
    //  CS << 16 + EIP
    //------------------------------------
    wire [31:0]     extended_cs;
    wire [19:0]     cs_limit; 
    wire [31:0]     instr_addr;
    wire [31:0]     next_cacheline_instr_addr;
    assign extended_cs = {W2F_cs_segr_value, 16'b0};
    assign cs_limit = A2F_cs_segr_limit;
    
    // eip
    wire [31:0] next_eip;
    wire [31:0] eip_no_branch;
    wire        ld_eip;
    wire        stall, stall_n;
    wire [31:0] eip_value; 

    wire icache_read_valid_n;
    inv1$ inv_read_valid(icache_read_valid_n, icache_read_valid);
    or3$ or_stall(stall, icache_miss, icache_read_valid_n, X2F_stall);
    
    // !stall && icache_valid = 1
    assign ld_eip = !stall;
    reg32e$ eip(.CLK(clk), .Din(next_eip), 
                .Q(eip_value), .CLR(reset), .PRE(set), .en(ld_eip));

    //  Instruction_address
    // since the cacheline is 16 byte, the low 4 bits of the instruction isn't important to check the 
    instr_addr[31:4] = extended_cs[31:4] + eip_value[31:4];                         // adder without carry in
    next_cacheline_instr_addr[31:4] = extended_cs[31:4] + eip_value[31:4] + 1'b1;   // adder with carry in

    //  if there is control flow change, the prefetch_address should be changed, and kill the previous prefetch.
    wire [31:0] icache_addr_no_branch;
    wire [31:0] next_icache_addr;
    wire [31:0] icache_addr;
    // icache_index
    adder32b icache_addr_adder(icache_addr_no_branch, icache_addr, 32'h10);

    mux2_32 mux_icache_addr(next_icache_addr, icache_addr_no_branch, target_address, branch_taken);
    // when ld_eip && instr_buffer isn't full.
    //nand2$ nand_icache_addr(ld_icache_addr, ld_eip, instr_buf_full);    

    wire [31:0] icache_addr_tmp;
    mux2_32 mux_icache_addr_tmp(icache_addr_tmp, eip_value, next_icache_addr, reset);
    reg32e$ icache_addr_reg(.CLK(clk), .Din(icache_addr_tmp), .Q(icache_addr), .CLR(reset), .PRE(set), .en(ld_eip));
    



    //------------------------------
    // generate starting address of next instruction  
    //------------------------------
    assign eip_no_br0 = eip_value;
    adder32b eip_adder_1(eip_no_br1, eip_value, 4'b0001);
    adder32b eip_adder_2(eip_no_br2, eip_value, 4'b0010);
    adder32b eip_adder_3(eip_no_br3, eip_value, 4'b0011);
    adder32b eip_adder_4(eip_no_br4, eip_value, 4'b0100);
    adder32b eip_adder_5(eip_no_br5, eip_value, 4'b0101);
    adder32b eip_adder_6(eip_no_br6, eip_value, 4'b0110);
    adder32b eip_adder_7(eip_no_br7, eip_value, 4'b0111);
    adder32b eip_adder_8(eip_no_br8, eip_value, 4'b1000);
    adder32b eip_adder_9(eip_no_br9, eip_value, 4'b1001);
    adder32b eip_adder_a(eip_no_bra, eip_value, 4'b1010);
    adder32b eip_adder_b(eip_no_brb, eip_value, 4'b1011);
    adder32b eip_adder_c(eip_no_brc, eip_value, 4'b1100);
    adder32b eip_adder_d(eip_no_brd, eip_value, 4'b1101);
    adder32b eip_adder_e(eip_no_bre, eip_value, 4'b1110);
    adder32b eip_adder_f(eip_no_brf, eip_value, 4'b1111);

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
        eip_no_brf
        D2F_instr_length[3],
        D2F_instr_length[2],
        D2F_instr_length[1],
        D2F_instr_length[0]
    );
    
      nand2$(instr_buf_write, instr_buf_full, read_miss);

    //------------------------------
    //  Instruction Buffer
    //------------------------------
    wire instr_buf_full;
    wire instr_buf_empty;
    wire instr_buf_write;
    wire       instr_buf_flush; 
    wire [3:0] instr_buf_col;
    wire [1:0] instr_buf_row;

    assign instr_buf_flush = branch_taken;
    // instr_buf_row++, when decode consume two 16 bytes of instruction,
    incrementer2b instr_row_inc(instr_buf_row_inc, instr_buf_row, D2F_instr_gt_16); 
    reg2e instr_buf_row_reg(.CLK(clk), .Din(instr_buf_row_inc), .Q(instr_buf_row), .CLR(reset), .PRE(set), .en(stall));
    // initially instr_buf_row = 0; 

    wire instr_buf_instr_gt_16;
    // Instruction Buffer
    instruction_buffer fetch_instr_buffer(
        .flush(instr_buf_flush), 
        .reset(reset),
        .set(set),
        .clk(clk),
        .next_row_valid(instr_buf_instr_gt_16),
        .data_in(icache_out), 
        .data_out(F2D_instruction), 
        .full_flag(instr_buf_full), 
        .row_addr(instr_buf_row), 
        .column_addr(instr_buf_col), 
        .write(instr_buf_write)
    );
 


    //instruction_buffer instr_buf(flush, reset,set, next_row_valid, data_in, data_out, full_flag, row_addr, column_addr, write);


    // Intr/Except Logic

    // 

    assign F_icache_addr = icache_addr; 
    assign F2D_instr_gt_16 = instr_buf_instr_gt_16;
    assign F2D_instruction = icache_out;
    assign F2D_current_eip = eip_value;
   

endmodule

// 256 B -> 16B * 16
// direct-mapped
module icache_controller(
    clk,
    reset, 
    set,
    miss_signal, 
    mem_data, 
    mem_data_finish,
    icache_fill, 
    icache_write_data,
    icache_write_addr,
    M2I_mem_addr,
    addr_to_bus_station,
    req_to_bus_station,
    physical_addr
);
    //-------------------------------------
    //  Input Ports
    //------------------------------------- 
    input           clk;
    input           reset, set;
    input           miss_signal;
    
    input [127:0]   mem_data;
    input           mem_data_finish;
    input [31:0]    M2I_mem_addr;
    input [31:0]    physical_addr;
    
    //------------------------------------- 
    //  Output Ports
    //------------------------------------- 
    output          icache_fill;    // telling the I-Cache that data comes from memory
    output [127:0]  icache_write_data;  // data from memory to write into I-Cache
    output [31:0]   icache_write_addr;  // addr to write to the icache
    output          req_to_bus_station; // telling the bus station to request BUS.
    output [31:0]   addr_to_bus_station;    // physical addr to get data from memory



    //-------------------------------------
    //  Output Data
    //------------------------------------- 
    // 1. to bus_station
    assign req_to_bus_station = miss_signal;
    assign addr_to_bus_station = physical_addr;
    // 2. to I-Cache
    //  addr, and fill signal
    reg32e$ addr_out(.CLK(clk), .Din(M2I_mem_addr), .Q(icache_write_addr), .CLR(reset), .PRE(set), .en(1'b1));
    reg1e fill_signal(.CLK(clk), .Din(mem_data_finish), .Q(icache_fill), .CLR(reset), .PRE(set), .en(1'b1));
    //  tristate gate of write data 
    //  Q: data is sent to I-Cache ealier than fill and addr??
    wire output_enable_n;
    inv1$ inv_0(output_enable_n, mem_data_finish);
    tristate128L tri_out(output_enable_n, mem_data, icache_write_data);     
endmodule

// When icache is written, you cannot read.
module icache(clk, reset, set, out, wr_addr, rd_addr, wr, enable, din, read_miss, update, read, read_valid);
    //-------------------------------------- 
    //  Input Ports
    //--------------------------------------    
    input           clk;            
    input           reset;
    input           set;

    input [14:0]    rd_addr;        // generated by fetch stage 
    input [14:0]    wr_addr;        // generated by icache controller (write from memory)
    input [127:0]   din;            // new instruction data from memory
    input           update;        // update is AMLOST write.
    // unused: 
    input           wr;             // same as update
    input           enable;         // unused...
    input           read;          // complementary of update, because icache is either read by fetch stage or updated by memroy
    
    //-------------------------------------- 
    //  Output Ports
    //--------------------------------------
    output [127:0]  out;            // output instruction
    output          read_miss;      // read_miss, if the data referenced by the OFFSET of the virtual address isn't in the cache.
    output          read_valid;     // read is valid
    

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
    
    assign index_part = addr[7:4];
    assign partial_tag  = addr[11:8];
    assign addr_tag_part[6:0] = addr[14:8];
    assign addr_tag_part[7]   = 1'b0;

   
    //-------------------------------------- 
    //  Condition Status
    //-------------------------------------- 
    //1. read_valid: 
    //   read_miss
    //   OR is updating (write)
    wire read_valid;
    nor2$ nor_read_valid(read_valid, read_miss, update);
    
    //2. address
    //   rd_address: used for fetch stage
    //   wr_address: used for memory updating cache_line
    wire dummy_wire;
    mux2_16$ mux_addr({dummy_wire, addr}, {1'b0, rd_addr}, {1'b0, wr_addr}, update);

    //--------------------------------------
    //  Tag Match or NOT 
    //--------------------------------------
    // icache_miss
    wire tag_match;
    cmp4b cmp_1(tag_match, partial_tag, tag[3:0]);        // tag[3:0] is partial part of the tag, tag[7:4] is pfn part.
    
    //--------------------------------------
    //  Read Miss
    //--------------------------------------
    wire tag_and_valid;
    and2$ and_1(tag_and_valid, tag_match, valid_bit);
    nor2$ and_read_miss(read_miss, tag_and_valid, update);  // !tag_and_valid, && update = 0
   
   

    //--------------------------------------
    //  COMPONENTS OF ICACHE
    //-------------------------------------- 
    //-------------------------------------- 
    // 1. Valid Bit
    //--------------------------------------
    // row: 16,  all initialized to 0
    // update: set to 1 if relevant cache_line is updated
    wire valid_bit;
    valid_column icache_valid(.addr(index_part), .out(valid_bit), .update(update), .reset(reset));
    
    //-------------------------------------- 
    // 2. Tag
    //-------------------------------------- 
    //  |14 : 8| -- 7bit
    //  for convenience, fixing the tag[7] to 0
    icache_ram8 icache_tag(.addr(index_part), .out(tag), .din(addr_tag_part), .update(update));
    
    //-------------------------------------- 
    // 3. Data 
    //-------------------------------------- 
    wire [127:0] data_out;
    icache_ram128 icache_data(.addr(index_part), .out(data_out), .din(din), .update(update));


    //--------------------------------------
    //  Output Instruction 
    //-------------------------------------- 
    // only enable output when no read_miss && not updating
    wire output_enable_n;
    or2$ nand_output_enable(output_enable_n, read_miss, update);
    tristate128L tri_out(output_enable_n, data_out, out);

endmodule


module valid_column(out, update, addr, reset);
    input [3:0] addr;
    input       reset;
    input       update;
    output      out;
    
    reg mem_data [0:15]; 

    assign out = mem_data[addr];

    always@(*)
    begin 
        if(!reset)
        begin
            mem_data[0] <= 0;
            mem_data[1] <= 0;
            mem_data[2] <= 0;
            mem_data[3] <= 0;
            mem_data[4] <= 0;
            mem_data[5] <= 0;
            mem_data[6] <= 0;
        end
        else if(update)
            mem_data[addr] <= 1;
    end
endmodule


module asyn_reg1b(out, set);
    input set;
    output out;

    wire reset;
    inv1$ (reset, set);
    dff$ dff_1(.r(reset), .s(set));
endmodule

module asyn_reg16b(out, set);
    input set;
    output [15:0] out;

    wire reset;
    inv1$ (reset, set);
    dff16$ dff_1(.Q(out), .CLR(reset), .PRE(set));
endmodule


// row: 16 
// column: 8  [6:0] is valid tag part, [7] is fixed to 0 for convenience
module icache_ram8(addr, out, din, update);
    input [3:0]     addr;
    input           update;
    input [7:0]    din;
    output [7:0]   out;
    
    //--------------------------------------
    //  Condition Status
    //--------------------------------------
    // 1. write_n: inv of update -- low active
    wire write_n;
    inv1$ inv_write(write_n, update);
    // 2. select ram0
    // if addr in (0-7) select ram0 0000 - 0111
    // if addr in (8-7) select ram1 1000 - 1111
    wire ram0_sel_n, ram0_sel;
    wire [7:0] ram0_out, ram1_out;
    assign ram0_sel_n = addr[3];        // addr[3] = 1==> addr > 8 ==> ram1
    inv1$ inv_0(ram0_sel, addr[3]);
    // 3. when update the ram, you let OE be 1 ==> output is HIGH Z
    // OE = ram0_sel and !update
    wire ram0_OE, ram1_OE;
    and2$ and_0(ram0_OE, ram0_sel, update);
    nand2$ nand_0(ram1_OE, ram0_sel, update);
    
    //--------------------------------------
    //  Select RAM and OUTPUT
    //-------------------------------------- 
    ram8b8w$ ram0(addr[2:0], din, ram0_OE, write_n, ram0_out);       // ram's OE is low-active
    ram8b8w$ ram1(addr[2:0], din, ram1_OE, write_n, ram0_out);       // ram's OE is low-active
    wire [7:0] ram_out;     
    mux2_8$ mux_out(ram_out, ram0_out, ram1_out, ram0_sel_n);
    tristate8L$ tri_0(update, ram_out, out);
endmodule



module icache_ram16(addr, out, din, update);
    input [3:0]     addr;
    input           update;
    input [15:0]    din;
    output [15:0]   out;

    icache_ram8 ram_0(addr, out[7:0], din[7:0], update);
    icache_ram8 ram_1(addr, out[15:8], din[15:8], update);

endmodule


module icache_ram128(addr, out, din, update);
    input [3:0]     addr;
    input           update;
    input [127:0]    din;
    output [127:0]   out;

    // BlackBox
    // if read
    reg [127:0] mem [0:15];
    // if write tag <= ...
    always@(*)
    begin
        if(update)
        begin
            mem[addr] = din;
        end
    end

    assign out = mem[addr];
endmodule

// 3 column of instruction, 16Byte
// 1. write instruction into the buffer
// 2. read instruction from the buffer at the end of the cycle
//
//

module instruction_buffer(clk, flush, reset,set, next_row_valid, data_in, data_out, full_flag, row_addr, column_addr, write);
    input           clk;
    input [127:0]   data_in;
    input [1:0]     row_addr;
    input [3:0]     column_addr;
    input           write;
    input           reset;
    input           set;
    input           flush;
    
    output [127:0]  data_out;
    output          full_flag;
    output          next_row_valid;
    
    wire [3:0] v_bit;

    // full flag
    and4$ and_0(full_flag, v_bit[0], v_bit[1], v_bit[2], v_bit[3]);

    // write && flush
    // find first empty entry
    wire [3:0] ffz_out;
    wire [3:0] ld_buffer;
    wire       flush_n;
    wire set_zero_n;

    and2$ gate_set_zero(set_zero_n, flush_n, reset);
    inv1$ inv_0(flush_n, flush);
    find_first_zero4b ffz_1(ffz_out, v_bit);

    dff$ ld_buf3(.clk(clk), .d(ffz_out[3]), .q(ld_buffer[3]), .r(reset), .s(flush_n));
    dff$ ld_buf2(.clk(clk), .d(ffz_out[2]), .q(ld_buffer[2]), .r(set_zero_n), .s(set));
    dff$ ld_buf1(.clk(clk), .d(ffz_out[1]), .q(ld_buffer[1]), .r(set_zero_n), .s(set));
    dff$ ld_buf0(.clk(clk), .d(ffz_out[0]), .q(ld_buffer[0]), .r(set_zero_n), .s(set));

    wire [127:0] data0_out;
    wire [127:0] data1_out;
    wire [127:0] data2_out;
    wire [127:0] data3_out;

    latch128 data0(reset, data_in, ld_buffer[0], set, data0_out );
    latch128 data1(reset, data_in, ld_buffer[1], set, data1_out );
    latch128 data2(reset, data_in, ld_buffer[2], set, data2_out );
    latch128 data3(reset, data_in, ld_buffer[3], set, data3_out );
    
    latch$ valid_bit3(.d(1'b1), .q(v_bit[3]), .en(ld_buffer[3]), .r(reset), .s(flush_n));
    latch$ valid_bit2(.d(1'b1), .q(v_bit[2]), .en(ld_buffer[2]), .r(set_zero_n), .s(set));
    latch$ valid_bit1(.d(1'b1), .q(v_bit[1]), .en(ld_buffer[1]), .r(set_zero_n), .s(set));
    latch$ valid_bit0(.d(1'b1), .q(v_bit[0]), .en(ld_buffer[0]), .r(set_zero_n), .s(set));


    // read out from buffer  
    // assemble the data using two rows of data 
    wire [127:0] assem_data0;
    wire [127:0] assem_data1;
    wire [127:0] assem_data2;
    wire [127:0] assem_data3;
    
    assign assem_data0 = (data0_out >> (15-column_addr)) || (data0_out <<(column_addr));
    assign assem_data1 = (data0_out >> (15-column_addr)) || (data0_out <<(column_addr));
    assign assem_data2 = (data0_out >> (15-column_addr)) || (data0_out <<(column_addr));
    assign assem_data3 = (data0_out >> (15-column_addr)) || (data0_out <<(column_addr));
    
    mux4_128 mux_output(data_out, assem_data0, assem_data1, assem_data2, assem_data3, row_addr[0], row_addr[1]);

    /*
    or2$ or_0(ld_buffer[3], ffz_out[3], flush);
    and2$ and_1(ld_buffer[2], ffz_out[2], flush_n);
    and2$ and_2(ld_buffer[2], ffz_out[2], flush_n);
    and2$ and_3(ld_buffer[2], ffz_out[2], flush_n);
    */
    // write data into buffer
    // if ld_buffer[i] == 1, v_bit[i] <= 1, data[i] <= din; 
    


    // update valid bit: all v_bit except the first one will be reset.
endmodule


