//`ifdef YZHU_BASIC_GATES
//`else
//`define YZHU_BASIC_GATES
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib1"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib2"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib3"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib4"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib5"
`include "/home/projects/courses/spring_12/ee382n-16905/lib/lib6"
`include "/misc/collaboration/382nGPS/382nG6/yhuang/misc.v"

module mux2_96(o, a, b, s);
	input[95:0] a, b;
	output[95:0] o;
	input s;

	mux2_32 mux1(o[31:0], a[31:0], b[31:0], s);
	mux2_32 mux2(o[63:32], a[63:32], b[63:32], s);
	mux2_32 mux3(o[95:64], a[95:64], b[95:64], s);
endmodule

module mux2_64(o, a, b, s);
	input[63:0] a, b;
	output[63:0] o;
	input s;

	mux2_32 mux1(o[31:0], a[31:0], b[31:0], s);
	mux2_32 mux2(o[63:32], a[63:32], b[63:32], s);
endmodule

module mux2_32(o, a, b, s);
	input[31:0] a, b;
	output[31:0] o;
	input s;

	// s: 0-a, 1-b
	mux2_16$ mux1(o[31:16], a[31:16], b[31:16], s);
	mux2_16$ mux2(o[15:0], a[15:0], b[15:0], s);
endmodule

module mux2_20(o, a, b, s);
	input[19:0] a, b;
	output[19:0] o;
	input s;

	wire[31:0] temp_o;

	assign o = temp_o[19:0];

	// s[1:0]: 00-a, 01-c, 10-b, 11-d
	mux2_32 mux1(temp_o, {12'b0, a}, {12'b0, b}, s);
endmodule

module mux2_5(o, a, b, s);
	input[4:0] a, b;
	input s;
	output[4:0] o;

	wire[7:0] temp_o;

	mux2_8$ mux1(temp_o, {3'b0, a}, {3'b0, b}, s);
	assign o = temp_o[4:0];
endmodule

module mux2_4(o, a, b, s);
	input[3:0] a, b;
	input s;
	output[3:0] o;

	wire[7:0] temp_o;

	mux2_8$ mux1(temp_o, {4'b0, a}, {4'b0, b}, s);
	assign o = temp_o[3:0];
endmodule

module mux3_64(o, a, b, c, s);
	input[63:0] a, b, c;
	output[63:0] o;
	input[1:0] s;

	// s[1:0]: 00-a, 01-c, 10-b, 11-c
	mux3_32 mux1(o[63:32], a[63:32], b[63:32], c[63:32], s);
	mux3_32 mux2(o[31:0], a[31:0], b[31:0], c[31:0], s);
endmodule

module mux3_32(o, a, b, c, s);
	input[31:0] a, b, c;
	output[31:0] o;
	input[1:0] s;

	// s[1:0]: 00-a, 01-c, 10-b, 11-c
	mux3_16$ mux1(o[31:16], a[31:16], b[31:16], c[31:16], s[1], s[0]);
	mux3_16$ mux2(o[15:0], a[15:0], b[15:0], c[15:0], s[1], s[0]);
endmodule

module mux3_20(o, a, b, c, s);
	input[19:0] a, b, c;
	output[19:0] o;
	input[1:0] s;

	// s[1:0]: 00-a, 01-c, 10-b, 11-c
	mux3_16$ mux1(o[19:4], a[19:4], b[19:4], c[19:4], s[1], s[0]);
	mux3_4 mux2(o[3:0], a[3:0], b[3:0], c[3:0], s);
endmodule

module mux3_15(o, a, b, c, s);
	input[14:0] a, b, c;
	output[14:0] o;
	input[1:0] s;

	wire[15:0] temp_o;

	// s[1:0]: 00-a, 01-c, 10-b, 11-c
	mux3_16$ mux1(temp_o, {1'b0, a}, {1'b0, b}, {1'b0, c}, s[1], s[0]);
	assign o = temp_o[14:0];
endmodule

module mux3_5(o, a, b, c, s);
	input[4:0] a, b, c;
	input[1:0] s;
	output[4:0] o;

	wire[7:0] temp_o;

	assign o = temp_o[4:0];

	mux3_8$ mux1(temp_o, {3'b0, a}, {3'b0, b}, {3'b0, c}, s[1], s[0]);
endmodule

module mux3_4(o, a, b, c, s);
	input[3:0] a, b, c;
	input[1:0] s;
	output[3:0] o;

	wire[7:0] temp_o;

	assign o = temp_o[3:0];

	mux3_8$ mux1(temp_o, {4'b0, a}, {4'b0, b}, {4'b0, c}, s[1], s[0]);
endmodule

module mux4_32(o, a, b, c, d, s);
	input[31:0] a, b, c, d;
	output[31:0] o;
	input[1:0] s;

	// s[1:0]: 00-a, 01-c, 10-b, 11-d
	mux4_16$ mux1(o[31:16], a[31:16], b[31:16], c[31:16], d[31:16], s[1], s[0]);
	mux4_16$ mux2(o[15:0], a[15:0], b[15:0], c[15:0], d[15:0], s[1], s[0]);
endmodule

module mux4_20(o, a, b, c, d, s);
	input[19:0] a, b, c, d;
	output[19:0] o;
	input[1:0] s;

	wire[31:0] temp_o;

	assign o = temp_o[19:0];

	// s[1:0]: 00-a, 01-c, 10-b, 11-d
	mux4_32 mux1(temp_o, {12'b0, a}, {12'b0, b}, {12'b0, c}, {12'b0, d}, s);
endmodule

module mux4_96(o, a, b, c, d, s);
	input[95:0] a, b, c, d;
	output[95:0] o;
	input[1:0] s;

	mux4_32 mux1(o[31:0], a[31:0], b[31:0], c[31:0], d[31:0], s);
	mux4_32 mux2(o[63:32], a[63:32], b[63:32], c[63:32], d[63:32], s);
	mux4_32 mux3(o[95:64], a[95:64], b[95:64], c[95:64], d[95:64], s);
endmodule

module mux4_15(o, a, b, c, d, s);
	input[14:0] a, b, c, d;
	input[1:0] s;
	output[14:0] o;

	wire[15:0] temp_o;

	assign o = temp_o[14:0];

	mux4_16$ mux1(temp_o, {1'b0, a}, {1'b0, b}, {1'b0, c}, {1'b0, d}, s[1], s[0]);
endmodule

module mux4_6(o, a, b, c, d, s);
	input[5:0] a, b, c, d;
	input[1:0] s;
	output[5:0] o;

	wire[7:0] temp_o;

	mux4_8$ mux1(temp_o, {2'b0, a}, {2'b0, b}, {2'b0, c}, {2'b0, d}, s[1], s[0]);
	assign o = temp_o[5:0];
endmodule

module mux4_5(o, a, b, c, d, s);
	input[4:0] a, b, c, d;
	input[1:0] s;
	output[4:0] o;

	wire[7:0] temp_o;

	mux4_8$ mux1(temp_o, {3'b0, a}, {3'b0, b}, {3'b0, c}, {3'b0, d}, s[1], s[0]);
	assign o = temp_o[4:0];
endmodule

module mux4_2(o, a, b, c, d, s);
	input[1:0] a, b, c, d;
	output[1:0] o;
	input[1:0] s;

	// s[1:0]: 00-a, 01-c, 10-b, 11-d
	mux4$ mux1(o[0], a[0], b[0], c[0], d[0], s[1], s[0]);
	mux4$ mux2(o[1], a[1], b[1], c[1], d[1], s[1], s[0]);
endmodule

module mux4_24(o, a, b, c, d, s);
	input[23:0] a, b, c, d;
	input[1:0] s;
	output[23:0] o;

	mux4_8$ mux1(o[7:0], a[7:0], b[7:0], c[7:0], d[7:0], s[1], s[0]);
	mux4_16$ mux2(o[23:8], a[23:8], b[23:8], c[23:8], d[23:8], s[1], s[0]);
endmodule

module mux2_24(o, a, b, s);
	input[23:0] a, b;
	input s;
	output[23:0] o;

	mux2_8$ mux1(o[7:0], a[7:0], b[7:0], s);
	mux2_16$ mux2(o[23:8], a[23:8], b[23:8], s);
endmodule

module mux2_15(o, a, b, s);
	input[14:0] a, b;
	input s;
	output[14:0] o;

	wire[15:0] temp_o;

	mux2_16$ mux1(temp_o, {1'b0, a}, {1'b0, b}, s);
	assign o = temp_o[14:0];
endmodule

module mux2_2(o, a, b, s);
	input[1:0] a, b;
	input s;
	output[1:0] o;

	mux2$ mux1(o[0], a[0], b[0], s);
	mux2$ mux2(o[1], a[1], b[1], s);
endmodule

module mux3_24(o, a, b, c, s);
	input[23:0] a, b, c;
	input[1:0] s;
	output[23:0] o;

	mux3_8$ mux1(o[7:0], a[7:0], b[7:0], c[7:0], s[1], s[0]);
	mux3_8$ mux2(o[15:8], a[15:8], b[15:8], c[15:8], s[1], s[0]);
	mux3_8$ mux3(o[23:16], a[23:16], b[23:16], c[23:16], s[1], s[0]);
endmodule

module mux3_6(o, a, b, c, s);
	input[5:0] a, b, c;
	input[1:0] s;
	output[5:0] o;

	wire[7:0] temp_o;

	mux3_8$ mux1(temp_o, {2'b0, a}, {2'b0, b}, {2'b0, c}, s[1], s[0]);
	assign o = temp_o[5:0];
endmodule

module mux3_2(o, a, b, c, s);
	input[1:0] a, b, c;
	input[1:0] s;
	output[1:0] o;

	mux3$ mux1(o[1], a[1], b[1], c[1], s[1], s[0]);
	mux3$ mux2(o[0], a[0], b[0], c[0], s[1], s[0]);
endmodule

module mag_comp32(a, b, e);
	input[31:0] a, b;
	output e;

	wire g1, g2, g3, g4, s1, s2, s3, s4;

	mag_comp8$ comp1(a[7:0], b[7:0], g1, s1);
	mag_comp8$ comp2(a[15:8], b[15:8], g2, s2);
	mag_comp8$ comp3(a[23:16], b[23:16], g3, s3);
	mag_comp8$ comp4(a[31:24], b[31:24], g4, s4);

	//assign e = (~g1 & ~s1) & (~g2 & ~s2) & (~g3 & ~s3) & (~g4 & ~s4);
	wire g1_inv, g2_inv, g3_inv, g4_inv, s1_inv, s2_inv, s3_inv, s4_inv;
	wire e1, e2, e3, e4;
	inv1$ inv1(g1_inv, g1);
	inv1$ inv2(s1_inv, s1);
	inv1$ inv3(g2_inv, g2);
	inv1$ inv4(s2_inv, s2);
	inv1$ inv5(g3_inv, g3);
	inv1$ inv6(s3_inv, s3);
	inv1$ inv7(g4_inv, g4);
	inv1$ inv8(s4_inv, s4);
	and2$ and1(e1, g1_inv, s1_inv);
	and2$ and2(e2, g2_inv, s2_inv);
	and2$ and3(e3, g3_inv, s3_inv);
	and2$ and4(e4, g4_inv, s4_inv);
	and4$ and5(e, e1, e2, e3, e4);
endmodule

module mag_comp20(a, b, e);
	input[19:0] a, b;
	output e;

	wire g1, g2, g3, s1, s2, s3;

	mag_comp8$ comp1(a[7:0], b[7:0], g1, s1);
	mag_comp8$ comp2(a[15:8], b[15:8], g2, s2);
	mag_comp4$ comp3(a[19:16], b[19:16], g3, s3);

	//assign e = (~g1 & ~s1) & (~g2 & ~s2) & (~g3 & ~s3);
	wire g1_inv, g2_inv, g3_inv, s1_inv, s2_inv, s3_inv;
	wire e1, e2, e3;
	inv1$ inv1(g1_inv, g1);
	inv1$ inv2(s1_inv, s1);
	inv1$ inv3(g2_inv, g2);
	inv1$ inv4(s2_inv, s2);
	inv1$ inv5(g3_inv, g3);
	inv1$ inv6(s3_inv, s3);
	and2$ and1(e1, g1_inv, s1_inv);
	and2$ and2(e2, g2_inv, s2_inv);
	and2$ and3(e3, g3_inv, s3_inv);
	and3$ and5(e, e1, e2, e3);
endmodule

module mag_comp4(a, b, e);
	input[3:0] a, b;
	output e;

	mag_comp4$ comp1(a, b, g, s);

	//assign e = ~g & ~s;
	wire g_inv, s_inv;
	inv1$ inv1(g_inv, g);
	inv1$ inv2(s_inv, s);
	and2$ and1(e, g_inv, s_inv);
endmodule

module mag_comp5(a, b, e);
	input[4:0] a, b;
	output e;

	wire g, s;

	mag_comp8$ comp1({3'b0, a}, {3'b0, b}, g, s);

	//assign e = ~g & ~s;
	wire g_inv, s_inv;
	inv1$ inv1(g_inv, g);
	inv1$ inv2(s_inv, s);
	and2$ and1(e, g_inv, s_inv);
endmodule

module encoder8_3(in, out);
	input[7:0] in;
	output[2:0] out;

	//assign out[0] = in[1] | in[3] | in[5] | in[7];
	//assign out[1] = in[2] | in[3] | in[6] | in[7];
	//assign out[2] = in[4] | in[5] | in[6] | in[7];
	or4$ or1(out[0], in[1], in[3], in[5], in[7]);
	or4$ or2(out[1], in[2], in[3], in[6], in[7]);
	or4$ or3(out[2], in[4], in[5], in[6], in[7]);
endmodule

module sext_8_32(in, out);
	input[7:0] in;
	output[31:0] out;

	assign out = {in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in[7], in};
endmodule

module sext_16_32(in, out);
	input[15:0] in;
	output[31:0] out;

	assign out = {in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in[15], in};
endmodule

module zext_16_32(in, out);
	input[15:0] in;
	output[31:0] out;

	assign out = {16'b0, in};
endmodule

module dff_128(clk, d, q, clr, ld);
	input[127:0] d;
	input clk, clr, ld;
	output[127:0] q;

	dff_64 dff1(clk, d[63:0], q[63:0], clr, ld);
	dff_64 dff2(clk, d[127:64], q[127:64], clr, ld);
endmodule

module dff_64(clk, d, q, clr, ld);
	input[63:0] d;
	input clk, clr, ld;
	output[63:0] q;

	//reg64e$(CLK, Din, Q, QBAR, CLR, PRE,en);
	reg64e$ reg1(clk, d, q, , clr, 1'b1, ld);
endmodule

module dff_32(clk, d, q, clr, ld);
	input[31:0] d;
	input clk, clr, ld;
	output[31:0] q;

	//reg32e$(CLK, Din, Q, QBAR, CLR, PRE,en);
	reg32e$ reg1(clk, d, q, , clr, 1'b1, ld);
endmodule

module dff_17(clk, d, q, clr, ld);
	input[16:0] d;
	input clk, clr, ld;
	output[16:0] q;

	wire[31:0] q32;

	reg32e$ reg1(clk, {15'b0, d}, q32, , clr, 1'b1, ld);
	assign q = q32[16:0];
endmodule

module dff_16(clk, d, q, clr, ld);
	input[15:0] d;
	input clk, clr, ld;
	output[15:0] q;

	wire[31:0] q32;

	reg32e$ reg1(clk, {16'b0, d}, q32, , clr, 1'b1, ld);
	assign q = q32[15:0];
endmodule

module dff_15(clk, d, q, clr, ld);
	input[14:0] d;
	input clk, clr, ld;
	output[14:0] q;

	wire[31:0] q32;

	reg32e$ reg1(clk, {17'b0, d}, q32, , clr, 1'b1, ld);
	assign q = q32[14:0];
endmodule

module dff_8(clk, q, d, clr, ld);
	input[7:0] d;
	input clk, clr, ld;
	output[7:0] q;

	dff_4 dff1(clk, q[3:0], d[3:0], clr, ld);
	dff_4 dff2(clk, q[7:4], d[7:4], clr, ld);
endmodule

module dff_7(clk, q, d, clr, ld);
	input[6:0] d;
	input clk, clr, ld;
	output[6:0] q;

	dff_6 dff1(clk, q[5:0], d[5:0], clr, ld);
	dff_1 dff2(clk, q[6], d[6], clr, ld);
endmodule

module dff_6(clk, q, d, clr, ld);
	input[5:0] d;
	input clk, clr, ld;
	output[5:0] q;

	dff_2 dff1(clk, q[1:0], d[1:0], clr, ld);
	dff_2 dff2(clk, q[3:2], d[3:2], clr, ld);
	dff_2 dff3(clk, q[5:4], d[5:4], clr, ld);
endmodule

module dff_5(clk, q, d, clr, ld);
	input[4:0] d;
	input clk, clr, ld;
	output[4:0] q;

	dff_2 dff1(clk, q[1:0], d[1:0], clr, ld);
	dff_2 dff2(clk, q[3:2], d[3:2], clr, ld);
	dff_1 dff3(clk, q[4], d[4], clr, ld);
endmodule

module dff_4(clk, q, d, clr, ld);
	input[3:0] d;
	input clk, clr, ld;
	output[3:0] q;

	dff_2 dff1(clk, q[1:0], d[1:0], clr, ld);
	dff_2 dff2(clk, q[3:2], d[3:2], clr, ld);
endmodule

module dff_2(clk, d, q, clr, ld);
	input[1:0] d;
	input clk, clr, ld;
	output[1:0] q;

	wire[1:0] in;

	//dff$(clk, d, q, qbar, r, s);
	mux2$ mux1(in[0], q[0], d[0], ld);
	mux2$ mux2(in[1], q[1], d[1], ld);
	dff$ dff1(clk, in[0], q[0], , clr, 1'b1);
	dff$ dff2(clk, in[1], q[1], , clr, 1'b1);
endmodule

module dff_1(clk, d, q, clr, ld);
	input d;
	input clk, clr, ld;
	output q;

	wire in;

	//dff$(clk, d, q, qbar, r, s);
	mux2$ mux1(in, q, d, ld);
	dff$ dff1(clk, in, q, , clr, 1'b1);
endmodule

module saturate_dff_32(clk, d, q, clr, ld);
	input clk, clr, ld;
	input[31:0] d;
	output[31:0] q;

	saturate_dff_1 dff1(clk, d[0], q[0], clr, ld);
	saturate_dff_1 dff2(clk, d[1], q[1], clr, ld);
	saturate_dff_1 dff3(clk, d[2], q[2], clr, ld);
	saturate_dff_1 dff4(clk, d[3], q[3], clr, ld);
	saturate_dff_1 dff5(clk, d[4], q[4], clr, ld);
	saturate_dff_1 dff6(clk, d[5], q[5], clr, ld);
	saturate_dff_1 dff7(clk, d[6], q[6], clr, ld);
	saturate_dff_1 dff8(clk, d[7], q[7], clr, ld);
	saturate_dff_1 dff9(clk, d[8], q[8], clr, ld);
	saturate_dff_1 dff10(clk, d[9], q[9], clr, ld);
	saturate_dff_1 dff11(clk, d[10], q[10], clr, ld);
	saturate_dff_1 dff12(clk, d[11], q[11], clr, ld);
	saturate_dff_1 dff13(clk, d[12], q[12], clr, ld);
	saturate_dff_1 dff14(clk, d[13], q[13], clr, ld);
	saturate_dff_1 dff15(clk, d[14], q[14], clr, ld);
	saturate_dff_1 dff16(clk, d[15], q[15], clr, ld);
	saturate_dff_1 dff17(clk, d[16], q[16], clr, ld);
	saturate_dff_1 dff18(clk, d[17], q[17], clr, ld);
	saturate_dff_1 dff19(clk, d[18], q[18], clr, ld);
	saturate_dff_1 dff20(clk, d[19], q[19], clr, ld);
	saturate_dff_1 dff21(clk, d[20], q[20], clr, ld);
	saturate_dff_1 dff22(clk, d[21], q[21], clr, ld);
	saturate_dff_1 dff23(clk, d[22], q[22], clr, ld);
	saturate_dff_1 dff24(clk, d[23], q[23], clr, ld);
	saturate_dff_1 dff25(clk, d[24], q[24], clr, ld);
	saturate_dff_1 dff26(clk, d[25], q[25], clr, ld);
	saturate_dff_1 dff27(clk, d[26], q[26], clr, ld);
	saturate_dff_1 dff28(clk, d[27], q[27], clr, ld);
	saturate_dff_1 dff29(clk, d[28], q[28], clr, ld);
	saturate_dff_1 dff30(clk, d[29], q[29], clr, ld);
	saturate_dff_1 dff31(clk, d[30], q[30], clr, ld);
	saturate_dff_1 dff32(clk, d[31], q[31], clr, ld);
endmodule

module saturate_dff_1(clk, d, q, clr, ld);
	input clk, d, clr, ld;
	output q;

	wire in;

	or2$ or1(in, d, q);
	dff_1 dff1(clk, in, q, clr, ld);
endmodule

//module mag_comp17(a, b, g, s);
//	input[16:0] a, b;
//	output g, s;
//
//	assign g = (a > b);
//	assign s = (a < b);
//endmodule

module decoder4_16(a, o);
	input[3:0] a;
	output[15:0] o;

	//assign o[0] = ~a[3] & ~a[2] & ~a[1] & ~a[0];
	//assign o[1] = ~a[3] & ~a[2] & ~a[1] & a[0];
	//assign o[2] = ~a[3] & ~a[2] & a[1] & ~a[0];
	//assign o[3] = ~a[3] & ~a[2] & a[1] & a[0];
	//assign o[4] = ~a[3] & a[2] & ~a[1] & ~a[0];
	//assign o[5] = ~a[3] & a[2] & ~a[1] & a[0];
	//assign o[6] = ~a[3] & a[2] & a[1] & ~a[0];
	//assign o[7] = ~a[3] & a[2] & a[1] & a[0];
	//assign o[8] = a[3] & ~a[2] & ~a[1] & ~a[0];
	//assign o[9] = a[3] & ~a[2] & ~a[1] & a[0];
	//assign o[10] = a[3] & ~a[2] & a[1] & ~a[0];
	//assign o[11] = a[3] & ~a[2] & a[1] & a[0];
	//assign o[12] = a[3] & a[2] & ~a[1] & ~a[0];
	//assign o[13] = a[3] & a[2] & ~a[1] & a[0];
	//assign o[14] = a[3] & a[2] & a[1] & ~a[0];
	//assign o[15] = a[3] & a[2] & a[1] & a[0];
	wire a3_inv, a2_inv, a1_inv, a0_inv;
	inv1$ inv1(a3_inv, a[3]);
	inv1$ inv2(a2_inv, a[2]);
	inv1$ inv3(a1_inv, a[1]);
	inv1$ inv4(a0_inv, a[0]);
	and4$ and1(o[0], a3_inv, a2_inv, a1_inv, a0_inv);
	and4$ and2(o[1], a3_inv, a2_inv, a1_inv, a[0]);
	and4$ and3(o[2], a3_inv, a2_inv, a[1], a0_inv);
	and4$ and4(o[3], a3_inv, a2_inv, a[1], a[0]);
	and4$ and5(o[4], a3_inv, a[2], a1_inv, a0_inv);
	and4$ and6(o[5], a3_inv, a[2], a1_inv, a[0]);
	and4$ and7(o[6], a3_inv, a[2], a[1], a0_inv);
	and4$ and8(o[7], a3_inv, a[2], a[1], a[0]);
	and4$ and9(o[8], a[3], a2_inv, a1_inv, a0_inv);
	and4$ and10(o[9], a[3], a2_inv, a1_inv, a[0]);
	and4$ and11(o[10], a[3], a2_inv, a[1], a0_inv);
	and4$ and12(o[11], a[3], a2_inv, a[1], a[0]);
	and4$ and13(o[12], a[3], a[2], a1_inv, a0_inv);
	and4$ and14(o[13], a[3], a[2], a1_inv, a[0]);
	and4$ and15(o[14], a[3], a[2], a[1], a0_inv);
	and4$ and16(o[15], a[3], a[2], a[1], a[0]);
endmodule

module add2_32(a, b, out, cout, adj);
	input[31:0] a, b;
	output[31:0] out;
	output cout, adj;

	wire cout1, cout2, cout3, cout4, cout5, cout6, cout7;

	//module alu4$(a,b,cin,m,s,cout,out);
	alu4$ alu8(a[31:28], b[31:28], cout7, 1'b1, 4'd9, cout, out[31:28]);
	alu4$ alu7(a[27:24], b[27:24], cout6, 1'b1, 4'd9, cout7, out[27:24]);
	alu4$ alu6(a[23:20], b[23:20], cout5, 1'b1, 4'd9, cout6, out[23:20]);
	alu4$ alu5(a[19:16], b[19:16], cout4, 1'b1, 4'd9, cout5, out[19:16]);
	alu4$ alu4(a[15:12], b[15:12], cout3, 1'b1, 4'd9, cout4, out[15:12]);
	alu4$ alu3(a[11:8], b[11:8], cout2, 1'b1, 4'd9, cout3, out[11:8]);
	alu4$ alu2(a[7:4], b[7:4], cout1, 1'b1, 4'd9, cout2, out[7:4]);
	alu4$ alu1(a[3:0], b[3:0], 1'b0, 1'b1, 4'd9, cout1, out[3:0]);

	assign adj = cout1; //TODO: This should be correct? AF only makes sense for BCD which only cares about two nibbles in LSB
endmodule

module add2_16(a, b, out, cout, adj);
	input[15:0] a, b;
	output[15:0] out;
	output cout, adj;

	wire cout1, cout2, cout3;

	//module alu4$(a,b,cin,m,s,cout,out);
	alu4$ alu4(a[15:12], b[15:12], cout3, 1'b1, 4'd9, cout, out[15:12]);
	alu4$ alu3(a[11:8], b[11:8], cout2, 1'b1, 4'd9, cout3, out[11:8]);
	alu4$ alu2(a[7:4], b[7:4], cout1, 1'b1, 4'd9, cout2, out[7:4]);
	alu4$ alu1(a[3:0], b[3:0], 1'b0, 1'b1, 4'd9, cout1, out[3:0]);

	assign adj = cout1; //TODO: This should be correct? AF only makes sense for BCD which only cares about two nibbles in LSB
endmodule

module or5$(out, a0, a1, a2, a3, a4);
	input a0, a1, a2, a3, a4;
	output out;

	or2$ or1(t0, a0, a1);
	or2$ or2(t1, a2, a3);
	or3$ or3(out, t0, t1, a4);
endmodule

module and5_1(out, a, b);
	input[4:0] a;
    input b;
	output[4:0] out;

    and2$ and1(out[0], a[0], b);
    and2$ and2(out[1], a[1], b);
    and2$ and3(out[2], a[2], b);
    and2$ and4(out[3], a[3], b);
    and2$ and5(out[4], a[4], b);
endmodule

module and5$(out, a0, a1, a2, a3, a4);
	input a0, a1, a2, a3, a4;
	output out;

	and2$ and1(t0, a0, a1);
	and2$ and2(t1, a2, a3);
	and3$ and3(out, t0, t1, a4);
endmodule

module and7$(out, a0, a1, a2, a3, a4, a5, a6);
	input a0, a1, a2, a3, a4, a5, a6;
	output out;

	and5$ and1(t0, a0, a1, a2, a3, a4);
	and2$ and2(t1, a5, a6);
	and2$ and3(out, t0, t1);
endmodule

module and2_32(out, a, b);
	input[31:0] a, b;
	output[31:0] out;

	and2_16 and1(out[15:0], a[15:0], b[15:0]);
	and2_16 and2(out[31:16], a[31:16], b[31:16]);
endmodule

module and2_16(out, a, b);
	input[15:0] a, b;
	output[15:0] out;

	and2_8 and1(out[7:0], a[7:0], b[7:0]);
	and2_8 and2(out[15:8], a[15:8], b[15:8]);
endmodule

module and2_8(out, a, b);
	input[7:0] a, b;
	output[7:0] out;

	and2$ and1(out[7], a[7], b[7]);
	and2$ and2(out[6], a[6], b[6]);
	and2$ and3(out[5], a[5], b[5]);
	and2$ and4(out[4], a[4], b[4]);
	and2$ and5(out[3], a[3], b[3]);
	and2$ and6(out[2], a[2], b[2]);
	and2$ and7(out[1], a[1], b[1]);
	and2$ and8(out[0], a[0], b[0]);
endmodule

module add2_8(a, b, out, cout);
	input[7:0] a, b;
	output[7:0] out;
	output cout;

	wire cout1;

	//module alu4$(a,b,cin,m,s,cout,out);
	alu4$ alu2(a[7:4], b[7:4], cout1, 1'b1, 4'd9, cout, out[7:4]);
	alu4$ alu1(a[3:0], b[3:0], 1'b0, 1'b1, 4'd9, cout1, out[3:0]);
endmodule

module dec_2(in, out);
	input[1:0] in;
	output[1:0] out;

	wire[3:0] out4;

	alu4$ alu1({2'b0, in}, {4'b0011}, 1'b0, 1'b1, 4'd9, , out4);
	assign out = out4[1:0];
endmodule

module or2_32(out, a, b);
	input[31:0] a, b;
	output[31:0] out;

	or2$ or1(out[0], a[0], b[0]);
	or2$ or2(out[1], a[1], b[1]);
	or2$ or3(out[2], a[2], b[2]);
	or2$ or4(out[3], a[3], b[3]);
	or2$ or5(out[4], a[4], b[4]);
	or2$ or6(out[5], a[5], b[5]);
	or2$ or7(out[6], a[6], b[6]);
	or2$ or8(out[7], a[7], b[7]);
	or2$ or9(out[8], a[8], b[8]);
	or2$ or10(out[9], a[9], b[9]);
	or2$ or11(out[10], a[10], b[10]);
	or2$ or12(out[11], a[11], b[11]);
	or2$ or13(out[12], a[12], b[12]);
	or2$ or14(out[13], a[13], b[13]);
	or2$ or15(out[14], a[14], b[14]);
	or2$ or16(out[15], a[15], b[15]);
	or2$ or17(out[16], a[16], b[16]);
	or2$ or18(out[17], a[17], b[17]);
	or2$ or19(out[18], a[18], b[18]);
	or2$ or20(out[19], a[19], b[19]);
	or2$ or21(out[20], a[20], b[20]);
	or2$ or22(out[21], a[21], b[21]);
	or2$ or23(out[22], a[22], b[22]);
	or2$ or24(out[23], a[23], b[23]);
	or2$ or25(out[24], a[24], b[24]);
	or2$ or26(out[25], a[25], b[25]);
	or2$ or27(out[26], a[26], b[26]);
	or2$ or28(out[27], a[27], b[27]);
	or2$ or29(out[28], a[28], b[28]);
	or2$ or30(out[29], a[29], b[29]);
	or2$ or31(out[30], a[30], b[30]);
	or2$ or32(out[31], a[31], b[31]);
endmodule

module xor8(out, in);
	input[7:0] in;
	output out;

	wire s1, s2, s3, s4, s5, s6, s7;

	xor2$ xor1(s1, in[7], in[6]);
	xor2$ xor2(s2, in[5], in[4]);
	xor2$ xor3(s3, in[3], in[2]);
	xor2$ xor4(s4, in[1], in[0]);
	xor2$ xor5(s5, s1, s2);
	xor2$ xor6(s6, s3, s4);
	xor2$ xor7(s7, s5, s6);
	inv1$ inv1(out, s7);
endmodule

module regfile16x6(row, col, DataIn, we, DataOut, clk, clr);
	input[1:0] DataIn;
	input[1:0] col;
	input[3:0] row;
	input we, clk, clr;
	output[5:0] DataOut; // two cache coherency bits [Way0, Way1, Way2, Reserved]

	wire ld_00, ld_01, ld_02, ld_10, ld_11, ld_12, ld_20, ld_21, ld_22, ld_30, ld_31, ld_32, ld_40, ld_41, ld_42, ld_50, ld_51, ld_52, ld_60, ld_61, ld_62, ld_70, ld_71, ld_72, ld_80, ld_81, ld_82, ld_90, ld_91, ld_92, ld_a0, ld_a1, ld_a2, ld_b0, ld_b1, ld_b2, ld_c0, ld_c1, ld_c2, ld_e0, ld_e1, ld_e2, ld_d0, ld_d1, ld_d2, ld_f0, ld_f1, ld_f2;
	wire[1:0] cc_00, cc_01, cc_02, cc_10, cc_11, cc_12, cc_20, cc_21, cc_22, cc_30, cc_31, cc_32, cc_40, cc_41, cc_42, cc_50, cc_51, cc_52, cc_60, cc_61, cc_62, cc_70, cc_71, cc_72, cc_80, cc_81, cc_82, cc_90, cc_91, cc_92, cc_a0, cc_a1, cc_a2, cc_b0, cc_b1, cc_b2, cc_c0, cc_c1, cc_c2, cc_e0, cc_e1, cc_e2, cc_d0, cc_d1, cc_d2, cc_f0, cc_f1, cc_f2;
	wire[5:0] cc_0, cc_1, cc_2, cc_3, cc_4, cc_5, cc_6, cc_7, cc_8, cc_9, cc_a, cc_b, cc_c, cc_d, cc_e, cc_f;
	wire[5:0] temp_dataout1, temp_dataout2, temp_dataout3, temp_dataout4;

	assign ld_00 = we & ~row[3] & ~row[2] & ~row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_01 = we & ~row[3] & ~row[2] & ~row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_02 = we & ~row[3] & ~row[2] & ~row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_10 = we & ~row[3] & ~row[2] & ~row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_11 = we & ~row[3] & ~row[2] & ~row[1] & row[0] & ~col[1] & col[0];
	assign ld_12 = we & ~row[3] & ~row[2] & ~row[1] & row[0] & col[1] & ~col[0];
	assign ld_20 = we & ~row[3] & ~row[2] & row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_21 = we & ~row[3] & ~row[2] & row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_22 = we & ~row[3] & ~row[2] & row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_30 = we & ~row[3] & ~row[2] & row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_31 = we & ~row[3] & ~row[2] & row[1] & row[0] & ~col[1] & col[0];
	assign ld_32 = we & ~row[3] & ~row[2] & row[1] & row[0] & col[1] & ~col[0];
	assign ld_40 = we & ~row[3] & row[2] & ~row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_41 = we & ~row[3] & row[2] & ~row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_42 = we & ~row[3] & row[2] & ~row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_50 = we & ~row[3] & row[2] & ~row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_51 = we & ~row[3] & row[2] & ~row[1] & row[0] & ~col[1] & col[0];
	assign ld_52 = we & ~row[3] & row[2] & ~row[1] & row[0] & col[1] & ~col[0];
	assign ld_60 = we & ~row[3] & row[2] & row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_61 = we & ~row[3] & row[2] & row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_62 = we & ~row[3] & row[2] & row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_70 = we & ~row[3] & row[2] & row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_71 = we & ~row[3] & row[2] & row[1] & row[0] & ~col[1] & col[0];
	assign ld_72 = we & ~row[3] & row[2] & row[1] & row[0] & col[1] & ~col[0];
	assign ld_80 = we & row[3] & ~row[2] & ~row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_81 = we & row[3] & ~row[2] & ~row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_82 = we & row[3] & ~row[2] & ~row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_90 = we & row[3] & ~row[2] & ~row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_91 = we & row[3] & ~row[2] & ~row[1] & row[0] & ~col[1] & col[0];
	assign ld_92 = we & row[3] & ~row[2] & ~row[1] & row[0] & col[1] & ~col[0];
	assign ld_a0 = we & row[3] & ~row[2] & row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_a1 = we & row[3] & ~row[2] & row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_a2 = we & row[3] & ~row[2] & row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_b0 = we & row[3] & ~row[2] & row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_b1 = we & row[3] & ~row[2] & row[1] & row[0] & ~col[1] & col[0];
	assign ld_b2 = we & row[3] & ~row[2] & row[1] & row[0] & col[1] & ~col[0];
	assign ld_c0 = we & row[3] & row[2] & ~row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_c1 = we & row[3] & row[2] & ~row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_c2 = we & row[3] & row[2] & ~row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_d0 = we & row[3] & row[2] & ~row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_d1 = we & row[3] & row[2] & ~row[1] & row[0] & ~col[1] & col[0];
	assign ld_d2 = we & row[3] & row[2] & ~row[1] & row[0] & col[1] & ~col[0];
	assign ld_e0 = we & row[3] & row[2] & row[1] & ~row[0] & ~col[1] & ~col[0];
	assign ld_e1 = we & row[3] & row[2] & row[1] & ~row[0] & ~col[1] & col[0];
	assign ld_e2 = we & row[3] & row[2] & row[1] & ~row[0] & col[1] & ~col[0];
	assign ld_f0 = we & row[3] & row[2] & row[1] & row[0] & ~col[1] & ~col[0];
	assign ld_f1 = we & row[3] & row[2] & row[1] & row[0] & ~col[1] & col[0];
	assign ld_f2 = we & row[3] & row[2] & row[1] & row[0] & col[1] & ~col[0];

	// coherencystate_set_way
	dff_2 dff_00(clk, DataIn, cc_00, clr, ld_00);
	dff_2 dff_01(clk, DataIn, cc_01, clr, ld_01);
	dff_2 dff_02(clk, DataIn, cc_02, clr, ld_02);

	dff_2 dff_10(clk, DataIn, cc_10, clr, ld_10);
	dff_2 dff_11(clk, DataIn, cc_11, clr, ld_11);
	dff_2 dff_12(clk, DataIn, cc_12, clr, ld_12);

	dff_2 dff_20(clk, DataIn, cc_20, clr, ld_20);
	dff_2 dff_21(clk, DataIn, cc_21, clr, ld_21);
	dff_2 dff_22(clk, DataIn, cc_22, clr, ld_22);

	dff_2 dff_30(clk, DataIn, cc_30, clr, ld_30);
	dff_2 dff_31(clk, DataIn, cc_31, clr, ld_31);
	dff_2 dff_32(clk, DataIn, cc_32, clr, ld_32);

	dff_2 dff_40(clk, DataIn, cc_40, clr, ld_40);
	dff_2 dff_41(clk, DataIn, cc_41, clr, ld_41);
	dff_2 dff_42(clk, DataIn, cc_42, clr, ld_42);

	dff_2 dff_50(clk, DataIn, cc_50, clr, ld_50);
	dff_2 dff_51(clk, DataIn, cc_51, clr, ld_51);
	dff_2 dff_52(clk, DataIn, cc_52, clr, ld_52);

	dff_2 dff_60(clk, DataIn, cc_60, clr, ld_60);
	dff_2 dff_61(clk, DataIn, cc_61, clr, ld_61);
	dff_2 dff_62(clk, DataIn, cc_62, clr, ld_62);

	dff_2 dff_70(clk, DataIn, cc_70, clr, ld_70);
	dff_2 dff_71(clk, DataIn, cc_71, clr, ld_71);
	dff_2 dff_72(clk, DataIn, cc_72, clr, ld_72);

	dff_2 dff_80(clk, DataIn, cc_80, clr, ld_80);
	dff_2 dff_81(clk, DataIn, cc_81, clr, ld_81);
	dff_2 dff_82(clk, DataIn, cc_82, clr, ld_82);

	dff_2 dff_90(clk, DataIn, cc_90, clr, ld_90);
	dff_2 dff_91(clk, DataIn, cc_91, clr, ld_91);
	dff_2 dff_92(clk, DataIn, cc_92, clr, ld_92);

	dff_2 dff_a0(clk, DataIn, cc_a0, clr, ld_a0);
	dff_2 dff_a1(clk, DataIn, cc_a1, clr, ld_a1);
	dff_2 dff_a2(clk, DataIn, cc_a2, clr, ld_a2);

	dff_2 dff_b0(clk, DataIn, cc_b0, clr, ld_b0);
	dff_2 dff_b1(clk, DataIn, cc_b1, clr, ld_b1);
	dff_2 dff_b2(clk, DataIn, cc_b2, clr, ld_b2);

	dff_2 dff_c0(clk, DataIn, cc_c0, clr, ld_c0);
	dff_2 dff_c1(clk, DataIn, cc_c1, clr, ld_c1);
	dff_2 dff_c2(clk, DataIn, cc_c2, clr, ld_c2);

	dff_2 dff_d0(clk, DataIn, cc_d0, clr, ld_d0);
	dff_2 dff_d1(clk, DataIn, cc_d1, clr, ld_d1);
	dff_2 dff_d2(clk, DataIn, cc_d2, clr, ld_d2);

	dff_2 dff_e0(clk, DataIn, cc_e0, clr, ld_e0);
	dff_2 dff_e1(clk, DataIn, cc_e1, clr, ld_e1);
	dff_2 dff_e2(clk, DataIn, cc_e2, clr, ld_e2);

	dff_2 dff_f0(clk, DataIn, cc_f0, clr, ld_f0);
	dff_2 dff_f1(clk, DataIn, cc_f1, clr, ld_f1);
	dff_2 dff_f2(clk, DataIn, cc_f2, clr, ld_f2);

	assign cc_0 = {cc_02, cc_01, cc_00};
	assign cc_1 = {cc_12, cc_11, cc_10};
	assign cc_2 = {cc_22, cc_21, cc_20};
	assign cc_3 = {cc_32, cc_31, cc_30};
	assign cc_4 = {cc_42, cc_41, cc_40};
	assign cc_5 = {cc_52, cc_51, cc_50};
	assign cc_6 = {cc_62, cc_61, cc_60};
	assign cc_7 = {cc_72, cc_71, cc_70};
	assign cc_8 = {cc_82, cc_81, cc_80};
	assign cc_9 = {cc_92, cc_91, cc_90};
	assign cc_a = {cc_a2, cc_a1, cc_a0};
	assign cc_b = {cc_b2, cc_b1, cc_b0};
	assign cc_c = {cc_c2, cc_c1, cc_c0};
	assign cc_d = {cc_d2, cc_d1, cc_d0};
	assign cc_e = {cc_e2, cc_e1, cc_e0};
	assign cc_f = {cc_f2, cc_f1, cc_f0};

	mux4_6 mux1(temp_dataout1, cc_0, cc_2, cc_1, cc_3, row[1:0]);
	mux4_6 mux2(temp_dataout2, cc_4, cc_6, cc_5, cc_7, row[1:0]);
	mux4_6 mux3(temp_dataout3, cc_8, cc_a, cc_9, cc_b, row[1:0]);
	mux4_6 mux4(temp_dataout4, cc_c, cc_e, cc_d, cc_f, row[1:0]);
	mux4_6 mux5(DataOut, temp_dataout1, temp_dataout3, temp_dataout2, temp_dataout4, row[3:2]);
endmodule

module sram128x16x32 (Address, DataIO, WR_in, we, OE);
	inout[31:0] DataIO;
	input[10:0] Address;
	input[3:0]  we;
	input       WR_in;  // 0-write, 1-read
    input       OE;     // 1-high z

	wire[15:0] WR_block;
    wire write = ~WR_in;
	wire[31:0] DataIO0, DataIO1, DataIO2, DataIO3, DataIO4, DataIO5, DataIO6, DataIO7, DataIO8, DataIO9, DataIOa, DataIOb, DataIOc, DataIOd, DataIOe, DataIOf;
	wire[7:0] DataIO0_0, DataIO0_1, DataIO0_2, DataIO0_3, DataIO1_0, DataIO1_1, DataIO1_2, DataIO1_3, DataIO2_0, DataIO2_1, DataIO2_2, DataIO2_3, DataIO3_0, DataIO3_1, DataIO3_2, DataIO3_3, DataIO4_0, DataIO4_1, DataIO4_2, DataIO4_3, DataIO5_0, DataIO5_1, DataIO5_2, DataIO5_3, DataIO6_0, DataIO6_1, DataIO6_2, DataIO6_3, DataIO7_0, DataIO7_1, DataIO7_2, DataIO7_3, DataIO8_0, DataIO8_1, DataIO8_2, DataIO8_3, DataIO9_0, DataIO9_1, DataIO9_2, DataIO9_3, DataIOa_0, DataIOa_1, DataIOa_2, DataIOa_3, DataIOb_0, DataIOb_1, DataIOb_2, DataIOb_3, DataIOc_0, DataIOc_1, DataIOc_2, DataIOc_3, DataIOd_0, DataIOd_1, DataIOd_2, DataIOd_3, DataIOe_0, DataIOe_1, DataIOe_2, DataIOe_3, DataIOf_0, DataIOf_1, DataIOf_2, DataIOf_3;
	wire WR0_0, WR0_1, WR0_2, WR0_3;
	wire WR1_0, WR1_1, WR1_2, WR1_3;
	wire WR2_0, WR2_1, WR2_2, WR2_3;
	wire WR3_0, WR3_1, WR3_2, WR3_3;
	wire WR4_0, WR4_1, WR4_2, WR4_3;
	wire WR5_0, WR5_1, WR5_2, WR5_3;
	wire WR6_0, WR6_1, WR6_2, WR6_3;
	wire WR7_0, WR7_1, WR7_2, WR7_3;
	wire WR8_0, WR8_1, WR8_2, WR8_3;
	wire WR9_0, WR9_1, WR9_2, WR9_3;
	wire WRa_0, WRa_1, WRa_2, WRa_3;
	wire WRb_0, WRb_1, WRb_2, WRb_3;
	wire WRc_0, WRc_1, WRc_2, WRc_3;
	wire WRd_0, WRd_1, WRd_2, WRd_3;
	wire WRe_0, WRe_1, WRe_2, WRe_3;
	wire WRf_0, WRf_1, WRf_2, WRf_3;
	wire neg_WR0_0, neg_WR0_1, neg_WR0_2, neg_WR0_3;
	wire neg_WR1_0, neg_WR1_1, neg_WR1_2, neg_WR1_3;
	wire neg_WR2_0, neg_WR2_1, neg_WR2_2, neg_WR2_3;
	wire neg_WR3_0, neg_WR3_1, neg_WR3_2, neg_WR3_3;
	wire neg_WR4_0, neg_WR4_1, neg_WR4_2, neg_WR4_3;
	wire neg_WR5_0, neg_WR5_1, neg_WR5_2, neg_WR5_3;
	wire neg_WR6_0, neg_WR6_1, neg_WR6_2, neg_WR6_3;
	wire neg_WR7_0, neg_WR7_1, neg_WR7_2, neg_WR7_3;
	wire neg_WR8_0, neg_WR8_1, neg_WR8_2, neg_WR8_3;
	wire neg_WR9_0, neg_WR9_1, neg_WR9_2, neg_WR9_3;
	wire neg_WRa_0, neg_WRa_1, neg_WRa_2, neg_WRa_3;
	wire neg_WRb_0, neg_WRb_1, neg_WRb_2, neg_WRb_3;
	wire neg_WRc_0, neg_WRc_1, neg_WRc_2, neg_WRc_3;
	wire neg_WRd_0, neg_WRd_1, neg_WRd_2, neg_WRd_3;
	wire neg_WRe_0, neg_WRe_1, neg_WRe_2, neg_WRe_3;
	wire neg_WRf_0, neg_WRf_1, neg_WRf_2, neg_WRf_3;

   
    //----------------------------------
    // Output Data
    //----------------------------------
    wire [31:0] DataOut0;
    wire [31:0] DataOut1;
    wire [31:0] DataOut2;
    wire [31:0] DataOut3;
    wire [31:0] DataOut4;
    wire [31:0] DataOut5;
    wire [31:0] DataOut6;
    wire [31:0] DataOut7;
    wire [31:0] DataOut8;
    wire [31:0] DataOut9;
    wire [31:0] DataOuta;
    wire [31:0] DataOutb;
    wire [31:0] DataOutc;
    wire [31:0] DataOutd;
    wire [31:0] DataOute;
    wire [31:0] DataOutf;


	assign DataOut0 = {DataIO0_0, DataIO0_1, DataIO0_2, DataIO0_3};
	assign DataOut1 = {DataIO1_0, DataIO1_1, DataIO1_2, DataIO1_3};
	assign DataOut2 = {DataIO2_0, DataIO2_1, DataIO2_2, DataIO2_3};
	assign DataOut3 = {DataIO3_0, DataIO3_1, DataIO3_2, DataIO3_3};
	assign DataOut4 = {DataIO4_0, DataIO4_1, DataIO4_2, DataIO4_3};
	assign DataOut5 = {DataIO5_0, DataIO5_1, DataIO5_2, DataIO5_3};
	assign DataOut6 = {DataIO6_0, DataIO6_1, DataIO6_2, DataIO6_3};
	assign DataOut7 = {DataIO7_0, DataIO7_1, DataIO7_2, DataIO7_3};
	assign DataOut8 = {DataIO8_0, DataIO8_1, DataIO8_2, DataIO8_3};
	assign DataOut9 = {DataIO9_0, DataIO9_1, DataIO9_2, DataIO9_3};
	assign DataOuta = {DataIOa_0, DataIOa_1, DataIOa_2, DataIOa_3};
	assign DataOutb = {DataIOb_0, DataIOb_1, DataIOb_2, DataIOb_3};
	assign DataOutc = {DataIOc_0, DataIOc_1, DataIOc_2, DataIOc_3};
	assign DataOutd = {DataIOd_0, DataIOd_1, DataIOd_2, DataIOd_3};
	assign DataOute = {DataIOe_0, DataIOe_1, DataIOe_2, DataIOe_3};
	assign DataOutf = {DataIOf_0, DataIOf_1, DataIOf_2, DataIOf_3};

    wire [31:0] DataOut;
    wire [31:0] DataOut_1;
    wire [31:0] DataOut_2;
    wire [31:0] DataOut_3;
    wire [31:0] DataOut_4;
	mux4_32 mux1(DataOut_1, DataOut0, DataOut2, DataOut1, DataOut3, Address[8:7]);
	mux4_32 mux2(DataOut_2, DataOut4, DataOut6, DataOut5, DataOut7, Address[8:7]);
	mux4_32 mux3(DataOut_3, DataOut8, DataOuta, DataOut9, DataOutb, Address[8:7]);
	mux4_32 mux4(DataOut_4, DataOutc, DataOute, DataOutd, DataOutf, Address[8:7]);
	mux4_32 mux5(DataOut, DataOut_1, DataOut_3, DataOut_2, DataOut_4, Address[10:9]);

    tristate32L tri_dataOut(OE, DataOut, DataIO);


    //-----------------------------------
    //  Input Data
    //-----------------------------------
    wire recv_data;
    inv1$ inv1(recv_data, OE);
    tristate32L tri_dataIO0(recv_data, DataIO, DataIO0); 
    tristate32L tri_dataIO1(recv_data, DataIO, DataIO1); 
    tristate32L tri_dataIO2(recv_data, DataIO, DataIO2); 
    tristate32L tri_dataIO3(recv_data, DataIO, DataIO3); 
    tristate32L tri_dataIO4(recv_data, DataIO, DataIO4); 
    tristate32L tri_dataIO5(recv_data, DataIO, DataIO5); 
    tristate32L tri_dataIO6(recv_data, DataIO, DataIO6); 
    tristate32L tri_dataIO7(recv_data, DataIO, DataIO7); 
    tristate32L tri_dataIO8(recv_data, DataIO, DataIO8); 
    tristate32L tri_dataIO9(recv_data, DataIO, DataIO9); 
    tristate32L tri_dataIOa(recv_data, DataIO, DataIOa); 
    tristate32L tri_dataIOb(recv_data, DataIO, DataIOb); 
    tristate32L tri_dataIOc(recv_data, DataIO, DataIOc); 
    tristate32L tri_dataIOd(recv_data, DataIO, DataIOd); 
    tristate32L tri_dataIOe(recv_data, DataIO, DataIOe); 
    tristate32L tri_dataIOf(recv_data, DataIO, DataIOf); 

    tristate8L$ tri_dataIO0_0(recv_data, DataIO0[31:24], DataIO0_3); 
    tristate8L$ tri_dataIO0_1(recv_data, DataIO0[23:16], DataIO0_2); 
    tristate8L$ tri_dataIO0_2(recv_data, DataIO0[15:8],  DataIO0_1); 
    tristate8L$ tri_dataIO0_3(recv_data, DataIO0[7:0],   DataIO0_0); 
    
    tristate8L$ tri_dataIO1_0(recv_data, DataIO1[31:24], DataIO1_3); 
    tristate8L$ tri_dataIO1_1(recv_data, DataIO1[23:16], DataIO1_2); 
    tristate8L$ tri_dataIO1_2(recv_data, DataIO1[15:8],  DataIO1_1); 
    tristate8L$ tri_dataIO1_3(recv_data, DataIO1[7:0],   DataIO1_0); 
    
    tristate8L$ tri_dataIO2_0(recv_data, DataIO2[31:24], DataIO2_3); 
    tristate8L$ tri_dataIO2_1(recv_data, DataIO2[23:16], DataIO2_2); 
    tristate8L$ tri_dataIO2_2(recv_data, DataIO2[15:8],  DataIO2_1); 
    tristate8L$ tri_dataIO2_3(recv_data, DataIO2[7:0],   DataIO2_0); 
    
    tristate8L$ tri_dataIO3_0(recv_data, DataIO3[31:24], DataIO3_3); 
    tristate8L$ tri_dataIO3_1(recv_data, DataIO3[23:16], DataIO3_2); 
    tristate8L$ tri_dataIO3_2(recv_data, DataIO3[15:8],  DataIO3_1); 
    tristate8L$ tri_dataIO3_3(recv_data, DataIO3[7:0],   DataIO3_0); 
    
    tristate8L$ tri_dataIO4_0(recv_data, DataIO4[31:24], DataIO4_3); 
    tristate8L$ tri_dataIO4_1(recv_data, DataIO4[23:16], DataIO4_2); 
    tristate8L$ tri_dataIO4_2(recv_data, DataIO4[15:8],  DataIO4_1); 
    tristate8L$ tri_dataIO4_3(recv_data, DataIO4[7:0],   DataIO4_0); 
 
    tristate8L$ tri_dataIO5_0(recv_data, DataIO5[31:24], DataIO5_3); 
    tristate8L$ tri_dataIO5_1(recv_data, DataIO5[23:16], DataIO5_2); 
    tristate8L$ tri_dataIO5_2(recv_data, DataIO5[15:8],  DataIO5_1); 
    tristate8L$ tri_dataIO5_3(recv_data, DataIO5[7:0],   DataIO5_0); 

    tristate8L$ tri_dataIO6_0(recv_data, DataIO6[31:24], DataIO6_3); 
    tristate8L$ tri_dataIO6_1(recv_data, DataIO6[23:16], DataIO6_2); 
    tristate8L$ tri_dataIO6_2(recv_data, DataIO6[15:8],  DataIO6_1); 
    tristate8L$ tri_dataIO6_3(recv_data, DataIO6[7:0],   DataIO6_0); 
    
    tristate8L$ tri_dataIO7_0(recv_data, DataIO7[31:24], DataIO7_3); 
    tristate8L$ tri_dataIO7_1(recv_data, DataIO7[23:16], DataIO7_2); 
    tristate8L$ tri_dataIO7_2(recv_data, DataIO7[15:8],  DataIO7_1); 
    tristate8L$ tri_dataIO7_3(recv_data, DataIO7[7:0],   DataIO7_0); 
 
    tristate8L$ tri_dataIO8_0(recv_data, DataIO8[31:24], DataIO8_3); 
    tristate8L$ tri_dataIO8_1(recv_data, DataIO8[23:16], DataIO8_2); 
    tristate8L$ tri_dataIO8_2(recv_data, DataIO8[15:8],  DataIO8_1); 
    tristate8L$ tri_dataIO8_3(recv_data, DataIO8[7:0],   DataIO8_0); 
 
    tristate8L$ tri_dataIO9_0(recv_data, DataIO9[31:24], DataIO9_3); 
    tristate8L$ tri_dataIO9_1(recv_data, DataIO9[23:16], DataIO9_2); 
    tristate8L$ tri_dataIO9_2(recv_data, DataIO9[15:8],  DataIO9_1); 
    tristate8L$ tri_dataIO9_3(recv_data, DataIO9[7:0],   DataIO9_0); 

    tristate8L$ tri_dataIOa_0(recv_data, DataIOa[31:24], DataIOa_3); 
    tristate8L$ tri_dataIOa_1(recv_data, DataIOa[23:16], DataIOa_2); 
    tristate8L$ tri_dataIOa_2(recv_data, DataIOa[15:8],  DataIOa_1); 
    tristate8L$ tri_dataIOa_3(recv_data, DataIOa[7:0],   DataIOa_0); 
    
    tristate8L$ tri_dataIOb_0(recv_data, DataIOb[31:24], DataIOb_3); 
    tristate8L$ tri_dataIOb_1(recv_data, DataIOb[23:16], DataIOb_2); 
    tristate8L$ tri_dataIOb_2(recv_data, DataIOb[15:8],  DataIOb_1); 
    tristate8L$ tri_dataIOb_3(recv_data, DataIOb[7:0],   DataIOb_0); 
 
    tristate8L$ tri_dataIOc_0(recv_data, DataIOc[31:24], DataIOc_3); 
    tristate8L$ tri_dataIOc_1(recv_data, DataIOc[23:16], DataIOc_2); 
    tristate8L$ tri_dataIOc_2(recv_data, DataIOc[15:8],  DataIOc_1); 
    tristate8L$ tri_dataIOc_3(recv_data, DataIOc[7:0],   DataIOc_0); 
 
    tristate8L$ tri_dataIOd_0(recv_data, DataIOd[31:24], DataIOd_3); 
    tristate8L$ tri_dataIOd_1(recv_data, DataIOd[23:16], DataIOd_2); 
    tristate8L$ tri_dataIOd_2(recv_data, DataIOd[15:8],  DataIOd_1); 
    tristate8L$ tri_dataIOd_3(recv_data, DataIOd[7:0],   DataIOd_0); 

    tristate8L$ tri_dataIOe_0(recv_data, DataIOe[31:24], DataIOe_3); 
    tristate8L$ tri_dataIOe_1(recv_data, DataIOe[23:16], DataIOe_2); 
    tristate8L$ tri_dataIOe_2(recv_data, DataIOe[15:8],  DataIOe_1); 
    tristate8L$ tri_dataIOe_3(recv_data, DataIOe[7:0],   DataIOe_0); 
    
    tristate8L$ tri_dataIOf_0(recv_data, DataIOf[31:24], DataIOf_3); 
    tristate8L$ tri_dataIOf_1(recv_data, DataIOf[23:16], DataIOf_2); 
    tristate8L$ tri_dataIOf_2(recv_data, DataIOf[15:8],  DataIOf_1); 
    tristate8L$ tri_dataIOf_3(recv_data, DataIOf[7:0],   DataIOf_0); 
 
    
	decoder4_16 decode1(Address[10:7], WR_block);
	assign neg_WR0_0 = write & WR_block[0] & we[0];
	assign neg_WR0_1 = write & WR_block[0] & we[1];
	assign neg_WR0_2 = write & WR_block[0] & we[2];
	assign neg_WR0_3 = write & WR_block[0] & we[3];

	assign neg_WR1_0 = write & WR_block[1] & we[0];
	assign neg_WR1_1 = write & WR_block[1] & we[1];
	assign neg_WR1_2 = write & WR_block[1] & we[2];
	assign neg_WR1_3 = write & WR_block[1] & we[3];

	assign neg_WR2_0 = write & WR_block[2] & we[0];
	assign neg_WR2_1 = write & WR_block[2] & we[1];
	assign neg_WR2_2 = write & WR_block[2] & we[2];
	assign neg_WR2_3 = write & WR_block[2] & we[3];

	assign neg_WR3_0 = write & WR_block[3] & we[0];
	assign neg_WR3_1 = write & WR_block[3] & we[1];
	assign neg_WR3_2 = write & WR_block[3] & we[2];
	assign neg_WR3_3 = write & WR_block[3] & we[3];

	assign neg_WR4_0 = write & WR_block[4] & we[0];
	assign neg_WR4_1 = write & WR_block[4] & we[1];
	assign neg_WR4_2 = write & WR_block[4] & we[2];
	assign neg_WR4_3 = write & WR_block[4] & we[3];

	assign neg_WR5_0 = write & WR_block[5] & we[0];
	assign neg_WR5_1 = write & WR_block[5] & we[1];
	assign neg_WR5_2 = write & WR_block[5] & we[2];
	assign neg_WR5_3 = write & WR_block[5] & we[3];

	assign neg_WR6_0 = write & WR_block[6] & we[0];
	assign neg_WR6_1 = write & WR_block[6] & we[1];
	assign neg_WR6_2 = write & WR_block[6] & we[2];
	assign neg_WR6_3 = write & WR_block[6] & we[3];

	assign neg_WR7_0 = write & WR_block[7] & we[0];
	assign neg_WR7_1 = write & WR_block[7] & we[1];
	assign neg_WR7_2 = write & WR_block[7] & we[2];
	assign neg_WR7_3 = write & WR_block[7] & we[3];

	assign neg_WR8_0 = write & WR_block[8] & we[0];
	assign neg_WR8_1 = write & WR_block[8] & we[1];
	assign neg_WR8_2 = write & WR_block[8] & we[2];
	assign neg_WR8_3 = write & WR_block[8] & we[3];

	assign neg_WR9_0 = write & WR_block[9] & we[0];
	assign neg_WR9_1 = write & WR_block[9] & we[1];
	assign neg_WR9_2 = write & WR_block[9] & we[2];
	assign neg_WR9_3 = write & WR_block[9] & we[3];

	assign neg_WRa_0 = write & WR_block[10] & we[0];
	assign neg_WRa_1 = write & WR_block[10] & we[1];
	assign neg_WRa_2 = write & WR_block[10] & we[2];
	assign neg_WRa_3 = write & WR_block[10] & we[3];

	assign neg_WRb_0 = write & WR_block[11] & we[0];
	assign neg_WRb_1 = write & WR_block[11] & we[1];
	assign neg_WRb_2 = write & WR_block[11] & we[2];
	assign neg_WRb_3 = write & WR_block[11] & we[3];

	assign neg_WRc_0 = write & WR_block[12] & we[0];
	assign neg_WRc_1 = write & WR_block[12] & we[1];
	assign neg_WRc_2 = write & WR_block[12] & we[2];
	assign neg_WRc_3 = write & WR_block[12] & we[3];

	assign neg_WRd_0 = write & WR_block[13] & we[0];
	assign neg_WRd_1 = write & WR_block[13] & we[1];
	assign neg_WRd_2 = write & WR_block[13] & we[2];
	assign neg_WRd_3 = write & WR_block[13] & we[3];

	assign neg_WRe_0 = write & WR_block[14] & we[0];
	assign neg_WRe_1 = write & WR_block[14] & we[1];
	assign neg_WRe_2 = write & WR_block[14] & we[2];
	assign neg_WRe_3 = write & WR_block[14] & we[3];

	assign neg_WRf_0 = write & WR_block[15] & we[0];
	assign neg_WRf_1 = write & WR_block[15] & we[1];
	assign neg_WRf_2 = write & WR_block[15] & we[2];
	assign neg_WRf_3 = write & WR_block[15] & we[3];

	inv1$ inv1_1(WR0_0, neg_WR0_0);
	inv1$ inv1_2(WR0_1, neg_WR0_1);
	inv1$ inv1_3(WR0_2, neg_WR0_2);
	inv1$ inv1_4(WR0_3, neg_WR0_3);

	inv1$ inv2_1(WR1_0, neg_WR1_0);
	inv1$ inv2_2(WR1_1, neg_WR1_1);
	inv1$ inv2_3(WR1_2, neg_WR1_2);
	inv1$ inv2_4(WR1_3, neg_WR1_3);

	inv1$ inv3_1(WR2_0, neg_WR2_0);
	inv1$ inv3_2(WR2_1, neg_WR2_1);
	inv1$ inv3_3(WR2_2, neg_WR2_2);
	inv1$ inv3_4(WR2_3, neg_WR2_3);

	inv1$ inv4_1(WR3_0, neg_WR3_0);
	inv1$ inv4_2(WR3_1, neg_WR3_1);
	inv1$ inv4_3(WR3_2, neg_WR3_2);
	inv1$ inv4_4(WR3_3, neg_WR3_3);

	inv1$ inv5_1(WR4_0, neg_WR4_0);
	inv1$ inv5_2(WR4_1, neg_WR4_1);
	inv1$ inv5_3(WR4_2, neg_WR4_2);
	inv1$ inv5_4(WR4_3, neg_WR4_3);

	inv1$ inv6_1(WR5_0, neg_WR5_0);
	inv1$ inv6_2(WR5_1, neg_WR5_1);
	inv1$ inv6_3(WR5_2, neg_WR5_2);
	inv1$ inv6_4(WR5_3, neg_WR5_3);

	inv1$ inv7_1(WR6_0, neg_WR6_0);
	inv1$ inv7_2(WR6_1, neg_WR6_1);
	inv1$ inv7_3(WR6_2, neg_WR6_2);
	inv1$ inv7_4(WR6_3, neg_WR6_3);

	inv1$ inv8_1(WR7_0, neg_WR7_0);
	inv1$ inv8_2(WR7_1, neg_WR7_1);
	inv1$ inv8_3(WR7_2, neg_WR7_2);
	inv1$ inv8_4(WR7_3, neg_WR7_3);

	inv1$ inv9_1(WR8_0, neg_WR8_0);
	inv1$ inv9_2(WR8_1, neg_WR8_1);
	inv1$ inv9_3(WR8_2, neg_WR8_2);
	inv1$ inv9_4(WR8_3, neg_WR8_3);

	inv1$ inva_1(WR9_0, neg_WR9_0);
	inv1$ inva_2(WR9_1, neg_WR9_1);
	inv1$ inva_3(WR9_2, neg_WR9_2);
	inv1$ inva_4(WR9_3, neg_WR9_3);

	inv1$ invb_1(WRa_0, neg_WRa_0);
	inv1$ invb_2(WRa_1, neg_WRa_1);
	inv1$ invb_3(WRa_2, neg_WRa_2);
	inv1$ invb_4(WRa_3, neg_WRa_3);

	inv1$ invc_1(WRb_0, neg_WRb_0);
	inv1$ invc_2(WRb_1, neg_WRb_1);
	inv1$ invc_3(WRb_2, neg_WRb_2);
	inv1$ invc_4(WRb_3, neg_WRb_3);

	inv1$ invd_1(WRc_0, neg_WRc_0);
	inv1$ invd_2(WRc_1, neg_WRc_1);
	inv1$ invd_3(WRc_2, neg_WRc_2);
	inv1$ invd_4(WRc_3, neg_WRc_3);

	inv1$ inve_1(WRd_0, neg_WRd_0);
	inv1$ inve_2(WRd_1, neg_WRd_1);
	inv1$ inve_3(WRd_2, neg_WRd_2);
	inv1$ inve_4(WRd_3, neg_WRd_3);

	inv1$ invf_1(WRe_0, neg_WRe_0);
	inv1$ invf_2(WRe_1, neg_WRe_1);
	inv1$ invf_3(WRe_2, neg_WRe_2);
	inv1$ invf_4(WRe_3, neg_WRe_3);

	inv1$ invg_1(WRf_0, neg_WRf_0);
	inv1$ invg_2(WRf_1, neg_WRf_1);
	inv1$ invg_3(WRf_2, neg_WRf_2);
	inv1$ invg_4(WRf_3, neg_WRf_3);

	sram128x8$ dram0_0(Address[6:0], DataIO0_0, OE, WR0_0, 1'b0);
	sram128x8$ dram0_1(Address[6:0], DataIO0_1, OE, WR0_1, 1'b0);
	sram128x8$ dram0_2(Address[6:0], DataIO0_2, OE, WR0_2, 1'b0);
	sram128x8$ dram0_3(Address[6:0], DataIO0_3, OE, WR0_3, 1'b0);

	sram128x8$ dram1_0(Address[6:0], DataIO1_0, OE, WR1_0, 1'b0);
	sram128x8$ dram1_1(Address[6:0], DataIO1_1, OE, WR1_1, 1'b0);
	sram128x8$ dram1_2(Address[6:0], DataIO1_2, OE, WR1_2, 1'b0);
	sram128x8$ dram1_3(Address[6:0], DataIO1_3, OE, WR1_3, 1'b0);

	sram128x8$ dram2_0(Address[6:0], DataIO2_0, OE, WR2_0, 1'b0);
	sram128x8$ dram2_1(Address[6:0], DataIO2_1, OE, WR2_1, 1'b0);
	sram128x8$ dram2_2(Address[6:0], DataIO2_2, OE, WR2_2, 1'b0);
	sram128x8$ dram2_3(Address[6:0], DataIO2_3, OE, WR2_3, 1'b0);

	sram128x8$ dram3_0(Address[6:0], DataIO3_0, OE, WR3_0, 1'b0);
	sram128x8$ dram3_1(Address[6:0], DataIO3_1, OE, WR3_1, 1'b0);
	sram128x8$ dram3_2(Address[6:0], DataIO3_2, OE, WR3_2, 1'b0);
	sram128x8$ dram3_3(Address[6:0], DataIO3_3, OE, WR3_3, 1'b0);

	sram128x8$ dram4_0(Address[6:0], DataIO4_0, OE, WR4_0, 1'b0);
	sram128x8$ dram4_1(Address[6:0], DataIO4_1, OE, WR4_1, 1'b0);
	sram128x8$ dram4_2(Address[6:0], DataIO4_2, OE, WR4_2, 1'b0);
	sram128x8$ dram4_3(Address[6:0], DataIO4_3, OE, WR4_3, 1'b0);

	sram128x8$ dram5_0(Address[6:0], DataIO5_0, OE, WR5_0, 1'b0);
	sram128x8$ dram5_1(Address[6:0], DataIO5_1, OE, WR5_1, 1'b0);
	sram128x8$ dram5_2(Address[6:0], DataIO5_2, OE, WR5_2, 1'b0);
	sram128x8$ dram5_3(Address[6:0], DataIO5_3, OE, WR5_3, 1'b0);

	sram128x8$ dram6_0(Address[6:0], DataIO6_0, OE, WR6_0, 1'b0);
	sram128x8$ dram6_1(Address[6:0], DataIO6_1, OE, WR6_1, 1'b0);
	sram128x8$ dram6_2(Address[6:0], DataIO6_2, OE, WR6_2, 1'b0);
	sram128x8$ dram6_3(Address[6:0], DataIO6_3, OE, WR6_3, 1'b0);

	sram128x8$ dram7_0(Address[6:0], DataIO7_0, OE, WR7_0, 1'b0);
	sram128x8$ dram7_1(Address[6:0], DataIO7_1, OE, WR7_1, 1'b0);
	sram128x8$ dram7_2(Address[6:0], DataIO7_2, OE, WR7_2, 1'b0);
	sram128x8$ dram7_3(Address[6:0], DataIO7_3, OE, WR7_3, 1'b0);

	sram128x8$ dram8_0(Address[6:0], DataIO8_0, OE, WR8_0, 1'b0);
	sram128x8$ dram8_1(Address[6:0], DataIO8_1, OE, WR8_1, 1'b0);
	sram128x8$ dram8_2(Address[6:0], DataIO8_2, OE, WR8_2, 1'b0);
	sram128x8$ dram8_3(Address[6:0], DataIO8_3, OE, WR8_3, 1'b0);

	sram128x8$ dram9_0(Address[6:0], DataIO9_0, OE, WR9_0, 1'b0);
	sram128x8$ dram9_1(Address[6:0], DataIO9_1, OE, WR9_1, 1'b0);
	sram128x8$ dram9_2(Address[6:0], DataIO9_2, OE, WR9_2, 1'b0);
	sram128x8$ dram9_3(Address[6:0], DataIO9_3, OE, WR9_3, 1'b0);

	sram128x8$ drama_0(Address[6:0], DataIOa_0, OE, WRa_0, 1'b0);
	sram128x8$ drama_1(Address[6:0], DataIOa_1, OE, WRa_1, 1'b0);
	sram128x8$ drama_2(Address[6:0], DataIOa_2, OE, WRa_2, 1'b0);
	sram128x8$ drama_3(Address[6:0], DataIOa_3, OE, WRa_3, 1'b0);

	sram128x8$ dramb_0(Address[6:0], DataIOb_0, OE, WRb_0, 1'b0);
	sram128x8$ dramb_1(Address[6:0], DataIOb_1, OE, WRb_1, 1'b0);
	sram128x8$ dramb_2(Address[6:0], DataIOb_2, OE, WRb_2, 1'b0);
	sram128x8$ dramb_3(Address[6:0], DataIOb_3, OE, WRb_3, 1'b0);

	sram128x8$ dramc_0(Address[6:0], DataIOc_0, OE, WRc_0, 1'b0);
	sram128x8$ dramc_1(Address[6:0], DataIOc_1, OE, WRc_1, 1'b0);
	sram128x8$ dramc_2(Address[6:0], DataIOc_2, OE, WRc_2, 1'b0);
	sram128x8$ dramc_3(Address[6:0], DataIOc_3, OE, WRc_3, 1'b0);

	sram128x8$ dramd_0(Address[6:0], DataIOd_0, OE, WRd_0, 1'b0);
	sram128x8$ dramd_1(Address[6:0], DataIOd_1, OE, WRd_1, 1'b0);
	sram128x8$ dramd_2(Address[6:0], DataIOd_2, OE, WRd_2, 1'b0);
	sram128x8$ dramd_3(Address[6:0], DataIOd_3, OE, WRd_3, 1'b0);

	sram128x8$ drame_0(Address[6:0], DataIOe_0, OE, WRe_0, 1'b0);
	sram128x8$ drame_1(Address[6:0], DataIOe_1, OE, WRe_1, 1'b0);
	sram128x8$ drame_2(Address[6:0], DataIOe_2, OE, WRe_2, 1'b0);
	sram128x8$ drame_3(Address[6:0], DataIOe_3, OE, WRe_3, 1'b0);

	sram128x8$ dramf_0(Address[6:0], DataIOf_0, OE, WRf_0, 1'b0);
	sram128x8$ dramf_1(Address[6:0], DataIOf_1, OE, WRf_1, 1'b0);
	sram128x8$ dramf_2(Address[6:0], DataIOf_2, OE, WRf_2, 1'b0);
	sram128x8$ dramf_3(Address[6:0], DataIOf_3, OE, WRf_3, 1'b0);
endmodule

module tlb(
    vpn0, 
    pfn0,
    tlb_miss0,
    present0,
    rw0,
	pcd0,

    vpn1,
    pfn1,
    tlb_miss1,
    present1,
    rw1,
	pcd1,

    vpn2, 
    pfn2,
    tlb_miss2,
    present2,
    rw2,
	pcd2,

    vpn3, 
    pfn3,
    tlb_miss3,
    present3,
    rw3,
	pcd3,

    vpn4,
    pfn4,
    tlb_miss4,
    present4,
    rw4,
	pcd4);

    input [19:0]    vpn0;
    output [19:0]   pfn0;
    output          tlb_miss0;
    output          present0;
    output          rw0;
	output			pcd0;
    
    input [19:0]    vpn1;
    output [19:0]   pfn1;
    output          tlb_miss1;
    output          present1;
    output          rw1;
	output			pcd1;

    input [19:0]    vpn2;
    output [19:0]   pfn2;
    output          tlb_miss2;
    output          present2;
    output          rw2;
	output			pcd2;

    input [19:0]    vpn3;
    output [19:0]   pfn3;
    output          tlb_miss3;
    output          present3;
    output          rw3;
	output			pcd3;

    input [19:0]    vpn4;
    output [19:0]   pfn4;
    output          tlb_miss4;
    output          present4;
    output          rw4;
	output			pcd4;

	wire e00, e01, e02, e03, e04, e05, e06, e07;
	wire e10, e11, e12, e13, e14, e15, e16, e17;
	wire e20, e21, e22, e23, e24, e25, e26, e27;
	wire e30, e31, e32, e33, e34, e35, e36, e37;
	wire e40, e41, e42, e43, e44, e45, e46, e47;
	wire[7:0] hit0, hit1, hit2, hit3, hit4;
	wire[19:0] pfn0_temp1, pfn0_temp2, pfn1_temp1, pfn1_temp2, pfn2_temp1, pfn2_temp2, pfn3_temp1, pfn3_temp2, pfn4_temp1, pfn4_temp2;
	wire present0_temp1, present0_temp2, present1_temp1, present1_temp2, present2_temp1, present2_temp2, present3_temp1, present3_temp2, present4_temp1, present4_temp2;
	wire rw0_temp1, rw0_temp2, rw1_temp1, rw1_temp2, rw2_temp1, rw2_temp2, rw3_temp1, rw3_temp2, rw4_temp1, rw4_temp2;
	wire pcd0_temp1, pcd0_temp2, pcd1_temp1, pcd1_temp2, pcd2_temp1, pcd2_temp2, pcd3_temp1, pcd3_temp2, pcd4_temp1, pcd4_temp2;
	wire[2:0] sel0, sel1, sel2, sel3, sel4;

    // mem_data
    reg [19:0] vpn_mem [0:7];
    reg [19:0] pfn_mem [0:7];
    reg v_mem [0:7];
    reg pre_mem [0:7];
    reg rw_mem [0:7];
    reg pcd_mem [0:7];

    initial
    begin
        $readmemh("/misc/collaboration/382nGPS/382nG6/yzhu/tlb_meta/original/tlb_vpn.list", tlb.vpn_mem);
        $readmemh("/misc/collaboration/382nGPS/382nG6/yzhu/tlb_meta/original/tlb_pfn.list", tlb.pfn_mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/tlb_meta/original/tlb_v.list", tlb.v_mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/tlb_meta/original/tlb_pre.list", tlb.pre_mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/tlb_meta/original/tlb_rw.list", tlb.rw_mem);
        $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/tlb_meta/original/tlb_pcd.list", tlb.pcd_mem);
    end

	//the last two entries in TLB are for MMIO:
	//MMIO address: the last page, vpn = 20'hFFFFF

	//read port 0;
	mag_comp20 comp01(vpn0, vpn_mem[0], e00);
	mag_comp20 comp02(vpn0, vpn_mem[1], e01);
	mag_comp20 comp03(vpn0, vpn_mem[2], e02);
	mag_comp20 comp04(vpn0, vpn_mem[3], e03);
	mag_comp20 comp05(vpn0, vpn_mem[4], e04);
	mag_comp20 comp06(vpn0, vpn_mem[5], e05);
	mag_comp20 comp07(vpn0, vpn_mem[6], e06);
	mag_comp20 comp08(vpn0, vpn_mem[7], e07);
	
	assign hit0[0] = e00 & v_mem[0];
	assign hit0[1] = e01 & v_mem[1];
	assign hit0[2] = e02 & v_mem[2];
	assign hit0[3] = e03 & v_mem[3];
	assign hit0[4] = e04 & v_mem[4];
	assign hit0[5] = e05 & v_mem[5];
	assign hit0[6] = e06 & v_mem[6];
	assign hit0[7] = e07 & v_mem[7];

	assign tlb_miss0 = ~(hit0[0] | hit0[1] | hit0[2] | hit0[3] | hit0[4] | hit0[5] | hit0[6] | hit0[7]);

	encoder8_3 encoder0(hit0, sel0);
	mux4_20 mux01(pfn0_temp1, pfn_mem[0], pfn_mem[2], pfn_mem[1], pfn_mem[3], sel0[1:0]);
	mux4_20 mux02(pfn0_temp2, pfn_mem[4], pfn_mem[6], pfn_mem[5], pfn_mem[7], sel0[1:0]);
	mux2_20 mux03(pfn0, pfn0_temp1, pfn0_temp2, sel0[2]);

	mux4$ mux05(present0_temp1, pre_mem[0], pre_mem[2], pre_mem[1], pre_mem[3], sel0[1], sel0[0]);
	mux4$ mux06(present0_temp2, pre_mem[4], pre_mem[6], pre_mem[5], pre_mem[7], sel0[1], sel0[0]);
	mux2$ mux07(present0, present0_temp1, present0_temp2, sel0[2]);

	mux4$ mux08(rw0_temp1, rw_mem[0], rw_mem[2], rw_mem[1], rw_mem[3], sel0[1], sel0[0]);
	mux4$ mux09(rw0_temp2, rw_mem[4], rw_mem[6], rw_mem[5], rw_mem[7], sel0[1], sel0[0]);
	mux2$ mux0a(rw0, rw0_temp1, rw0_temp2, sel0[2]);

	mux4$ mux0b(pcd0_temp1, pcd_mem[0], pcd_mem[2], pcd_mem[1], pcd_mem[3], sel0[1], sel0[0]);
	mux4$ mux0c(pcd0_temp2, pcd_mem[4], pcd_mem[6], pcd_mem[5], pcd_mem[7], sel0[1], sel0[0]);
	mux2$ mux0d(pcd0, pcd0_temp1, pcd0_temp2, sel0[2]);


	//read port 1;
	mag_comp20 comp11(vpn1, vpn_mem[0], e10);
	mag_comp20 comp12(vpn1, vpn_mem[1], e11);
	mag_comp20 comp13(vpn1, vpn_mem[2], e12);
	mag_comp20 comp14(vpn1, vpn_mem[3], e13);
	mag_comp20 comp15(vpn1, vpn_mem[4], e14);
	mag_comp20 comp16(vpn1, vpn_mem[5], e15);
	mag_comp20 comp17(vpn1, vpn_mem[6], e16);
	mag_comp20 comp18(vpn1, vpn_mem[7], e17);
	
	assign hit1[0] = e10 & v_mem[0];
	assign hit1[1] = e11 & v_mem[1];
	assign hit1[2] = e12 & v_mem[2];
	assign hit1[3] = e13 & v_mem[3];
	assign hit1[4] = e14 & v_mem[4];
	assign hit1[5] = e15 & v_mem[5];
	assign hit1[6] = e16 & v_mem[6];
	assign hit1[7] = e17 & v_mem[7];

	assign tlb_miss1 = ~(hit1[0] | hit1[1] | hit1[2] | hit1[3] | hit1[4] | hit1[5] | hit1[6] | hit1[7]);

	encoder8_3 encoder1(hit1, sel1);
	mux4_20 mux11(pfn1_temp1, pfn_mem[0], pfn_mem[2], pfn_mem[1], pfn_mem[3], sel1[1:0]);
	mux4_20 mux12(pfn1_temp2, pfn_mem[4], pfn_mem[6], pfn_mem[5], pfn_mem[7], sel1[1:0]);
	mux2_20 mux13(pfn1, pfn1_temp1, pfn1_temp2, sel1[2]);

	mux4$ mux15(present1_temp1, pre_mem[0], pre_mem[2], pre_mem[1], pre_mem[3], sel1[1], sel1[0]);
	mux4$ mux16(present1_temp2, pre_mem[4], pre_mem[6], pre_mem[5], pre_mem[7], sel1[1], sel1[0]);
	mux2$ mux17(present1, present1_temp1, present1_temp2, sel1[2]);

	mux4$ mux18(rw1_temp1, rw_mem[0], rw_mem[2], rw_mem[1], rw_mem[3], sel1[1], sel1[0]);
	mux4$ mux19(rw1_temp2, rw_mem[4], rw_mem[6], rw_mem[5], rw_mem[7], sel1[1], sel1[0]);
	mux2$ mux1a(rw1, rw1_temp1, rw1_temp2, sel1[2]);

	mux4$ mux1b(pcd1_temp1, pcd_mem[0], pcd_mem[2], pcd_mem[1], pcd_mem[3], sel1[1], sel1[0]);
	mux4$ mux1c(pcd1_temp2, pcd_mem[4], pcd_mem[6], pcd_mem[5], pcd_mem[7], sel1[1], sel1[0]);
	mux2$ mux1d(pcd1, pcd1_temp1, pcd1_temp2, sel1[2]);


	//read port 2;
	mag_comp20 comp21(vpn2, vpn_mem[0], e20);
	mag_comp20 comp22(vpn2, vpn_mem[1], e21);
	mag_comp20 comp23(vpn2, vpn_mem[2], e22);
	mag_comp20 comp24(vpn2, vpn_mem[3], e23);
	mag_comp20 comp25(vpn2, vpn_mem[4], e24);
	mag_comp20 comp26(vpn2, vpn_mem[5], e25);
	mag_comp20 comp27(vpn2, vpn_mem[6], e26);
	mag_comp20 comp28(vpn2, vpn_mem[7], e27);
	
	assign hit2[0] = e20 & v_mem[0];
	assign hit2[1] = e21 & v_mem[1];
	assign hit2[2] = e22 & v_mem[2];
	assign hit2[3] = e23 & v_mem[3];
	assign hit2[4] = e24 & v_mem[4];
	assign hit2[5] = e25 & v_mem[5];
	assign hit2[6] = e26 & v_mem[6];
	assign hit2[7] = e27 & v_mem[7];

	assign tlb_miss2 = ~(hit2[0] | hit2[1] | hit2[2] | hit2[3] | hit2[4] | hit2[5] | hit2[6] | hit2[7]);

	encoder8_3 encoder2(hit2, sel2);
	mux4_20 mux21(pfn2_temp1, pfn_mem[0], pfn_mem[2], pfn_mem[1], pfn_mem[3], sel2[1:0]);
	mux4_20 mux22(pfn2_temp2, pfn_mem[4], pfn_mem[6], pfn_mem[5], pfn_mem[7], sel2[1:0]);
	mux2_20 mux23(pfn2, pfn2_temp1, pfn2_temp2, sel2[2]);

	mux4$ mux25(present2_temp1, pre_mem[0], pre_mem[2], pre_mem[1], pre_mem[3], sel2[1], sel2[0]);
	mux4$ mux26(present2_temp2, pre_mem[4], pre_mem[6], pre_mem[5], pre_mem[7], sel2[1], sel2[0]);
	mux2$ mux27(present2, present2_temp1, present2_temp2, sel2[2]);

	mux4$ mux28(rw2_temp1, rw_mem[0], rw_mem[2], rw_mem[1], rw_mem[3], sel2[1], sel2[0]);
	mux4$ mux29(rw2_temp2, rw_mem[4], rw_mem[6], rw_mem[5], rw_mem[7], sel2[1], sel2[0]);
	mux2$ mux2a(rw2, rw2_temp1, rw2_temp2, sel2[2]);

	mux4$ mux2b(pcd2_temp1, pcd_mem[0], pcd_mem[2], pcd_mem[1], pcd_mem[3], sel2[1], sel2[0]);
	mux4$ mux2c(pcd2_temp2, pcd_mem[4], pcd_mem[6], pcd_mem[5], pcd_mem[7], sel2[1], sel2[0]);
	mux2$ mux2d(pcd2, pcd2_temp1, pcd2_temp2, sel2[2]);


	//read port 3;
	mag_comp20 comp31(vpn3, vpn_mem[0], e30);
	mag_comp20 comp32(vpn3, vpn_mem[1], e31);
	mag_comp20 comp33(vpn3, vpn_mem[2], e32);
	mag_comp20 comp34(vpn3, vpn_mem[3], e33);
	mag_comp20 comp35(vpn3, vpn_mem[4], e34);
	mag_comp20 comp36(vpn3, vpn_mem[5], e35);
	mag_comp20 comp37(vpn3, vpn_mem[6], e36);
	mag_comp20 comp38(vpn3, vpn_mem[7], e37);
	
	assign hit3[0] = e30 & v_mem[0];
	assign hit3[1] = e31 & v_mem[1];
	assign hit3[2] = e32 & v_mem[2];
	assign hit3[3] = e33 & v_mem[3];
	assign hit3[4] = e34 & v_mem[4];
	assign hit3[5] = e35 & v_mem[5];
	assign hit3[6] = e36 & v_mem[6];
	assign hit3[7] = e37 & v_mem[7];

	assign tlb_miss3 = ~(hit3[0] | hit3[1] | hit3[2] | hit3[3] | hit3[4] | hit3[5] | hit3[6] | hit3[7]);

	encoder8_3 encoder3(hit3, sel3);
	mux4_20 mux31(pfn3_temp1, pfn_mem[0], pfn_mem[2], pfn_mem[1], pfn_mem[3], sel3[1:0]);
	mux4_20 mux32(pfn3_temp2, pfn_mem[4], pfn_mem[6], pfn_mem[5], pfn_mem[7], sel3[1:0]);
	mux2_20 mux33(pfn3, pfn3_temp1, pfn3_temp2, sel3[2]);

	mux4$ mux35(present3_temp1, pre_mem[0], pre_mem[2], pre_mem[1], pre_mem[3], sel3[1], sel3[0]);
	mux4$ mux36(present3_temp2, pre_mem[4], pre_mem[6], pre_mem[5], pre_mem[7], sel3[1], sel3[0]);
	mux2$ mux37(present3, present3_temp1, present3_temp2, sel3[2]);

	mux4$ mux38(rw3_temp1, rw_mem[0], rw_mem[2], rw_mem[1], rw_mem[3], sel3[1], sel3[0]);
	mux4$ mux39(rw3_temp2, rw_mem[4], rw_mem[6], rw_mem[5], rw_mem[7], sel3[1], sel3[0]);
	mux2$ mux3a(rw3, rw3_temp1, rw3_temp2, sel3[2]);

	mux4$ mux3b(pcd3_temp1, pcd_mem[0], pcd_mem[2], pcd_mem[1], pcd_mem[3], sel3[1], sel3[0]);
	mux4$ mux3c(pcd3_temp2, pcd_mem[4], pcd_mem[6], pcd_mem[5], pcd_mem[7], sel3[1], sel3[0]);
	mux2$ mux3d(pcd3, pcd3_temp1, pcd3_temp2, sel3[2]);


	//read port 4;
	mag_comp20 comp41(vpn4, vpn_mem[0], e40);
	mag_comp20 comp42(vpn4, vpn_mem[1], e41);
	mag_comp20 comp43(vpn4, vpn_mem[2], e42);
	mag_comp20 comp44(vpn4, vpn_mem[3], e43);
	mag_comp20 comp45(vpn4, vpn_mem[4], e44);
	mag_comp20 comp46(vpn4, vpn_mem[5], e45);
	mag_comp20 comp47(vpn4, vpn_mem[6], e46);
	mag_comp20 comp48(vpn4, vpn_mem[7], e47);
	
	assign hit4[0] = e40 & v_mem[0];
	assign hit4[1] = e41 & v_mem[1];
	assign hit4[2] = e42 & v_mem[2];
	assign hit4[3] = e43 & v_mem[3];
	assign hit4[4] = e44 & v_mem[4];
	assign hit4[5] = e45 & v_mem[5];
	assign hit4[6] = e46 & v_mem[6];
	assign hit4[7] = e47 & v_mem[7];

	assign tlb_miss4 = ~(hit4[0] | hit4[1] | hit4[2] | hit4[3] | hit4[4] | hit4[5] | hit4[6] | hit4[7]);

	encoder8_3 encoder4(hit4, sel4);
	mux4_20 mux41(pfn4_temp1, pfn_mem[0], pfn_mem[2], pfn_mem[1], pfn_mem[3], sel4[1:0]);
	mux4_20 mux42(pfn4_temp2, pfn_mem[4], pfn_mem[6], pfn_mem[5], pfn_mem[7], sel4[1:0]);
	mux2_20 mux43(pfn4, pfn4_temp1, pfn4_temp2, sel4[2]);

	mux4$ mux45(present4_temp1, pre_mem[0], pre_mem[2], pre_mem[1], pre_mem[3], sel4[1], sel4[0]);
	mux4$ mux46(present4_temp2, pre_mem[4], pre_mem[6], pre_mem[5], pre_mem[7], sel4[1], sel4[0]);
	mux2$ mux47(present4, present4_temp1, present4_temp2, sel4[2]);

	mux4$ mux48(rw4_temp1, rw_mem[0], rw_mem[2], rw_mem[1], rw_mem[3], sel4[1], sel4[0]);
	mux4$ mux49(rw4_temp2, rw_mem[4], rw_mem[6], rw_mem[5], rw_mem[7], sel4[1], sel4[0]);
	mux2$ mux4a(rw4, rw4_temp1, rw4_temp2, sel4[2]);

	mux4$ mux4b(pcd4_temp1, pcd_mem[0], pcd_mem[2], pcd_mem[1], pcd_mem[3], sel4[1], sel4[0]);
	mux4$ mux4c(pcd4_temp2, pcd_mem[4], pcd_mem[6], pcd_mem[5], pcd_mem[7], sel4[1], sel4[0]);
	mux2$ mux4d(pcd4, pcd4_temp1, pcd4_temp2, sel4[2]);
endmodule

// added by YJL, 
// used to modify the sram module
module tristate32L(enbar, in, out);
    input          enbar;
    input [31:0]   in;
    output [31:0]  out;

    tristate16L$ tri_0(enbar, in[15:0], out[15:0]);
    tristate16L$ tri_1(enbar, in[31:16], out[31:16]);
endmodule

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

//`endif

//module SaturatingIncLogic(in, out);
//	input[1:0] in;
//	output[1:0] out;
//
//	//00-01;
//	//01-10;
//	//10-11;
//	//11-00;
//	assign out[0] = ~in[0];
//	assign out[1] = (in[1] & ~in[0]) | (~in[1] & in[0]);
//endmodule

//module StoreQueue(AddressIn, DataIn, SizeIn, AddressOut, DataOut, SizeOut, Address2DC, Data2DC, Size2DC, hit, full, CouldWrite, CouldRead, CMT_withdata, clk, clr);
//	input[14:0] AddressIn;
//	input[31:0] DataIn;
//	input[1:0] SizeIn;
//	//CouldWrite: set upon a store(write) instruction, i.e. the cache
//	//			controller decides it is OK to write to SQ (could still fail
//	//			if the SQ is full)
//	//CouldRead: set when the cache controller decides it is OK to commit data 
//	//			to memory (i.e. read from SQ to D$); Theoretically impossible 
//	//			to fail since SQ can't be empty if the WB stage wants to commit 
//	//			instruction.  But we still check it for the completeness of
//	//			the logic.  Note that in the current implementation, it 
//	//			being set means really write to D$.  If this write conflict
//	//			with other D$ read, priority is given to reads.  In future
//	//			implementations, ld_read would just mean that a particular
//	//			entry could be committed, and upon confliction, the read
//	//			pointer is incremented, but the entry still stays in the SQ 
//	//			without stalling the pipeline;
//	//ld_commit: in an optimized design, the commit pointer keeps track of the
//	//			earliest that has to be written to D$.  Any entrys inbetween
//	//			commit and read are ready to be committed.  When an entry is
//	//			actually being committed, ld_commit is set to increment the
//	//			commit pointer.
//	input CouldWrite, CouldRead, CMT_withdata;
//	input clk, clr;
//	output[14:0] AddressOut, Address2DC;
//	output[31:0] DataOut, Data2DC;
//	output[1:0] SizeOut, Size2DC;
//	output hit, full; // hit: is the associative search a hit;
//
//	wire[31:0] entry0_data, entry1_data, entry2_data, entry3_data;
//	wire[16:0] entry0_size_addr, entry1_size_addr, entry2_size_addr, entry3_size_addr;
//	wire[3:0] we, we_v, commit2dc, readfromSQ, write2SQ;
//	wire[1:0] write, read, commit, sel, incWrite, incRead, incCommit;
//	wire v0, v1, v2, v3;
//	wire ld_read, ld_write, ld_commit, full;
//	wire g0, s0, g1, s1, g2, s2, g3, s3, e0, e1, e2, e3, hitOn0, hitOn1, hitOn2, hitOn3;
//	wire empty; //empty: is the read from SQ (to D$) valid (indicating if SQ is empty).
//	wire temp1, temp2, empty_bar;
//
//	//Data
//	dff_32 dff1(clk, DataIn, entry0_data, clr, we[0]);
//	dff_32 dff2(clk, DataIn, entry1_data, clr, we[1]);
//	dff_32 dff3(clk, DataIn, entry2_data, clr, we[2]);
//	dff_32 dff4(clk, DataIn, entry3_data, clr, we[3]);
//
//	//Size:Address
//	//entry_size_addr: size[16:15]address[14:0]
//	dff_17 dff5(clk, {SizeIn, AddressIn}, entry0_size_addr, clr, we[0]);
//	dff_17 dff6(clk, {SizeIn, AddressIn}, entry1_size_addr, clr, we[1]);
//	dff_17 dff7(clk, {SizeIn, AddressIn}, entry2_size_addr, clr, we[2]);
//	dff_17 dff8(clk, {SizeIn, AddressIn}, entry3_size_addr, clr, we[3]);
//
//	mux2$ mux1(validIn, 1'b1, 1'b0, ld_read);
//	//valid bit in SQ entry
//	dff_1 dff9(clk, validIn, v0, clr, we_v[0]);
//	dff_1 dff10(clk, validIn, v1, clr, we_v[1]);
//	dff_1 dff11(clk, validIn, v2, clr, we_v[2]);
//	dff_1 dff12(clk, validIn, v3, clr, we_v[3]);
//
//	assign ld_write = we[0] | we[1] | we[2] | we[3];
//	assign ld_read = CouldRead & ~empty & ~CMT_withdata;
//
//	dff_2 dff13(clk, incWrite, write, clr, ld_write);
//	dff_2 dff14(clk, incRead, read, clr, ld_read);
//	dff_2 dff15(clk, incCommit, commit, clr, ld_commit);
//
//	SaturatingIncLogic satinc1(write, incWrite);
//	SaturatingIncLogic satinc2(read, incRead);
//	SaturatingIncLogic satinc3(commit, incCommit);
//
//	mux2$ mux2(we_v[0], we[0], 1'b1, commit2dc[0]);
//	mux2$ mux3(we_v[1], we[1], 1'b1, commit2dc[1]);
//	mux2$ mux4(we_v[2], we[2], 1'b1, commit2dc[2]);
//	mux2$ mux5(we_v[3], we[3], 1'b1, commit2dc[3]);
//
//	decoder2_4$ decode1(read, readfromSQ, );
//	assign commit2dc[0] = ld_read & readfromSQ[0];
//	assign commit2dc[1] = ld_read & readfromSQ[1];
//	assign commit2dc[2] = ld_read & readfromSQ[2];
//	assign commit2dc[3] = ld_read & readfromSQ[3];
//
//	decoder2_4$ decode2(write, write2SQ, );
//	assign full = v0 & v1 & v2 & v3; //if all entries are valid, it must be full..
//	assign we[3] = CouldWrite & ~full & write2SQ[3];
//	assign we[2] = CouldWrite & ~full & write2SQ[2];
//	assign we[1] = CouldWrite & ~full & write2SQ[1];
//	assign we[0] = CouldWrite & ~full & write2SQ[0];
//
//	mux4$ mux6(empty_bar, v0, v2, v1, v3, read[1], read[0]); // if the read pointer is pointing to an invalid entry, the SQ is empty
//	inv1$ not1(empty, empty_bar);
//	mux4_32 mux7(Data2DC, entry0_data, entry1_data, entry2_data, entry3_data, read);
//	mux4_15 mux8(Address2DC, entry0_size_addr[14:0], entry1_size_addr[14:0], entry2_size_addr[14:0], entry3_size_addr[14:0], read);
//	mux4_2 mux9(Size2DC, entry0_size_addr[16:15], entry1_size_addr[16:15], entry2_size_addr[16:15], entry3_size_addr[16:15], read);
//
//	//prioritized associative search logic...
//	//for now, comparison condition is strict
//	mag_comp17 comp1(entry0_size_addr, {SizeIn, AddressIn}, g0, s0);
//	mag_comp17 comp2(entry1_size_addr, {SizeIn, AddressIn}, g1, s1);
//	mag_comp17 comp3(entry2_size_addr, {SizeIn, AddressIn}, g2, s2);
//	mag_comp17 comp4(entry3_size_addr, {SizeIn, AddressIn}, g3, s3);
//	assign e0 = ~g0 & ~s0;
//	assign e1 = ~g1 & ~s1;
//	assign e2 = ~g2 & ~s2;
//	assign e3 = ~g3 & ~s3;
//
//	assign hit = (e0 & v0) | (e1 & v1) | (e2 & v2) | (e3 & v3);
//	assign hitOn0 = (v0 & ~v1 & ~v2 & ~v3 & e0) | (v0 & v1 & ~v2 & v3 & e0 & ~e1) | (v0 & ~v1 & ~v2 & v3 & e0) | (v0 & ~v1 & v2 & v3 & e0) | (v0 & v1 & ~v2 & v3 & e0 & ~e1) | (v0 & v1 & v2 & ~v3 & e0 & ~e1 & ~e2) | (v0 & v1 & v2 & v3 & ((~read[1] & ~read[0] & e0 & ~e1 & ~e2 & ~e3) | (~read[1] & read[0] & e0) | (read[1] & ~read[0] & e0 & ~e1) | (read[1] & read[0] & e0 & ~e1 & ~e2)));
//	assign hitOn1 = (~v0 & v1 & ~v2 & ~v3 & e1) & (~v0 & v1 & v2 & ~v3 & e1 & ~e2) & (v0 & v1 & ~v2 & ~v3 & e1) | (~v0 & v1 & v2 & v3 & e1 & ~e2 & ~e3) | (v0 & v1 & ~v2 & v3 & e1) | (v0 & v1 & v2 & ~v3 & e1 & ~e2) | (v0 & v1 & v2 & v3 & ((~read[1] & ~read[0] & e1 & ~e2 & ~e3) | (~read[1] & read[0] & ~e0 & e1 & ~e2 & ~e3) | (read[1] & ~read[0] & e1) | (read[1] & read[0] & e1 & ~e2)));
//	assign hitOn2 = (~v0 & ~v1 & v2 & ~v3 & e2) | (~v0 & ~v1 & v2 & v3 & e2 & ~e3) | (~v0 & v1 & v2 & ~v3 & e2) | (~v0 & v1 & v2 & v3 & e2 & ~e3) | (v0 & ~v1 & v2 & v3 & e2 & ~e3 & ~e0) | (v0 & v1 & v2 & ~v3 & e2) | (v0 & v1 & v2 & v3 & ((~read[1] & ~read[0] & e2 & ~e3) | (~read[1] & read[0] & ~e0 & e2 & ~e3) | (read[1] & ~read[0] & ~e0 & ~e1 & e2 & ~e3) | (read[1] & read[0] & e2)));
//	assign hitOn3 = (~v0 & ~v1 & ~v2 & v3 & e3) | (~v0 & ~v1 & v2 & v3 & e3) | (v0 & ~v1 & ~v2 & v3 & e3 & ~e0) | (~v0 & v1 & v2 & v3 & e3) | (v0 & ~v1 & v2 & v3 & e3 & ~e0) | (v0 & v1 & ~v2 & v3 & e3 & ~e0 & ~e1) | (v0 & v1 & v2 & v3 & ((~read[1] & ~read[0] & e3) | (~read[1] & read[0] & ~e0 & e3) | (read[1] & ~read[0] & ~e0 & ~e1 & e3) | (read[1] & read[0] & ~e0 & ~e1 & ~e2)));
//	xor2$ xor1(temp1, hitOn1, hitOn3);
//	assign sel[0] = temp1 & ~hitOn2 & ~hitOn0;
//	xor2$ xor2(temp2, hitOn0, hitOn2);
//	assign sel[1] = temp2 & ~hitOn1 & ~hitOn3;
//	mux4_32 mux10(DataOut, entry0_data, entry2_data, entry1_data, entry3_data, sel);
//	mux4_15 mux11(AddressOut, entry0_size_addr[14:0], entry1_size_addr[14:0], entry2_size_addr[14:0], entry3_size_addr[14:0], sel);
//	mux4_2 mux12(SizeOut, entry0_size_addr[16:15], entry1_size_addr[16:15], entry2_size_addr[16:15], entry3_size_addr[16:15], sel);
//endmodule
//	assign hitOn2 = (~v0 & ~v1 & v2 & ~v3 & e2) | (~v0 & ~v1 & v2 & v3 & e2 & ~e3) | (~v0 & v1 & v2 & ~v3 & e2) | (~v0 & v1 & v2 & v3 & e2 & ~e3) | (v0 & ~v1 & v2 & v3 & e2 & ~e3 & ~e0) | (v0 & v1 & v2 & ~v3 & e2) | (v0 & v1 & v2 & v3 & ((~read[1] & ~read[0] & e2 & ~e3) | (~read[1] & read[0] & ~e0 & e2 & ~e3) | (read[1] & ~read[0] & ~e0 & ~e1 & e2 & ~e3) | (read[1] & read[0] & e2)));
//	assign hitOn3 = (~v0 & ~v1 & ~v2 & v3 & e3) | (~v0 & ~v1 & v2 & v3 & e3) | (v0 & ~v1 & ~v2 & v3 & e3 & ~e0) | (~v0 & v1 & v2 & v3 & e3) | (v0 & ~v1 & v2 & v3 & e3 & ~e0) | (v0 & v1 & ~v2 & v3 & e3 & ~e0 & ~e1) | (v0 & v1 & v2 & v3 & ((~read[1] & ~read[0] & e3) | (~read[1] & read[0] & ~e0 & e3) | (read[1] & ~read[0] & ~e0 & ~e1 & e3) | (read[1] & read[0] & ~e0 & ~e1 & ~e2)));
//	xor2$ xor1(temp1, hitOn1, hitOn3);
//	assign sel[0] = temp1 & ~hitOn2 & ~hitOn0;
//	xor2$ xor2(temp2, hitOn0, hitOn2);
//	assign sel[1] = temp2 & ~hitOn1 & ~hitOn3;
//	mux4_32 mux10(DataOut, entry0_data, entry2_data, entry1_data, entry3_data, sel);
//	mux4_15 mux11(AddressOut, entry0_size_addr[14:0], entry1_size_addr[14:0], entry2_size_addr[14:0], entry3_size_addr[14:0], sel);
//	mux4_2 mux12(SizeOut, entry0_size_addr[16:15], entry1_size_addr[16:15], entry2_size_addr[16:15], entry3_size_addr[16:15], sel);
//endmodule
