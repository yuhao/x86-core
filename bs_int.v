
`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_gates.v"
//`uselib file=yjl_gates.v
module memory_black_box(clk, reset, set, cntl, req, gnt, addr, data, hsk_valid, hsk_ack);
    inout [31:0] addr;
    inout [31:0] data;
    inout [15:0]  cntl;
    inout         hsk_valid;          // data is valid on BUS
    inout         hsk_ack;          // data is valid on BUS

    // read_mem, write_mem, ...
    input       clk;
    input       gnt;
    input       reset;
    input       set;

    output      req;
    
    //wire read_mem;
    //assign read_mem = cntl[`RW];

    reg [127:0] mem [0:127];
    reg [127:0] mdr;
    reg [31:0]  mar;
    reg [15:0]   cntl_reg;
    reg         req;        // when req ==0, means that MM relieve BUS
    reg         hsk_ack_out;
    reg         hsk_valid_out;
   
    wire receiver;
    // if DST = 00, then its memory
    assign receiver = cntl[`VALID] && (cntl[`DST1:`DST0] == `MEM);

    assign hsk_ack = (receiver)? hsk_ack_out : 1'hz;
    assign hsk_valid = (gnt)? hsk_valid_out : 1'hz;

   // data_amount
    reg [3:0] data_amount;  // max = 15
    reg       ready_bit;    // be one when data is ready

    // if data_amount = 

    always@(gnt) 
    begin
        if(gnt)
        begin
            cntl_reg[`DST1:`DST0] = `IO;
            cntl_reg[`SRC1:`SRC0] = `MEM;
            cntl_reg[`VALID] = 1;
        end
    end

    always@(posedge(clk))
    begin
        if(!reset)
        begin
            req <= 0;
            hsk_valid_out <= 0;
            hsk_ack_out <= 0;
        end
        else
        if(receiver && (cntl[`RW] == 0))  // receive read_mem signal from BUS 
        begin
           mdr  <= mem[mar];
           ready_bit <= 1;
        end
        if(ready_bit)
        begin
            req <= 1;
        end
        if(gnt)
        begin
            if(hsk_ack)
            begin
                hsk_valid_out <= 0;
                req <= 0;
                ready_bit <= 0;
            end
            else    // initializing sending data 
            begin 
                hsk_valid_out <= 1;
            end
        end
        if(receiver)
        begin
            if(hsk_valid)
            begin    
                hsk_ack_out <= 1;
                mar <= addr;
            end
            else hsk_ack_out <= 0;
        end
    end

    assign data = (gnt)? mdr : 128'hz;
    assign addr = (gnt)? mar : 32'hz;
    assign cntl = (gnt)? cntl_reg: 16'hz;


endmodule

// This is simplely a bus arbitrator
// if the bus is granted to a certain bus station, the station should hold this bus until it get data from memory.
// since if the memory is preparing the data, no other devies can get data from memory.
// bus station can relieve bus by lowering request signal
module bus_interface(
    clk,
    reset,
    set,
    req,
    gnt,
    bus_data,
    bus_addr,
    bus_cntl,
    hsk_valid,
    hsk_ack
);
    //-----------------------------
    //  Bus 
    //-----------------------------
    inout [31:0] bus_addr;
    inout [15:0] bus_cntl;
    inout [31:0] bus_data;
    inout        hsk_valid;
    inout        hsk_ack;
    
    // Input Ports
    input       reset, set, clk;
    input [3:0] req;        // bitmap for requesting map 

    // Output Ports
    output [3:0] gnt;       // bitmap of granting bus    
    
    //-------------------------------
    //  Condition Status
    //-------------------------------
    // holding_n: 
    // 1. no one is granted the bus
    // 2. one is gnted bus but it relieves the bus by lowering the req signal)
    wire holding_n;
    wire hold0, hold1, hold2, hold3;
    and2$ and_0(hold0, gnt[0], req[0]);
    and2$ and_1(hold1, gnt[1], req[1]);
    and2$ and_2(hold2, gnt[2], req[2]);
    and2$ and_3(hold3, gnt[3], req[3]);
    nor4$ or_tenure(holding_n, hold0, hold1, hold2, hold3);
    
    // com_gnt: if the bus has been granted to any devices
    // 0: on one is granted the bus
    wire com_gnt;
    or4$ and_com_gnt(com_gnt, gnt[3], gnt[2], gnt[1], gnt[0]);
    
    // Some Notes
    // 1. difference between holding_n and com_gnt
    //      if A is holding the BUS and it decides to relieve by lowering REQ, its GNT will still be 1
    //      but at this point, you can redistribute BUS again. 
    //-------------------------------
    // Daisy Chains
    //-------------------------------
    // daisy_gnt: distributing bus according to req bitmap
    // 1000 (MSB -> LSB) : bus is granted to MEMORY
    // 0100 (MSB -> LSB) : bus is granted to DCACHE
    // 0010 (MSB -> LSB) : bus is granted to ICACHE
    // 0001 (MSB -> LSB) : bus is granted to IO
    wire [3:0] daisy_gnt;
    daisy_chain bus_daisy(daisy_gnt, req);
  
    //--------------------------
    //  Tenure 
    //--------------------------
    // enable modifying gnt only when NO ONE is holding 
    reg4e gnt_reg(.CLK(clk), .Din(daisy_gnt), .Q(gnt), .CLR(reset), .PRE(set), .en(holding_n));
    
    //--------------------------
    //  Set Default BUS value 
    //--------------------------
    // data <- 0
    // addr <- 0
    // cntl <- not valid, 0 for others
    // hsk_valid, hsk_ack <- 0;
    tristate32L tri_data(com_gnt, 32'b0, bus_data);
    tristate32L tri_addr(com_gnt, 32'bz, bus_addr);
    tristate16L$ tri_cntl(com_gnt, 16'b0000_0000_0000_0000, bus_cntl);
    tristateL$ tri_hsk_0(com_gnt, 1'b0, hsk_valid);
    tristateL$ tri_hsk_1(com_gnt, 1'b0, hsk_ack);

    //--------------------------
    // Unused Wires
    //--------------------------
    // 1. request_n: 0 : no one is requesting bus
    //wire requesting_n;
    //nor4$ or_request(requesting_n, req[3], req[2], req[1], req[0]);
    

endmodule

// logic: find 1st ONE in the bitmap of requesting BUS
// eg: in = 1100 out = 1000 
//     in = 0010 out = 0010
module daisy_chain(out, in);
   input [3:0] in;
   output [3:0] out;

   // find first one
   wire [3:0] in_neg;
   inv4 inv_0(in_neg, in);
   find_first_zero4b ffz_0(out, in_neg);
endmodule

//-------------------------------------------
// Bus Station
// function: uniform interface 
//      between device and bus/bus_interface
//-------------------------------------------
// state0: IDLE req = 0 | N/A
// state1: NOTIFYING MEM gnt = 1 | hsk_valid = 1
// state2: WAITING FOR DATA  hsk_ack == 1 | counter = 4, hsk_valid = 0
// state3: REC DATA hsk_valid == 1 | cache_fill = 1, hsk_ack = 1
// state4: FINISH counter == 0 | req = 0
module bus_station(
    clk,
    reset,
    set,
    ready_bit,      // memory 
    device_id,      // 
    dst_device_id,  //
    bus_data,   
    bus_addr, 
    bus_cntl,
    req,
    gnt,
    receiving_data, // 
    hsk_ack,
    hsk_valid,      // 
    finish,         // 
    req_signal,     // some signal telling the blackbox to request BUS resource. 
    write_memory_signal,
    data_in,
    counter_in,
    cntl_signal,
    addr_in,
    data_out,
    addr_out,
    cntl_out,
    device_wr,      // device write or read (read or write memory)
    write_signal,   // generate negative puslses to write the Cache/Memory
    device_we       // device write enable  (write memory)
); 
    //---------------------------------------- 
    // Bus 
    //---------------------------------------- 
    inout [31:0]    bus_data;
    inout [31:0]    bus_addr;
    inout [15:0]    bus_cntl;
    // handshake protocol
    inout hsk_valid;
    inout hsk_ack;
    
    //---------------------------------------- 
    // Input Ports
    //---------------------------------------- 
    input       clk, reset, set;
    input       gnt;
    input       ready_bit;      //   for memory to send out data`
    input [1:0] device_id;
    input [1:0] dst_device_id;
    
    input         req_signal;       // for icache and dcache, miss_signal is the req_signal, used by the connected device to req bus.
    input         write_memory_signal;

    input [8:0]   counter_in;       // value to load into counter
    input [31:0]  data_in;          // direct -> bus_data
    input [31:0]  addr_in;          // direct -> bus_addr
    input [15:0]  cntl_signal;       // select relevant operations
 

    //---------------------------------------- 
    // Output Ports
    //---------------------------------------- 
    output          req;
    output          finish;    // flag of work finished, telling the device to clear request_signal (i.e., miss_signal)
    output [31:0]   data_out;
    output [31:0]   addr_out;
    output [15:0]   cntl_out;
    output          receiving_data;       // after gnting the bus.
    output          device_wr;
    output [3:0]    device_we;
    output          write_signal;

   
    // relevant operations to load to the bus_cntl
    wire [15:0] bus_cntl_op0;
    wire [15:0] bus_cntl_op3;
    //wire bus_cntl_op1;
    wire [15:0] bus_cntl_op;
    wire [1:0]  bus_cntl_sel;
    
    //---------------------------------------- 
    // Relevant Operations (Devvice to Memory)
    //---------------------------------------- 
    // if D-Cache 
    // 1. read operation
    //    THe only function is read from memory
    //    data_in = ???
    //    addr_in = icache_addr
    //    cntl: [`valid] = 1; [`DST1:DST0] = `MEM; [`SRC1:`SRC0] = `ICACHE; [`WR] = 0, [SUM4:SUM0] = 16
     
    assign bus_cntl_op0[`VALID] = 1;
    assign bus_cntl_op0[`UNUSED] = 0;
    assign bus_cntl_op0[`DST1:`DST0] = dst_device_id;
    assign bus_cntl_op0[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op0[`RW] = 0;
    assign bus_cntl_op0[`SUM3:`SUM0] = `ICACHE_COUNTER;
   

    // 2. write operation
    //    read memory is similar to ICache
    //    write memory:
    //    data_in = write_back data
    //    cntl: [`valid], [dst], [src], [wr] = 1, [sum] = 4
    /*
    assign bus_cntl_op0[`VALID] = 1;
    assign bus_cntl_op0[`VALID-1:`RW+1] = 0;
    assign bus_cntl_op0[`DST1:`DST0] = `MEM;
    assign bus_cntl_op0[`SRC1:`SRC0] = `DCACHE;
    assign bus_cntl_op0[`RW] = 1;
    assign bus_cntl_op0[`SUM3:SUM0] = `DCACHE_COUNTER;
    */ 


    // 3. finish operations, notifying the memory
  
    assign bus_cntl_op3[`VALID] = 0;
    assign bus_cntl_op3[`UNUSED] = 0;
    assign bus_cntl_op3[`DST1:`DST0] = dst_device_id;
    assign bus_cntl_op3[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op3[`RW] = 0;
    assign bus_cntl_op3[`SUM3:`SUM0] = `ICACHE_COUNTER;

    //---------------------------------------
    //  Bus Station states
    //--------------------------------------
    // req, gnt
    // 00       idle
    // 01       wrong
    // 10       requesting
    // 11       holding

    parameter BUS_REQ = 3'b000;     // when not give bus, just idle
    parameter BUS_HOLD = 3'b011;
    parameter BUS_IDLE = 3'b000;
    parameter BUS_WRONG = 4'b001;

    // control signal
    parameter JUMP_FIELD0 = 0;
    parameter JUMP_FIELD1 = 1;
    parameter JUMP_FIELD2 = 2;
    parameter JUMP_FIELD3 = 2;
    parameter COUNTER_PL = 6;
    //parameter COUNTER_IN0 = 4;
    //parameter COUNTER_IN1 = 5;
    //parameter COUNTER_IN2 = 6;
    parameter COUNTER_EN = 7;
    parameter RECEIVING = 8;
    parameter BUS_DATA_ENBAR = 9;   // rec/set
    parameter BUS_ADDR_ENBAR = 10;   // rec/set
    parameter BUS_CNTL_ENBAR = 11;   // rec/set
    parameter FINISH = 12;
    parameter HSK_ACK = 13;
    parameter HSK_VALID = 14;
    // used to select the values to put on the control bus.
    parameter BUS_CNTL_SEL0 = 15;
    parameter BUS_CNTL_SEL1 = 16;
    parameter DEVICE_WR = 17;
    parameter DEVICE_WE0 = 18;
    parameter DEVICE_WE1 = 19;
    parameter DEVICE_WE2 = 20;
    parameter DEVICE_WE3 = 21;
   
    wire gnt_n;
    inv1$(gnt_n, gnt);

    wire receiver;
    wire receiver_tmp;
    wire receiver_valid;        // aka. send_neg

    wire [3:0] next_state1;
    wire [3:0] next_state0;
    wire [3:0] next_state;
    wire [3:0] state;               // state that changes every cycle

    wire [7:0] counter_out;   // output of counter
    wire       counter_pl;    // signal to parallel load counter;
    wire       counter_en;

    wire [31:0] control_signal;
    wire [31:0] recv_cs;
    wire [31:0] send_cs;

    wire counter_empty;     // counter = 11     
    wire [3:0] J;       // jump field
    wire mem_w;
    wire mem_r;
    wire req_bus;

    assign mem_w = write_memory_signal;
    assign mem_r = req_signal;
    xor2$ and_req_bus(req_bus, mem_w, mem_r);

    cmp8b cmp_counter_zero(counter_empty, counter_out, 8'b0);

    assign counter_pl = control_signal[COUNTER_PL];
    assign counter_en = write_signal;//control_signal[COUNTER_EN];

    // the first 3 bits of the ucode is jump field
    //assign J[3] = mem_w;            // write fsm are 1xxx, read fsm are 0xxx 
    assign J[2] = send_cs[JUMP_FIELD2];
    assign J[1] = send_cs[JUMP_FIELD1];
    assign J[0] = send_cs[JUMP_FIELD0];


    initial
    begin
        $readmemb("bus_station_icache_fsm.list", send_state_machine.mem);
        $readmemb("bus_station_mem_fsm.list", recv_state_machine.mem);
    end
    rom32b32w$ send_state_machine(.A(state), .OE(1'b1), .DOUT(send_cs));  // 
    // microsequencer 
    assign next_state1[3] = mem_w;
    or2$(next_state1[2], J[2], counter_empty);
    assign next_state1[1] = J[1];
    and2$(next_state1[0], J[0], hsk_valid);


    mux2_3(next_state0, BUS_REQ, next_state1, gnt);
    mux2_3(next_state, BUS_IDLE, next_state0, req);
    reg3e state_reg(.CLK(clk), .Din(next_state), .Q(state), .CLR(reset), .PRE(set), .en(1'b1));
    //latch3 state_reg(.EN(1'b1), .CLR(reset), .PRE(set), .D(next_state), .Q(state));
    
    syn_cntr8$ amount_counter(
        .CLK(clk),
        .CLR(1'b1),
        .PRE(!finish),  // when not finish, default value of couner is 8'hff
        .D(counter_in),
        .EN(counter_en),
        .PL(counter_pl),
        .UP(1'b0),
        .Q(counter_out)
    );


    //--------------------------------
    //  State Machine of Receiver
    //--------------------------------
    wire [2:0] _J;
    wire [2:0] _state;
    wire [2:0] _next_state0;
    wire [2:0] _next_state;

    parameter _IDLE = 3'b00;
    parameter _REC_REQ = 3'b011;
    parameter _SEND_DATA = 3'b010;
    
    assign _J[2] = recv_cs[JUMP_FIELD2];
    assign _J[1] = recv_cs[JUMP_FIELD1];
    assign _J[0] = recv_cs[JUMP_FIELD0];

    wire _j0_or_ack;
    or2$(_j0_or_ack, _J[0], hsk_ack);

    assign _next_state0[2] = _J[2];
    assign _next_state0[1] = _J[1];
    assign _next_state0[0] = _j0_or_ack;

    mux2_3(_next_state, _IDLE, _next_state0, !req);

    reg3e _state_reg(.CLK(clk), .Din(_next_state), .Q(_state), .CLR(reset), .PRE(set), .en(1'b1));
   
    rom32b32w$ recv_state_machine(.A(_state), .OE(1'b1), .DOUT(recv_cs));  // 
    
    // being used as a receiver...
    cmp2b cmp_0(receiver_tmp, bus_cntl[`DST1:`DST0], device_id);
    and2$ and_0(receiver_valid, receiver_tmp, bus_cntl[`VALID]);
    //latch$ receiver_latch(.en(bus_cntl[`VALID]), .r(reset), .s(set), .d(receiver_valid), .q(receiver));
    assign receiving = receiver_valid;
    
    // if gnt (holding BUS) && hsk_ack==0, then hsk_valid = 1;
    //wire hsk_valid_tmp;
    //wire hsk_valid_out;
    //wire hsk_ack_out;
    //reg1e hsk_valid_reg(.CLK(clk), .Din(!hsk_ack), .Q(hsk_valid_out), .CLR(reset), .PRE(set), .en(gnt));

    //reg1e hsk_ack_reg(.CLK(clk), .Din(finish), .Q(hsk_ack_out), .CLR(reset), .PRE(set), .en(receiver));

    
    
    // when gnt && hsk_ack, waiting is set to 1
    // then relieve the bus (req -> 0 ==> gnt->0), waiting should be still 1
    // until when receiver && finish waiting clear.
    //reg waiting;      
    //always@(*)
    //begin
    //    if(!reset)
    //        waiting <= 0;
    //    if(hsk_ack)
    //        if(gnt)
    //        waiting <= 1;
    //    if(finish) 
    //        waiting <= 0;
    //end

    // if req_signal, and not receiving data, then req BUS
    //wire no_ack;    
    //wire req_tmp;
    //nor2$ and_req_tmp(req_tmp, !req_signal, waiting);  // not holding BUS, 
    //nor2$ nor_0(no_ack, gnt_n, hsk_ack);    // sending data && no feedback
    
    //reg1e req_reg(.CLK(clk), .Din(req_tmp), .Q(req), .CLR(reset), .PRE(set), .en(1'b1));
    dff$ request_reg(.clk(clk), .r(reset), .s(set), .d(req_signal), .q(req));
    
    //wire hsk_ack_n;
    //inv1$ inv_hsk_ack(hsk_ack_n, hsk_ack_out);
    
    //wire [3:0] counter; 
    //assign counter = `ICACHE_COUNTER;
    //wire [3:0] counter_tmp;
    //wire [3:0] counter_out;
    //wire [3:0] counter_dec;
    //wire finish_tmp;
    //assign finish_tmp = req_signal && (counter_out==0) && receiver;
    //reg1e finish_reg(.CLK(clk), .Din(finish_tmp), .Q(finish), .CLR(reset), .PRE(set), .en(1'b1));
    

    // if the device is requesting or holding the BUS
    //wire working;
    //or2$ or_working(working, req, receiver);

    //// set counter a initial value, decrease it every cycle if receive some data.
    //// counter == 0, && if req_signal == 1 
    //mux2_4 mux_counter(counter_tmp, counter, counter_dec, receiver);        // when not receiver, set counter back to initial value.
    //decrementer4b dec_counter(counter_dec, counter_out);
    //reg4e counter_reg(.CLK(clk), .Din(counter_tmp), .Q(counter_out), .CLR(reset), .PRE(set), .en(working));
    
    // if req == 1, in MASTER mode
    // if req == 0, in SLAVE mode
    mux2_32 mux_control_signal(control_signal, recv_cs, send_cs, req);
 

    // if gnt == 1, MASTER is holding the BUS, waiting for the valid bit of SLAVE
    // if gnt == 9, SLAVE is waiting for the bus_cntl signal...
    wire slave;
    wire master;
    assign master = gnt;
    inv1$(slave, master);
    tristateL$ tri_hsk_ack(slave, control_signal[HSK_ACK], hsk_ack);
    tristateL$ tri_hsk_valid(master, control_signal[HSK_VALID], hsk_valid);
   

    // get data, addr, cntl from the BUS
    // for the I-Cache, we only need the data.
    assign data_out = bus_data;
    assign addr_out = bus_addr;
    assign cntl_out = bus_cntl;

    // set control bus according to the fsm 
    assign bus_cntl_sel = control_signal[BUS_CNTL_SEL1:BUS_CNTL_SEL0];
    mux4_16$ mux_bus_cntl(bus_cntl_op, bus_cntl_op0, bus_cntl_op1, bus_cntl_op2, bus_cntl_op3, bus_cntl_sel[0], bus_cntl_sel[1]);

    tristate32L tri_bus_data(control_signal[BUS_DATA_ENBAR], data_in, bus_data);
    tristate32L tri_bus_addr(control_signal[BUS_ADDR_ENBAR], {addr_in[31:4],counter_out[1:0], {2'b0}}, bus_addr);
    tristate16L$ tri_bus_cntl(control_signal[BUS_CNTL_ENBAR], bus_cntl_op, bus_cntl);
    
    assign finish = control_signal[FINISH];
    assign receiving_data = control_signal[RECEIVING];

    assign device_we = control_signal[DEVICE_WE3:DEVICE_WE0];
    assign device_wr = control_signal[DEVICE_WR];
    and2$ and_write_signal(write_signal, hsk_valid, hsk_ack);
    
 endmodule


