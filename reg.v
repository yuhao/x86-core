/*module regTOP;
	//`define clk 8

	reg CLK, CLR, PRE;
	reg[63:0] dr0, dr1;
	reg[2:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel;
	reg[1:0] sr0_size, sr1_size, sr2_size, sr3_size, dr0_size, dr1_size;
	reg dr0_ld, dr1_ld;
	wire[63:0] sr0, sr1, sr2, sr3;
	
	
	
	GPR$ gpr(sr0, sr1, sr2, sr3, dr0, dr1,
			 sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel,
			 sr0_size, sr1_size, sr2_size, sr3_size, dr0_size, dr1_size,
			 dr0_ld, dr1_ld,
			 CLK, CLR, PRE);
			 
	SegR$ segr(sr0[15:0], sr1[15:0], dr0[15:0], dr1[15:0],
			   sr0_sel, sr1_sel, dr0_sel, dr1_sel,
			   dr0_ld, dr1_ld, 			
			   CLK, CLR, PRE);
			   
	MMX$ mmx(sr0, sr1, dr0,
			sr0_sel, sr1_sel, dr0_sel,
			dr0_ld,
			CLK, CLR, PRE);
			 
	initial
		begin	CLK = 0;
				CLR = 1;
				PRE = 1;
		
		#`clk	dr0 = 64'h3322110000112233;
				dr0_size = 0;
				dr0_ld = 1;			
				dr0_sel = 0;
				
				dr1 = 64'h7766554444556677;
				dr1_size = 0;
				dr1_ld = 1;			
				dr1_sel = 4;
		
		#`clk	dr0 = 64'h0000000000000000;
				dr0_size = 1;
				dr0_ld = 1;
				dr0_sel = 0;
				dr1 = 64'h1111111111111111;
				dr1_size = 1;
				dr1_ld = 1;
				dr1_sel = 4;
				
				
				sr0_sel = 0;
				sr0_size = 0;
				sr1_sel = 4;
				sr1_size = 0;
				sr2_sel = 4;
				sr2_size = 1;
			
		#`clk	dr0 = 64'hxxxxxxxxxxxxxxxx;
				dr1 = 64'hxxxxxxxxxxxxxxxx;

		//#`clk	$finish;
		end
	
	
	
		Test for General Register file
	
	
	reg[31:0] dr0, dr1;
	reg[2:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel;
	reg[3:0] dr0_ld, dr1_ld;
	wire[31:0] sr0, sr1, sr2, sr3;
	
	RegFile8_32$ GPR(sr0, sr1, sr2, sr3, dr0, dr1,
					 sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel,
					 dr0_ld, dr1_ld, 
					 CLK, CLR, PRE);
	
	initial
	begin	CLK = 0;
			CLR = 1;
			PRE = 1;
			dr0 = 32'h00000000;
			dr1 = 32'h11111111;
	
	#`clk	dr0_ld = 4'b0000;
			dr1_ld = 4'b1111;
			dr0_sel = 0;
			dr1_sel = 1;

	#`clk	sr0_sel = 0;
			sr1_sel = 1;
			dr0_sel = 2;
			dr1_sel = 3;
			dr0_ld = 4'b0011;
			dr1_ld = 4'b1100;
			
	#`clk	sr2_sel = 2;
			sr3_sel = 3;
			dr0_sel = 4;
			dr1_sel = 5;
			dr0_ld = 4'b0101;
			dr1_ld = 4'b1010;
			
	#`clk	sr0_sel = 4;
			sr1_sel = 5;
			dr0_sel = 6;
			dr1_sel = 7;
			dr0_ld = 4'b1110;
			dr1_ld = 4'b0001;
			
	#`clk	sr2_sel = 6;
			sr3_sel = 7;
			dr0_sel = 0;
			dr1_sel = 1;
			dr0 = 32'h22222222;
			dr1 = 32'h33333333;
			dr0_ld = 4'b0001;
			dr1_ld = 4'b1000;
			
	#`clk	sr1_sel = 0;
			sr2_sel = 1;
			dr0_ld = 4'b0000;
			dr1_ld = 4'b0000;
		
	#`clk
	#`clk	$finish;
	end
	
	
	always #(`clk/2) CLK = ~CLK; 	// ticking
	
	initial
		begin
		$dumpfile ("reg.dump");
		$dumpvars (0, TOP);
		end

endmodule*/

module LimitRegisters$(
	out0, out1, out2, out3,
	sel0, sel1, sel2, sel3);
	
	output[31:0] out0, out1, out2, out3;
	input[2:0] sel0, sel1, sel2, sel3;
	
	reg[31:0] segment_limit[0:7];
	
	mux8_32$ muxOut[3:0](
		{out3, out2, out1, out0},
		segment_limit[0], 
		segment_limit[1], 
		segment_limit[2], 
		segment_limit[3], 
		segment_limit[4], 
		segment_limit[5], 
		segment_limit[6], 
		segment_limit[7],
		{sel3, sel2, sel1, sel0}
	);
	
	initial $readmemh("/misc/collaboration/382nGPS/382nG6/yhuang/segment_limit.dat", segment_limit);
	
endmodule

module MMX$(sr0, sr1, dr,
			sr0_sel, sr1_sel, dr_sel,
			dr_ld,
			CLK, CLR, PRE,
			reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7);
			
	output[63:0] sr0, sr1;
	input[63:0] dr;
	input[2:0] sr0_sel, sr1_sel, dr_sel;
	input dr_ld;
	input CLK, CLR, PRE;
	output[63:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
	
	RegFile8_32$ regFile[1:0](sr0, sr1, , , dr, ,
							  sr0_sel, sr1_sel, , , dr_sel, ,
							  {8{dr_ld}}, 8'h0, 
							  CLK, CLR, PRE,
							  reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7);
			
endmodule

module SegR$(sr0, sr1, sr2, sr3, dr0, dr1,
			 sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel,
			 dr0_ld, dr1_ld, 			
			 CLK, CLR, PRE,
			 reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7);
	
	output[15:0] sr0, sr1, sr2, sr3;
	input[15:0] dr0, dr1;
	input[2:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel;
	input dr0_ld, dr1_ld;
	input CLK, CLR, PRE;
	output[15:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
	
	wire[31:0] in0 = {16'hz, dr0},
			   in1 = {16'hz, dr1};
	
	wire[31:0] out0, out1, out2, out3;
	wire[31:0] temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7;
	
	assign sr0 = out0[15:0],
		   sr1 = out1[15:0],
		   sr2 = out2[15:0],
		   sr3 = out3[15:0];
	
	RegFile8_32$ regFile(out0, out1, out2, out3, in0, in1,
						 sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel,
						 {4{dr0_ld}}, {4{dr0_ld}}, 
						 CLK, CLR, PRE,
						 temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7);
						 
	assign reg0 = temp0[15:0];
	assign reg1 = temp1[15:0];
	assign reg2 = temp2[15:0];
	assign reg3 = temp3[15:0];
	assign reg4 = temp4[15:0];
	assign reg5 = temp5[15:0];
	assign reg6 = temp6[15:0];
	assign reg7 = temp7[15:0];
		
endmodule

module GPR$(sr0, sr1, sr2, sr3, dr0, dr1,
			sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel,
			sr0_size, sr1_size, sr2_size, sr3_size, dr0_size, dr1_size,
			dr0_ld, dr1_ld, 			
			CLK, CLR, PRE,
			reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7);
	
	output[31:0] sr0, sr1, sr2, sr3;
	input[31:0] dr0, dr1;
	input[2:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel;
	input[1:0] sr0_size, sr1_size, sr2_size, sr3_size, dr0_size, dr1_size;
	input dr0_ld, dr1_ld;
	input CLK, CLR, PRE;
	output[31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
	
	
	
	wire dr0_shift, dr1_shift, sr0_shift, sr1_shift, sr2_shift, sr3_shift; 
	wire[3:0] dr0_ld_adj, dr1_ld_adj;
	wire[2:0] dr0_sel_adj, dr1_sel_adj, sr0_sel_adj, sr1_sel_adj, sr2_sel_adj, sr3_sel_adj;
	GPRRegLdSelTranslate logic0(dr0_size, dr0_ld, dr0_sel, dr0_shift, dr0_ld_adj, dr0_sel_adj),
						 logic1(dr1_size, dr1_ld, dr1_sel, dr1_shift, dr1_ld_adj, dr1_sel_adj),
						 logic2(sr0_size, 1'b0, sr0_sel, sr0_shift, , sr0_sel_adj),
						 logic3(sr1_size, 1'b0, sr1_sel, sr1_shift, , sr1_sel_adj),
						 logic4(sr2_size, 1'b0, sr2_sel, sr2_shift, , sr2_sel_adj),
						 logic5(sr3_size, 1'b0, sr3_sel, sr3_shift, , sr3_sel_adj);
	
	
	wire[31:0] in0, in1;
	wire[31:0] out0, out1, out2, out3;
	mux2_32$ muxDr0Lshf(in0, dr0, {dr0[23:0], 8'b0}, dr0_shift),
			 muxDr1Lshf(in1, dr1, {dr1[23:0], 8'b0}, dr1_shift);
			 
	RegFile8_32$ regFile(out0, out1, out2, out3, in0, in1,
						 sr0_sel_adj, sr1_sel_adj, sr2_sel_adj, sr3_sel_adj, dr0_sel_adj, dr1_sel_adj,
						 dr0_ld_adj, dr1_ld_adj, 
						 CLK, CLR, PRE,
						 reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7);
				 
	mux2_32$ muxSr0Rshf(sr0, out0, {8'b0, out0[31:8]}, sr0_shift),
			 muxSr1Rshf(sr1, out1, {8'b0, out1[31:8]}, sr1_shift),
			 muxSr2Rshf(sr2, out2, {8'b0, out2[31:8]}, sr2_shift),
			 muxSr3Rshf(sr3, out3, {8'b0, out3[31:8]}, sr3_shift);
	
	
	
	
	
	
endmodule



module GPRRegLdSelTranslate(size, ld, sel, need_shift, ld_adj, sel_adj);
	input[1:0] size;
	input ld;
	input[2:0] sel;
	output need_shift;
	output[3:0] ld_adj;
	output[2:0] sel_adj;
	
	wire is_byte, is_word, is_dw, is_qw;
	wire high_byte = sel[2];
	decoder2_4$ deSize(size, {is_qw, is_dw, is_word, is_byte}, );
	
	wire need_not_shift;
	nand2$ and0(need_not_shift, is_byte, high_byte);
	inv1$ inv1(need_shift, need_not_shift);
	
	// adjust select
	and2$ and2[2:0](sel_adj, sel, {need_not_shift, 2'b11});
	
	// adjust l0
	wire w0, w1, w2, w3;
	inv1$ inv3(w0, is_byte);
	nor2$ nor4(w1, w0, high_byte);
	nor3$ nor5(w2, is_word, is_dw, w1);
	inv1$ inv6(w3, ld);
	nor2$ nor7(ld_adj[0], w2, w3);
	
	// adjust ld[1]
	// ld[1] = ((is_byte * high_byte) + is_word + is_dw) * ld
	wire w4, w5;
	and2$ and8(w4, is_byte, high_byte);
	nor3$ nor9(w5, is_word, is_dw, w4);
	nor2$ nor10(ld_adj[1], w5, w3);
	
	// adjust ld[2], ld[3]
	// ld[2] = ld[3] = is_dw * ld
	and2$ and11(ld_adj[2], is_dw, ld);
	assign ld_adj[3] = ld_adj[2];
endmodule


module RegFile8_32$(sr0, sr1, sr2, sr3, dr0, dr1,
				    sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel,
				    dr0_ld, dr1_ld, 
				    CLK, CLR, PRE,
					out0, out1, out2, out3, out4, out5, out6, out7);
	
	output[31:0] sr0, sr1, sr2, sr3;
	input[31:0] dr0, dr1;
	input[2:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel;
	input[3:0] dr0_ld, dr1_ld;
	input CLK, CLR, PRE;
	output[31:0] out0, out1, out2, out3, out4, out5, out6, out7;
	
	wire[31:0] in0, in1, in2, in3, in4, in5, in6, in7;
	wire[3:0] in0_sel, in1_sel, in2_sel, in3_sel, in4_sel, in5_sel, in6_sel, in7_sel;
	wire[3:0] ld0, ld1, ld2, ld3, ld4, ld5, ld6, ld7;
	
	//======================================
	//	Decode DR select signals
	//======================================
	wire[7:0] dr0_sel_de, dr1_sel_de;
	decoder3_8$ deDr0SelDe(dr0_sel, dr0_sel_de, ),
				deDr1SelDe(dr1_sel, dr1_sel_de, );
	
	//==================================
	// Logic for Register Load Signal
	//			 Register Input Select Signal
	//==================================
	RegLdInSelLogic regLogic[7:0](dr0_sel_de, dr1_sel_de, dr0_ld, dr1_ld, 
								  {in7_sel, in6_sel, in5_sel, in4_sel, in3_sel, in2_sel, in1_sel, in0_sel}, 
								  {ld7, ld6, ld5, ld4, ld3, ld2, ld1, ld0});
	
//	mux2_32$ inMux[7:0]({in7, in6, in5, in4, in3, in2, in1, in0},
//						dr0, dr1, 
//						{in7_sel, in6_sel, in5_sel, in4_sel, in3_sel, in2_sel, in1_sel, in0_sel});
						
	mux2_8$ muxIn0[3:0](in0, dr0, dr1, in0_sel),
			muxIn1[3:0](in1, dr0, dr1, in1_sel),
			muxIn2[3:0](in2, dr0, dr1, in2_sel),
			muxIn3[3:0](in3, dr0, dr1, in3_sel),
			muxIn4[3:0](in4, dr0, dr1, in4_sel),
			muxIn5[3:0](in5, dr0, dr1, in5_sel),
			muxIn6[3:0](in6, dr0, dr1, in6_sel),
			muxIn7[3:0](in7, dr0, dr1, in7_sel);
	
	//====================================
	//	Register
	//====================================
	reg8e$ reg0[3:0](CLK, in0, out0, , CLR, PRE, ld0),
		   reg1[3:0](CLK, in1, out1, , CLR, PRE, ld1),
		   reg2[3:0](CLK, in2, out2, , CLR, PRE, ld2),
		   reg3[3:0](CLK, in3, out3, , CLR, PRE, ld3),
		   reg4[3:0](CLK, in4, out4, , CLR, PRE, ld4),
		   reg5[3:0](CLK, in5, out5, , CLR, PRE, ld5),
		   reg6[3:0](CLK, in6, out6, , CLR, PRE, ld6),
		   reg7[3:0](CLK, in7, out7, , CLR, PRE, ld7);
		   
	mux8_32$ srMux[3:0]({sr3, sr2, sr1, sr0},
						out0, out1, out2, out3, out4, out5, out6, out7,
						{sr3_sel, sr2_sel, sr1_sel, sr0_sel});
	
endmodule

module reg8e$(CLK, Din, Q, Qbar, CLR, PRE, en);
	input CLK, CLR, PRE, en;
	input[7:0] Din;
	output[7:0] Q, Qbar;
	
	wire[31:0] Din_temp, Q_temp, Qbar_temp;
	assign Din_temp = {24'h0, Din};
	assign Q = Q_temp[7:0];
	assign Qbar = Qbar_temp[7:0];
	
	reg32e$ reg0(CLK, Din_temp, Q_temp, Qbar_temp, CLR, PRE, en);
endmodule

//************************************************************************
//	inputs:
//		dr0_sel_de: dr0 selects this register
//		dr1_sel_de: dr1 selects this register
//		dr0_ld:	dr0 byte-wise load enable 
//		dr1_ld: dr1 byte-wise load enable	
//
//	outputs:
//		in_sel: regsiter inputs from dr0 or dr1
//		ld: register byte-wise load enable
module RegLdInSelLogic(dr0_sel_de, dr1_sel_de, dr0_ld, dr1_ld, in_sel, ld);
	input dr0_sel_de, dr1_sel_de;
	input[3:0] dr0_ld, dr1_ld;
	output[3:0] in_sel;
	output[3:0] ld;
	
	wire[3:0] dr0_reg_ld_n, dr1_reg_ld_n;
	
	nand2$ nandDr0RegLd[3:0](dr0_reg_ld_n, dr0_sel_de, dr0_ld),
		   nandDr1RegLd[3:0](dr1_reg_ld_n, dr1_sel_de, dr1_ld),
		   nandLd[3:0](ld, dr0_reg_ld_n, dr1_reg_ld_n);
	
	inv1$ invInSel[3:0](in_sel, dr1_reg_ld_n);
	
	//nand4$ nandInSel(in_sel, dr1_reg_ld_n[0], dr1_reg_ld_n[1], dr1_reg_ld_n[2], dr1_reg_ld_n[3]);
	
endmodule

/*

module SegR16$(sr0, sr1, dr0, dr1,
			   sr0_sel, sr1_sel, dr0_sel, dr1_sel,
			   dr0_ld_en, dr1_ld_en, CLK, CLR, PRE);
			   
	output[15:0] sr0, sr1;
	input[15:0] dr0, dr1;
	input[2:0] sr0_sel, sr1_sel, dr0_sel, dr1_sel;
	input dr0_ld_en, dr1_ld_en, CLK, CLR, PRE;

	wire[31:0] dr0_temp = {16'h0, dr0};
	wire[31:0] dr1_temp = {16'h0, dr1};
	wire[31:0] sr0_temp;
	wire[31:0] sr1_temp;
	wire[7:0] in_sel;
	
	wire[7:0] dr0_sel_de, dr1_sel_de;
	wire[7:0] dr0_ld, dr1_ld;
	wire[7:0] ld;
	wire[31:0] in0, in1, in2, in3, in4, in5, in6, in7;
	wire[31:0] out0, out1, out2, out3, out4, out5, out6, out7;
	
	decoder3_8$ deDr0Sel(dr0_sel, dr0_sel_de, ),
			    deDr1Sel(dr1_sel, dr1_sel_de, );
	inv1$ invInSel[7:0](in_sel, dr0_sel_de);			 
	and2$ andDr0LdEn[7:0](dr0_ld, dr0_sel_de, dr0_ld_en),
		  andDr1LdEn[7:0](dr1_ld, dr1_sel_de, dr1_ld_en);
	or2$ orLd[7:0](ld, dr0_ld, dr1_ld);
	
	mux2_32$ inMux[7:0]({in7, in6, in5, in4, in3, in2, in1, in0},
						dr0_temp, dr1_temp, in_sel);		 
						
	reg32e$ segr[7:0](CLK, {in7, in6, in5, in4, in3, in2, in1, in0}, 
						   {out7, out6, out5, out4, out3, out2, out1, out0}
						   , , CLR, PRE, ld);
	
	mux8_32$ sr0Mux(sr0_temp, out0, out1, out2, out3, out4, out5, out6, out7, sr0_sel),
			 sr1Mux(sr1_temp, out0, out1, out2, out3, out4, out5, out6, out7, sr1_sel);
	
	assign sr0 = sr0_temp[15:0];
	assign sr1 = sr1_temp[15:0];
	
			   
endmodule
*/

/*
module RegFile32$(sr0, sr1, sr2, sr3, dr0, dr1,
				  sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr_sel0, dr_sel1,
				  data_type, 
				  CLK, CLR, PRE);
	
	output[31:0] sr0, sr1, sr2, sr3;
	input[31:0] dr0, dr1;
	input[7:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr_sel0, dr_sel1;
	input[2:0] data_type;
	
	wire[7:0] dr0_ld, dr1_ld;
	wire[31:0] raw0, l0, h0, x0, ex0;
	wire[31:0] out0;
	
	
	decoder3_8$ deDr0Sel(dr0_sel, dr0_ld, ),
				deDr1Sel(dr1_sel, dr1_ld, );
	mux2_32$(raw0, dr0, dr1, dr0_ld);
	assign l0 = 
	
	
	mux
	
	
	
	reg32e$(CLK, Din, Q, QBAR, CLR, PRE,en)
				  
				  
endmodule


				  

module RegFile16$(sr0, sr1, sr2, sr3, dr,
				  sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr_sel,
			      CLK, CLR, PRE);
	
	output[15:0] sr0, sr1, sr2, sr3;
	input[15:0] dr;
	input[2:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr_sel;
	input CLK, CLR, PRE;
	
	wire[15:0] out0, out1, out2, out3, out4, out5, out6, out7;
	wire ld0, ld1, ld2, ld3, ld4, ld5, ld6, ld;

	decoder3_8$ de(dr_sel, {ld7, ld6, ld5, ld4, ld3, ld2, ld1, ld0}, );
	
	reg16e$	regs[7:0](CLK, dr, {out7, out6, out5, out4, out3, out2, out1, out0}, ,
					  CLR, PRE, {ld7, ld6, ld5, ld4, ld3, ld2, ld1, ld0});
	
	mux8_16$ outMux[3:0]( {sr3, sr2, sr1, sr0}, 
						 out0, out1, out2, out3, out4, out5, out6, out7, 
						 {sr3_sel, sr2_sel, sr1_sel, sr0_sel} );
	
	
	
	
	
	
	
	
endmodule

*/

/*module asdfRegFile32$(sr0, sr1, sr2, sr3, dr0, dr1,
				  sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel,
				  sr0_size, sr1_size, sr2_size, sr3_size, dr0_size, dr1_size,
				  dr0_ld, dr1_ld, 
				  CLK, CLR, PRE);
	
	output[31:0] sr0, sr1, sr2, sr3;
	input[31:0] dr0, dr1;
	input[2:0] sr0_sel, sr1_sel, sr2_sel, sr3_sel, dr0_sel, dr1_sel;
	input[1:0] sr0_size, sr1_size, sr2_size, sr3_size, dr0_size, dr1_size;
	input dr0_ld, dr1_ld;
	input CLK, CLR, PRE;
	
	//==============================
	//	Registers
	//==============================
	wire[31:0] in0, in1, in2, in3, in4, in5, in6, in7;
	wire[31:0] out0, out1, out2, out3, out4, out5, out6, out7;
	wire[3:0] in0_sel, in1_sel, in2_sel, in3_sel, in4_sel, in5_sel, in6_sel, in7_sel;
	wire[3:0] ld0, ld1, ld2, ld3, ld4, ld5, ld6, ld7;
	
	reg8e$ reg0[3:0](CLK, in0, out0, , CLR, PRE, ld0),
		   reg1[3:0](CLR, in1, out1, , CLR, PRE, ld1),
		   reg2[3:0](CLR, in2, out2, , CLR, PRE, ld2),
		   reg3[3:0](CLR, in3, out3, , CLR, PRE, ld3),
		   reg4[3:0](CLR, in4, out4, , CLR, PRE, ld4),
		   reg5[3:0](CLR, in5, out5, , CLR, PRE, ld5),
		   reg6[3:0](CLR, in6, out6, , CLR, PRE, ld6),
		   reg7[3:0](CLR, in7, out7, , CLR, PRE, ld7);
	
	//===============================
	//	Data Size Decode
	//===============================
	wire[1:0] dr_size_byte, dr_size_word, dr_size_doubleword;
	wire[3:0] sr_size_byte, sr_size_word, sr_size_doubleword;
	decoder2_4$ deDrSize[1:0]({dr1_size, dr0_size}, {1'bz, dr_size_doubleword, dr_size_word, dr_size_byte}, );
	decoder2_4$ deSrSize[3:0]({sr3_size, sr2_size, sr1_size, sr0_size}, {1'bz, sr_size_doubleword, sr_size_word, sr_size_byte}, );
	
	//================================
	//	Register Select Decode
	//================================
	wire[7:0] dr0_sel_de, dr1_sel_de;
	wire[7:0] dr0_sel_de_ld, dr1_sel_de_ld;
	decoder3_8$ deDr0SelDe(dr0_sel, dr0_sel_de, ),
				deDr1SelDe(dr1_sel, dr1_sel_de, );
	and2$ andDr0SelDeLd[7:0](dr0_sel_de_ld, dr0_sel_de, dr0_ld),
		  andDr1SelDeLd[7:0](dr1_sel_de_ld, dr1_sel_de, dr1_ld);
	
	//================================
	// Register Load Enable Logic
	//================================
	wire[7:0] reg_ld;
	or2$ orRegLd[7:0](reg_ld, dr0_sel_de_ld, dr1_sel_de_ld);
	
	// for Reg3-0
	assign {ld3[0], ld2[0], ld1[0], ld0[0]} = reg_ld[3:0];
	mux2$ muxLd30_1[3:0]({ld3[1], ld2[1], ld1[1], ld0[1]}, reg_ld[3:0], reg_ld[7:4], is_byte);
	and2$ andLd30_2[3:0]({ld3[2], ld2[2], ld1[2], ld0[2]}, reg_ld[3:0], is_dw);
	assign {ld3[3], ld2[3], ld1[3], ld0[3]} = {ld3[2], ld2[2], ld1[2], ld0[2]};
	
	// for Reg7-4
	and2$ andLd74_0[3:0]({ld7[0], ld6[0], ld5[0], ld4[0]}, reg_ld[7:4], is_not_byte);
	assign {ld7[1], ld6[1], ld5[1], ld4[1]} = {ld7[0], ld6[0], ld5[0], ld4[0]};
	and2$ andLd74_2[3:0]({ld7[2], ld6[2], ld5[2], ld4[2]}, reg_ld[7:4], is_dw);
	assign {ld7[3], ld6[3], ld5[3], ld4[3]} = {ld7[2], ld6[2], ld5[2], ld4[2]};
	
	//================================
	//	Register Input Select Logic
	//================================
	wire[7:0] reg_in_sel;
	inv1$ invRegInSel[7:0](reg_in_sel, dr0_sel_de_ld);
	
	// for Reg3-0
	assign {in3_sel[0], in2_sel[0], in1_sel[0], in0_sel[0]} = reg_in_sel[3:0];
	mux2$ muxInSel30_2[3:0]({in3_sel[1], in2_sel[1], in1_sel[1], in0_sel[1]}, reg_in_sel[3:0], reg_in_sel[7:4], is_byte);
	assign {in3_sel[2], in2_sel[2], in1_sel[2], in0_sel[2]} = reg_in_sel[3:0];
	assign {in3_sel[3], in2_sel[3], in1_sel[3], in0_sel[3]} = reg_in_sel[3:0];
	
	// for Reg7-4
	assign {in7_sel[0], in6_sel[0], in5_sel[0], in4_sel[0]} = reg_in_sel[7:4];
	assign {in7_sel[1], in6_sel[1], in5_sel[1], in4_sel[1]} = reg_in_sel[7:4];
	assign {in7_sel[2], in6_sel[2], in5_sel[2], in4_sel[2]} = reg_in_sel[7:4];
	assign {in7_sel[3], in6_sel[3], in5_sel[3], in4_sel[3]} = reg_in_sel[7:4];
	
	//============================
	//	input to registers
	//============================
	
	// input muxes
	mux2_8$ muxIn0[3:0](in0, dr0, dr1, in0_sel),
			muxIn1[3:0](in1, dr0, dr1, in1_sel),
			muxIn2[3:0](in2, dr0, dr1, in2_sel),
			muxIn3[3:0](in3, dr0, dr1, in3_sel),
			muxIn4[3:0](in4, dr0, dr1, in4_sel),
			muxIn5[3:0](in5, dr0, dr1, in5_sel),
			muxIn6[3:0](in6, dr0, dr1, in6_sel),
			muxIn7[3:0](in7, dr0, dr1, in7_sel);
	

	

	//===============================
	//	output logic
	//===============================
	wire[3:0] sr_sel_gt3;
	
	mag_comp4$ magSrSelCmp[3:0]({1'h0, sr3_sel, 1'h0, sr2_sel, 1'h0, sr1_sel, 1'h0, sr0_sel},
								{4{4'h3}}, 
								sr_sel_gt3, );
	
	
	mux8_32$ muxSr[3:0]({sr3, sr2, sr1, sr0},
						out0, out1, out2, out3, out4, out5, out6, out7,
						{sr3_sel, sr2_sel, sr1_sel, sr0_sel});
	
endmodule*/
