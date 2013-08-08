`include "/misc/collaboration/382nGPS/382nG6/yzhu/yzhu_gates.v"

module Memory(Address, DataIO, write_signal, we, OE);
	inout[31:0] DataIO;
	input[14:0] Address;
	input[3:0]  we;
    input       OE;             // OE = 1 when write.
    input       write_signal;   // generated negative pulse

	wire        WR; // 1-write, 0-read
    assign WR = write_signal | !OE; 
	wire[31:0]  DataIO0, DataIO1, DataIO2, DataIO3;

	// *memory layout
	// \Addr[1:0] |    00    |    01    |    10    |    11    |
	// Addr[14:2] |          |          |          |          |
	//            |   ....   |   ....   |   ....   |   ....   |
	//                 we3        we2        we1        we0
	// DataIO     |  [31:24] |  [23:16] |  [15:8]  |   [7:0]  |
	//14:9-select sram modules
	//8:2-index into each sram module
	//1:0-byte offset
	//dram0: 0 1 2 3
	//dram1: 0 1 2 3
	//... ...
	//dram2^6-1: 0 1 2 3

	//sram128x8$ (A,DIO,OE,WR, CE);
    //-----------------------------------

    wire [3:0]  dram_sel, dram_sel_n;
    wire [1:0]  dram_index;
    wire [3:0]  dram_WR;
    assign dram_index = Address[14:13];
    decoder2_4$ decode_dram_sel(dram_index, dram_sel, dram_sel_n);

    // generate WR signal for dram #num
    // dram_WR: WR is low, and the dram is selected (low)
    or2$ or_dram_WR0(dram_WR[0], dram_sel_n[0], WR);
    or2$ or_dram_WR1(dram_WR[1], dram_sel_n[1], WR);
    or2$ or_dram_WR2(dram_WR[2], dram_sel_n[2], WR);
    or2$ or_dram_WR3(dram_WR[3], dram_sel_n[3], WR);

    wire recv_data;
    inv1$ inv_rec_data(recv_data, OE);
    tristate32L tri_dataIO0(recv_data, DataIO, DataIO0); 
    tristate32L tri_dataIO1(recv_data, DataIO, DataIO1); 
    tristate32L tri_dataIO2(recv_data, DataIO, DataIO2); 
    tristate32L tri_dataIO3(recv_data, DataIO, DataIO3); 
    //-----------------------------------

    // read data from dram
    `uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/yzhu_gates.v
	sram128x16x32 dram0(Address[12:2], DataIO0, dram_WR[0], we, OE);
	sram128x16x32 dram1(Address[12:2], DataIO1, dram_WR[1], we, OE);
	sram128x16x32 dram2(Address[12:2], DataIO2, dram_WR[2], we, OE);
	sram128x16x32 dram3(Address[12:2], DataIO3, dram_WR[3], we, OE);

    //-----------------------------------------
    // output data from dram
    wire [31:0] DataOut;
	mux4_32 mux1(DataOut, DataIO0, DataIO2, DataIO1, DataIO3, Address[14:13]);
    tristate32L tri_dataIO(OE, DataOut, DataIO); 
    //-----------------------------------------
endmodule


