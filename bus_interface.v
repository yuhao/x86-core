`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_gates.v"

// 1. DMA_station
// 2. icache_station
// 3. dcache_station
// 4. memory_station

`define BUS_REQ   4'b000     // when not give bus, just idle
`define BUS_HOLD   4'b011
`define BUS_IDLE   4'b000
`define BUS_WRONG   4'b001

// control signal
`define JUMP_FIELD0   0
`define JUMP_FIELD1   1
`define JUMP_FIELD2   2
`define COUNTER_PL   6
//`define COUNTER_IN0   4
//`define COUNTER_IN1   5
//`define COUNTER_IN2   6
`define COUNTER_EN   7
`define RECEIVING   8
`define BUS_DATA_ENBAR   9   // rec/set
`define BUS_ADDR_ENBAR   10   // rec/set
`define BUS_CNTL_ENBAR   11   // rec/set
`define FINISH   12
`define HSK_ACK   13
`define HSK_VALID   14
// used to select the values to put on the control bus.
`define BUS_CNTL_SEL0   15
`define BUS_CNTL_SEL1   16
`define DEVICE_WR   17
`define DEVICE_WE0   18
`define DEVICE_WE1   19
`define DEVICE_WE2   20
`define DEVICE_WE3   21

//---------------------------------------
//
//	Bus Arbitrator
//
//---------------------------------------
// This is simplely a bus arbitrator
// if the bus is granted to a certain bus station, the station should hold this bus until it get data from memory.
// since if the memory is preparing the data, no other devies can get data from memory.
// bus station can relieve bus by lowering request signal
// simply use *DAISY CHAIN* to decide the order to serve
module bus_arbitrator(
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

//---------------------------------
//
//	Daisy Chain
//
//--------------------------------
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

    input [7:0]   counter_in;       // value to load into counter
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
    wire [15:0] bus_cntl_op1;
    wire [15:0] bus_cntl_op2;
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
    assign bus_cntl_op0[`DST1:`DST0] = `MEM;
    assign bus_cntl_op0[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op0[`RW] = 0;
   

    // 2. write operation
    //    read memory is similar to ICache
    //    write memory:
    //    data_in = write_back data
    //    cntl: [`valid], [dst], [src], [wr] = 1, [sum] = 4
    
    assign bus_cntl_op1[`VALID] = 1;
    assign bus_cntl_op1[`UNUSED] = 0;
    assign bus_cntl_op1[`DST1:`DST0] = `MEM;
    assign bus_cntl_op1[`SRC1:`SRC0] = `DCACHE;
    assign bus_cntl_op1[`RW] = 1;
     


    // 3. finish operations, notifying the memory
  
    assign bus_cntl_op3[`VALID] = 0;
    assign bus_cntl_op3[`UNUSED] = 0;
    assign bus_cntl_op3[`DST1:`DST0] = `MEM; 
    assign bus_cntl_op3[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op3[`RW] = 0;

    //---------------------------------------
    //  Bus Station states
    //--------------------------------------
    // req, gnt
    // 00       idle
    // 01       wrong
    // 10       requesting
    // 11       holding

    wire gnt_n;
    inv1$ inv_gnt(gnt_n, gnt);

    wire req_bus;
    wire mem_w;
    wire mem_r;
    assign mem_w = write_memory_signal;
    assign mem_r = req_signal;
    xor2$ xor_req_bus(req_bus, mem_r, mem_w);

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
    wire [2:0] J;       // jump field

    cmp8b cmp_counter_zero(counter_empty, counter_out, 8'b0);

    assign counter_pl = control_signal[`COUNTER_PL];
    assign counter_en = write_signal;//control_signal[COUNTER_EN];

    // the first 3 bits of the ucode is jump field
    assign J[2] = send_cs[`JUMP_FIELD2];
    assign J[1] = send_cs[`JUMP_FIELD1];
    assign J[0] = send_cs[`JUMP_FIELD0];


    initial
    begin
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/bs_dma_send.list", send_state_machine.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/bs_dma_recv.list", recv_state_machine.mem);
    end
    rom32b32w$ send_state_machine(.A({1'b0, state}), .OE(1'b1), .DOUT(send_cs));  // 
    // microsequencer 
    assign next_state1[3] = mem_w;
    or2$ or_next1(next_state1[2], J[2], counter_empty);
    assign next_state1[1] = J[1];
    and2$ and_next1(next_state1[0], J[0], hsk_valid);


    mux2_4 mux_next_state0(next_state0, `BUS_REQ, next_state1, gnt);
    mux2_4 mux_next_state(next_state, `BUS_IDLE, next_state0, req);
    reg4e state_reg(.CLK(clk), .Din(next_state), .Q(state), .CLR(reset), .PRE(set), .en(1'b1));
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
    
    assign _J[2] = recv_cs[`JUMP_FIELD2];
    assign _J[1] = recv_cs[`JUMP_FIELD1];
    assign _J[0] = recv_cs[`JUMP_FIELD0];

    wire _j0_or_ack;
    or2$ _or_jack(_j0_or_ack, _J[0], hsk_ack);

    assign _next_state0[2] = _J[2];
    assign _next_state0[1] = _J[1];
    assign _next_state0[0] = _j0_or_ack;

    mux2_3 _mux_next_state(_next_state, _IDLE, _next_state0, !req);

    reg3e _state_reg(.CLK(clk), .Din(_next_state), .Q(_state), .CLR(reset), .PRE(set), .en(1'b1));
   
    rom32b32w$ recv_state_machine(.A({2'b0, _state}), .OE(1'b1), .DOUT(recv_cs));  // 
    
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
    dff$ request_reg(.clk(clk), .r(reset), .s(set), .d(req_bus), .q(req));
    
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
    inv1$ inv_slave(slave, master);
    tristateL$ tri_hsk_ack(slave, control_signal[`HSK_ACK], hsk_ack);
    tristateL$ tri_hsk_valid(1'b1, control_signal[`HSK_VALID], hsk_valid);
   

    // get data, addr, cntl from the BUS
    // for the I-Cache, we only need the data.
    assign data_out = bus_data;
    assign addr_out = bus_addr;
    assign cntl_out = bus_cntl;

    // set control bus according to the fsm 
    assign bus_cntl_sel = control_signal[`BUS_CNTL_SEL1:`BUS_CNTL_SEL0];
    mux4_16$ mux_bus_cntl(bus_cntl_op, bus_cntl_op0, bus_cntl_op1, bus_cntl_op2, bus_cntl_op3, bus_cntl_sel[0], bus_cntl_sel[1]);
    
    wire bus_data_enbar;
    assign bus_data_enbar = control_signal[`BUS_DATA_ENBAR];
    tristate32L tri_bus_data(bus_data_enbar, data_in, bus_data);
    wire [1:0] addr_counter_part;
    reg4e count_addr_reg(.CLK(clk), .Din(counter_out[3:0]), .Q(addr_counter_part), .CLR(reset), .PRE(set), .en(1'b1));
    tristate32L tri_bus_addr(control_signal[`BUS_ADDR_ENBAR], {addr_in[31:4],addr_counter_part, {2'b0}}, bus_addr);
    //tristate16L$ tri_bus_cntl(control_signal[BUS_CNTL_ENBAR], bus_cntl_op, bus_cntl);
    tristate16L$ tri_bus_cntl(gnt_n, bus_cntl_op, bus_cntl);
    
    assign finish = control_signal[`FINISH];
    assign receiving_data = control_signal[`RECEIVING];

    assign device_we = control_signal[`DEVICE_WE3:`DEVICE_WE0];
    assign device_wr = control_signal[`DEVICE_WR];
    and2$ and_write_signal(write_signal, hsk_valid, hsk_ack);
    
 endmodule


//-----------------------------
//
//  Memory Station
//
//-----------------------------
module memory_station(
    clk,
    reset,
    set,
    ready_bit,      // memory 
    device_id,      // 
    dst_device_id,  //
    bus_data,   
    bus_addr, 
    bus_cntl,
    mem_data,
    req,
    gnt,
    receiving_data, // 
    hsk_ack,
    hsk_valid,      // 
    finish,         // 
    req_signal,     // some signal telling the blackbox to request BUS resource. 
    write_memory_signal,
    data_in,
    cntl_signal,
    addr_in,
    data_out,
    addr_out,
    cntl_out,
    device_wr,      // device write or read (read or write memory)
    write_signal,   // generate negative puslses to write the Cache/Memory
    device_we_out       // device write enable  (write memory)
); 
    //---------------------------------------- 
    // Bus 
    //---------------------------------------- 
    inout [31:0]    bus_data;
    inout [31:0]    bus_addr;
    inout [15:0]    bus_cntl;
    inout [31:0]    mem_data;
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
    output [3:0]    device_we_out;
    output          write_signal;

   
    //-----------------------------------------
    // Memory or DMA receive
    //-----------------------------------------
    wire is_slave; 
    wire is_slave_n; 
    cmp2b cmp_is_slave(is_slave, bus_cntl[`DST1:`DST0], device_id);
    cmp2bL cmp_is_slave_n(is_slave_n, bus_cntl[`DST1:`DST0], device_id);

       
    wire gnt_n;
    inv1$ inv_gnt(gnt_n, gnt);

    wire [31:0] control_signal;
    
    initial
    begin
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/bs_mem_fsm.list", recv_state_machine.mem);
    end

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
    
    assign _J[2] = control_signal[`JUMP_FIELD2];
    assign _J[1] = control_signal[`JUMP_FIELD1];
    assign _J[0] = control_signal[`JUMP_FIELD0];

    wire _j0_or_ack;
    or2$ _or_jack(_j0_or_ack, _J[0], hsk_ack);

    assign _next_state0[2] = _J[2];
    assign _next_state0[1] = _J[1];
    assign _next_state0[0] = _j0_or_ack;

    mux2_3 _mux_next_state(_next_state, _IDLE, _next_state0, is_slave); //!req);

    reg3e _state_reg(.CLK(clk), .Din(_next_state), .Q(_state), .CLR(reset), .PRE(set), .en(1'b1));
   
    rom32b32w$ recv_state_machine(.A({2'b0, _state}), .OE(1'b1), .DOUT(control_signal));  // 
    
    // being used as a receiver...
    cmp2b cmp_0(receiver_tmp, bus_cntl[`DST1:`DST0], device_id);
    and2$ and_0(receiver_valid, receiver_tmp, bus_cntl[`VALID]);
    //latch$ receiver_latch(.en(bus_cntl[`VALID]), .r(reset), .s(set), .d(receiver_valid), .q(receiver));
    assign receiving = receiver_valid;
   
    //reg1e req_reg(.CLK(clk), .Din(req_tmp), .Q(req), .CLR(reset), .PRE(set), .en(1'b1));
    assign req = req_signal;
 

    // if gnt == 1, MASTER is holding the BUS, waiting for the valid bit of SLAVE
    // if gnt == 9, SLAVE is waiting for the bus_cntl signal...
    wire slave;
    wire master;
    assign master = gnt;
    inv1$ inv_slave(slave, master);
    //tristateL$ tri_hsk_valid(1'b0, control_signal[HSK_VALID], hsk_valid);
    tristateL$ tri_hsk_valid(is_slave_n, control_signal[`HSK_VALID], hsk_valid);
   

    // get data, addr, cntl from the BUS
    // for the I-Cache, we only need the data.
    assign data_out = bus_data;
    assign addr_out = bus_addr;
    assign cntl_out = bus_cntl;

    wire bus_data_enbar;
    assign bus_data_enbar = bus_cntl[`RW];
    tristate32L tri_bus_data(bus_cntl[`RW], mem_data, bus_data);
    tristate32L tri_mem_data(!bus_cntl[`RW], bus_data, mem_data);
    tristate32L tri_bus_addr(1'b1, 32'hffff, bus_addr);

    //tristate32L tri_bus_addr(control_signal[BUS_ADDR_ENBAR], {addr_in[31:4],counter_out[1:0], {2'b0}}, bus_addr);

    
    assign finish = control_signal[`FINISH];
    assign receiving_data = control_signal[`RECEIVING];

    assign device_we_out = bus_cntl[`WE3:`WE0]; 
    assign device_wr = bus_cntl[`RW];
    nand2$ nand_write_signal(write_signal, hsk_valid, hsk_ack);
    
 endmodule


//------------------------------------------
//
//  D-Cache Station
//
//------------------------------------------
// note:
// 1. finish:
//  for read, d-cache can begin to read data
//  for write, d-cache can begin to do other thing
module dcache_station(
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
    device_we_in       // device write enable  (write memory)
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

    input [7:0]   counter_in;       // value to load into counter
    input [31:0]  data_in;          // direct -> bus_data
    input [31:0]  addr_in;          // direct -> bus_addr
    input [15:0]  cntl_signal;       // select relevant operations
    input [3:0]   device_we_in;
 
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
    output          write_signal;

      
    //-----------------------------------
    //  Wires
    //-----------------------------------
    // holding bus or not.
    wire gnt_n;
    // bus req
    wire req_bus;
    wire mem_w;     // if mem_w | mem_r, we req bus.
    wire mem_r;
    wire [3:0] next_state1;
    // state machine
    wire [3:0] next_state0;
    wire [3:0] next_state;
    wire [3:0] state;               // state that changes every cycle
    // counter
    wire [7:0] counter_out;   // output of counter
    wire       counter_pl;    // signal to parallel load counter;
    wire       counter_en;
    // fsm ucode
    wire [31:0] control_signal;
    wire [31:0] master_cs;
    wire counter_empty;     // counter = 11     
    // fsm jump
    wire [2:0] J;       // jump field

    // relevant operations to load to the bus_cntl
    wire [15:0] bus_cntl_op0;
    wire [15:0] bus_cntl_op1;
    wire [15:0] bus_cntl_op2;
    wire [15:0] bus_cntl_op3;
    //wire bus_cntl_op1;
    wire [15:0] bus_cntl_op;
    wire [1:0]  bus_cntl_sel;
    
    wire [1:0]  destination;
    wire dma_or_mem;
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    //---------------------------------------- 
    // Relevant Operations (Devvice to Memory)
    //---------------------------------------- 
    // 1. read operation
    //    THe only function is read from memory
    //    data_in = ???
    //    addr_in = icache_addr
    //    cntl: [`valid] = 1; [`DST1:DST0] = `MEM; [`SRC1:`SRC0] = `ICACHE; [`WR] = 0, [SUM4:SUM0] = 16
    assign bus_cntl_op0[`VALID] = 1;
    assign bus_cntl_op0[`UNUSED] = 0;
    assign bus_cntl_op0[`DST1:`DST0] = destination; 
    assign bus_cntl_op0[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op0[`WE3:`WE0] = device_we_in;
    assign bus_cntl_op0[`RW] = 0;
   
    // 2. write operation
    //    read memory is similar to ICache
    //    write memory:
    //    data_in = write_back data
    //    cntl: [`valid], [dst], [src], [wr] = 1, [sum] = 4
    assign bus_cntl_op1[`VALID] = 1;
    assign bus_cntl_op1[`UNUSED] = 0;
    assign bus_cntl_op1[`DST1:`DST0] = destination; 
    assign bus_cntl_op1[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op1[`WE3:`WE0] = device_we_in;
    assign bus_cntl_op1[`RW] = 1;
   

    // 3. finish operations, notifying the memory
    assign bus_cntl_op3[`VALID] = 1;
    assign bus_cntl_op3[`UNUSED] = 0;
    assign bus_cntl_op3[`DST1:`DST0] = destination; 
    assign bus_cntl_op3[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op3[`WE3:`WE0] = device_we_in;
    assign bus_cntl_op3[`RW] = 0;

    cmp16b cmp_dstid(dma_or_mem, addr_in[31:16], 16'hffff);
    mux2_2 mux_dstid(destination, `MEM, `IO, dma_or_mem);


    inv1$ inv_gnt(gnt_n, gnt);
    // generate negative pulses.
    and2$ and_write_signal(write_signal, hsk_valid, hsk_ack);
    // generate request signal
    assign mem_w = write_memory_signal;
    assign mem_r = req_signal;
    xor2$ xor_req_bus(req_bus, mem_r, mem_w);
    
    //------------------------------
    // state machine
    //------------------------------
    // state machine of master (such as DMA, Icache, Dcache)
    rom32b32w$ master_state_machine(.A({1'b0, state}), .OE(1'b1), .DOUT(master_cs));  
    initial 
    begin
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/bs_dcache_fsm.list", master_state_machine.mem);
    end

    //-----------------------------
    // microsequencer 
    //-----------------------------
    // the first 3 bits of the ucode is jump field
    assign J[2] = master_cs[`JUMP_FIELD2];
    assign J[1] = master_cs[`JUMP_FIELD1];
    assign J[0] = master_cs[`JUMP_FIELD0];

    assign next_state1[3] = mem_w;
    or2$ or_next1(next_state1[2], J[2], counter_empty);
    assign next_state1[1] = J[1];
    and2$ and_next1(next_state1[0], J[0], hsk_valid);

    mux2_4 mux_next_state0(next_state0, `BUS_REQ, next_state1, gnt);
    mux2_4 mux_next_state(next_state, `BUS_IDLE, next_state0, req);
    reg4e state_reg(.CLK(clk), .Din(next_state), .Q(state), .CLR(reset), .PRE(set), .en(1'b1));
    
    // counter of byte transfer
    // dec counter from the #num byte you want to transfer to zero
    cmp8b cmp_counter_zero(counter_empty, counter_out, 8'b0);
    assign counter_pl = control_signal[`COUNTER_PL];
    assign counter_en = write_signal;//control_signal[COUNTER_EN];

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


    // req d-flop
    dff$ request_reg(.clk(clk), .r(reset), .s(set), .d(req_bus), .q(req));
    
	assign control_signal = master_cs;
 
    // only use hsk_ack.
    // the slave station will use the hsk_valid 
    tristateL$ tri_hsk_ack(gnt_n, control_signal[`HSK_ACK], hsk_ack);
    tristateL$ tri_hsk_valid(1'b1, control_signal[`HSK_VALID], hsk_valid);
   

    // get data, addr, cntl from the BUS
    // for the I-Cache, we only need the data.
    assign data_out = bus_data;
    assign addr_out = bus_addr;
    assign cntl_out = bus_cntl;

    // set control bus according to the fsm 
    assign bus_cntl_sel = control_signal[`BUS_CNTL_SEL1:`BUS_CNTL_SEL0];
    mux4_16$ mux_bus_cntl(bus_cntl_op, bus_cntl_op0, bus_cntl_op1, bus_cntl_op2, bus_cntl_op3, bus_cntl_sel[0], bus_cntl_sel[1]);
    
    wire bus_data_enbar;
    assign bus_data_enbar = control_signal[`BUS_DATA_ENBAR];
    tristate32L tri_bus_data(bus_data_enbar, data_in, bus_data);
    tristate32L tri_bus_addr(control_signal[`BUS_ADDR_ENBAR], addr_in, bus_addr);
    //tristate16L$ tri_bus_cntl(control_signal[BUS_CNTL_ENBAR], bus_cntl_op, bus_cntl);
    tristate16L$ tri_bus_cntl(gnt_n, bus_cntl_op, bus_cntl);
    
    assign finish = control_signal[`FINISH];
    assign receiving_data = control_signal[`RECEIVING];


 endmodule




//--------------------------------------
//
//  DMA Station
//
//--------------------------------------
module dma_station(
    clk,
    reset,
    set,
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
    mem_we_signal,
    data_in,
    counter_in,
    addr_in,
    data_out,
    addr_out,
    write_signal   // generate negative puslses to write the Cache/Memory
); 

    //---------------------------------------- 
    // Bus 
    //---------------------------------------- 
    inout [31:0]    bus_data;
    inout [31:0]    bus_addr;
    inout [15:0]    bus_cntl;
    inout hsk_valid;
    inout hsk_ack;
    
    //---------------------------------------- 
    // Input Ports
    //---------------------------------------- 
    input         clk, reset, set;
    input         gnt;
    input [1:0]   device_id;
    input [1:0]   dst_device_id;
    input         req_signal;               // mem read signal
    input         write_memory_signal;      // mem write_signal
    input [3:0]   mem_we_signal;
    input [7:0]   counter_in;               // value to load into counter
    input [31:0]  data_in;                  // direct -> bus_data
    input [31:0]  addr_in;                  // direct -> bus_addr

    //---------------------------------------- 
    // Output Ports
    //---------------------------------------- 
    output          req;
    output          finish;    // flag of work finished
    output [31:0]   data_out;
    output [31:0]   addr_out;
    output          receiving_data;   // receiving data from BUS 
    output          write_signal;

    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    //::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


    // relevant operations to load to the bus_cntl
    wire [15:0] bus_cntl_op0;
    wire [15:0] bus_cntl_op1;
    wire [15:0] bus_cntl_op2;
    wire [15:0] bus_cntl_op3;
    //wire bus_cntl_op1;
    wire [15:0] bus_cntl_op;
    wire [1:0]  bus_cntl_sel;
    
    //---------------------------------------- 
    // Relevant Operations (Devvice to Memory)
    //---------------------------------------- 
    // 1. read operation
        // actually, dma *won't* read data from memory
    assign bus_cntl_op0[`VALID] = 1;
    assign bus_cntl_op0[`UNUSED] = 0;
    assign bus_cntl_op0[`DST1:`DST0] = dst_device_id;
    assign bus_cntl_op0[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op0[`RW] = 0;
    assign bus_cntl_op0[`WE3:`WE0] = mem_we_signal;                     // use to indicate which bits are to be written
   
    // 2. write operation
    assign bus_cntl_op1[`VALID] = 1;
    assign bus_cntl_op1[`UNUSED] = 0;
    assign bus_cntl_op1[`DST1:`DST0] = dst_device_id;
    assign bus_cntl_op1[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op1[`RW] = 1;
    assign bus_cntl_op1[`WE3:`WE0] = mem_we_signal;                     // use to indicate which bits are to be written
     
    // 3. finish operations, notifying the memory
    assign bus_cntl_op3[`VALID] = 0;
    assign bus_cntl_op3[`UNUSED] = 0;
    assign bus_cntl_op3[`DST1:`DST0] = dst_device_id;
    assign bus_cntl_op3[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op3[`RW] = 0;
    assign bus_cntl_op3[`WE3:`WE0] = mem_we_signal;                     // use to indicate which bits are to be written

    //-----------------------------
    //  Condition Status
    //-----------------------------
    wire gnt_n;
    wire req_bus;
    wire mem_w;
    wire mem_r;
    assign mem_w = write_memory_signal;
    assign mem_r = req_signal;
    wire [31:0] control_signal;         // ucode for state machine
    wire [31:0] recv_cs;                // ucode for slave
    wire [31:0] send_cs;                // ucode for master
    
    // gnt bus
    inv1$ inv_gnt(gnt_n, gnt);

    // req bus
    //xor2$ xor_req_bus(req_bus, mem_r, mem_w);   
    assign req_bus = mem_w;
    dff$ request_reg(.clk(clk), .r(reset), .s(set), .d(req_bus), .q(req));

    // is slave or not (be the dst device of certain master (D-Cache in our case))
    wire is_slave; 
    wire is_slave_tmp;
    wire is_slave_n; 
    cmp2b cmp_is_slave(is_slave_tmp, bus_cntl[`DST1:`DST0], device_id);
    and2$ and_is_slave(is_slave, is_slave_tmp, bus_cntl[`VALID]);
    nand2$ nand_is_slave(is_slave_n, is_slave_tmp, bus_cntl[`VALID]);
    

    //:::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::
    //:::::::::::::::::::::::::::::::::::::::::
    wire [3:0] next_state1;
    wire [3:0] next_state0;
    wire [3:0] next_state;
    wire [3:0] state;               // state that changes every cycle
    wire [2:0] _J;
    wire [2:0] _state;
    wire [2:0] _next_state0;
    wire [2:0] _next_state;

    // rom for fsm ucode
    rom32b32w$ send_state_machine(.A({1'b0, state}), .OE(1'b1), .DOUT(send_cs));  // 
    rom32b32w$ recv_state_machine(.A({2'b0, _state}), .OE(1'b1), .DOUT(recv_cs));  // 
    // if req = 1, master fsm
    // if req = 0, slave  fsm
    mux2_32 mux_control_signal(control_signal, recv_cs, send_cs, req);

    initial
    begin
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/bs_dma_ms.list", send_state_machine.mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/bs_dma_sl.list", recv_state_machine.mem);
    end

    //--------------------------------
    //  Master FSM
    //--------------------------------
    // for master part, dma need to send 4 byte data (use bus once) to write data to memory
    // if the action is finished, bus station will generate a finish signal to dma to notify it.


    wire [7:0] counter_out;   // output of counter
    wire       counter_pl;    // signal to parallel load counter;
    wire       counter_en;

    wire counter_empty;     // counter = 11     
    wire [2:0] J;       // jump field

    // when enough amount of data has been transfered
    cmp8b cmp_counter_zero(counter_empty, counter_out, 8'b0);
    assign counter_pl = control_signal[`COUNTER_PL];
    assign counter_en = write_signal;//control_signal[COUNTER_EN];

    // jump field
    assign J[2] = send_cs[`JUMP_FIELD2];
    assign J[1] = send_cs[`JUMP_FIELD1];
    assign J[0] = send_cs[`JUMP_FIELD0];
    
    // microsequencer 
    assign next_state1[3] = mem_w;
    or2$ or_next1(next_state1[2], J[2], counter_empty);
    assign next_state1[1] = J[1];
    and2$ and_next1(next_state1[0], J[0], hsk_valid);

    mux2_4 mux_next_state0(next_state0, `BUS_REQ, next_state1, gnt);
    mux2_4 mux_next_state(next_state, `BUS_IDLE, next_state0, req);
    reg4e state_reg(.CLK(clk), .Din(next_state), .Q(state), .CLR(reset), .PRE(set), .en(1'b1));
   

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
    //  Slave FSM 
    //--------------------------------

    parameter _IDLE = 3'b00;
    parameter _REC_REQ = 3'b011;
    parameter _SEND_DATA = 3'b010;
    
    assign _J[2] = recv_cs[`JUMP_FIELD2];
    assign _J[1] = recv_cs[`JUMP_FIELD1];
    assign _J[0] = recv_cs[`JUMP_FIELD0];

    wire _j0_or_ack;
    or2$ _or_jack(_j0_or_ack, _J[0], hsk_ack);

    assign _next_state0[2] = _J[2];
    assign _next_state0[1] = _J[1];
    assign _next_state0[0] = _j0_or_ack; 

    mux2_3 _mux_next_state(_next_state, _IDLE, _next_state0, is_slave);
    reg3e _state_reg(.CLK(clk), .Din(_next_state), .Q(_state), .CLR(reset), .PRE(set), .en(1'b1));
    

    // when bus_station get the bus, use hsk_ack to communicate
        // write to memory, hsk_ack
    // when bus_station is slave, it use hsk_valid to 
        // when write to dma, use hsk_valid to show if it has receive data
    tristateL$ tri_hsk_ack(gnt_n, control_signal[`HSK_ACK], hsk_ack);
    tristateL$ tri_hsk_valid(is_slave_n, control_signal[`HSK_VALID], hsk_valid);

    // bus_data
    // when read data from BUS
    // dma's bus_data is receiver
    wire bus_data_enbar;
    wire bus_addr_enbar;
    assign bus_data_enbar = control_signal[`BUS_DATA_ENBAR];
    assign bus_addr_enbar = control_signal[`BUS_ADDR_ENBAR];
    
    // little endian
    wire [31:0] data_out_little;
    assign data_out_little[31-0*`BYTE:31-1*`BYTE+1] = bus_data[1*`BYTE-1:0*`BYTE];
    assign data_out_little[31-1*`BYTE:31-2*`BYTE+1] = bus_data[2*`BYTE-1:1*`BYTE];
    assign data_out_little[31-2*`BYTE:31-3*`BYTE+1] = bus_data[3*`BYTE-1:2*`BYTE];
    assign data_out_little[31-3*`BYTE:31-4*`BYTE+1] = bus_data[4*`BYTE-1:3*`BYTE];
    
    wire [31:0] data_in_little;
    assign data_in_little[31-0*`BYTE:31-1*`BYTE+1] = data_in[1*`BYTE-1:0*`BYTE];
    assign data_in_little[31-1*`BYTE:31-2*`BYTE+1] = data_in[2*`BYTE-1:1*`BYTE];
    assign data_in_little[31-2*`BYTE:31-3*`BYTE+1] = data_in[3*`BYTE-1:2*`BYTE];
    assign data_in_little[31-3*`BYTE:31-4*`BYTE+1] = data_in[4*`BYTE-1:3*`BYTE];

    tristate32L tri_bus_data0(gnt_n, data_in, bus_data);
    tristate32L tri_bus_addr0(gnt_n, addr_in, bus_addr);
    tristate32L tri_bus_data1(is_slave_n, data_out_little, data_out);
    tristate32L tri_bus_addr1(is_slave_n, bus_addr, addr_in);
    tristate16L$ tri_bus_cntl(gnt_n, bus_cntl_op, bus_cntl);

    // set control bus according to the fsm 
    assign bus_cntl_sel = control_signal[`BUS_CNTL_SEL1:`BUS_CNTL_SEL0];
    mux4_16$ mux_bus_cntl(bus_cntl_op, bus_cntl_op0, bus_cntl_op1, bus_cntl_op2, bus_cntl_op3, 
                          bus_cntl_sel[0], bus_cntl_sel[1]);
    
    tristate32L tri_bus_addr(control_signal[`BUS_ADDR_ENBAR], addr_in, bus_addr);
    
    assign finish = control_signal[`FINISH];
    assign receiving_data = control_signal[`RECEIVING];
    and2$ and_write_signal(write_signal, hsk_valid, hsk_ack);
    
 endmodule



//------------------------------------
//
//  I-Cache Station
//
//------------------------------------
module icache_station(
    clk,
    reset,
    set,
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
    mem_we_signal,
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
    input [1:0] device_id;
    input [1:0] dst_device_id;
    
    input         req_signal;       // for icache and dcache, miss_signal is the req_signal, used by the connected device to req bus.
    input         write_memory_signal;

    input [7:0]   counter_in;       // value to load into counter
    input [31:0]  data_in;          // direct -> bus_data
    input [31:0]  addr_in;          // direct -> bus_addr
    input [3:0]   mem_we_signal;       // select relevant operations
 

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
    wire [15:0] bus_cntl_op1;
    wire [15:0] bus_cntl_op2;
    wire [15:0] bus_cntl_op3;
    //wire bus_cntl_op1;
    wire [15:0] bus_cntl_op;
    wire [1:0]  bus_cntl_sel;
    
    //---------------------------------------- 
    // Relevant Operations (Devvice to Memory)
    //---------------------------------------- 
    // 1. read data from BUS 
    //    THe only function is read from memory
    //    data_in = ???
    //    addr_in = icache_addr
    //    cntl: [`valid] = 1; [`DST1:DST0] = `MEM; [`SRC1:`SRC0] = `ICACHE; [`WR] = 0, [SUM4:SUM0] = 16
     
    assign bus_cntl_op0[`VALID] = 1;
    assign bus_cntl_op0[`UNUSED] = 0;
    assign bus_cntl_op0[`DST1:`DST0] = `MEM;
    assign bus_cntl_op0[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op0[`RW] = 0;
   
   
    // 2. write operation
    //    write memory:
    assign bus_cntl_op1[`VALID] = 1;
    assign bus_cntl_op1[`UNUSED] = 0;
    assign bus_cntl_op1[`DST1:`DST0] = dst_device_id;
    assign bus_cntl_op1[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op1[`RW] = 1;
   
    // 3. finish operations, notifying the memory
  
    assign bus_cntl_op3[`VALID] = 0;
    assign bus_cntl_op3[`UNUSED] = 0;
    assign bus_cntl_op3[`DST1:`DST0] = `MEM; 
    assign bus_cntl_op3[`SRC1:`SRC0] = device_id;
    assign bus_cntl_op3[`RW] = 0;
  



    //---------------------------------------
    //  Bus Station states
    //--------------------------------------
    // req, gnt
    // 00       idle
    // 01       wrong
    // 10       requesting
    // 11       holding
 
    wire gnt_n;
    inv1$ inv_gnt(gnt_n, gnt);

    wire req_bus;
    wire mem_w;
    wire mem_r;
    assign mem_w = write_memory_signal;
    assign mem_r = req_signal;
    xor2$ xor_req_bus(req_bus, mem_r, mem_w);

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

    wire counter_empty;     // counter = 11     
    wire [2:0] J;       // jump field

    cmp8b cmp_counter_zero(counter_empty, counter_out, 8'b0);

    assign counter_pl = control_signal[`COUNTER_PL];
    assign counter_en = write_signal;//control_signal[COUNTER_EN];

    // the first 3 bits of the ucode is jump field
    assign J[2] = control_signal[`JUMP_FIELD2];
    assign J[1] = control_signal[`JUMP_FIELD1];
    assign J[0] = control_signal[`JUMP_FIELD0];


    initial
    begin
        $readmemb("/misc/collaboration/382nGPS/382nG6/yjl/bs_icache_fsm.list", send_state_machine.mem);
    end

    rom32b32w$ send_state_machine(.A({1'b0, state}), .OE(1'b1), .DOUT(control_signal));  // 
    // microsequencer 
    assign next_state1[3] = mem_w;
    or2$ or_next1(next_state1[2], J[2], counter_empty);
    assign next_state1[1] = J[1];
    and2$ and_next1(next_state1[0], J[0], hsk_valid);


    mux2_4 mux_next_state0(next_state0, `BUS_REQ, next_state1, gnt);
    mux2_4 mux_next_state(next_state, `BUS_IDLE, next_state0, req_bus);
    reg4e state_reg(.CLK(clk), .Din(next_state), .Q(state), .CLR(reset), .PRE(set), .en(1'b1));
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

 
    dff$ request_reg(.clk(clk), .r(reset), .s(set), .d(req_bus), .q(req));
   
    // if gnt == 1, MASTER is holding the BUS, waiting for the valid bit of SLAVE
    // if gnt == 9, SLAVE is waiting for the bus_cntl signal...
    tristateL$ tri_hsk_ack(gnt_n, control_signal[`HSK_ACK], hsk_ack);
    tristateL$ tri_hsk_valid(1'b1, control_signal[`HSK_VALID], hsk_valid);
   

    // get data, addr, cntl from the BUS
    // for the I-Cache, we only need the data.
    assign data_out = bus_data;
    assign addr_out = bus_addr;
    assign cntl_out = bus_cntl;

    // set control bus according to the fsm 
    assign bus_cntl_sel = control_signal[`BUS_CNTL_SEL1:`BUS_CNTL_SEL0];
    mux4_16$ mux_bus_cntl(bus_cntl_op, bus_cntl_op0, bus_cntl_op1, bus_cntl_op2, bus_cntl_op3, bus_cntl_sel[0], bus_cntl_sel[1]);
    
    wire bus_data_enbar;
    assign bus_data_enbar = control_signal[`BUS_DATA_ENBAR];
    tristate32L tri_bus_data(bus_data_enbar, data_in, bus_data);
    wire [1:0] addr_counter_part;
    reg2e count_addr_reg(.CLK(clk), .Din(counter_out[1:0]), .Q(addr_counter_part), .CLR(reset), .PRE(set), .en(1'b1));
    tristate32L tri_bus_addr(control_signal[`BUS_ADDR_ENBAR], {addr_in[31:4],addr_counter_part, {2'b0}}, bus_addr);
    //tristate16L$ tri_bus_cntl(control_signal[BUS_CNTL_ENBAR], bus_cntl_op, bus_cntl);
    tristate16L$ tri_bus_cntl(gnt_n, bus_cntl_op, bus_cntl);
    
    assign finish = control_signal[`FINISH];
    assign receiving_data = control_signal[`RECEIVING];

    assign device_we = control_signal[`DEVICE_WE3:`DEVICE_WE0];
    assign device_wr = control_signal[`DEVICE_WR];
    and3$ and_write_signal(write_signal, hsk_valid, hsk_ack, req_bus);
    
 endmodule


