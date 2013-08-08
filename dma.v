// `include "/home/projects/courses/spring_12/ee382n-16905/lib/lib1"
// `include "/home/projects/courses/spring_12/ee382n-16905/lib/lib2"
// `include "/home/projects/courses/spring_12/ee382n-16905/lib/lib3"
// `include "/home/projects/courses/spring_12/ee382n-16905/lib/lib4"
// `include "/home/projects/courses/spring_12/ee382n-16905/lib/lib5"
// `include "/home/projects/courses/spring_12/ee382n-16905/lib/lib6"
`include "./misc.v"

module TOP;
	reg CLK;
	reg CLR;
	
	
	reg[31:0] address, data;
	reg drive;
	reg bus_valid, bus_grant, bus_finish, interrupt_clear;
	wire[31:0] bus_address, bus_control, bus_data;
	wire bus_request, interrupt_flag;
	
	tristate_bus_driver16$ addressDrive[1:0](~drive, address, bus_address);
	tristate_bus_driver16$ dataDrive[1:0](~drive, data, bus_data);
	
	wire[31:0] DISK_ADDR = dma.disk_addr;
	wire[31:0] MEM_ADDR = dma.mem_addr;
	wire[31:0] TRANS_SIZE = dma.trans_size;
	wire[31:0] TRANS_INIT = dma.trans_init;
	wire[2:0] STATE = dma.current_state;
	wire[31:0] COUNT = dma.count_out;
	
	
	
	
	
	DMA dma(
		.CLK(CLK), 
		.CLR(CLR), 
		.PRE(1'b1),
		
		.bus_address(bus_address), 
		.bus_control(bus_control), 
		.bus_data(bus_data),
		
		.bus_valid(bus_valid),
		.bus_grant(bus_grant),
		.bus_request(bus_request),
		.bus_finish(bus_finish),
		
		.interrupt_clear(interrupt_clear),
		.interrupt_flag(interrupt_flag)
);
	
	muxTop top();
	
	initial	begin
		$dumpfile ("dma.dump");
		$dumpvars (0, TOP);
		
		CLK = 1;
		CLR = 0;
		drive = 0;
		bus_valid = 0;
		bus_grant = 0;
		bus_finish = 0;
		interrupt_clear = 0;
		address = 0;
		data = 0;
		
		#10
		CLR = 1;
		bus_valid = 0;
		address = 32'h0;
		data = 2;
		drive = 1;
		
		#10
		bus_valid = 1;
		address = 0;
		data = 2;
		
		#20
		address = 1;
		data = 10;
		
		#20
		address = 2;
		data = 5;
		
		#20
		address = 3;
		data = 1;
		
		#20
		bus_valid = 0;
		address = 32'hz;
		data = 32'hz;
		
		#1000
		bus_grant = 1;
		
		#50
		bus_finish = 1;
		
		#200
		interrupt_clear = 1;
		
		#500
		
		
		
		
		
		
		
		
		
		#10
		#10
		#10	$finish;
	end
	
	always #5	CLK = ~CLK;

endmodule




module DMA(
	CLK, 
	CLR, 
	PRE,
	
	bus_address, 
	bus_control, 
	bus_data,
	
	bus_valid,
	bus_grant,
	bus_request,
	bus_finish,
	
	interrupt_clear,
	interrupt_flag
);
	
	//==============================
	//	IO signal
	//==============================
	
	// global control signals
	input CLK, CLR, PRE;
	
	// bus line
	inout[31:0] bus_address;
	inout[31:0] bus_data;
	inout[31:0] bus_control;
	
	// with bus station
	input bus_valid;
	input bus_grant;
	input bus_finish;
	output bus_request;
	
	// with cpu
	input interrupt_clear;	
	output interrupt_flag;
	
	//==================================
	//	Memory-mapped registers
	//==================================
	wire bus_rd;	// by state machine
	wire[3:0] addr_de, bus_reg_ld;
	decoder2_4$ deAddr(bus_address[1:0], addr_de, );
	and2$ andBusRegLd[3:0](bus_reg_ld, addr_de, bus_rd);
	
	
	wire init_clr;	// by state machine
	wire init_clr_bar, init_reg_clr;
	inv1$ invInitClr(init_clr_bar, init_clr);
	and2$ andInitRegClr(init_reg_clr, CLR, init_clr_bar);
	
	
	wire[31:0] disk_addr, mem_addr, trans_size, trans_init;
	reg32e$ reg32DiskAddr(CLK, bus_data, disk_addr, , CLR, PRE, bus_reg_ld[0]),
			reg32MemAddr(CLK, bus_data, mem_addr, , CLR, PRE, bus_reg_ld[1]),
			reg32TransSize(CLK, bus_data, trans_size, , CLR, PRE, bus_reg_ld[2]),
			reg32TransInit(CLK, bus_data, trans_init, , init_reg_clr, PRE, bus_reg_ld[3]);
	
	//=====================
	//	Access to DISK
	//=====================
	wire[4095:0] disk_data;
	wire disk_ready;
	DISK disk(disk_addr, 13'd4096, disk_data, disk_ready);
	
	
	//================================
	//	Data transfer register
	//================================
	wire data_sel, data_ld;	// by state machine
	wire[4095:0] data_in, data_out, data_out_rshf32;
	
	mux2_32$ muxDataIn[127:0](data_in, disk_data, data_out_rshf32, data_sel);
	reg32e$ reg32Data[127:0](CLK, data_in, data_out, , CLR, PRE, data_ld);
	assign data_out_rshf32 = {32'h0, data_out[4095:32]};
	
	
	
	//==============================
	// Address transfer register
	//==============================
	wire addr_sel, addr_ld;		// state machine output
	wire[31:0] addr_in, addr_out, addr_out_plus4;
	
	mux2_32$ muxAddrIn(addr_in, {mem_addr[31:2], 2'b0}, addr_out_plus4, addr_sel);
	reg32e$ reg32Addr(CLK, addr_in, addr_out, , CLR, PRE, addr_ld);
	Adder32$ adderAddr(addr_out, 32'h4, 1'b0, addr_out_plus4, );
	
	
	//============================
	//	Count trasnfer register
	//============================
	
	wire count_sel, count_ld;	// state machine output
	wire[31:0] count_in, count_out, count_out_minus4;
	
	
	mux2_32$ muxCountIn(count_in, trans_size, count_out_minus4, count_sel);
	reg32e$ reg32Count(CLK, count_in, count_out, , CLR, PRE, count_ld);
	Adder32$ adderCount(count_out, -32'h4, 1'b0, count_out_minus4, );
	
	//==========================
	//	Write enable logic
	//==========================
	wire[3:0] control_we, we_first, we_middle, we_last;
	wire is_first, is_last, trans_zero;
	
	id_comp16$ compTransIsZero(trans_size[15:0], 16'h0, trans_zero, );
	id_comp16$ compCountIsSize(count_out[15:0], trans_size[15:0], is_first, );
	mag_comp16$ compCountLtZero(count_out[15:0], 16'h4, , is_last);
	
	mux4$ muxWeFirst[3:0](we_first, 4'b1111, 4'b1110, 4'b1100, 4'b1000, mem_addr[0], mem_addr[1]);
	mux4$ muxWeLast[3:0](we_last, 4'b0000, 4'b0001, 4'b0011, 4'b0111, mem_addr[0], mem_addr[1]);
	assign we_middle = 4'b1111;
	mux4$ muxWe[3:0](control_we, we_middle, we_first, we_last, we_last, is_first, is_last);
	
	assign count_dec_lt_zero = count_out_minus4[15];
	
	
	//============================
	//	Bus driver
	//============================
	
	wire data_dr, addr_dr, ctrl_dr;	// state machine output
	wire data_dr_bar, addr_dr_bar, ctrl_dr_bar;
	inv1$ invDataDrBar(data_dr_bar, data_dr);
	inv1$ invAddrDrBar(addr_dr_bar, addr_dr);
	inv1$ invCtrlDrBar(ctrl_dr_bar, ctrl_dr);
	
	tristate_bus_driver16$ driveData[1:0](data_dr_bar, data_out[31:0], bus_data);
	tristate_bus_driver16$ driveAddr[1:0](addr_dr_bar, addr_out, bus_address);
	tristate_bus_driver16$ driveControl[1:0](ctrl_dr_bar, {28'h0, control_we}, bus_control);
	
	
	//===============================
	//	State machine
	//===============================
	wire[2:0] current_state;
	wire[2:0] next_state;
	
	dff$ dffState[2:0](CLK, next_state, current_state, , CLR, 1'b1);
	
	DMA_StateMachine dma_sm(
		.current_state(current_state),
		.bus_valid(bus_valid),
		.bus_grant(bus_grant),
		.bus_finish(bus_finish),
		.disk_ready(disk_ready),
		.trans_init(trans_init[0]),
		.count_lt_zero(count_dec_lt_zero),
		.trans_zero(trans_zero),
		.int_ack(interrupt_clear),
		
		.next_state(next_state),
		.bus_rd(bus_rd),
		.bus_req(bus_req),
		.data_ld(data_ld),
		.addr_ld(addr_ld),
		.count_ld(count_ld),
		.data_sel(data_sel),
		.addr_sel(addr_sel),
		.count_sel(count_sel),
		.data_dr(data_dr),
		.addr_dr(addr_dr),
		.ctrl_dr(ctrl_dr),
		.init_clr(init_clr),
		.flag_set(flag_set)
	);
	
endmodule

module DMA_StateMachine(
	current_state,
	bus_valid,
	bus_grant,
	bus_finish,
	disk_ready,
	trans_init,
	trans_zero,
	count_lt_zero,
	int_ack,
	
	next_state,
	bus_rd,
	bus_req,
	data_ld,
	count_ld,
	addr_ld,
	data_sel,
	addr_sel,
	count_sel,
	data_dr,
	addr_dr,
	ctrl_dr,
	init_clr,
	flag_set
);
	input[2:0] current_state;
	input bus_valid;
	input bus_grant;
	input bus_finish;
	input disk_ready;
	input trans_init;
	input trans_zero;
	input count_lt_zero;
	input int_ack;
	
	output[2:0] next_state;
	output bus_rd;
	output bus_req;
	output data_ld;
	output count_ld;
	output addr_ld;
	output data_sel;
	output addr_sel;
	output count_sel;
	output data_dr;
	output addr_dr;
	output ctrl_dr;
	output init_clr;
	output flag_set;
	
	`define S0 3'b000	// Idle 
	`define S1 3'b001	// Set register
	`define S2 3'b010	// Read disk / Initialize transfer
	`define S3 3'b011	// Request bus
	`define S4 3'b100	// Transfer data
	`define S5 3'b101	// Prepare next transfer
	`define S6 3'b110	// Raise interrupt flag
	`define S7 3'b111	// (reserved)
	
	wire[2:0] ns0, ns1, ns2, ns3, ns4, ns5, ns6, ns7;
	
	//
	// Next State
	//
	mux4$ muxNS0[2:0](ns0, `S0, `S1, `S2, `S2, bus_valid, trans_init);
	mux2$ muxNS1[2:0](ns1, `S0, `S1, bus_valid);
	mux4$ muxNS2[2:0](ns2, `S2, `S2, `S3, `S6, trans_zero, disk_ready);
	mux2$ muxNS3[2:0](ns3, `S3, `S4, bus_grant);
	mux2$ muxNS4[2:0](ns4, `S4, `S5, bus_finish);
	mux2$ muxNS5[2:0](ns5, `S3, `S6, count_lt_zero);
	mux2$ muxNS6[2:0](ns6, `S6, `S0, int_ack);
	mux2$ muxNS7[2:0](ns7, `S7, `S7, 1'b0);
	
	mux8$ muxNS[2:0](
		next_state,
		ns0, ns1, ns2, ns3, ns4, ns5, ns6, ns7,
		current_state[0], current_state[1], current_state[2]
	);
	
	//
	//	Outputs
	//
	wire[7:0] cs;
	decoder3_8$ deCS(current_state, cs, );
	assign bus_rd = cs[1];
	or2$ orBusReq(bus_req, cs[3], cs[4]);
	or2$ orDataLd(data_ld, cs[2], cs[5]);
	or2$ orAddrLd(addr_ld, cs[2], cs[5]);
	or2$ orCountLd(count_ld, cs[2], cs[5]);
	assign data_sel = cs[5];
	assign addr_sel = cs[5];
	assign count_sel = cs[5];
	assign data_dr = cs[4];
	assign addr_dr = cs[4];
	assign ctrl_dr = cs[4];
	assign init_clr = cs[2];
	assign flag_set = cs[6];
	
	
endmodule




module DISK(addr, size, data, r);
	
	input[31:0] addr;
	input[12:0] size;
	output[4095:0] data;
	output r;
	
	// disk data
	//reg[4095:0] disk_data;
	reg[31:0] disk_data[0:1023];
	initial $readmemh("disk_data.dat", disk_data);
	
	reg r_temp;
	assign r = r_temp;
	reg[4095:0] data_temp;
	assign data = data_temp;
	
	
	integer i;
	integer j;
	
	
	
	always @ (addr) begin
		r_temp = 0;
		data_temp = 4096'hz;
		for(i = 0; i < size / 4; i = i + 1) begin
			for(j = 0; j < 32; j = j + 1) begin
				data_temp[i * 32 + j] = disk_data[addr + i][j];
			end	
		end
		
		# 750	
		r_temp = 1;
		
	end
	
	//assign data = disk_data[addr];
	
		
endmodule
