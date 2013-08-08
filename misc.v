`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib1"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib2"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib3"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib4"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib5"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib6"
`include "/misc/collaboration/382nGPS/382nG6/yhuang/macro.v"
`include "/misc/collaboration/382nGPS/382nG6/yhuang/fu.v"
`include "/misc/collaboration/382nGPS/382nG6/yhuang/reg.v"





module muxTOP;
	
	reg[2:0] s;
	wire[15:0] out;
	
	//mux8_16 mux0(out, 16'h0000, 16'h1111, 16'h2222, 16'h3333, 16'h4444, 16'h5555, 16'h6666, 16'h7777, s);
	
	

	initial
		begin
			#10	s = 0;
			#10	s = 1;
			#10	s = 2;
			#10	s = 3;
			#10	s = 4;
			#10	s = 5;
			#10	s = 6;
			#10	s = 7;
			#10 s = 0;
		end
		
endmodule

module mux8$(out, in0, in1, in2, in3, in4, in5, in6, in7, s0, s1, s2);
	input in0, in1, in2, in3, in4, in5, in6, in7;
	input s0, s1, s2;
	output out;
	
	wire w0, w1;
	mux4$ mux0(w0, in0, in1, in2, in3, s0, s1);
	mux4$ mux1(w1, in4, in5, in6, in7, s0, s1);
	mux2$ mux2(out, w0, w1, s2);
	
endmodule


module mux2_32$(out, in0, in1, s);
	input[31:0] in0, in1;
	input s;
	output[31:0] out;
	
	mux2_16$ outMux[1:0](out, in0, in1, s);
endmodule

module mux4_32$(out, in0, in1, in2, in3, s);
	input[31:0] in0, in1, in2, in3;
	input[1:0] s;
	output[31:0] out;
	
	mux4_16$ outMux[1:0](out, in0, in1, in2, in3, s[0], s[1]);
endmodule
		
module mux8_16$(out, in0, in1, in2, in3, in4, in5, in6, in7, s);
	input[15:0] in0, in1, in2, in3, in4, in5, in6, in7;
	input[2:0] s;
	output[15:0] out;
	
	wire[15:0] in0_3, in4_7;
	
	mux4_16$ lowMux(in0_3, in0, in1, in2, in3, s[0], s[1]),
			 highMux(in4_7, in4, in5, in6, in7, s[0], s[1]);
	
	mux2_16$ outMux(out, in0_3, in4_7, s[2]);	
	
endmodule
		
module mux8_32$(out, in0, in1, in2, in3, in4, in5, in6, in7, s);
	input[31:0] in0, in1, in2, in3, in4, in5, in6, in7;
	input[2:0] s;
	output[31:0] out;
	
	mux8_16$ outMux[1:0](out, in0, in1, in2, in3, in4, in5, in6, in7, s);
	
endmodule

module id_comp4$(a, b, equal, notEqual);
	input[3:0] a, b;
	output equal, notEqual;
	
	wire[3:0] a_xor_b;
	wire[1:0] w1;
	
	xor2$ xor0[3:0](a_xor_b, a, b);
	nor4$ nor1(equal, a_xor_b[0], a_xor_b[1], a_xor_b[2], a_xor_b[3]);
	inv1$ inv2(notEqual, equal);
	
	
endmodule

module id_comp16$(a, b, equal, notEqual);
	input[15:0] a, b;
	output equal, notEqual;
	
	wire[15:0] a_xor_b;
	wire[7:0] w0;
	wire[3:0] w1;
	wire[1:0] w2;
	
	xor2$ xor0[15:0](a_xor_b, a, b);
	nor2$ nor1[7:0](w0, a_xor_b[15:8], a_xor_b[7:0]);
	nand2$ nand2[3:0](w1, w0[7:4], w0[3:0]);
	nor2$ nor3[1:0](w2, w1[3:2], w1[1:0]);
	nand2$ nand4(equal, w2[1], w2[0]);
	inv1$ inv5(notEqual, equal);
	
endmodule

module id_comp32$(a, b, equal, notEqual);
	input[31:0] a, b;
	output equal, notEqual;
	
	wire[1:0] equal_temp, notEqual_temp;
	
	id_comp16$ comp[1:0](a, b, notEqual_temp, equal_temp);
	and2$ and0(equal, equal_temp[0], equal_temp[1]);
	or2$ or0(notEqual, notEqual_temp[0], notEqual_temp[1]);
	
	
endmodule

module mag_comp16$(a, b, aGb, bGa);
	input[15:0] a, b;
	output aGb, bGa;
	
	wire aGb15_8, aGb7_0, bGa15_8, bGa7_0;
	
	mag_comp8$ comp15_8(a[15:8], b[15:8], aGb15_8, bGa15_8),
			   comp7_0(a[7:0], b[7:0], aGb7_0, bGa7_0);
	
	wire[1:0] w0, w1, w2;
	inv1$ inv0[1:0](w0, {bGa15_8, aGb15_8});
	nand2$ nand1[1:0](w1, w0, {aGb7_0, bGa7_0});
	inv1$ inv2[1:0](w2, {aGb15_8, bGa15_8});
	nand2$ nand3[1:0]({aGb, bGa}, w1, w2);
	
endmodule

module mag_comp32$(a, b, aGb, bGa);
	input[31:0] a, b;
	output aGb, bGa;
	
	wire aGb31_16, aGb15_0, bGa31_16, bGa15_0;
	
	mag_comp16$ comp31_16(a[31:16], b[31:16], aGb31_16, bGa31_16),
			    comp15_0(a[15:0], b[15:0], aGb15_0, bGa15_0);
	
	wire[1:0] w0, w1, w2;
	inv1$ inv0[1:0](w0, {bGa31_16, aGb31_16});
	nand2$ nand1[1:0](w1, w0, {aGb15_0, bGa15_0});
	inv1$ inv2[1:0](w2, {aGb31_16, bGa31_16});
	nand2$ nand3[1:0]({aGb, bGa}, w1, w2);

endmodule


module reg1e$(CLK, Din, Q, QBAR, CLR, PRE, en);
	input CLK, CLR, PRE, en;
	input Din;
	output Q, QBAR;
	
	wire[30:0] Q_top, QBAR_top;
	
	reg32e$ reg0(CLK, {31'h0, Din}, {Q_top, Q}, {QBAR_top, QBAR}, CLR, PRE, en);
endmodule

module reg16e$(CLK, Din, Q, QBAR, CLR, PRE, en);
	input CLK, CLR, PRE, en;
	input[15:0] Din;
	output[15:0] Q, QBAR;
	
	wire[15:0] Q_top, QBAR_top;
	
	reg32e$ reg0(CLK, {16'h0 ,Din}, {Q_top, Q}, {QBAR_top, QBAR}, CLR, PRE, en);
	
	
	
endmodule

module SEXT64$(in, size, out, sign);
	input[63:0] in;
	input[1:0] size;
	output[63:0] out;
	output sign;
	
	mux4$ muxSign(sign, in[7], in[15], in[31], in[63], size[0], size[1]);
	mux4_32$ muxOut[1:0](out, 
						 {{56{sign}}, in[7:0]},
						 {{48{sign}}, in[15:0]},
						 {{32{sign}}, in[31:0]},
						 in,
						 size);
endmodule

module SEXT32$(in, size, out, sign);
	input[31:0] in;
	input[1:0] size;
	output[31:0] out;
	output sign;
	
	wire[63:0] in_temp, out_temp;
	assign in_temp = {32'h0, in};
	assign out = out_temp[31:0];
	
	SEXT64$ sext(in_temp, size, out_temp, sign);
	
endmodule
			
				
				
