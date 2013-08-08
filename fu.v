/*module fuTOP;
	reg[31:0] a, b;
	reg cin;
	wire[31:0] s;
	wire[32:0] cout;
	
	Adder32$ adder(a, b, cin, s, cout);
	
	initial
	begin	a = 32'hffffffff;
			b = 32'h0;
			cin = 1;
	#4		cin = 0;
	#4		cin = 1;
	//#4		$finish;
	
	end
	
	//always #4 a = a - 1;
	
	initial
		begin
		$dumpfile ("fu.dump");
		$dumpvars (0, TOP);
		end

endmodule*/


module ALU(a, b, op, cc, s, cout);
	
	//==============================
	// IO port definition
	//==============================
	input[63:0]	a, b;	
	input[2:0] op;	
	input[31:0] cc;
	output[63:0] s;		// result
	output[31:0] cout;	// carry-out
	

	//===============================
	//	Intermediate results
	//===============================
	wire[63:0] s_passb, s_or, s_xor, s_add32, s_sub32, s_daa;
	wire[32:0] cout_add32, cout_sub32, cout_daa;
	
	//wire[63:0] invB, negB;
	//wire[63:0] cin_add8, cin_add16, cin_add32, cin_sub32;
	//wire[63:0] cout_add8, cout_add16, cout_add32, cout_sub32, cout_daa;
				

	//=============================
	//	Operations
	//=============================
	
	// op = 0: s = b
	assign s_passb = b;
	
	// op = 1: s = a | b
	or2$ or0[63:0](s_or, a, b);
	
	// op = 2: s = a ^ b
	xor2$ xor0[63:0](s_xor, a, b);
	
	
	// op = 3, 4, 5
	Adder32$ adder0(a[31:0], b[31:0], 1'b0, s_add32[31:0], cout_add32);
	Adder32$ adder1(a[63:32], b[63:32], 1'b0, s_add32[63:32], );
	
	/* 
	
	// op = 3: s = a + b, 8-bit
	assign cin_add8 = {cout_add8[62:56], 1'b0, cout_add8[54:48], 1'b0, cout_add8[46:40], 1'b0, cout_add8[38:32], 1'b0,
					   cout_add8[30:24], 1'b0, cout_add8[22:16], 1'b0, cout_add8[14:8], 1'b0, cout_add8[6:0], 1'b0};
					   
	
	FullAdder$ add8[63:0](a, b, cin_add8, s_add8, cout_add8, , );
	
	// op = 4: s = a + b, 16-bit
	assign cin_add16 = {cout_add16[62:48], 1'b0, cout_add16[46:32], 1'b0, cout_add16[30:16], 1'b0, cout_add16[14:0], 1'b0};
	FullAdder$ add16[63:0](a, b, cin_add16, s_add16, cout_add16, , );

	// op = 5: s = a + b, 32-bit
	assign cin_add32 = {cout_add32[62:32], 1'b0, cout_add32[30:0], 1'b0};
	FullAdder$ add32[63:0](a, b, cin_add32, s_add32, cout_add32, , ); */
	
	// op = 6: s = a - b, 32-bit
	wire[63:0] invB;
	wire[32:0] cout_sub32_temp;
	inv1$ inv0[63:0](invB, b);	
	Adder32$ adder3(a[31:0], invB[31:0], 1'b1, s_sub32[31:0], cout_sub32_temp);
	inv1$ inv2[32:0](cout_sub32_temp, cout_sub32);
	
	// wire[63:0] cout_sub32_temp;
	// assign cin_sub32 = {cout_sub32_temp[62:32], 1'b1, cout_sub32_temp[30:0], 1'b1};
	
	// FullAdder$ sub32[63:0](a, invB, cin_sub32, s_sub32, cout_sub32_temp, , );
	// inv1$ inv1[63:0](cout_sub32, cout_sub32_temp);
	
	// op = 7: daa
	wire[7:0] cout_daa_low, cout_daa_high;
	wire[7:0] s_daa_low, s_daa_temp, s_daa_high;
	wire adjust_low;
	FullAdder$ daa_low[7:0](a[7:0], 8'h06, {cout_daa_low[6:0], 1'b0}, s_daa_low, cout_daa_low, , );
	FullAdder$ daa_high[7:0](s_daa_temp[7:0], 8'h60, {cout_daa_high[6:0], 1'b0}, s_daa_high, cout_daa_high, , );
	
	or2$ daa_or0(adjust_low, cc[`AF], cout_daa_low[3]);
	or3$ daa_or1(adjust_high, cc[`CF], cout_daa_low[7], cout_daa_high[7]);
	
	mux2_8$ daaLowMux(s_daa_temp, a[7:0], s_daa_low, adjust_low);
	mux2_8$ daaHighMux(s_daa[7:0], s_daa_temp, s_daa_high, adjust_high);
	
	or2$ daa_or3[7:0](cout_daa[7:0], cout_daa_low, cout_daa_high);
	
	
	
	
	
	//DAA daa(a[7:0], cc[4], cc[0], s_daa[7:0], cout_daa[7:0]);
	

	//==============================
	//	Output MUX
	//==============================
	mux8_16$ smux[3:0] (s, s_passb, s_or, s_xor, s_add32, s_add32, s_add32, s_sub32, {56'h0, s_daa[7:0]}, op);
	mux8_16$ cmux[1:0] (cout, 32'h0, 32'h0, 32'h0, cout_add32[32:1], cout_add32[32:1], cout_add32[32:1], cout_sub32[32:1], {24'h0, cout_daa[7:0]}, op);
	
endmodule

module SHF(a, amt, op, s, out);

	//==============================
	// IO port definition
	//==============================
	input[63:0] a;
	input[7:0] amt;
	input[1:0] op;
	output[63:0] s;
	output[3:0] out;
	
	//===============================
	//	Intermediate results
	//===============================
	wire[64:0] s_lshf0, s_lshf1, s_lshf2, s_lshf4, s_lshf8, s_lshf16;
	wire[64:0] s_rshf0, s_rshf1, s_rshf2, s_rshf4, s_rshf8, s_rshf16;
	wire[63:0] s_shuf16;

	
	//===============================
	//	Operations
	//===============================
	
	// op = 0: passa
	
	// op = 1: left shift
	assign s_lshf0 = {a[63], a[63:0]};
	mux2$ lsfh1_mux[64:0](s_lshf1, s_lshf0, {s_lshf0[63:0], 1'h0}, amt[0]),
		  lsfh2_mux[64:0](s_lshf2, s_lshf1, {s_lshf1[62:0], 2'h0}, amt[1]),
		  lsfh4_mux[64:0](s_lshf4, s_lshf2, {s_lshf2[60:0], 4'h0}, amt[2]),
		  lsfh8_mux[64:0](s_lshf8, s_lshf4, {s_lshf4[56:0], 8'h0}, amt[3]),
		  lsfh16_mux[64:0](s_lshf16, s_lshf8, {s_lshf8[48:0], 16'h0}, amt[4]);
			 

	
	// op = 2: right shift
	assign s_rshf0 = {a[63:0], 1'b0};
	mux2$ rshf1_mux[64:0](s_rshf1, s_rshf0, {{1{s_rshf0[64]}}, s_rshf0[64:1]}, amt[0]),
		  rshf2_mux[64:0](s_rshf2, s_rshf1, {{2{s_rshf1[64]}}, s_rshf1[64:2]}, amt[1]),
		  rshf4_mux[64:0](s_rshf4, s_rshf2, {{4{s_rshf1[64]}}, s_rshf2[64:4]}, amt[2]),
		  rshf8_mux[64:0](s_rshf8, s_rshf4, {{8{s_rshf1[64]}}, s_rshf4[64:8]}, amt[3]),
		  rshf16_mux[64:0](s_rshf16, s_rshf8, {{16{s_rshf1[64]}}, s_rshf8[64:16]}, amt[4]);
			 
	// op = 3: shuffle packed words
	mux4_16$ shuf16_mux0(s_shuf16[15:0], a[15:0], a[31:16], a[47:32], a[63:48], amt[0], amt[1]),
			 shuf16_mux1(s_shuf16[31:16], a[15:0], a[31:16], a[47:32], a[63:48], amt[2], amt[3]),
			 shuf16_mux2(s_shuf16[47:32], a[15:0], a[31:16], a[47:32], a[63:48], amt[4], amt[5]),
			 shuf16_mux3(s_shuf16[63:48], a[15:0], a[31:16], a[47:32], a[63:48], amt[6], amt[7]);
			 
	//=================================
	//	Output 
	//=================================
	mux4_16$ sMux[3:0](s, a, s_lshf16[63:0], s_rshf16[64:1], s_shuf16, op[0], op[1]);
	mux4$ outMux[3:0](out, 
		4'b0, 
		{s_lshf16[64], s_lshf16[32], s_lshf16[16], s_lshf16[8]}, 
		{s_rshf16[0], s_rshf16[0], s_rshf16[0], s_rshf16[0]}, 
		1'b0, op[0], op[1]);
			 
			 
			 
endmodule


/*
module DAA(in, af, cf, out, cout);
	input[7:0] in;
	input af, cf;
	output[7:0] out, cout;
	
	wire lowNotDigit;
	wire lowNeedAdjust;
	wire[7:0] low_plus_6, low_plus_6_cout;
	wire new_cf;
	wire[7:0] temp_in;
	
	wire highNotDigit, highNeedAdjust;
	wire[7:0] high_plus_6, high_plus_6_cout;
	
	// adjust for in[3:0]
	mag_comp4$ cmp_low(in[3:0], 4'h9, lowNotDigit, );
	or2$ or_low(lowNeedAdjust, af, lowNotDigit);
	FullAdder add_low[7:0](in, 8'h06, {low_plus_6[6:0], 1'b0}, low_plus_6, low_plus_6_cout);
	mux2_8$ mux_low(temp_in, in, low_plus_6, lowNeedAdjust);
	
	// adjust for new CF
	or2$ or_cf(new_cf, cf, low_plus_6_cout[7]);
	
	// adjust for in[7:4]
	mag_comp4$ cmp_high(temp_in[7:4], 4'h9, highNotDigit, );
	or2$ or_high(highNeedAdjust, new_cf, highNotDigit);
	FullAdder add_high[7:0](temp_in, 8'h60, {low_plus_6[6:0], 1'b0}, high_plus_6, high_plus_6_cout);
	mux2_8$ mux_high(out, temp_in, high_plus_6, highNeedAdjust);
	
	assign cout = {highNeedAdjust, 3'h0, lowNeedAdjust, 3'h0};
	
	
endmodule

*/


//************************************
//	1-bit Full Adder
//************************************
module FullAdder$(a, b, c, s, cout, g, p);
	input a, b, c;
	output s, cout, g, p;
	
	wire nota, notb, notc;
	wire s0, s1, s2, s3, c0, c1, c2;
	
	inv1$ invA(nota, a),
		  invB(notb, b),
		  invC(notc, c);
	
	// s = a'b'c + a'bc' + ab'c' + abc
	nand3$ nandS0(s0, nota, notb, c),
		   nandS1(s1, nota, b, notc),
		   nandS2(s2, a, notb, notc),
		   nandS3(s3, a, b, c);
	nand4$ nandS(s, s0, s1, s2, s3);
	
	// cout = ab + bc + ac
	nand2$ nandC0(c0, a, b),
		   nandC1(c1, b, c),
		   nandC2(c2, a, c);
	nand3$ nandCout(cout, c0, c1, c2);
	
	// g = a * b
	// p = a + b
	and2$ andG(g, a, b);
	or2$ orP(p, a, b);
endmodule

module Adder16$(a, b, cin, s, cout);
	input[15:0] a, b;
	input cin;
	output[15:0] s;
	output[16:0] cout;
	
	wire[31:0] s_temp;
	wire[32:0] cout_temp;
	
	Adder32$ adder({16'h0, a}, {16'h0, b}, cin, s_temp, cout_temp);
	assign s = s_temp[15:0];
	assign cout = cout_temp[16:0]; 
	
	
	
endmodule

module Adder32$(a, b, cin, s, cout);
	input[31:0] a, b;
	input cin;
	output[31:0] s;
	output[32:0] cout;
	
	wire[63:0] carry;
	
	CarryLookahead64$ cl0({32'h0, a}, {32'h0, b}, cin, carry);
	FullAdder$ fa0[31:0](a, b, carry[31:0], s, , , );
	assign cout = carry[32:0];
	
endmodule

module CarryLookahead64$(a, b, c0, carry);
	input[63:0] a, b;
	input c0;
	output[63:0] carry;
	
	
	wire[63:0] g, p, c;
	wire[15:0] gg, pp, cc;
	wire[3:0] ggg, ppp, ccc;
	
	//==========================
	// Generate g and p
	//==========================
	// first level
	and2$ andG[63:0](g, a, b);
	or2$ orP[63:0](p, a, b);
	
	// second level
	GP4$ gp0[3:0](g, p, gg, pp);
	
	// third level
	GP4$ gp1(gg, pp, ggg, ppp);
	
	
	//==========================
	//	first level carry
	//==========================
	Carry4$ CCCarry0(ggg, ppp, c0, ccc),
			CCarry0[3:0](gg, pp, ccc, cc),
			Carry0[15:0](g, p, cc, c);
			
		
	assign carry = c;
	

endmodule

module Carry4$(g, p, cin, c);
	input[3:0] g, p;
	input cin;
	output[3:0] c;
	
	wire w10, w11, w20, w21, w22, w30, w31, w32, w33, w40, w41, w42, w43, w44;
	
	assign c[0] = cin;
	
	// c1 = g0 + p0*cin
	nand2$ nandC1(c[1], w10, w11);
	nand2$ nandW10(w10, g[0], g[0]);
	nand2$ nandW11(w11, p[0], cin);
	
	// c2 = g1 + p1*g0 + p1*p0*cin
	nand3$ nandC2(c[2], w20, w21, w22);
	nand2$ nandW20(w20, g[1], g[1]);
	nand2$ nandW21(w21, p[1], g[0]);
	nand3$ nandW22(w22, p[1], p[0], cin);
	
	// c3 = g2 + p2*g1 + p2*p1*g0 + p2*p1*p0*cin
	nand4$ nandC3(c[3], w30, w31, w32, w33);
	nand2$ nandW30(w30, g[2], g[2]);
	nand2$ nandW31(w31, p[2], g[1]);
	nand3$ nandW32(w32, p[2], p[1], g[0]);
	nand4$ nandW33(w33, p[2], p[1], p[0], cin);
	
	// c4 = g3 + p3*g2 + p3*p2*g1 + p3*p2*p1*g0 + p3*p2*p1*p0*cin
	// nand5$ nandC4(c[4], g[3], w41, w42, w43, w44);
	// nand2$ nandW41(w41, p[3], g[2]);
	// nand3$ nandW42(w42, p[3], p[2], g[1]);
	// nand4$ nandW43(w43, p[3], p[2], p[1], g[0]);
	// nand5$ nandW44(w44, p[3], p[2], p[1], p[0], cin);
	
endmodule

module GP4$(g, p, gg, pp);
	input[15:0] g, p;
	output[3:0] gg, pp;
	
	and4$ andPP[3:0](pp, {p[15], p[11], p[7], p[3]},
						 {p[14], p[10], p[6], p[2]},
						 {p[13], p[9], p[5], p[1]},
						 {p[12], p[8], p[4], p[0]});
						 
	wire[3:0] w1, w2, w3, w4;
	nand4$ nandGG[3:0](gg, w1, w2, w3, w4);
	nand2$ nandW1[3:0](w1, {g[15], g[11], g[7], g[3]}, {g[15], g[11], g[7], g[3]});	
	nand2$ nandW2[3:0](w2, {p[15], p[11], p[7], p[3]},
						   {g[14], g[10], g[6], g[2]});
	nand3$ nandW3[3:0](w3, {p[15], p[11], p[7], p[3]},
						   {p[14], p[10], p[6], p[2]},
						   {g[13], g[9], g[5], g[1]});
	nand4$ nandW4[3:0](w4, {p[15], p[11], p[7], p[3]},
						   {p[14], p[10], p[6], p[2]},
						   {p[13], p[9], p[5], p[1]},
						   {g[12], g[8], g[4], g[0]});

endmodule


/*
//***************************
//	4-bit Lookahead Carry Unit
//***************************
module LCU4$(g, p, cin, cout, pg, gg);
	input[3:0] g, p;
	input cin;
	output[4:0] cout;
	

	// pg = p3 + p2 + p1 + p0
	or4$ orPG(pg, p[3], p[2], p[1], p[0]);
	
	// gg = g3 + p3*g2 + p3*p2*g1 + p3*p2*p1*g0
	wire w0, w1, w2, w3;
	inv1$ inv0(w0, g[3]);
	nand2$ nand1(w1, p[3], g[2]);
	nand3$ nand2(w2, p[3], p[2], g[1]);
	nand4$ nand3(w3, p[3], p[2], p[1], g[0]);
	nand4$ nandGG(gg, w0, w1, w2, w3);
	
	
	// c0 = cin
	assign c[0] = cin;
	
	// c1 = g0 + p0*c0
	wire w10, w11;
	inv1$ inv10(w10, g[0]);
	nand2$ nand11(w11, p[0], cout[0]);
	nand2$ nandC1(cout[1], w10, w11);
	
	// c2 = g1 + g0*p1 + c0*p0*p1
	wire w20, w21, w22;
	inv1$ inv20(w20, g[1]);
	nand2$ nand21(w21, g[0], p[1]);
	nand3$ nand22(w22, cout[0], p[0], p[1]);
	nand3$ nandC2(cout[2], w20, w21, w22);
	
	// c3 = g2 + g1*p2 + g0*p1*p2 + c0*p0*p1*p2
	wire w30, w31, w32, w33;
	inv1$ inv30(w30, g[2]);
	nand2$ nand31(w31, g[1], p[2]);
	nand3$ nand32(w32, g[0], p[1], p[2]);
	nand4$ nand33(w33, cout[0], p[0], p[1], p[2]);
	nand4$ nandC3(cout[3], w30, w31, w32, w33);
	
	// c4 = g3 + g2*p3 + g1*p2*p3 + g0*p1*p2*p3 + c0*p0*p1*p2*p3
	wire w40, w41, w42, w43, w44;
	and2$ and40(w40, g[2], p[3]);
	nand3$ nand41(w41, g[1], p[2], p[3]);
	nand4$ nand42(w42, g[0], p[1], p[2], p[3]);
	and2$ and43(w43, c[0], p[0]);
	nand4$ nand44(w44, w43, p[1], p[2], p[3]);
	nor2$ nor45(w45, g[3], w40);
	nand4$ nandC4(cout[4], w45, w41, w42, w44);
	
endmodule



module CLAdder4$(a, b, cin, s, cout, g, p);
	input[3:0] a, b;
	input cin;
	output[3:0] s;
	output[4:0] cout;
	output pg, gg;
	
	wire[3:0] g, p;
	wire[4:0] carry;
	
	FullAdder$ fa[3:0](a, b, carry[3:0], s, , g, p);
	LCU4$ clu(g, p, cin, carry, pg, gg)
	
	assign cout = carry;
	
endmodule

module CLAdder16$(a, b, cin, s, cout, g, p);
	input[15:0] a, b;
	input cin;
	output[15:0] s;
	output[16:0] cout;
	
	wire[3:0] g, p;
	wire[4:0] carry;
	
	CLAdder4$ adder[3:0](a, b, carry[3:0], s, cout, g, p);
	LCU4$ luc(g, p, cin, carry, pg, gg);
	
	assign cout = carry[4], 
	
	
endmodule*/

// module Negative32(B, negB);
	// input[31:0] B;
	// output[31:0] negB;
	
	// wire[31:0] invB;
	// wire[31:0] invB_cout, negB_cout;
		
	// inv1$ inv0[31:0](invB, B);
	// FullAdder add0[31:0](invB, 32'h1, {invB_cout[30:0], 1'b0}, negB, invB_cout[31:0]);

// endmodule

/*
module COND(eax, sr1, sr2, sr1_sel, dr_ld, mem_st_en, op, cc, result, cond_dr_sel, cond_dr_ld, cond_mem_st_en, cmpxchg_equal);

	//==============================
	// IO port definition
	//==============================
	input[63:0] eax, sr1, sr2;
	input[2:0] sr1_sel;
	input dr_ld, mem_st_en;
	input op;	
	input[31:0] cc;
	output[63:0] result;
	output[2:0] cond_dr_sel;
	output cond_dr_ld, cond_mem_st_en, cmpxchg_equal;
	
	//===============================
	//	Intermediate Results
	//===============================
	wire cmpxchg_not_equal, cmpxchg_dr_ld, cmov_dr_ld;
	
	//===============================
	//	Operation
	//===============================
	comp_32 comp0(eax[31:0], sr1[31:0], , cmpxchg_equal, );
	
	
	//================================
	//	Outputs
	//================================
	
	// result
	mux2_16$ result_mux[3:0](result, sr1, sr2, cmpxchg_equal);
	
	// mem_st_en
	mux2$ memsten_mux(cond_mem_st_en, 1'b0, mem_st_en, cmpxchg_equal);
		
	// dr_sel
	mux2$ drsel_mux[2:0](cond_dr_sel, 3'h0, sr1_sel, cmpxchg_equal);
	
	// dr_ld
	mux2$ cmpxchg_dr_ld_mux(cmpxchg_dr_ld, 1'b1, dr_ld, cmpxchg_equal);
	mux2$ cmov_dr_ld_mux(cmov_dr_ld, 1'b0, dr_ld, cc[0]);
	mux2$ cond_dr_ld_mux(cond_dr_ld, cmov_dr_ld, cmpxchg_dr_ld, op);
	
endmodule
*/
/*
//**************************************
//
//	32-bit sign comparator
//
//**************************************
module comp_32(a, b, aGb, aEb, aLb);
	input[31:0] a, b;
	output aGb, aEb, aLb;
	
	wire[31:0] inv_b, neg_b;
	wire[31:0] invb_cout, negb_cout;
	wire[31:0] a_minus_b;
	wire isNotZero;
	
	inv1$ inv0[31:0](inv_b, b);
	FullAdder add0[31:0](inv_b, 32'h1, {invb_cout[30:0], 1'b0}, neg_b, invb_cout[31:0]);
	FullAdder add1[31:0](a, neg_b, {negb_cout[30:0], 1'b0}, a_minus_b, negb_cout);
	
	assign aLb = a_minus_b[31];
	zcomp_32 zcomp0(a_minus_b, aEb, );
	nor2$ nor0(aGb, aLb, aEb);
	
endmodule

//**************************************
//
//	32-bit zero comparator
//
//**************************************
module zcomp_32(a, isZero, isNotZero);
	input[31:0] a;
	output isZero, isNotZero;

	wire[15:0] w0;
	wire[7:0] w1;
	wire[3:0] w2;
	wire[1:0] w3;
	
	or2$ or0[15:0](w0, a[31:16], a[15:0]),
		 or1[7:0](w1, w0[15:8], w0[7:0]),
		 or2[3:0](w2, w1[7:4], w1[3:0]),
		 or3[1:0](w3, w2[3:2], w2[1:0]),
		 or4(isNotZero, w3[1], w3[0]);
		  
	inv1$ inv0(isZero, isNotZero);
	
endmodule
*/