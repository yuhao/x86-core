`include "/misc/collaboration/382nGPS/382nG6/yhuang/misc.v"

/*module TOP;
	reg[31:0] readAddr, writeAddr;
	reg[1:0] readType, writeType;
	wire mem_dep;
	
	MemoryDepCheck check(readAddr, readType, writeAddr, writeType, mem_dep);
	
	initial
	begin
	   $dumpfile ("./mem_dep_check.dump");
	   $dumpvars (0, TOP);
	end
	
	initial
		begin	readAddr = 32'h00004006;
				writeAddr = 32'h00004000;
				readType = 0;
				writeType = 0;
		
		#400		$finish;
		end
		
	always	#10 readType = readType + 1;
	always  #40	writeType = writeType + 1;
			
		
	

endmodule*/

module MemoryDepCheck(readAddr, readType, writeAddr, writeType, mem_dep);
	input[31:0] readAddr, writeAddr;
	input[1:0] readType, writeType;
	output mem_dep;
	
	wire[31:0] readSize, writeSize;
	mux4_32$ muxSize[1:0](
		{readSize, writeSize}, 
		32'h1,
		32'h2,
		32'h4,
		32'h8,
		{readType, writeType}
	);
	
	wire[31:0] readAddrEnd, writeAddrEnd;
	Adder32$ adderAddrEnd[1:0](
		{readAddr, writeAddr},
		{readSize, writeSize},
		{1'b0, 1'b0},
		{readAddrEnd, writeAddrEnd},
		
	);
	
	wire wGr, rGw, wGrend, rendGw, rGwend, wendGr;
	mag_comp32$ compWR(writeAddr, readAddr, wGr, rGw),
				compWRend(writeAddr, readAddrEnd, wGrend, rendGw),
				compRWend(readAddr, writeAddrEnd, rGwend, wendGr);
	
	
	
	
	// mem_dep = (~wGr && ~rGw) || (wGr && rendGw) || (rGw && wendGr)
	wire w0, w1, w2, w3, w4;
	inv1$ inv0(w0, wGr);
	inv1$ inv1(w1, rGw);
	nand2$ nand2(w2, w0, w1);
	nand2$ nand3(w3, wGr, rendGw);
	nand2$ nand4(w4, rGw, wendGr);
	nand3$ nand5(mem_dep, w2, w3, w4);	

endmodule

