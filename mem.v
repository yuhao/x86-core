`timescale 1ns/10ps
`include "/misc/collaboration/382nGPS/382nG6/yhuang/macro.v"
`include "/misc/collaboration/382nGPS/382nG6/yzhu/yzhu_gates.v"
`include "/misc/collaboration/382nGPS/382nG6/yjl/yjl_constants.v"
//`uselib file=/misc/collaboration/382nGPS/382nG6/yzhu/yzhu_gates.v

module regfile64x6(row, col, DataIn, we, DataOut, clk, clr);
	input[1:0] DataIn;
	input[1:0] col;
	input[5:0] row;
	input we, clk, clr;
	output[5:0] DataOut;

	wire[3:0] block_sel;
	wire[5:0] DataOut1, DataOut2, DataOut3, DataOut4;

	regfile16x6 rf1(row[3:0], col, DataIn, we1, DataOut1, clk, clr);
	regfile16x6 rf2(row[3:0], col, DataIn, we2, DataOut2, clk, clr);
	regfile16x6 rf3(row[3:0], col, DataIn, we3, DataOut3, clk, clr);
	regfile16x6 rf4(row[3:0], col, DataIn, we4, DataOut4, clk, clr);

	decoder2_4$ decode1(row[5:4], block_sel, );
	and2$ and1(we1, we, block_sel[0]);
	and2$ and2(we2, we, block_sel[1]);
	and2$ and3(we3, we, block_sel[2]);
	and2$ and4(we4, we, block_sel[3]);
	//assign we1 = we & block_sel[0];
	//assign we2 = we & block_sel[1];
	//assign we3 = we & block_sel[2];
	//assign we4 = we & block_sel[3];

	mux4_6 mux1(DataOut, DataOut1, DataOut3, DataOut2, DataOut4, row[5:4]);
endmodule

module ram64x24(setIndex, wayId, dataIn, OE, WR, dataOut);
	input[5:0] setIndex;
	input[6:0] dataIn;
	input[1:0] wayId;
	input OE, WR; // WR-1: write; 0-read
	output[23:0] dataOut;

	wire[23:0] dataOut1, dataOut2, dataOut3, dataOut4, dataOut5, dataOut6, dataOut7, dataOut8, temp_data1, temp_data2;
	wire[7:0] WR_block;
	//WRM_N: 1-write; 0-read
	wire WR1_1, WR1_2, WR1_3, WR2_1, WR2_2, WR2_3, WR3_1, WR3_2, WR3_3, WR4_1, WR4_2, WR4_3, WR5_1, WR5_2, WR5_3, WR6_1, WR6_2, WR6_3, WR7_1, WR7_2, WR7_3, WR8_1, WR8_2, WR8_3;
	wire WR_block1, WR_block2, WR_block3, WR_block4, WR_block5, WR_block6, WR_block7, WR_block8;
	//wire WR_temp, WR_temp1, wayId0, wayId1;

	decoder3_8$ decode1(setIndex[5:3], WR_block, );
	assign WR_block1 = WR_block[0];
	assign WR_block2 = WR_block[1];
	assign WR_block3 = WR_block[2];
	assign WR_block4 = WR_block[3];
	assign WR_block5 = WR_block[4];
	assign WR_block6 = WR_block[5];
	assign WR_block7 = WR_block[6];
	assign WR_block8 = WR_block[7];

	//buffer$ buffer1(WR_temp, WR_in);
	//buffer$ buffer2(WR_temp1, WR_temp);
	//and2$ and1(WR, WR_temp1, WR_in);

	//buffer$ buffer3(wayId0, wayId[0]);
	//buffer$ buffer4(wayId1, wayId[1]);

	and4$ and2(WR1_1, WR, WR_block1, ~wayId[0], ~wayId[1]);
	and4$ and3(WR1_2, WR, WR_block1, wayId[0], ~wayId[1]);
	and4$ and4(WR1_3, WR, WR_block1, ~wayId[0], wayId[1]);
	and4$ and5(WR2_1, WR, WR_block2, ~wayId[0], ~wayId[1]);
	and4$ and6(WR2_2, WR, WR_block2, wayId[0], ~wayId[1]);
	and4$ and7(WR2_3, WR, WR_block2, ~wayId[0], wayId[1]);
	and4$ and8(WR3_1, WR, WR_block3, ~wayId[0], ~wayId[1]);
	and4$ and9(WR3_2, WR, WR_block3, wayId[0], ~wayId[1]);
	and4$ and10(WR3_3, WR, WR_block3, ~wayId[0], wayId[1]);
	and4$ and11(WR4_1, WR, WR_block4, ~wayId[0], ~wayId[1]);
	and4$ and12(WR4_2, WR, WR_block4, wayId[0], ~wayId[1]);
	and4$ and13(WR4_3, WR, WR_block4, ~wayId[0], wayId[1]);
	and4$ and14(WR5_1, WR, WR_block5, ~wayId[0], ~wayId[1]);
	and4$ and15(WR5_2, WR, WR_block5, wayId[0], ~wayId[1]);
	and4$ and16(WR5_3, WR, WR_block5, ~wayId[0], wayId[1]);
	and4$ and17(WR6_1, WR, WR_block6, ~wayId[0], ~wayId[1]);
	and4$ and18(WR6_2, WR, WR_block6, wayId[0], ~wayId[1]);
	and4$ and19(WR6_3, WR, WR_block6, ~wayId[0], wayId[1]);
	and4$ and20(WR7_1, WR, WR_block7, ~wayId[0], ~wayId[1]);
	and4$ and21(WR7_2, WR, WR_block7, wayId[0], ~wayId[1]);
	and4$ and22(WR7_3, WR, WR_block7, ~wayId[0], wayId[1]);
	and4$ and23(WR8_1, WR, WR_block8, ~wayId[0], ~wayId[1]);
	and4$ and24(WR8_2, WR, WR_block8, wayId[0], ~wayId[1]);
	and4$ and25(WR8_3, WR, WR_block8, ~wayId[0], wayId[1]);

	//write at the negedge...
	ram8b8w$ DCTagArray1_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR1_1, dataOut1[7:0]);
	ram8b8w$ DCTagArray1_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR1_2, dataOut1[15:8]);
	ram8b8w$ DCTagArray1_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR1_3, dataOut1[23:16]);

	ram8b8w$ DCTagArray2_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR2_1, dataOut2[7:0]);
	ram8b8w$ DCTagArray2_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR2_2, dataOut2[15:8]);
	ram8b8w$ DCTagArray2_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR2_3, dataOut2[23:16]);

	ram8b8w$ DCTagArray3_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR3_1, dataOut3[7:0]);
	ram8b8w$ DCTagArray3_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR3_2, dataOut3[15:8]);
	ram8b8w$ DCTagArray3_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR3_3, dataOut3[23:16]);

	ram8b8w$ DCTagArray4_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR4_1, dataOut4[7:0]);
	ram8b8w$ DCTagArray4_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR4_2, dataOut4[15:8]);
	ram8b8w$ DCTagArray4_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR4_3, dataOut4[23:16]);

	ram8b8w$ DCTagArray5_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR5_1, dataOut5[7:0]);
	ram8b8w$ DCTagArray5_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR5_2, dataOut5[15:8]);
	ram8b8w$ DCTagArray5_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR5_3, dataOut5[23:16]);

	ram8b8w$ DCTagArray6_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR6_1, dataOut6[7:0]);
	ram8b8w$ DCTagArray6_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR6_2, dataOut6[15:8]);
	ram8b8w$ DCTagArray6_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR6_3, dataOut6[23:16]);

	ram8b8w$ DCTagArray7_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR7_1, dataOut7[7:0]);
	ram8b8w$ DCTagArray7_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR7_2, dataOut7[15:8]);
	ram8b8w$ DCTagArray7_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR7_3, dataOut7[23:16]);

	ram8b8w$ DCTagArray8_1(setIndex[2:0], {1'b0, dataIn}, OE, ~WR8_1, dataOut8[7:0]);
	ram8b8w$ DCTagArray8_2(setIndex[2:0], {1'b0, dataIn}, OE, ~WR8_2, dataOut8[15:8]);
	ram8b8w$ DCTagArray8_3(setIndex[2:0], {1'b0, dataIn}, OE, ~WR8_3, dataOut8[23:16]);

	mux4_24 mux1(temp_data1, dataOut1, dataOut3, dataOut2, dataOut4, setIndex[4:3]);
	mux4_24 mux2(temp_data2, dataOut5, dataOut7, dataOut6, dataOut8, setIndex[4:3]);
	mux2_24 mux3(dataOut, temp_data1, temp_data2, setIndex[5]);
endmodule

module ram64x96(setIndex, wayId, WR_byte, dataIn, OE, WR_in, dataOut);
	input[5:0] setIndex;
	input[31:0] dataIn;
	input[3:0] WR_byte;
	input[1:0] wayId;
	input OE, WR_in;
	output[95:0] dataOut;

	wire[95:0] dataOut1, dataOut2, dataOut3, dataOut4, dataOut5, dataOut6, dataOut7, dataOut8, temp_data1, temp_data2;
	wire[7:0] WR_block;
	wire WR_way1, WR_way2, WR_way3, WR_block1, WR_block2, WR_block3, WR_block4, WR_block5, WR_block6, WR_block7, WR_block8;
	wire WR1_1_0, WR1_1_1, WR1_1_2, WR1_1_3, WR1_2_0, WR1_2_1, WR1_2_2, WR1_2_3, WR1_3_0, WR1_3_1, WR1_3_2, WR1_3_3;
	wire WR2_1_0, WR2_1_1, WR2_1_2, WR2_1_3, WR2_2_0, WR2_2_1, WR2_2_2, WR2_2_3, WR2_3_0, WR2_3_1, WR2_3_2, WR2_3_3;
	wire WR3_1_0, WR3_1_1, WR3_1_2, WR3_1_3, WR3_2_0, WR3_2_1, WR3_2_2, WR3_2_3, WR3_3_0, WR3_3_1, WR3_3_2, WR3_3_3;
	wire WR4_1_0, WR4_1_1, WR4_1_2, WR4_1_3, WR4_2_0, WR4_2_1, WR4_2_2, WR4_2_3, WR4_3_0, WR4_3_1, WR4_3_2, WR4_3_3;
	wire WR5_1_0, WR5_1_1, WR5_1_2, WR5_1_3, WR5_2_0, WR5_2_1, WR5_2_2, WR5_2_3, WR5_3_0, WR5_3_1, WR5_3_2, WR5_3_3;
	wire WR6_1_0, WR6_1_1, WR6_1_2, WR6_1_3, WR6_2_0, WR6_2_1, WR6_2_2, WR6_2_3, WR6_3_0, WR6_3_1, WR6_3_2, WR6_3_3;
	wire WR7_1_0, WR7_1_1, WR7_1_2, WR7_1_3, WR7_2_0, WR7_2_1, WR7_2_2, WR7_2_3, WR7_3_0, WR7_3_1, WR7_3_2, WR7_3_3;
	wire WR8_1_0, WR8_1_1, WR8_1_2, WR8_1_3, WR8_2_0, WR8_2_1, WR8_2_2, WR8_2_3, WR8_3_0, WR8_3_1, WR8_3_2, WR8_3_3;
	wire WR1_1_0_neg, WR1_1_1_neg, WR1_1_2_neg, WR1_1_3_neg, WR1_2_0_neg, WR1_2_1_neg, WR1_2_2_neg, WR1_2_3_neg, WR1_3_0_neg, WR1_3_1_neg, WR1_3_2_neg, WR1_3_3_neg;
	wire WR2_1_0_neg, WR2_1_1_neg, WR2_1_2_neg, WR2_1_3_neg, WR2_2_0_neg, WR2_2_1_neg, WR2_2_2_neg, WR2_2_3_neg, WR2_3_0_neg, WR2_3_1_neg, WR2_3_2_neg, WR2_3_3_neg;
	wire WR3_1_0_neg, WR3_1_1_neg, WR3_1_2_neg, WR3_1_3_neg, WR3_2_0_neg, WR3_2_1_neg, WR3_2_2_neg, WR3_2_3_neg, WR3_3_0_neg, WR3_3_1_neg, WR3_3_2_neg, WR3_3_3_neg;
	wire WR4_1_0_neg, WR4_1_1_neg, WR4_1_2_neg, WR4_1_3_neg, WR4_2_0_neg, WR4_2_1_neg, WR4_2_2_neg, WR4_2_3_neg, WR4_3_0_neg, WR4_3_1_neg, WR4_3_2_neg, WR4_3_3_neg;
	wire WR5_1_0_neg, WR5_1_1_neg, WR5_1_2_neg, WR5_1_3_neg, WR5_2_0_neg, WR5_2_1_neg, WR5_2_2_neg, WR5_2_3_neg, WR5_3_0_neg, WR5_3_1_neg, WR5_3_2_neg, WR5_3_3_neg;
	wire WR6_1_0_neg, WR6_1_1_neg, WR6_1_2_neg, WR6_1_3_neg, WR6_2_0_neg, WR6_2_1_neg, WR6_2_2_neg, WR6_2_3_neg, WR6_3_0_neg, WR6_3_1_neg, WR6_3_2_neg, WR6_3_3_neg;
	wire WR7_1_0_neg, WR7_1_1_neg, WR7_1_2_neg, WR7_1_3_neg, WR7_2_0_neg, WR7_2_1_neg, WR7_2_2_neg, WR7_2_3_neg, WR7_3_0_neg, WR7_3_1_neg, WR7_3_2_neg, WR7_3_3_neg;
	wire WR8_1_0_neg, WR8_1_1_neg, WR8_1_2_neg, WR8_1_3_neg, WR8_2_0_neg, WR8_2_1_neg, WR8_2_2_neg, WR8_2_3_neg, WR8_3_0_neg, WR8_3_1_neg, WR8_3_2_neg, WR8_3_3_neg;
	wire wayId1_bar, wayId0_bar;
	wire WR, WR_temp;

	//within each line, data layout as follows:
	//addr: 00 01 10 11, from left to right.
	//exactly the same layout as in memory

	buffer$ buf1(WR_temp, WR_in);
	buffer$ buf2(WR, WR_temp);

	//read: OE = 0; WR = 0;
	//write: OE = x; WR = 1;
	//Chip disable: OE = 1; WR = 0;

	//byte:3  2  1  0
	//addr:00 01 10 11

	inv1$ inv1(wayId1_bar, wayId[1]);
	inv1$ inv2(wayId0_bar, wayId[0]);
	and2$ and1(WR_way1, wayId0_bar, wayId1_bar);
	and2$ and2(WR_way2, wayId[0], wayId1_bar);
	and2$ and3(WR_way3, wayId0_bar, wayId[1]);

	decoder3_8$ decode1(setIndex[5:3], WR_block, );
	assign WR_block1 = WR_block[0];
	assign WR_block2 = WR_block[1];
	assign WR_block3 = WR_block[2];
	assign WR_block4 = WR_block[3];
	assign WR_block5 = WR_block[4];
	assign WR_block6 = WR_block[5];
	assign WR_block7 = WR_block[6];
	assign WR_block8 = WR_block[7];

	and4$ and1_1_0(WR1_1_0_neg, WR, WR_block1, WR_way1, WR_byte[0]);
	and4$ and1_1_1(WR1_1_1_neg, WR, WR_block1, WR_way1, WR_byte[1]);
	and4$ and1_1_2(WR1_1_2_neg, WR, WR_block1, WR_way1, WR_byte[2]);
	and4$ and1_1_3(WR1_1_3_neg, WR, WR_block1, WR_way1, WR_byte[3]);
	and4$ and1_2_0(WR1_2_0_neg, WR, WR_block1, WR_way2, WR_byte[0]);
	and4$ and1_2_1(WR1_2_1_neg, WR, WR_block1, WR_way2, WR_byte[1]);
	and4$ and1_2_2(WR1_2_2_neg, WR, WR_block1, WR_way2, WR_byte[2]);
	and4$ and1_2_3(WR1_2_3_neg, WR, WR_block1, WR_way2, WR_byte[3]);
	and4$ and1_3_0(WR1_3_0_neg, WR, WR_block1, WR_way3, WR_byte[0]);
	and4$ and1_3_1(WR1_3_1_neg, WR, WR_block1, WR_way3, WR_byte[1]);
	and4$ and1_3_2(WR1_3_2_neg, WR, WR_block1, WR_way3, WR_byte[2]);
	and4$ and1_3_3(WR1_3_3_neg, WR, WR_block1, WR_way3, WR_byte[3]);

	and4$ and2_1_0(WR2_1_0_neg, WR, WR_block2, WR_way1, WR_byte[0]);
	and4$ and2_1_1(WR2_1_1_neg, WR, WR_block2, WR_way1, WR_byte[1]);
	and4$ and2_1_2(WR2_1_2_neg, WR, WR_block2, WR_way1, WR_byte[2]);
	and4$ and2_1_3(WR2_1_3_neg, WR, WR_block2, WR_way1, WR_byte[3]);
	and4$ and2_2_0(WR2_2_0_neg, WR, WR_block2, WR_way2, WR_byte[0]);
	and4$ and2_2_1(WR2_2_1_neg, WR, WR_block2, WR_way2, WR_byte[1]);
	and4$ and2_2_2(WR2_2_2_neg, WR, WR_block2, WR_way2, WR_byte[2]);
	and4$ and2_2_3(WR2_2_3_neg, WR, WR_block2, WR_way2, WR_byte[3]);
	and4$ and2_3_0(WR2_3_0_neg, WR, WR_block2, WR_way3, WR_byte[0]);
	and4$ and2_3_1(WR2_3_1_neg, WR, WR_block2, WR_way3, WR_byte[1]);
	and4$ and2_3_2(WR2_3_2_neg, WR, WR_block2, WR_way3, WR_byte[2]);
	and4$ and2_3_3(WR2_3_3_neg, WR, WR_block2, WR_way3, WR_byte[3]);

	and4$ and3_1_0(WR3_1_0_neg, WR, WR_block3, WR_way1, WR_byte[0]);
	and4$ and3_1_1(WR3_1_1_neg, WR, WR_block3, WR_way1, WR_byte[1]);
	and4$ and3_1_2(WR3_1_2_neg, WR, WR_block3, WR_way1, WR_byte[2]);
	and4$ and3_1_3(WR3_1_3_neg, WR, WR_block3, WR_way1, WR_byte[3]);
	and4$ and3_2_0(WR3_2_0_neg, WR, WR_block3, WR_way2, WR_byte[0]);
	and4$ and3_2_1(WR3_2_1_neg, WR, WR_block3, WR_way2, WR_byte[1]);
	and4$ and3_2_2(WR3_2_2_neg, WR, WR_block3, WR_way2, WR_byte[2]);
	and4$ and3_2_3(WR3_2_3_neg, WR, WR_block3, WR_way2, WR_byte[3]);
	and4$ and3_3_0(WR3_3_0_neg, WR, WR_block3, WR_way3, WR_byte[0]);
	and4$ and3_3_1(WR3_3_1_neg, WR, WR_block3, WR_way3, WR_byte[1]);
	and4$ and3_3_2(WR3_3_2_neg, WR, WR_block3, WR_way3, WR_byte[2]);
	and4$ and3_3_3(WR3_3_3_neg, WR, WR_block3, WR_way3, WR_byte[3]);

	and4$ and4_1_0(WR4_1_0_neg, WR, WR_block4, WR_way1, WR_byte[0]);
	and4$ and4_1_1(WR4_1_1_neg, WR, WR_block4, WR_way1, WR_byte[1]);
	and4$ and4_1_2(WR4_1_2_neg, WR, WR_block4, WR_way1, WR_byte[2]);
	and4$ and4_1_3(WR4_1_3_neg, WR, WR_block4, WR_way1, WR_byte[3]);
	and4$ and4_2_0(WR4_2_0_neg, WR, WR_block4, WR_way2, WR_byte[0]);
	and4$ and4_2_1(WR4_2_1_neg, WR, WR_block4, WR_way2, WR_byte[1]);
	and4$ and4_2_2(WR4_2_2_neg, WR, WR_block4, WR_way2, WR_byte[2]);
	and4$ and4_2_3(WR4_2_3_neg, WR, WR_block4, WR_way2, WR_byte[3]);
	and4$ and4_3_0(WR4_3_0_neg, WR, WR_block4, WR_way3, WR_byte[0]);
	and4$ and4_3_1(WR4_3_1_neg, WR, WR_block4, WR_way3, WR_byte[1]);
	and4$ and4_3_2(WR4_3_2_neg, WR, WR_block4, WR_way3, WR_byte[2]);
	and4$ and4_3_3(WR4_3_3_neg, WR, WR_block4, WR_way3, WR_byte[3]);

	and4$ and5_1_0(WR5_1_0_neg, WR, WR_block5, WR_way1, WR_byte[0]);
	and4$ and5_1_1(WR5_1_1_neg, WR, WR_block5, WR_way1, WR_byte[1]);
	and4$ and5_1_2(WR5_1_2_neg, WR, WR_block5, WR_way1, WR_byte[2]);
	and4$ and5_1_3(WR5_1_3_neg, WR, WR_block5, WR_way1, WR_byte[3]);
	and4$ and5_2_0(WR5_2_0_neg, WR, WR_block5, WR_way2, WR_byte[0]);
	and4$ and5_2_1(WR5_2_1_neg, WR, WR_block5, WR_way2, WR_byte[1]);
	and4$ and5_2_2(WR5_2_2_neg, WR, WR_block5, WR_way2, WR_byte[2]);
	and4$ and5_2_3(WR5_2_3_neg, WR, WR_block5, WR_way2, WR_byte[3]);
	and4$ and5_3_0(WR5_3_0_neg, WR, WR_block5, WR_way3, WR_byte[0]);
	and4$ and5_3_1(WR5_3_1_neg, WR, WR_block5, WR_way3, WR_byte[1]);
	and4$ and5_3_2(WR5_3_2_neg, WR, WR_block5, WR_way3, WR_byte[2]);
	and4$ and5_3_3(WR5_3_3_neg, WR, WR_block5, WR_way3, WR_byte[3]);

	and4$ and6_1_0(WR6_1_0_neg, WR, WR_block6, WR_way1, WR_byte[0]);
	and4$ and6_1_1(WR6_1_1_neg, WR, WR_block6, WR_way1, WR_byte[1]);
	and4$ and6_1_2(WR6_1_2_neg, WR, WR_block6, WR_way1, WR_byte[2]);
	and4$ and6_1_3(WR6_1_3_neg, WR, WR_block6, WR_way1, WR_byte[3]);
	and4$ and6_2_0(WR6_2_0_neg, WR, WR_block6, WR_way2, WR_byte[0]);
	and4$ and6_2_1(WR6_2_1_neg, WR, WR_block6, WR_way2, WR_byte[1]);
	and4$ and6_2_2(WR6_2_2_neg, WR, WR_block6, WR_way2, WR_byte[2]);
	and4$ and6_2_3(WR6_2_3_neg, WR, WR_block6, WR_way2, WR_byte[3]);
	and4$ and6_3_0(WR6_3_0_neg, WR, WR_block6, WR_way3, WR_byte[0]);
	and4$ and6_3_1(WR6_3_1_neg, WR, WR_block6, WR_way3, WR_byte[1]);
	and4$ and6_3_2(WR6_3_2_neg, WR, WR_block6, WR_way3, WR_byte[2]);
	and4$ and6_3_3(WR6_3_3_neg, WR, WR_block6, WR_way3, WR_byte[3]);

	and4$ and7_1_0(WR7_1_0_neg, WR, WR_block7, WR_way1, WR_byte[0]);
	and4$ and7_1_1(WR7_1_1_neg, WR, WR_block7, WR_way1, WR_byte[1]);
	and4$ and7_1_2(WR7_1_2_neg, WR, WR_block7, WR_way1, WR_byte[2]);
	and4$ and7_1_3(WR7_1_3_neg, WR, WR_block7, WR_way1, WR_byte[3]);
	and4$ and7_2_0(WR7_2_0_neg, WR, WR_block7, WR_way2, WR_byte[0]);
	and4$ and7_2_1(WR7_2_1_neg, WR, WR_block7, WR_way2, WR_byte[1]);
	and4$ and7_2_2(WR7_2_2_neg, WR, WR_block7, WR_way2, WR_byte[2]);
	and4$ and7_2_3(WR7_2_3_neg, WR, WR_block7, WR_way2, WR_byte[3]);
	and4$ and7_3_0(WR7_3_0_neg, WR, WR_block7, WR_way3, WR_byte[0]);
	and4$ and7_3_1(WR7_3_1_neg, WR, WR_block7, WR_way3, WR_byte[1]);
	and4$ and7_3_2(WR7_3_2_neg, WR, WR_block7, WR_way3, WR_byte[2]);
	and4$ and7_3_3(WR7_3_3_neg, WR, WR_block7, WR_way3, WR_byte[3]);

	and4$ and8_1_0(WR8_1_0_neg, WR, WR_block8, WR_way1, WR_byte[0]);
	and4$ and8_1_1(WR8_1_1_neg, WR, WR_block8, WR_way1, WR_byte[1]);
	and4$ and8_1_2(WR8_1_2_neg, WR, WR_block8, WR_way1, WR_byte[2]);
	and4$ and8_1_3(WR8_1_3_neg, WR, WR_block8, WR_way1, WR_byte[3]);
	and4$ and8_2_0(WR8_2_0_neg, WR, WR_block8, WR_way2, WR_byte[0]);
	and4$ and8_2_1(WR8_2_1_neg, WR, WR_block8, WR_way2, WR_byte[1]);
	and4$ and8_2_2(WR8_2_2_neg, WR, WR_block8, WR_way2, WR_byte[2]);
	and4$ and8_2_3(WR8_2_3_neg, WR, WR_block8, WR_way2, WR_byte[3]);
	and4$ and8_3_0(WR8_3_0_neg, WR, WR_block8, WR_way3, WR_byte[0]);
	and4$ and8_3_1(WR8_3_1_neg, WR, WR_block8, WR_way3, WR_byte[1]);
	and4$ and8_3_2(WR8_3_2_neg, WR, WR_block8, WR_way3, WR_byte[2]);
	and4$ and8_3_3(WR8_3_3_neg, WR, WR_block8, WR_way3, WR_byte[3]);

	inv1$ inv1_1(WR1_1_0, WR1_1_0_neg);
	inv1$ inv1_2(WR1_1_1, WR1_1_1_neg);
	inv1$ inv1_3(WR1_1_2, WR1_1_2_neg);
	inv1$ inv1_4(WR1_1_3, WR1_1_3_neg);
	inv1$ inv1_5(WR1_2_0, WR1_2_0_neg);
	inv1$ inv1_6(WR1_2_1, WR1_2_1_neg);
	inv1$ inv1_7(WR1_2_2, WR1_2_2_neg);
	inv1$ inv1_8(WR1_2_3, WR1_2_3_neg);
	inv1$ inv1_9(WR1_3_0, WR1_3_0_neg);
	inv1$ inv1_a(WR1_3_1, WR1_3_1_neg);
	inv1$ inv1_b(WR1_3_2, WR1_3_2_neg);
	inv1$ inv1_c(WR1_3_3, WR1_3_3_neg);

	inv1$ inv2_1(WR2_1_0, WR2_1_0_neg);
	inv1$ inv2_2(WR2_1_1, WR2_1_1_neg);
	inv1$ inv2_3(WR2_1_2, WR2_1_2_neg);
	inv1$ inv2_4(WR2_1_3, WR2_1_3_neg);
	inv1$ inv2_5(WR2_2_0, WR2_2_0_neg);
	inv1$ inv2_6(WR2_2_1, WR2_2_1_neg);
	inv1$ inv2_7(WR2_2_2, WR2_2_2_neg);
	inv1$ inv2_8(WR2_2_3, WR2_2_3_neg);
	inv1$ inv2_9(WR2_3_0, WR2_3_0_neg);
	inv1$ inv2_a(WR2_3_1, WR2_3_1_neg);
	inv1$ inv2_b(WR2_3_2, WR2_3_2_neg);
	inv1$ inv2_c(WR2_3_3, WR2_3_3_neg);

	inv1$ inv3_1(WR3_1_0, WR3_1_0_neg);
	inv1$ inv3_2(WR3_1_1, WR3_1_1_neg);
	inv1$ inv3_3(WR3_1_2, WR3_1_2_neg);
	inv1$ inv3_4(WR3_1_3, WR3_1_3_neg);
	inv1$ inv3_5(WR3_2_0, WR3_2_0_neg);
	inv1$ inv3_6(WR3_2_1, WR3_2_1_neg);
	inv1$ inv3_7(WR3_2_2, WR3_2_2_neg);
	inv1$ inv3_8(WR3_2_3, WR3_2_3_neg);
	inv1$ inv3_9(WR3_3_0, WR3_3_0_neg);
	inv1$ inv3_a(WR3_3_1, WR3_3_1_neg);
	inv1$ inv3_b(WR3_3_2, WR3_3_2_neg);
	inv1$ inv3_c(WR3_3_3, WR3_3_3_neg);

	inv1$ inv4_1(WR4_1_0, WR4_1_0_neg);
	inv1$ inv4_2(WR4_1_1, WR4_1_1_neg);
	inv1$ inv4_3(WR4_1_2, WR4_1_2_neg);
	inv1$ inv4_4(WR4_1_3, WR4_1_3_neg);
	inv1$ inv4_5(WR4_2_0, WR4_2_0_neg);
	inv1$ inv4_6(WR4_2_1, WR4_2_1_neg);
	inv1$ inv4_7(WR4_2_2, WR4_2_2_neg);
	inv1$ inv4_8(WR4_2_3, WR4_2_3_neg);
	inv1$ inv4_9(WR4_3_0, WR4_3_0_neg);
	inv1$ inv4_a(WR4_3_1, WR4_3_1_neg);
	inv1$ inv4_b(WR4_3_2, WR4_3_2_neg);
	inv1$ inv4_c(WR4_3_3, WR4_3_3_neg);

	inv1$ inv5_1(WR5_1_0, WR5_1_0_neg);
	inv1$ inv5_2(WR5_1_1, WR5_1_1_neg);
	inv1$ inv5_3(WR5_1_2, WR5_1_2_neg);
	inv1$ inv5_4(WR5_1_3, WR5_1_3_neg);
	inv1$ inv5_5(WR5_2_0, WR5_2_0_neg);
	inv1$ inv5_6(WR5_2_1, WR5_2_1_neg);
	inv1$ inv5_7(WR5_2_2, WR5_2_2_neg);
	inv1$ inv5_8(WR5_2_3, WR5_2_3_neg);
	inv1$ inv5_9(WR5_3_0, WR5_3_0_neg);
	inv1$ inv5_a(WR5_3_1, WR5_3_1_neg);
	inv1$ inv5_b(WR5_3_2, WR5_3_2_neg);
	inv1$ inv5_c(WR5_3_3, WR5_3_3_neg);

	inv1$ inv6_1(WR6_1_0, WR6_1_0_neg);
	inv1$ inv6_2(WR6_1_1, WR6_1_1_neg);
	inv1$ inv6_3(WR6_1_2, WR6_1_2_neg);
	inv1$ inv6_4(WR6_1_3, WR6_1_3_neg);
	inv1$ inv6_5(WR6_2_0, WR6_2_0_neg);
	inv1$ inv6_6(WR6_2_1, WR6_2_1_neg);
	inv1$ inv6_7(WR6_2_2, WR6_2_2_neg);
	inv1$ inv6_8(WR6_2_3, WR6_2_3_neg);
	inv1$ inv6_9(WR6_3_0, WR6_3_0_neg);
	inv1$ inv6_a(WR6_3_1, WR6_3_1_neg);
	inv1$ inv6_b(WR6_3_2, WR6_3_2_neg);
	inv1$ inv6_c(WR6_3_3, WR6_3_3_neg);

	inv1$ inv7_1(WR7_1_0, WR7_1_0_neg);
	inv1$ inv7_2(WR7_1_1, WR7_1_1_neg);
	inv1$ inv7_3(WR7_1_2, WR7_1_2_neg);
	inv1$ inv7_4(WR7_1_3, WR7_1_3_neg);
	inv1$ inv7_5(WR7_2_0, WR7_2_0_neg);
	inv1$ inv7_6(WR7_2_1, WR7_2_1_neg);
	inv1$ inv7_7(WR7_2_2, WR7_2_2_neg);
	inv1$ inv7_8(WR7_2_3, WR7_2_3_neg);
	inv1$ inv7_9(WR7_3_0, WR7_3_0_neg);
	inv1$ inv7_a(WR7_3_1, WR7_3_1_neg);
	inv1$ inv7_b(WR7_3_2, WR7_3_2_neg);
	inv1$ inv7_c(WR7_3_3, WR7_3_3_neg);

	inv1$ inv8_1(WR8_1_0, WR8_1_0_neg);
	inv1$ inv8_2(WR8_1_1, WR8_1_1_neg);
	inv1$ inv8_3(WR8_1_2, WR8_1_2_neg);
	inv1$ inv8_4(WR8_1_3, WR8_1_3_neg);
	inv1$ inv8_5(WR8_2_0, WR8_2_0_neg);
	inv1$ inv8_6(WR8_2_1, WR8_2_1_neg);
	inv1$ inv8_7(WR8_2_2, WR8_2_2_neg);
	inv1$ inv8_8(WR8_2_3, WR8_2_3_neg);
	inv1$ inv8_9(WR8_3_0, WR8_3_0_neg);
	inv1$ inv8_a(WR8_3_1, WR8_3_1_neg);
	inv1$ inv8_b(WR8_3_2, WR8_3_2_neg);
	inv1$ inv8_c(WR8_3_3, WR8_3_3_neg);

	ram8b8w$ DCdataArray1_1(setIndex[2:0], dataIn[7:0], OE, WR1_1_0, dataOut1[7:0]);
	ram8b8w$ DCdataArray1_2(setIndex[2:0], dataIn[15:8], OE, WR1_1_1, dataOut1[15:8]);
	ram8b8w$ DCdataArray1_3(setIndex[2:0], dataIn[23:16], OE, WR1_1_2, dataOut1[23:16]);
	ram8b8w$ DCdataArray1_4(setIndex[2:0], dataIn[31:24], OE, WR1_1_3, dataOut1[31:24]);
	ram8b8w$ DCdataArray1_5(setIndex[2:0], dataIn[7:0], OE, WR1_2_0, dataOut1[39:32]);
	ram8b8w$ DCdataArray1_6(setIndex[2:0], dataIn[15:8], OE, WR1_2_1, dataOut1[47:40]);
	ram8b8w$ DCdataArray1_7(setIndex[2:0], dataIn[23:16], OE, WR1_2_2, dataOut1[55:48]);
	ram8b8w$ DCdataArray1_8(setIndex[2:0], dataIn[31:24], OE, WR1_2_3, dataOut1[63:56]);
	ram8b8w$ DCdataArray1_9(setIndex[2:0], dataIn[7:0], OE, WR1_3_0, dataOut1[71:64]);
	ram8b8w$ DCdataArray1_a(setIndex[2:0], dataIn[15:8], OE, WR1_3_1, dataOut1[79:72]);
	ram8b8w$ DCdataArray1_b(setIndex[2:0], dataIn[23:16], OE, WR1_3_2, dataOut1[87:80]);
	ram8b8w$ DCdataArray1_c(setIndex[2:0], dataIn[31:24], OE, WR1_3_3, dataOut1[95:88]);

	ram8b8w$ DCdataArray2_1(setIndex[2:0], dataIn[7:0], OE, WR2_1_0, dataOut2[7:0]);
	ram8b8w$ DCdataArray2_2(setIndex[2:0], dataIn[15:8], OE, WR2_1_1, dataOut2[15:8]);
	ram8b8w$ DCdataArray2_3(setIndex[2:0], dataIn[23:16], OE, WR2_1_2, dataOut2[23:16]);
	ram8b8w$ DCdataArray2_4(setIndex[2:0], dataIn[31:24], OE, WR2_1_3, dataOut2[31:24]);
	ram8b8w$ DCdataArray2_5(setIndex[2:0], dataIn[7:0], OE, WR2_2_0, dataOut2[39:32]);
	ram8b8w$ DCdataArray2_6(setIndex[2:0], dataIn[15:8], OE, WR2_2_1, dataOut2[47:40]);
	ram8b8w$ DCdataArray2_7(setIndex[2:0], dataIn[23:16], OE, WR2_2_2, dataOut2[55:48]);
	ram8b8w$ DCdataArray2_8(setIndex[2:0], dataIn[31:24], OE, WR2_2_3, dataOut2[63:56]);
	ram8b8w$ DCdataArray2_9(setIndex[2:0], dataIn[7:0], OE, WR2_3_0, dataOut2[71:64]);
	ram8b8w$ DCdataArray2_a(setIndex[2:0], dataIn[15:8], OE, WR2_3_1, dataOut2[79:72]);
	ram8b8w$ DCdataArray2_b(setIndex[2:0], dataIn[23:16], OE, WR2_3_2, dataOut2[87:80]);
	ram8b8w$ DCdataArray2_c(setIndex[2:0], dataIn[31:24], OE, WR2_3_3, dataOut2[95:88]);

	ram8b8w$ DCdataArray3_1(setIndex[2:0], dataIn[7:0], OE, WR3_1_0, dataOut3[7:0]);
	ram8b8w$ DCdataArray3_2(setIndex[2:0], dataIn[15:8], OE, WR3_1_1, dataOut3[15:8]);
	ram8b8w$ DCdataArray3_3(setIndex[2:0], dataIn[23:16], OE, WR3_1_2, dataOut3[23:16]);
	ram8b8w$ DCdataArray3_4(setIndex[2:0], dataIn[31:24], OE, WR3_1_3, dataOut3[31:24]);
	ram8b8w$ DCdataArray3_5(setIndex[2:0], dataIn[7:0], OE, WR3_2_0, dataOut3[39:32]);
	ram8b8w$ DCdataArray3_6(setIndex[2:0], dataIn[15:8], OE, WR3_2_1, dataOut3[47:40]);
	ram8b8w$ DCdataArray3_7(setIndex[2:0], dataIn[23:16], OE, WR3_2_2, dataOut3[55:48]);
	ram8b8w$ DCdataArray3_8(setIndex[2:0], dataIn[31:24], OE, WR3_2_3, dataOut3[63:56]);
	ram8b8w$ DCdataArray3_9(setIndex[2:0], dataIn[7:0], OE, WR3_3_0, dataOut3[71:64]);
	ram8b8w$ DCdataArray3_a(setIndex[2:0], dataIn[15:8], OE, WR3_3_1, dataOut3[79:72]);
	ram8b8w$ DCdataArray3_b(setIndex[2:0], dataIn[23:16], OE, WR3_3_2, dataOut3[87:80]);
	ram8b8w$ DCdataArray3_c(setIndex[2:0], dataIn[31:24], OE, WR3_3_3, dataOut3[95:88]);

	ram8b8w$ DCdataArray4_1(setIndex[2:0], dataIn[7:0], OE, WR4_1_0, dataOut4[7:0]);
	ram8b8w$ DCdataArray4_2(setIndex[2:0], dataIn[15:8], OE, WR4_1_1, dataOut4[15:8]);
	ram8b8w$ DCdataArray4_3(setIndex[2:0], dataIn[23:16], OE, WR4_1_2, dataOut4[23:16]);
	ram8b8w$ DCdataArray4_4(setIndex[2:0], dataIn[31:24], OE, WR4_1_3, dataOut4[31:24]);
	ram8b8w$ DCdataArray4_5(setIndex[2:0], dataIn[7:0], OE, WR4_2_0, dataOut4[39:32]);
	ram8b8w$ DCdataArray4_6(setIndex[2:0], dataIn[15:8], OE, WR4_2_1, dataOut4[47:40]);
	ram8b8w$ DCdataArray4_7(setIndex[2:0], dataIn[23:16], OE, WR4_2_2, dataOut4[55:48]);
	ram8b8w$ DCdataArray4_8(setIndex[2:0], dataIn[31:24], OE, WR4_2_3, dataOut4[63:56]);
	ram8b8w$ DCdataArray4_9(setIndex[2:0], dataIn[7:0], OE, WR4_3_0, dataOut4[71:64]);
	ram8b8w$ DCdataArray4_a(setIndex[2:0], dataIn[15:8], OE, WR4_3_1, dataOut4[79:72]);
	ram8b8w$ DCdataArray4_b(setIndex[2:0], dataIn[23:16], OE, WR4_3_2, dataOut4[87:80]);
	ram8b8w$ DCdataArray4_c(setIndex[2:0], dataIn[31:24], OE, WR4_3_3, dataOut4[95:88]);

	ram8b8w$ DCdataArray5_1(setIndex[2:0], dataIn[7:0], OE, WR5_1_0, dataOut5[7:0]);
	ram8b8w$ DCdataArray5_2(setIndex[2:0], dataIn[15:8], OE, WR5_1_1, dataOut5[15:8]);
	ram8b8w$ DCdataArray5_3(setIndex[2:0], dataIn[23:16], OE, WR5_1_2, dataOut5[23:16]);
	ram8b8w$ DCdataArray5_4(setIndex[2:0], dataIn[31:24], OE, WR5_1_3, dataOut5[31:24]);
	ram8b8w$ DCdataArray5_5(setIndex[2:0], dataIn[7:0], OE, WR5_2_0, dataOut5[39:32]);
	ram8b8w$ DCdataArray5_6(setIndex[2:0], dataIn[15:8], OE, WR5_2_1, dataOut5[47:40]);
	ram8b8w$ DCdataArray5_7(setIndex[2:0], dataIn[23:16], OE, WR5_2_2, dataOut5[55:48]);
	ram8b8w$ DCdataArray5_8(setIndex[2:0], dataIn[31:24], OE, WR5_2_3, dataOut5[63:56]);
	ram8b8w$ DCdataArray5_9(setIndex[2:0], dataIn[7:0], OE, WR5_3_0, dataOut5[71:64]);
	ram8b8w$ DCdataArray5_a(setIndex[2:0], dataIn[15:8], OE, WR5_3_1, dataOut5[79:72]);
	ram8b8w$ DCdataArray5_b(setIndex[2:0], dataIn[23:16], OE, WR5_3_2, dataOut5[87:80]);
	ram8b8w$ DCdataArray5_c(setIndex[2:0], dataIn[31:24], OE, WR5_3_3, dataOut5[95:88]);

	ram8b8w$ DCdataArray6_1(setIndex[2:0], dataIn[7:0], OE, WR6_1_0, dataOut6[7:0]);
	ram8b8w$ DCdataArray6_2(setIndex[2:0], dataIn[15:8], OE, WR6_1_1, dataOut6[15:8]);
	ram8b8w$ DCdataArray6_3(setIndex[2:0], dataIn[23:16], OE, WR6_1_2, dataOut6[23:16]);
	ram8b8w$ DCdataArray6_4(setIndex[2:0], dataIn[31:24], OE, WR6_1_3, dataOut6[31:24]);
	ram8b8w$ DCdataArray6_5(setIndex[2:0], dataIn[7:0], OE, WR6_2_0, dataOut6[39:32]);
	ram8b8w$ DCdataArray6_6(setIndex[2:0], dataIn[15:8], OE, WR6_2_1, dataOut6[47:40]);
	ram8b8w$ DCdataArray6_7(setIndex[2:0], dataIn[23:16], OE, WR6_2_2, dataOut6[55:48]);
	ram8b8w$ DCdataArray6_8(setIndex[2:0], dataIn[31:24], OE, WR6_2_3, dataOut6[63:56]);
	ram8b8w$ DCdataArray6_9(setIndex[2:0], dataIn[7:0], OE, WR6_3_0, dataOut6[71:64]);
	ram8b8w$ DCdataArray6_a(setIndex[2:0], dataIn[15:8], OE, WR6_3_1, dataOut6[79:72]);
	ram8b8w$ DCdataArray6_b(setIndex[2:0], dataIn[23:16], OE, WR6_3_2, dataOut6[87:80]);
	ram8b8w$ DCdataArray6_c(setIndex[2:0], dataIn[31:24], OE, WR6_3_3, dataOut6[95:88]);

	ram8b8w$ DCdataArray7_1(setIndex[2:0], dataIn[7:0], OE, WR7_1_0, dataOut7[7:0]);
	ram8b8w$ DCdataArray7_2(setIndex[2:0], dataIn[15:8], OE, WR7_1_1, dataOut7[15:8]);
	ram8b8w$ DCdataArray7_3(setIndex[2:0], dataIn[23:16], OE, WR7_1_2, dataOut7[23:16]);
	ram8b8w$ DCdataArray7_4(setIndex[2:0], dataIn[31:24], OE, WR7_1_3, dataOut7[31:24]);
	ram8b8w$ DCdataArray7_5(setIndex[2:0], dataIn[7:0], OE, WR7_2_0, dataOut7[39:32]);
	ram8b8w$ DCdataArray7_6(setIndex[2:0], dataIn[15:8], OE, WR7_2_1, dataOut7[47:40]);
	ram8b8w$ DCdataArray7_7(setIndex[2:0], dataIn[23:16], OE, WR7_2_2, dataOut7[55:48]);
	ram8b8w$ DCdataArray7_8(setIndex[2:0], dataIn[31:24], OE, WR7_2_3, dataOut7[63:56]);
	ram8b8w$ DCdataArray7_9(setIndex[2:0], dataIn[7:0], OE, WR7_3_0, dataOut7[71:64]);
	ram8b8w$ DCdataArray7_a(setIndex[2:0], dataIn[15:8], OE, WR7_3_1, dataOut7[79:72]);
	ram8b8w$ DCdataArray7_b(setIndex[2:0], dataIn[23:16], OE, WR7_3_2, dataOut7[87:80]);
	ram8b8w$ DCdataArray7_c(setIndex[2:0], dataIn[31:24], OE, WR7_3_3, dataOut7[95:88]);

	ram8b8w$ DCdataArray8_1(setIndex[2:0], dataIn[7:0], OE, WR8_1_0, dataOut8[7:0]);
	ram8b8w$ DCdataArray8_2(setIndex[2:0], dataIn[15:8], OE, WR8_1_1, dataOut8[15:8]);
	ram8b8w$ DCdataArray8_3(setIndex[2:0], dataIn[23:16], OE, WR8_1_2, dataOut8[23:16]);
	ram8b8w$ DCdataArray8_4(setIndex[2:0], dataIn[31:24], OE, WR8_1_3, dataOut8[31:24]);
	ram8b8w$ DCdataArray8_5(setIndex[2:0], dataIn[7:0], OE, WR8_2_0, dataOut8[39:32]);
	ram8b8w$ DCdataArray8_6(setIndex[2:0], dataIn[15:8], OE, WR8_2_1, dataOut8[47:40]);
	ram8b8w$ DCdataArray8_7(setIndex[2:0], dataIn[23:16], OE, WR8_2_2, dataOut8[55:48]);
	ram8b8w$ DCdataArray8_8(setIndex[2:0], dataIn[31:24], OE, WR8_2_3, dataOut8[63:56]);
	ram8b8w$ DCdataArray8_9(setIndex[2:0], dataIn[7:0], OE, WR8_3_0, dataOut8[71:64]);
	ram8b8w$ DCdataArray8_a(setIndex[2:0], dataIn[15:8], OE, WR8_3_1, dataOut8[79:72]);
	ram8b8w$ DCdataArray8_b(setIndex[2:0], dataIn[23:16], OE, WR8_3_2, dataOut8[87:80]);
	ram8b8w$ DCdataArray8_c(setIndex[2:0], dataIn[31:24], OE, WR8_3_3, dataOut8[95:88]);

	mux4_96 mux1(temp_data1, dataOut1, dataOut3, dataOut2, dataOut4, setIndex[4:3]);
	mux4_96 mux2(temp_data2, dataOut5, dataOut7, dataOut6, dataOut8, setIndex[4:3]);
	mux2_96 mux3(dataOut, temp_data1, temp_data2, setIndex[5]);
endmodule

module DCDataLogic(evict_wayId, DAdataOut, evict_data);
	input[1:0] evict_wayId;
	input[95:0] DAdataOut;
	output[31:0] evict_data;

	mux3_32 mux1(evict_data, DAdataOut[31:0], DAdataOut[95:64], DAdataOut[63:32], evict_wayId);
endmodule

module DCTagCCLogic(Tags, CCStatus, address, DCWR, CMT_DMA_Init, DChit, evict, DAIndex, LRB_wayId, LRB_address, evict_address, newCCStatus1, evicted_wayId);
	input[23:0] Tags;
	input[5:0] CCStatus;
	input[31:0] address;// the address to be read from or written into
	input DCWR; // is a D$ write (1) or read(0)
	input CMT_DMA_Init; // is it a DMA commit now?
	output DChit;
	output evict;
	output[1:0] DAIndex; // index to the mux of the Data Array, selecting the correct line..
	output[1:0] LRB_wayId, evicted_wayId;
	output[31:0] LRB_address, evict_address;
	output[1:0] newCCStatus1;

	wire[7:0] evicted_tag_temp;
	wire[6:0] tagField, evicted_tag;
	wire[5:0] setIndex;
	wire[1:0] lineOffset;
	wire g0, s0, g1, s1, g2, s2, e0, e1, e2;
	wire shared0, shared1, shared2, modified0, modified1, modified2, invalid0, invalid1, invalid2;
	wire choose0, choose1, choose2;
	wire lineOffset1_inv;
	wire CCStatus0_inv, CCStatus1_inv, CCStatus2_inv, CCStatus3_inv, CCStatus4_inv, CCStatus5_inv;

	assign tagField = address[14:8];
	assign setIndex = address[7:2];
	assign lineOffset = address[1:0];
	// as of now, always evict is the line offset saturating at 2'b10.  TODO: implement a realistic replacement policy...
	wire[1:0] evicted_wayId_temp;
	assign evicted_wayId_temp[1] = lineOffset[1];
	inv1$ inv1_1(lineOffset1_inv, lineOffset[1]);
	and2$ and1_1(evicted_wayId_temp[0], lineOffset1_inv, lineOffset[0]);
	//assign evicted_wayId[0] = ~lineOffset[1] & lineOffset[0];
	mux2_2 mux3(evicted_wayId, evicted_wayId_temp, DAIndex, CMT_DMA_Init);

	inv1$ inv2_1(CCStatus0_inv, CCStatus[0]);
	inv1$ inv2_2(CCStatus1_inv, CCStatus[1]);
	inv1$ inv2_3(CCStatus2_inv, CCStatus[2]);
	inv1$ inv2_4(CCStatus3_inv, CCStatus[3]);
	inv1$ inv2_5(CCStatus4_inv, CCStatus[4]);
	inv1$ inv2_6(CCStatus5_inv, CCStatus[5]);

	//valid-10
	//assign shared0 = CCStatus[0] & ~CCStatus[1];
	//assign shared1 = CCStatus[2] & ~CCStatus[3];
	//assign shared2 = CCStatus[4] & ~CCStatus[5];
	and2$ and2_1(shared0, CCStatus[1], CCStatus0_inv);
	and2$ and2_2(shared1, CCStatus[3], CCStatus2_inv);
	and2$ and2_3(shared2, CCStatus[5], CCStatus4_inv);
	//dirty-01
	//assign modified0 = CCStatus[0] & ~CCStatus[1];
	//assign modified1 = CCStatus[2] & ~CCStatus[3];
	//assign modified2 = CCStatus[4] & ~CCStatus[5];
	and2$ and3_1(modified0, CCStatus[1], CCStatus0_inv);
	and2$ and3_2(modified1, CCStatus[3], CCStatus2_inv);
	and2$ and3_3(modified2, CCStatus[5], CCStatus4_inv);
	//invalid-00
	//assign invalid0 = ~CCStatus[0] & ~CCStatus[1];
	//assign invalid1 = ~CCStatus[2] & ~CCStatus[3];
	//assign invalid2 = ~CCStatus[4] & ~CCStatus[5];
	and2$ and4_1(invalid0, CCStatus1_inv, CCStatus0_inv);
	and2$ and4_2(invalid1, CCStatus3_inv, CCStatus2_inv);
	and2$ and4_3(invalid2, CCStatus5_inv, CCStatus4_inv);

	mag_comp8$ comp1({1'b0, tagField}, {1'b0, Tags[6:0]}, g0, s0);
	mag_comp8$ comp2({1'b0, tagField}, {1'b0, Tags[14:8]}, g1, s1);
	mag_comp8$ comp3({1'b0, tagField}, {1'b0, Tags[22:16]}, g2, s2);
	wire g0_inv, g1_inv, g2_inv, s0_inv, s1_inv, s2_inv;
	wire invalid0_inv, invalid1_inv, invalid2_inv;
	//assign e0 = ~g0 & ~s0;
	//assign e1 = ~g1 & ~s1;
	//assign e2 = ~g2 & ~s2;
	//assign choose0 = (e0 & ~invalid0);
	//assign choose1 = (e1 & ~invalid1);
	//assign choose2 = (e2 & ~invalid2);
	inv1$ inv3_1(g0_inv, g0);
	inv1$ inv3_2(g1_inv, g1);
	inv1$ inv3_3(g2_inv, g2);
	inv1$ inv3_4(s0_inv, s0);
	inv1$ inv3_5(s1_inv, s1);
	inv1$ inv3_6(s2_inv, s2);
	and2$ and5_1(e0, g0_inv, s0_inv);
	and2$ and5_2(e1, g1_inv, s1_inv);
	and2$ and5_3(e2, g2_inv, s2_inv);
	inv1$ inv4_1(invalid0_inv, invalid0);
	inv1$ inv4_2(invalid1_inv, invalid1);
	inv1$ inv4_3(invalid2_inv, invalid2);
	and2$ and5_4(choose0, e0, invalid0_inv);
	and2$ and5_5(choose1, e1, invalid1_inv);
	and2$ and5_6(choose2, e2, invalid2_inv);

	//assign DChit = choose0 | choose1 | choose2;
	or3$ or6_1(DChit, choose0, choose1, choose2);
	assign DAIndex[0] = choose1;
	assign DAIndex[1] = choose2;
	wire DCWR_inv, DChit_inv;
	inv1$ inv5_1(DCWR_inv, DCWR);
	inv1$ inv5_2(DChit_inv, DChit);
	//assign evict = ~invalid0 & ~invalid1 & ~invalid2 & (~DCWR & ~DChit);
	and5$ and6_1(evict, invalid0_inv, invalid1_inv, invalid2_inv, DCWR_inv, DChit_inv);
	assign LRB_address = address;

	//if eviction is needed, LRB_wayId = evicted_wayId;  For realistic
	//replacement, the logic of LRB_wayId has to be changed accordingly
	//assign LRB_wayId[0] = (invalid2 & invalid1 & ~invalid0) | (~invalid2 & invalid1 & ~invalid0) | (~invalid2 & ~invalid1 & ~invalid0 & evicted_wayId[0]);
	wire LRB_wayId0_temp0, LRB_wayId0_temp1, LRB_wayId0_temp2;
	and3$ and7_1(LRB_wayId0_temp0, invalid2, invalid1, invalid0_inv);
	and3$ and7_2(LRB_wayId0_temp1, invalid2_inv, invalid1, invalid0_inv);
	and4$ and7_3(LRB_wayId0_temp2, invalid2_inv, invalid1_inv, invalid0_inv, evicted_wayId[0]);
	or3$ or8_1(LRB_wayId[0], LRB_wayId0_temp0, LRB_wayId0_temp1, LRB_wayId0_temp2);

	//assign LRB_wayId[1] = (invalid2 & ~invalid1 & ~invalid0) | (~invalid2 & ~invalid1 & ~invalid0 & evicted_wayId[1]);
	wire LRB_wayId1_temp0, LRB_wayId1_temp1;
	and3$ and9_1(LRB_wayId1_temp0, invalid2, invalid1_inv, invalid0_inv);
	and4$ and9_2(LRB_wayId1_temp1, invalid2_inv, invalid1_inv, invalid0_inv, evicted_wayId[1]);
	or2$ or10_1(LRB_wayId[1], LRB_wayId1_temp0, LRB_wayId1_temp1);

	mux3_8$ mux1(evicted_tag_temp, {1'b0, Tags[6:0]}, {1'b0, Tags[22:16]}, {1'b0, Tags[14:8]}, evicted_wayId[1], evicted_wayId[0]);
	assign evicted_tag = evicted_tag_temp[6:0];
	assign evict_address = {evicted_tag, setIndex, 2'b00}; // reconstruct the word-aligned address of the original data in way0

	//cc states are initialized to invalid, but can't be written as invalid, unless cache controller flushes it because of DMA intervention..
	//RH keeps CC states; RM leads to line refill which will write CC states
	//later; WM bypasses cache; only WH overwrite old CC bits (to dirty)
	//assign newCCStatus1 = 2'b01;
	mux2_2 mux2(newCCStatus1, 2'b01, 2'b00, CMT_DMA_Init);
	//mux3_24 mux1(newCCStatus1, {CCStatus[5:2], 2'b01}, {2'b01, CCStatus[3:0]}, {CCStatus[5:4], 2'b01, CCStatus[1:0]}, DAIndex); // DAIndex indicates which line is to be written to
endmodule

module LineRefillBuffeLogic(LRB_wayId, LRB_address, LRB_dataIn, ld_LRB, LRB_back_wayId, LRB_back_address, memory_data_lrb, clk, clr);
	input[1:0] LRB_wayId;
	input[31:0] LRB_address;
	input[31:0] memory_data_lrb;
	input ld_LRB, clk, clr;
	output[1:0] LRB_back_wayId;
	output[31:0] LRB_back_address;
	output[31:0] LRB_dataIn;

	dff_2 dff1(clk, LRB_wayId, LRB_back_wayId, clr, ld_LRB);
	dff_32 dff2(clk, LRB_address, LRB_back_address, clr, ld_LRB);
	//dff_32 dff3(clk, memory_data_lrb, LRB_dataIn, clr, ld_LRB);
	assign LRB_dataIn = memory_data_lrb;
endmodule

module WriteBufferLogic(WB_mem_we, WB_address, WB_data, ld_WB, memory_we_wb, memory_address_wb, memory_data_wb, WB_Valid, clk, clr_wb, clr);
	input[3:0] WB_mem_we;
	input[31:0] WB_address;
	input[31:0] WB_data;
	input ld_WB, clk, clr_wb, clr;
	output WB_Valid;
	output[3:0] memory_we_wb;
	output[31:0] memory_address_wb;
	output[31:0] memory_data_wb;

	wire wb_clr;
	and2$ and1(wb_clr, clr, clr_wb);
	//dff_1 dff1(clk, 1'b1, WB_Valid, clr & clr_wb, ld_WB);
	dff_1 dff1(clk, 1'b1, WB_Valid, wb_clr, ld_WB);
	dff_4 dff2(clk, WB_mem_we, memory_we_wb, clr, ld_WB);
	dff_32 dff3(clk, WB_address, memory_address_wb, clr, ld_WB);
	dff_32 dff4(clk, WB_data, memory_data_wb, clr, ld_WB);
endmodule

module DataOutAdjustLogic (DataOut, MemData, size, addr, unalign);
	input[31:0] DataOut;
	input[1:0] size, addr, unalign;
	output[31:0] MemData;

	//wire size0_bar, addr0_bar, size1_bar, addr1_bar, ua1_bar, ua0_bar;
	wire mux_4;
	wire[1:0] mux_1, mux_2, mux_3;
	wire[5:0] upc;
	wire[7:0] Byte0, Byte1, Byte2, Byte3;
	wire[3:0] ControlSignals00, ControlSignals01, ControlSignals10, ControlSignals11;
	wire[7:0] ControlSignals0, ControlSignals1, ControlSignals;

	//unalign doesn't include one case: addr-01, size-01, since this case doesn't require two separate memory accesses.
	//unalign: 00-normal; 01-first half, 10-second half

	assign Byte3 = DataOut[7:0];
	assign Byte2 = DataOut[15:8];
	assign Byte1 = DataOut[23:16];
	assign Byte0 = DataOut[31:24];

	assign upc = {addr[1], addr[0], size[1], size[0], unalign[1], unalign[0]};
	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/DOutAdjucode00", DOut_ControlStore00.mem);
	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/DOutAdjucode01", DOut_ControlStore01.mem);
	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/DOutAdjucode10", DOut_ControlStore10.mem);
	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/DOutAdjucode11", DOut_ControlStore11.mem);
	rom4b32w$ DOut_ControlStore00(upc[4:0], 1'b1, ControlSignals00);
	rom4b32w$ DOut_ControlStore01(upc[4:0], 1'b1, ControlSignals01);
	rom4b32w$ DOut_ControlStore10(upc[4:0], 1'b1, ControlSignals10);
	rom4b32w$ DOut_ControlStore11(upc[4:0], 1'b1, ControlSignals11);
	assign ControlSignals0 = {ControlSignals00, ControlSignals01};
	assign ControlSignals1 = {ControlSignals10, ControlSignals11};
	mux2_8$ mux1(ControlSignals, ControlSignals0, ControlSignals1, upc[5]);

	assign mux_1[0] = ControlSignals[0];
	assign mux_1[1] = ControlSignals[1];
	assign mux_2[0] = ControlSignals[2];
	assign mux_2[1] = ControlSignals[3];
	assign mux_3[0] = ControlSignals[4];
	assign mux_3[1] = ControlSignals[5];
	assign mux_4 = ControlSignals[6];

	mux4_8$ mux2(MemData[7:0], Byte0, Byte2, Byte1, Byte3, mux_1[1], mux_1[0]);
	mux4_8$ mux3(MemData[15:8], Byte0, Byte2, Byte1, Byte3, mux_2[1], mux_2[0]);
	mux3_8$ mux4(MemData[23:16], Byte0, Byte2, Byte1, mux_3[1], mux_3[0]);
	mux2_8$ mux5(MemData[31:24], Byte0, Byte3, mux_4);
endmodule

module UnalignAdjustLogic (uaSSE, FH, SH, LH, FH_mem_size, FH_unalign, SH_mem_size, SH_unalign, LH_mem_size, LH_unalign, alignedData, alignedSize);
	input[31:0] FH, SH, LH;
	input[1:0] FH_mem_size, FH_unalign, SH_mem_size, SH_unalign, LH_mem_size, LH_unalign;
	input uaSSE;
	output[1:0] alignedSize;
	output[63:0] alignedData;

	//LH could be the second half (in unaligned normal access or anligned SSE access)  or the third half (in unaligned SSE access)
	//LH really means last half

	//X types of unaligned accesses plus one normal SSE access
	//unalign[1:0]	addr[1:0]	size[1:0]	ID    Order
	//    01		   01		  10		a		F
	//    01		   10		  01		b		F
	//    01		   11		  00		c		F
	//    10		   00		  00		d		L
	//    10		   00		  01		e		L
	//    10		   00		  10		f		L
	//    01           00         11        g		F
	//    10           00         11        h		L
	//    10           00         11        l		S
	//    11           00         00        i		L
	//    11           00         01        j		L
	//    11           00         10        k		L
	//Word: cd; DoubleWord: ad, be, cf; SSE: gh; unaligned SSE: ali, blj, clk
	//only using unalign and size is sufficient to differentiate different IDs

	wire a, b, c, d, e, f, g, h, i, j, k, l;
	wire ad, be, cf, cd, gh, ali, blj, clk;
	wire[1:0] mux_adj1, mux_adj2;
	wire[31:0] adjData1, adjData2, adjData3, adjData4, alignedData_nonSSE;
	wire[63:0] adjData5, adjData6, adjData7, adjData8, alignedData1, alignedData2;

	wire FH_unalign1_inv, FH_unaligned0_inv, FH_mem_size1_inv, FH_mem_size0_inv;
	wire LH_unalign1_inv, LH_unaligned0_inv, LH_mem_size1_inv, LH_mem_size0_inv;
	wire SH_unalign1_inv, SH_unaligned0_inv, SH_mem_size1_inv, SH_mem_size0_inv;
	inv1$ inv1_1(FH_unaligned1_inv, FH_unalign[1]);
	inv1$ inv1_2(FH_unaligned0_inv, FH_unalign[0]);
	inv1$ inv1_3(SH_unaligned1_inv, SH_unalign[1]);
	inv1$ inv1_4(SH_unaligned0_inv, SH_unalign[0]);
	inv1$ inv1_5(LH_unaligned1_inv, LH_unalign[1]);
	inv1$ inv1_6(LH_unaligned0_inv, LH_unalign[0]);
	inv1$ inv2_1(FH_mem_size1_inv, FH_mem_size[1]);
	inv1$ inv2_2(FH_mem_size0_inv, FH_mem_size[0]);
	inv1$ inv2_3(SH_mem_size1_inv, SH_mem_size[1]);
	inv1$ inv2_4(SH_mem_size0_inv, SH_mem_size[0]);
	inv1$ inv2_5(LH_mem_size1_inv, LH_mem_size[1]);
	inv1$ inv2_6(LH_mem_size0_inv, LH_mem_size[0]);

	//assign a = ~FH_unalign[1] & FH_unalign[0] & FH_mem_size[1] & ~FH_mem_size[0];
	and4$ and1(a, FH_unaligned1_inv, FH_unalign[0], FH_mem_size[1], FH_mem_size0_inv);
	//assign b = ~FH_unalign[1] & FH_unalign[0] & ~FH_mem_size[1] & FH_mem_size[0];
	and4$ and2(b, FH_unaligned1_inv, FH_unalign[0], FH_mem_size1_inv, FH_mem_size[0]);
	//assign c = ~FH_unalign[1] & FH_unalign[0] & ~FH_mem_size[1] & ~FH_mem_size[0];
	and4$ and3(c, FH_unaligned1_inv, FH_unalign[0], FH_mem_size1_inv, FH_mem_size0_inv);
	//assign d = LH_unalign[1] & ~LH_unalign[0] & ~LH_mem_size[1] & ~LH_mem_size[0];
	and4$ and4(d, LH_unalign[1], LH_unaligned0_inv, LH_mem_size1_inv, LH_mem_size0_inv);
	//assign e = LH_unalign[1] & ~LH_unalign[0] & ~LH_mem_size[1] & LH_mem_size[0];
	and4$ and5(e, LH_unalign[1], LH_unaligned0_inv, LH_mem_size1_inv, LH_mem_size[0]);
	//assign f = LH_unalign[1] & ~LH_unalign[0] & LH_mem_size[1] & ~LH_mem_size[0];
	and4$ and6(f, LH_unalign[1], LH_unaligned0_inv, LH_mem_size[1], LH_mem_size0_inv);
	//assign g = ~FH_unalign[1] & FH_unalign[0] & FH_mem_size[1] & FH_mem_size[0];
	and4$ and7(g, FH_unaligned1_inv, FH_unalign[0], FH_mem_size[1], FH_mem_size[0]);
	//assign h = LH_unalign[1] & ~LH_unalign[0] & LH_mem_size[1] & LH_mem_size[0];
	and4$ and8(h, LH_unalign[1], LH_unaligned0_inv, LH_mem_size[1], LH_mem_size[0]);
	//assign i = LH_unalign[1] & LH_unalign[0] & ~LH_mem_size[1] & ~LH_mem_size[0];
	and4$ and9(i, LH_unalign[1], LH_unalign[0], LH_mem_size1_inv, LH_mem_size0_inv);
	//assign j = LH_unalign[1] & LH_unalign[0] & ~LH_mem_size[1] & LH_mem_size[0];
	and4$ and10(j, LH_unalign[1], LH_unalign[0], LH_mem_size1_inv, LH_mem_size[0]);
	//assign k = LH_unalign[1] & LH_unalign[0] & LH_mem_size[1] & ~LH_mem_size[0];
	and4$ and11(k, LH_unalign[1], LH_unalign[0], LH_mem_size[1], LH_mem_size0_inv);
	//assign l = SH_unalign[1] & ~SH_unalign[0] & SH_mem_size[1] & SH_mem_size[0];
	and4$ and12(l, SH_unalign[1], SH_unaligned0_inv, SH_mem_size[1], SH_mem_size[0]);

	//assign ad = a & d;
	//assign be = b & e;
	//assign cf = c & f;
	//assign cd = c & d;
	//assign gh = g & h;
	//assign ali = a & l & i;
	//assign blj = b & l & j;
	//assign clk = c & l & k;
	and2$ and1_1(ad, a, d);
	and2$ and1_2(be, b, e);
	and2$ and1_3(cf, c, f);
	and2$ and1_4(cd, c, d);
	and2$ and1_5(gh, g, h);
	and3$ and1_6(ali, a, l, i);
	and3$ and1_7(blj, b, l, j);
	and3$ and1_8(clk, c, l, k);

	//assign alignedSize[1] = ad | be | cf | gh | ali | blj | clk;
	//assign alignedSize[0] = cd | gh | ali | blj | clk;
	and7$ and2_1(alignedSize[1], ad, be, cf, gh, ali, blj, clk);
	and5$ and2_2(alignedSize[0], cd, gh, ali, blj, clk);

	//bytes layout after adjusted by adjout logic. note that useful bytes are always aligned to the right
	//FH: F0, F1, F2, F3;[31:0]
	//SH: S0, S1, S2, S3;[31:0]
	//LH: L0, L1, L2, L3;[31:0]
	//ad(3+1): L3, F3, F2, F1
	//be(2+2): L3, L3, F3, F2
	//cf(1+3): L3, L2, L1, F3
	//cd(1+1): L3, F3
	//gh(4+4): L3, L2, L1, L0, F3, F2, F1, F0
	//ali(3+4+1): L0, S3, S2, S1, S0, F3, F2, F1
	//blj(2+4+2): L1, L0, S3, S2, S1, S0, F3, F2
	//////clk(1+4+3): L2, L1, L0, S3, S2, S1, S0, F3
	//clk(1+4+3): L3, L2, L1, S3, S2, S1, S0, F3
	assign adjData1 = {LH[7:0], FH[7:0], FH[15:8], FH[23:16]};
	assign adjData2 = {LH[7:0], LH[15:8], FH[7:0], FH[15:8]};
	assign adjData3 = {LH[7:0], LH[15:8], LH[23:16], FH[7:0]};
	assign adjData4 = {LH[7:0], FH[7:0]};
	assign adjData5 = {LH[7:0], LH[15:8], LH[23:16], LH[31:24], FH[7:0], FH[15:8], FH[23:16], FH[31:24]};
	//////assign adjData6 = {LH[31:24], SH[7:0], SH[15:8], SH[23:16], SH[31:24], FH[7:0], FH[15:8], FH[23:16]};
	assign adjData6 = {LH[7:0], SH[7:0], SH[15:8], SH[23:16], SH[31:24], FH[7:0], FH[15:8], FH[23:16]};
	//////assign adjData7 = {LH[23:16], LH[31:24], SH[7:0], SH[15:8], SH[23:16], SH[31:24], FH[7:0], FH[15:8]};
	assign adjData7 = {LH[7:0], LH[15:8], SH[7:0], SH[15:8], SH[23:16], SH[31:24], FH[7:0], FH[15:8]};
	//////assign adjData8 = {LH[15:8], LH[23:16], LH[31:24], SH[7:0], SH[15:8], SH[23:16], SH[31:24], FH[7:0]};
	assign adjData8 = {LH[7:0], LH[15:8], LH[23:16], SH[7:0], SH[15:8], SH[23:16], SH[31:24], FH[7:0]};

	mux4_32 mux1(alignedData_nonSSE, adjData1, adjData3, adjData2, adjData4, mux_adj1);
	//assign mux_adj1[0] = be | cd;
	//assign mux_adj1[1] = cf | cd;
	or2$ or1(mux_adj1[0], be, cd);
	or2$ or2(mux_adj1[1], cf, cd);
	mux2_64 mux2(alignedData1, {32'b0, alignedData_nonSSE}, adjData5, gh);
	mux3_64 mux3(alignedData2, adjData6, adjData8, adjData7, mux_adj2);
	assign mux_adj2[0] = blj;
	assign mux_adj2[1] = clk;
	mux2_64 mux4(alignedData, alignedData1,  alignedData2, uaSSE);
endmodule

module DataInAdjustLogic(CMT_PA1, CMT_PA2, CMT_PA3, CMT_DMA_Init, DMA_Target, DMA_Size, CMT_Data, CMT_addr, CMT_size, ld_cnt, mux_mem_size, cmt2wb_data, cmt2wb_addr, check_done, mem_we, cnt_dec, clk, clr);
	input[63:0] CMT_Data;
	input[31:0] CMT_PA1, CMT_PA2, CMT_PA3, CMT_addr, DMA_Target;
	input[15:0] DMA_Size;
	input[1:0] CMT_size;
	input CMT_DMA_Init, mux_mem_size, ld_cnt, cnt_dec, clk, clr;
	output[31:0] cmt2wb_data;
	output[31:0] cmt2wb_addr;
	output[3:0] mem_we;
	output check_done;

	wire[31:0] adjData1, adjData2, adjData3, adjData4, adjData5, adjData6, adjData7, adjData8, adjData9, adjData10, adjData11, FH_Data, SH_Data, LH_Data;
	wire[31:0] nMMIO_addr;
	wire[15:0] CMT_addr_inc_temp1, CMT_addr_inc_temp2, CMT_addr_aligned;
	wire[14:0] CMT_addr_inc1, CMT_addr_inc2;
	wire[7:0] Byte0, Byte1, Byte2, Byte3, Byte4, Byte5, Byte6, Byte7;
	wire[7:0] temp_cnt, sizeCnt;
	wire[3:0] we_FH, we_SH, we_LH;
	wire[1:0] mux_chunk, count, incCount;
	wire[1:0] mux_FH, mux_SH, mux_LH;
	wire[3:0] mem_we_temp;
	wire[31:0] ControlSignals;
	wire[15:0] DMA_Cur_Addr;
	wire g, s, g_inv, s_inv;
	wire cnt_dec_inv;

	assign Byte0 = CMT_Data[63:56];
	assign Byte1 = CMT_Data[55:48];
	assign Byte2 = CMT_Data[47:40];
	assign Byte3 = CMT_Data[39:32];
	assign Byte4 = CMT_Data[31:24];
	assign Byte5 = CMT_Data[23:16];
	assign Byte6 = CMT_Data[15:8];
	assign Byte7 = CMT_Data[7:0];

	assign adjData1 = {Byte7, Byte6, Byte5, Byte4};
	assign adjData2 = {8'b0, Byte7, Byte6, Byte5};
	assign adjData3 = {16'b0, Byte7, Byte6};
	assign adjData4 = {24'b0, Byte7};
	assign adjData5 = {Byte3, Byte2, Byte1, Byte0};
	assign adjData6 = {Byte4, Byte3, Byte2, Byte1};
	assign adjData7 = {Byte5, Byte4, Byte3, Byte2};
	assign adjData8 = {Byte6, Byte5, Byte4, Byte3};
	assign adjData9 = {Byte0, 24'b0};
	assign adjData10 = {Byte1, Byte0, 16'b0};
	assign adjData11 = {Byte2, Byte1, Byte0, 8'b0};

	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/dinucode", DIn_ControlStore.mem);
	rom32b32w$ DIn_ControlStore({1'b0, CMT_addr[1], CMT_addr[0], CMT_size[1], CMT_size[0]}, 1'b1, ControlSignals); //OE: high-level enabled
	assign we_LH[0] = ControlSignals[0];
	assign we_LH[1] = ControlSignals[1];
	assign we_LH[2] = ControlSignals[2];
	assign we_LH[3] = ControlSignals[3];
	assign we_SH[0] = ControlSignals[4];
	assign we_SH[1] = ControlSignals[5];
	assign we_SH[2] = ControlSignals[6];
	assign we_SH[3] = ControlSignals[7];
	assign we_FH[0] = ControlSignals[8];
	assign we_FH[1] = ControlSignals[9];
	assign we_FH[2] = ControlSignals[10];
	assign we_FH[3] = ControlSignals[11];
	assign mux_LH[0] = ControlSignals[12];
	assign mux_LH[1] = ControlSignals[13];
	assign mux_SH[0] = ControlSignals[14];
	assign mux_SH[1] = ControlSignals[15];
	assign mux_FH[0] = ControlSignals[16];
	assign mux_FH[1] = ControlSignals[17];
	assign count[0] = ControlSignals[18];
	assign count[1] = ControlSignals[19];

	inv1$ inv1(cnt_dec_inv, cnt_dec);
	inv1$ inv2(g_inv, g);
	inv1$ inv3(s_inv, s);
	mux2_8$ mux9(sizeCnt, {6'b0, count}, DMA_Size[7:0], CMT_DMA_Init); // as of now, only counting up to 8-bit long...
	//syn_cntr8$(CLK, CLR, D, EN, PRE, PL, UP, COUT, Q);
	//syn_cntr8$ counter(clk, clr, sizeCnt, ~cnt_dec, 1'b1, ld_cnt, cnt_dec, , temp_cnt);
	syn_cntr8$ counter(clk, clr, sizeCnt, cnt_dec_inv, 1'b1, ld_cnt, cnt_dec, , temp_cnt);
	//assign mux_chunk = temp_cnt[1:0];
	//00->00; 01->01; 10->10; 11->00
	assign mux_chunk[0] = ~temp_cnt[1] & temp_cnt[0];
	assign mux_chunk[1] = temp_cnt[1] & ~temp_cnt[0];
	mag_comp8$ comp1(temp_cnt, 8'hFF, g, s);
	//assign check_done = ~g & ~s;
	and2$ and1_1(check_done, g_inv, s_inv);

	add2_16 add3(DMA_Target[15:0], {8'b0, temp_cnt}, DMA_Cur_Addr, , );

	mux4_32 mux1(FH_Data, adjData1, adjData3, adjData2, adjData4, mux_FH);
	mux4_32 mux2(SH_Data, adjData5, adjData7, adjData6, adjData8, mux_SH);
	mux3_32 mux8(LH_Data, adjData9, adjData11, adjData10, mux_LH);

	and2_16 and1(CMT_addr_aligned, {1'b0, CMT_addr[14:0]}, 16'hFFFC);
	add2_16 add1(CMT_addr_aligned, 16'h4, CMT_addr_inc_temp1, , );
	add2_16 add2(CMT_addr_aligned, 16'h8, CMT_addr_inc_temp2, , );
	assign CMT_addr_inc1 = CMT_addr_inc_temp1[14:0];
	assign CMT_addr_inc2 = CMT_addr_inc_temp2[14:0];

	mux3_32 mux3(cmt2wb_data, FH_Data, LH_Data, SH_Data, mux_chunk);
	//mux3_32 mux4(nMMIO_addr, CMT_addr, {17'b0, CMT_addr_inc2}, {17'b0, CMT_addr_inc1}, mux_chunk);
	mux3_32 mux4(nMMIO_addr, CMT_PA1, CMT_PA3, CMT_PA2, mux_chunk);

	//mux2_32 mux10(cmt2wb_addr, nMMIO_addr, {16'b0, DMA_Cur_Addr}, CMT_DMA_Init);
	// (CMT_DMA_Init, check_done)
	// <0, x> nMMIO_addr
	// <1, 0> DMA_Cur_Addr
	// <1, 1> CMT_addr
	mux4_32 mux10(cmt2wb_addr, nMMIO_addr, {16'b0, DMA_Cur_Addr}, nMMIO_addr, CMT_addr, {CMT_DMA_Init, check_done});

	mux3_4 mux5(mem_we_temp, we_FH, we_LH, we_SH, mux_chunk);
	mux2_4 mux6(mem_we, mem_we_temp, 4'b1111, mux_mem_size); //line refill always writes all 4 bytes
endmodule

module usequencer(uinstruction, isException, CMT_DMA_Init, PRE_PCD, PRE_MEM_Valid, PRE_Valid, PRE_WR, commit, DChit, WB_Valid, memory_ready, evict, check_done, upc);
	input[48:0] uinstruction;
	input check_done, isException, CMT_DMA_Init, PRE_PCD, PRE_MEM_Valid, PRE_Valid, PRE_WR, commit, DChit, WB_Valid, memory_ready, evict;
	output[4:0] upc;

	wire sel_1, sel_3, sel_5, sel_6, sel_7, sel_9, sel_12;
	wire[1:0] sel_2, sel_4, sel_8, sel_11;
	wire[4:0] temp_next1, temp_next2, temp_next3, temp_next4, temp_next5, temp_next6, temp_next7, temp_next8, temp_next9, temp_next10, temp_next11;
	wire[4:0] normal_next;
	wire m1, m2, m3, m4, m5, m6, m7, m8, m9;

	assign m9 = uinstruction[45];
	assign m8 = uinstruction[44];
	assign normal_next = uinstruction[4:0];
	assign m1 = uinstruction[11];
	assign m2 = uinstruction[10];
	assign m3 = uinstruction[9];
	assign m4 = uinstruction[8];
	assign m5 = uinstruction[7];
	assign m6 = uinstruction[6];
	assign m7 = uinstruction[5];

	mux2_5 mux1(temp_next1, temp_next7, 5'b11011, sel_1);
	mux4_5 mux2(temp_next2, temp_next1, 5'b10111, 5'b10110, 5'b11001, sel_2);
	mux2_5 mux6(temp_next5, temp_next11, 5'b11010, sel_6);
	mux2_5 mux3(temp_next3, temp_next2, temp_next5, sel_3);
	mux4_5 mux4(temp_next4, temp_next3, 5'b00001, 5'b10011, 5'b01011, sel_4);
	mux2_5 mux5(temp_next6, temp_next4, {1'b0, PRE_PCD, (PRE_Valid & PRE_MEM_Valid) & ~isException, PRE_WR, commit}, sel_5);
	mux2_5 mux7(temp_next7, normal_next, temp_next9, sel_7);
	mux3_5 mux8(temp_next8, temp_next6, 5'b00000, 5'b10000, sel_8);
	mux2_5 mux9(upc, temp_next8, temp_next10, sel_9);
	mux2_5 mux10(temp_next10, 5'b00000, 5'b10010, sel_10);
	mux3_5 mux11(temp_next9, 5'b00111, 5'b00011, 5'b10010, sel_11);
	mux2_5 mux12(temp_next11, 5'b00000, 5'b01010, sel_12);

	//assign sel_1 = m6 & WB_Valid;
	and2$ and1(sel_1, m6, WB_Valid);

	//assign sel_2[0] = (m4 & ~DChit & evict) | (m4 & DChit & ~evict);
	wire DChit_inv, evict_inv, sel2_0_0, sel2_0_1;
	inv1$ inv1(DChit_inv, DChit);
	inv1$ inv2(evict_inv, evict);
	and3$ and2(sel2_0_0, m4, DChit_inv, evict);
	and3$ and3(sel2_0_1, m4, DChit, evict_inv);
	or2$ or1(sel_2[0], sel2_0_0, sel2_0_1);
	//assign sel_2[1] = m4 & ~DChit & evict;
	and3$ and4(sel_2[1], m4, DChit_inv, evict);

	//assign sel_3 = memory_ready & (m3 | m5) & ~sel_7;
	wire sel7_inv, sel3_0;
	inv1$ inv3(sel7_inv, sel_7);
	or2$ or2(sel3_0, m3, m5);
	and3$ and5(sel_3, memory_ready, sel3_0, sel7_inv);

	//assign sel_4[0] = m2 & ((DChit & ~CMT_DMA_Init) | (~DChit & CMT_DMA_Init));
	wire CMT_DMA_Init_inv, sel4_0_0, sel4_0_1, sel4_0_3;
	inv1$ inv4(CMT_DMA_Init_inv, CMT_DMA_Init);
	and2$ and6(sel4_0_0, DChit, CMT_DMA_Init_inv);
	and2$ and7(sel4_0_1, DChit_inv, CMT_DMA_Init);
	or2$ or3(sel4_0_3, sel4_0_0, sel4_0_1);
	and2$ and8(sel_4[0], m2, sel4_0_3);
	//assign sel_4[1] = m2 & CMT_DMA_Init;
	and2$ and9(sel_4[1], m2, CMT_DMA_Init);

	//assign sel_5 = m1 & (~sel_1 & ~sel_7) & (~m3 | (m3 & memory_ready));
	wire sel1_inv, m3_inv, sel5_0, sel5_1, sel5_2;
	inv1$ inv5(sel1_inv, sel_1);
	inv1$ inv6(m3_inv, m3);
	and2$ and10(sel5_0, sel1_inv, sel7_inv);
	and2$ and11(sel5_1, m3, memory_ready);
	or2$ or6(sel5_2, m3_inv, sel5_1);
	and3$ and13(sel_5, m1, sel5_0, sel5_2);

	//assign sel_6 = ~m3 & m5;
	and2$ and14(sel_6, m3_inv, m5);

	//assign sel_7 = m7 & ~check_done & ((m3 & memory_ready) | ~m3); // if m3 is set, then only take a look at incoming new signals when memory is ready, otherwise will be jumping to 00000, wasting one cycle
	wire check_done_inv, sel7_0, sel7_1;
	inv1$ inv7(check_done_inv, check_done);
	and2$ and15(sel7_0, m3, memory_ready);
	or2$ or4(sel7_1, sel7_0, m3_inv);
	and3$ and16(sel_7, m7, check_done_inv, sel7_1);

	//assign sel_8[0] = (~temp_next6[4] & temp_next6[0]) & sel_5;
	wire temp_next6_4_inv;
	inv1$ inv8(temp_next6_4_inv, temp_next6[4]);
	and3$ and17(sel_8[0], temp_next6_4_inv, temp_next6[0], sel_5);
	//assign sel_8[1] = (~temp_next6[4] & temp_next6[3] & ~temp_next6[2] & ~temp_next6[0]) & sel_5;
	wire temp_next6_2_inv, temp_mext6_0_inv;
	inv1$ inv9(temp_next6_2_inv, temp_next6[2]);
	inv1$ inv10(temp_next6_0_inv, temp_next6[0]);
	and5$ and18(sel_8[1], temp_next6_4_inv, temp_next6[3], temp_next6_2_inv, temp_next6_0_inv, sel_5);

	//assign sel_9 = (m8 & PRE_PCD) | (~m8 & m9 & PRE_PCD & ~CMT_DMA_Init);
	wire sel9_0, sel9_1, m8_inv;
	inv1$ inv11(m8_inv, m8);
	and4$ and19(sel9_1, m8_inv, m9, PRE_PCD, CMT_DMA_Init_inv);
	and2$ and20(sel9_0, m8, PRE_PCD);
	or2$ or5(sel_9, sel9_0, sel9_1);

	//assign sel_10 = ~m8 & m9;
	and2$ and21(sel_10, m8_inv, m9);

	//assign sel_11[0] = PRE_PCD & ~CMT_DMA_Init;
	and2$ and22(sel_11[0], PRE_PCD, CMT_DMA_Init_inv);
	assign sel_11[1] = CMT_DMA_Init;

	assign sel_12 = CMT_DMA_Init;
endmodule

module CacheController(PRE_PCD, PRE_MEM_Valid, PRE_Valid, PRE_WR, isException, IF_flush, commit, upc_helper, TA_WR, DA_WR, CC_WE, OE, ld_cnt, mux_mem_size, mux_ld_data2DC, mux_wb_data, mux_wb_addr, mux_wb_mem_we, mux_ld_cc, mux_wayId, mux_dataFromDC, ld_cc2DC, ld_data2DC, ld_LRB, ld_WB, ld_exe_data, ld_DAIndex, ld_rreq, ld_wreq, ld_mem_we, ld_dma_init, clr_req, cnt_dec, ld_data2exe, ld_car, stall, mux_address, mux_setId, clr_wb, clr_uaW, clr_dma_init, clk, clr, upc);
	input[5:0] upc_helper;
	input PRE_MEM_Valid, PRE_Valid, PRE_PCD, PRE_WR, commit, isException, IF_flush, clk, clr;
	output TA_WR, DA_WR, CC_WE, OE, ld_cnt, mux_mem_size, mux_ld_data2DC, mux_wb_data, mux_wb_addr, mux_wb_mem_we, mux_ld_cc, mux_wayId, mux_dataFromDC, ld_cc2DC, ld_data2DC, ld_LRB, ld_WB, ld_exe_data, ld_DAIndex, cnt_dec, ld_data2exe, ld_car, ld_rreq, ld_wreq, ld_mem_we, ld_dma_init, clr_req, stall, clr_wb, clr_uaW, clr_dma_init;
	output[1:0] mux_address, mux_setId;
	output[4:0] upc;

	wire check_done, CMT_DMA_Init_temp, CMT_DMA_Init, memory_ready, evict, WB_Valid, DChit, unaligned_stall, no_flush;
	wire[4:0] upc, upc_noFlush;
	wire[63:0] ControlSignals, uinstruction;

	initial $readmemb("/misc/collaboration/382nGPS/382nG6/yzhu/rom/ccucode", CacheControlller_ControlStore.mem);

    inv1$ inv1(no_flush, IF_flush);
	rom64b32w$ CacheControlller_ControlStore(upc, 1'b1, ControlSignals); //OE: high-level enabled
	dff_64 dff1(clk, ControlSignals, uinstruction, clr, 1'b1);
	usequencer logic1(uinstruction[48:0], isException, CMT_DMA_Init, PRE_PCD, PRE_MEM_Valid, PRE_Valid, PRE_WR, commit, DChit, WB_Valid, memory_ready, evict, check_done, upc_noFlush);
    and5_1 and1(upc, upc_noFlush, no_flush);

	//assign CMT_DMA_Init_temp = upc_helper[6];
	assign CMT_DMA_Init = upc_helper[5];
	assign DChit = upc_helper[4];
	assign check_done = upc_helper[3];
	assign evict = upc_helper[2];
	assign memory_ready = upc_helper[1];
	assign WB_Valid = upc_helper[0];

	assign ld_dma_init = ControlSignals[48];
	assign ld_mem_we = ControlSignals[47];
	assign clr_dma_init = ControlSignals[46];
	assign clr_req = ControlSignals[43];
	assign ld_wreq = ControlSignals[42];
	assign ld_rreq = ControlSignals[41];
	assign ld_car = ControlSignals[40];
	assign ld_data2exe = ControlSignals[39];
	assign cnt_dec = ControlSignals[38];
	assign TA_WR = ControlSignals[37];
	assign DA_WR = ControlSignals[36];
	assign CC_WE = ControlSignals[35];
	assign OE = ControlSignals[34];
	assign ld_cnt = ControlSignals[33];
	assign mux_mem_size = ControlSignals[32];
	assign mux_ld_data2DC = ControlSignals[31];
	assign mux_wb_data = ControlSignals[30];
	assign mux_wb_addr = ControlSignals[29];
	assign mux_wb_mem_we = ControlSignals[28];
	assign mux_ld_cc = ControlSignals[27];
	assign mux_wayId = ControlSignals[26];
	assign mux_dataFromDC = ControlSignals[25];
	assign mux_address[1] = ControlSignals[24];
	assign mux_address[0] = ControlSignals[23];
	assign mux_setId[1] = ControlSignals[22];
	assign mux_setId[0] = ControlSignals[21];
	assign clr_uaW = ControlSignals[20];
	assign clr_wb = ControlSignals[19];
	assign ld_cc2DC = ControlSignals[18];
	assign ld_data2DC = ControlSignals[17];
	assign ld_LRB = ControlSignals[16];
	assign ld_WB = ControlSignals[15];
	assign ld_exe_data = ControlSignals[14];
	assign ld_DAIndex = ControlSignals[13];
	assign stall = ControlSignals[12];

endmodule

module MemSLVLogic(upc, stall, memory_ready, check_done, CMT, PRE_Valid, PRE_MEM_Valid, PRE_PCD, WB_Valid, EXE_stall, MEM2Pre_stall, MEM2CMT_stall, read_end, MEM_Valid, ld_exe_data, ld_mem_en, IF_flush, clk, clr);
	input[4:0] upc;
	input stall, memory_ready, check_done, PRE_Valid, PRE_MEM_Valid, PRE_PCD, WB_Valid, EXE_stall, read_end, ld_exe_data, CMT;
	input IF_flush, clk, clr;
	output MEM2Pre_stall, MEM2CMT_stall, ld_mem_en, MEM_Valid;

	wire dc_stall, dc_not_stall, ld_mem;
	wire state_11010, state_11100, state_000x0, state_10001, state_10100, state_11011, state_10110, state_01000;
	wire read_end, MEM_Valid_temp;

	mag_comp5 comp1(upc, 5'b11010, state_11010);
	mag_comp5 comp2(upc, 5'b11100, state_11100);
	mag_comp4 comp3({upc[4:2], upc[0]}, 4'b0000, state_000x0);
	mag_comp5 comp4(upc, 5'b10001, state_10001);
	mag_comp5 comp5(upc, 5'b10100, state_10100);
	mag_comp5 comp6(upc, 5'b11011, state_11011);
	mag_comp5 comp7(upc, 5'b10110, state_10110);
	//mag_comp5 comp8(upc, 5'b01000, state_01000);

	assign dc2pre_not_stall = ~stall | (state_11011 & memory_ready) | (state_11100 & ~WB_Valid) | (state_11010 & PRE_PCD) | state_10110;
	assign dc2cmt_not_stall = ~stall | (state_10001 & check_done) | (state_10100 & check_done & memory_ready);
	inv1$ inv1(dc2pre_stall, dc2pre_not_stall);
	inv1$ inv2(dc2cmt_stall, dc2cmt_not_stall);

	assign MEM2Pre_stall = (PRE_Valid & PRE_MEM_Valid & dc2pre_stall) | (PRE_Valid & EXE_stall); // in fact, dc2pre_stall implies PRE_Valid and PRE_MEM_Valid, just check for completeness...
	assign MEM2CMT_stall = CMT & dc2cmt_stall; // dc2cmt_stall implies CMT, check for completeness..

	// dealing with load enable and valid signal
	// generally, if EXE doesn't stall, should enable pipeline register load, except for one exception which is unaligned read where we have to wait for all chunks are read
	// if PRE passes valid data and dcache by itself doesn't require a stall, MEM_Valid should be set.  in case of unaligned read chunk boundary, ld_mem_en will be unset although MEM_Valid is still (uselessly) set...
	assign ld_mem_en = (~EXE_stall & ((~state_11100 & ~state_10110 & ~state_11011) | read_end)) | IF_flush; // if in state_11100, state_11100 or state_11011, then has to be read_end in order to ld_mem_en
	assign MEM_Valid_temp = (PRE_Valid & ~MEM2Pre_stall) & ~IF_flush; // no need to check MEM2CMT_stall since that'll cause EXE_stall, so that MEM_Valid will never be loaded in anyway..
	dff_1 dff1(clk, MEM_Valid_temp, MEM_Valid, clr, ld_mem_en);
endmodule

// memory stage
module mem(
	/******************input******************/
	//-----------------------input from Fetch stage
	IF_flush,
	//-----------------------input from PreMem stage
	PRE_CS,
	PRE_EXP,
	PRE_WR, // write or read (1, 0)
	PRE_RD_PA, // the address where the operand is to be read (for non MMIO, [19:0] indicates physical address, for MMIO, all 32 bits are used)
	PRE_WR_VA, // the virtual address where the operand is to be written to. passed to the execution and write stages, and finally get fed back to the memory stage
	PRE_WR_PA1, // the address where the operand is to be written (for non MMIO, [19:0] indicates physical address, for MMIO, all 32 bits are used)
	PRE_WR_PA2, // the address where the operand is to be written (for non MMIO, [19:0] indicates physical address, for MMIO, all 32 bits are used)
	PRE_WR_PA3, // the address where the operand is to be written (for non MMIO, [19:0] indicates physical address, for MMIO, all 32 bits are used)
	PRE_size, // the size of the memory operation, (note the different between PRE_effsize) essentially just AGRF_size; it is the same for read and write
	PRE_effsize, // the size of the data to be read from memory (byte, word, dword, qword)
	PRE_MEM_Valid, // can we trust PRE_WR and PRE_needW, etc?
	//PRE_needW, // will this instruction finally require a write? AGRF_WR
	PRE_unalign, // the unalign id of the read operation
	PRE_uaSSE, // is it an unaligned SSE read
	PRE_PCD, // is the current operation PCD?
	PRE_Valid, // are PRE stage registers valid?
	//PRE_pf_exp, // does the current instruction raise a page fault exception
	//PRE_prot_exp, // does the current instruction raise a general protection exception
	PRE_CURRENT_EIP,
	PRE_NEXT_EIP,
	PRE_REL_EIP,
	PRE_DISP,
	PRE_IMM,
	PRE_DEST_GPR,
	PRE_SRC_GPR,
	PRE_DEST_SEGR,
	PRE_SRC_SEGR,
	PRE_DEST_MMX,
	PRE_SRC_MMX,
	//-----------------------input from EXE state
	EXE_stall, // does the execution stage stall?
	//input from Commit stage
	CMT, // is there a commit to memory currently?
	CMT_addr, // the address of the data to be committed, passed from PRE_WR_VA
	CMT_Data, // the data to be committed
	CMT_size, // the size of data to be committed
	CMT_PA1,
	CMT_PA2,
	CMT_PA3,
	//-----------------------input from Bus
	memory_ready,
	memory_data_lrb,

	/******************output******************/
	//-----------------------output to PreMEM stage
	MEM2Pre_stall, // does memory stage need to stall from PreMem stage's perspective
	M2P_MEM_WR,
	M2P_WR_VA,
	M2P_WR_SIZE,
	//-----------------------output to EXE stage
	MEM_CS,
	MEM_EXP,
	MEM_RD_data, // the data read from the memory
	//MEM_WR_Data, // the data to be written to memory, PRE_WR_Data
	MEM_Valid, // can you trust the pipeline registers from the memory stage
	//MEM_RD_size, // the size of the operand read from the memory
	//MEM_WR_size, // the size of data to be written to memory
	//MEM_size, //PRE_size
	MEM_PCD, // PRE_PCD. passes through until the commit stage that tells the memory stage to bypass dcache
	//MEM_CMT, // does this instruction requires commit to memory
	MEM_WR_VA,
	MEM_WR_PA1,
	MEM_WR_PA2,
	MEM_WR_PA3,
	MEM_CURRENT_EIP,
	MEM_NEXT_EIP,
	MEM_REL_EIP,
	MEM_DISP,
	MEM_IMM,
	MEM_DEST_GPR,
	MEM_SRC_GPR,
	MEM_DEST_SEGR,
	MEM_SRC_SEGR,
	MEM_DEST_MMX,
	MEM_SRC_MMX,
	//-----------------------output to LR stage
	MEM_dest_gpr_sel,
	MEM_src_gpr_sel,
	MEM_dest_segr_sel,
	MEM_dest_mmx_sel,
	MEM_dest_gpr_wt,
	MEM_src_gpr_wt,
	MEM_dest_segr_wt,
	MEM_dest_mmx_wt,
	MEM_dest_gpr_type,
	MEM_src_gpr_type,
    MEM_set_cc,
	//-----------------------output to Commit stage
	MEM2CMT_stall, // does memory stage need to stall from Commit stage's perspective
	//-----------------------output to Bus
	MEM_RReq,
	MEM_WReq,
	Bus_Req_address,
	memory_data_wb,
	memory_we_wb,

	clk,
	clr);

	input[`CS_NUM] PRE_CS;
	input[31:0] PRE_CURRENT_EIP, PRE_NEXT_EIP, PRE_REL_EIP, PRE_DISP, PRE_IMM, PRE_DEST_GPR, PRE_SRC_GPR, PRE_EXP;
	input[15:0] PRE_DEST_SEGR, PRE_SRC_SEGR;
	input[63:0] PRE_DEST_MMX, PRE_SRC_MMX;
	input[63:0] CMT_Data;
	input[31:0] PRE_RD_PA, PRE_WR_VA, PRE_WR_PA1, PRE_WR_PA2, PRE_WR_PA3, CMT_addr, CMT_PA1, CMT_PA2, CMT_PA3;
	input[31:0] memory_data_lrb;
	input[1:0] PRE_effsize, CMT_size, PRE_unalign, PRE_size;
	input PRE_Valid/*, PRE_needW*/, PRE_WR, clk, clr, PRE_MEM_Valid, PRE_PCD, PRE_uaSSE;
	input IF_flush, EXE_stall, CMT, memory_ready;

	output[`CS_NUM] MEM_CS;
	output[31:0] MEM_CURRENT_EIP, MEM_NEXT_EIP, MEM_REL_EIP, MEM_DISP, MEM_IMM, MEM_DEST_GPR, MEM_SRC_GPR, MEM_EXP;
	output[15:0] MEM_DEST_SEGR, MEM_SRC_SEGR;
	output[63:0] MEM_DEST_MMX, MEM_SRC_MMX;
	output MEM_PCD, MEM_Valid, MEM2Pre_stall, MEM2CMT_stall, MEM_RReq, MEM_WReq/*, MEM_CMT*/;
	output[31:0] Bus_Req_address, memory_data_wb, MEM_WR_VA, MEM_WR_PA1, MEM_WR_PA2, MEM_WR_PA3;
	output[63:0] MEM_RD_data;
	output[3:0] memory_we_wb;
	output[2:0] MEM_dest_gpr_sel;
	output[2:0] MEM_src_gpr_sel;
	output[2:0] MEM_dest_segr_sel;
	output[2:0] MEM_dest_mmx_sel;
	output MEM_dest_gpr_wt;
	output MEM_src_gpr_wt;
	output MEM_dest_segr_wt;
	output MEM_dest_mmx_wt;
	output[1:0] MEM_dest_gpr_type;
	output[1:0] MEM_src_gpr_type;
    output MEM_set_cc;
	output M2P_MEM_WR;
	output[1:0] M2P_WR_SIZE;
	output[31:0] M2P_WR_VA;

	wire[95:0] DAdataOut;
	wire[63:0] alignedData, adjData;
	wire[31:0] DAdataIn, DCdata, dataFromDC, DCDataOut, evict_data, DCDR, LRB_dataIn, WB_data, memory_data_wb, nonevict_data, FirstHalf, SecondHalf, cmt2wb_data;
	wire[23:0] Tags;
	wire[31:0] data2EXE;
	wire[5:0] setIndex, setId, setId_in;
	wire[6:0] tagField, newTagField;
	wire[1:0] lineOffset, wayId, DAIndex, LRB_wayId_in, LRB_wayId, evict_wayId_in, evict_wayId, LRB_back_wayId, WHitWayId;
	wire TA_WR, DA_WR, CC_WE, OE;
	wire[1:0] newCCStatus, newCCStatus1, CCDR, nonevict_size;
	wire[5:0] CCStatus;
	wire DChit, evict, WB_Valid;
	wire[31:0] LRB_address_in, LRB_address, evict_address_in, evict_address, WB_address, LRB_back_address, memory_address_wb, address, nonevict_addr, cmt2wb_addr, DMA_Target, memory_data_lrb_rot;
	wire[1:0] mux_address, mux_setId;
	wire mux_mem_size, mux_ld_data2DC, mux_wb_data, mux_wb_addr, mux_wb_mem_we, mux_ld_cc, mux_wayId, mux_dataFromDC;
	wire ld_cc2DC, ld_data2DC, ld_LRB, ld_WB, ld_exe_data, ld_DAIndex, ld_mem, cnt_dec, ld_data2exe, ld_car, ld_rreq, ld_wreq, ld_mem_we, ld_dma_init, ld_mem_en, clr_req, clr_wb, clr_uaW, clr_dma_init;
	wire[5:0] upc_helper;
	wire[3:0] mem_we, WB_mem_we, memory_we_wb, mem_we_in;
	wire[1:0] FH_mem_size, FH_unalign, SH_mem_size, SH_unalign, alignedSize, adjSize, adj_pre_size;
	wire ld_FH, ld_SH;
	wire[15:0] DMA_Size, DMA_Size_dec;
	wire read_end, new_read_start, isException, commit, CMT_DMA_Init_temp, CMT_DMA_Init;// is the current commit for the dma init bit?
	wire[4:0] upc;

	//Addr: |--7--|--6--|--2--|
	//Tags: |--[22:16]Tag2--|--[14:8]Tag1--|--[6:0]Tag0--|
	//CCStatus: |--[5:4]CC2--|--[3:2]CC2--|--[1:0]CC0--|

	assign setIndex = PRE_RD_PA[7:2];
	assign tagField = PRE_RD_PA[14:8];
	assign lineOffset = PRE_RD_PA[1:0];

	assign newTagField = LRB_back_address[14:8]; // only read miss needs to write new tag (write hit doesn't)
	wire PRE_effsize1_inv;
	inv1$ inv1(PRE_effsize1_inv, PRE_effsize[1]);
	and2$ and3(adj_pre_size[0], PRE_effsize1_inv, PRE_effsize[0]);
	//assign adj_pre_size[0] = ~PRE_effsize[1] & PRE_effsize[0];
	assign adj_pre_size[1] = PRE_effsize[1];

	// rotate data from memory...
	assign memory_data_lrb_rot = {memory_data_lrb[7:0], memory_data_lrb[15:8], memory_data_lrb[23:16], memory_data_lrb[31:24]};

	mux2_32 mux14(Bus_Req_address, LRB_back_address, memory_address_wb, MEM_WReq);

	//TA_WR, DA_WR: 0-write; 1-read
	ram64x24 DCTagArray(setId, wayId, newTagField, OE, TA_WR, Tags);
	regfile64x6 CCStatusArray(setId, wayId, newCCStatus, CC_WE, CCStatus, clk, clr);
	//ram64x96 DCdataArray(setId, wayId, size, DCDR, OE, DA_WR, DAdataOut);
	ram64x96 DCdataArray(setId, wayId, mem_we, DCDR, OE, DA_WR, DAdataOut);
	//StoreQueue sq(SQAddressIn, SQDataIn, SQSizeIn, SQAddressOut, SQDataOut, SQSizeOut, SQAddress2DC, SQData2DC, SQSize2DC, SQhit, full, CouldWrite, CouldRead, CMT_withdata, clk, clr);

	mux2_32 mux1(DAdataIn, nonevict_data, LRB_dataIn, mux_ld_data2DC); // d-cache data register
	mux2_32 mux2(WB_data, evict_data, nonevict_data, mux_wb_data); //evict_data could be cache line flushed due to DMA access..
	mux2_32 mux3(WB_address, evict_address, nonevict_addr, mux_wb_addr); //nonevict_addr could be the addr of the cache line flushed due to DMA access..
	mux2_2 mux4(newCCStatus, CCDR, 2'b10, mux_ld_cc);
	mux3_6 mux5(setId_in, setIndex, cmt2wb_addr[7:2], LRB_back_address[7:2], mux_setId);
	mux2_2 mux6(wayId, WHitWayId, LRB_back_wayId, mux_wayId);
	mux3_32 mux7(DCdata, DAdataOut[31:0], DAdataOut[95:64], DAdataOut[63:32], DAIndex);
	mux2_64 mux8(adjData, {32'b0, data2EXE}, alignedData, PRE_unalign[1]);
	mux2_4 mux9(WB_mem_we, mem_we, 4'b1111, mux_wb_mem_we); // eviction is always 4-byte aligned..
	mux3_32 mux11(address, PRE_RD_PA, cmt2wb_addr, LRB_back_address, mux_address);
	mux2_32 mux12(dataFromDC, DCdata, LRB_dataIn, mux_dataFromDC);
	mux2_2 mux13(adjSize, adj_pre_size, alignedSize, PRE_unalign[1]);

	dff_32 dff1(clk, DAdataIn, DCDR, clr, ld_data2DC);
	dff_2 dff2(clk, newCCStatus1, CCDR, clr, ld_cc2DC); // cc data register
	dff_32 dff3(clk, data2EXE, FirstHalf, clr, ld_FH);
	dff_2 dff4(clk, DAIndex, WHitWayId, clr, ld_DAIndex);
	dff_32 dff5(clk, evict_address_in, evict_address, clr, 1'b1);
	dff_2 dff6(clk, evict_wayId_in, evict_wayId, clr, 1'b1);
	dff_32 dff7(clk, LRB_address_in, LRB_address, clr, 1'b1);
	dff_2 dff8(clk, LRB_wayId_in, LRB_wayId, clr, 1'b1);
	//dff_7 dff9(clk, {CMT_DMA_Init_temp, CMT_DMA_Init, DChit, check_done, evict, memory_ready, WB_Valid}, upc_helper, clr, 1'b1); //use CMT_DMA_Init_temp for deciding next state, CMT_DMA_Init is just flagging
	dff_5 dff9(clk, {DChit, check_done, evict, memory_ready, WB_Valid}, upc_helper[4:0], clr, 1'b1);
    assign upc_helper[5] = CMT_DMA_Init;
	dff_32 dff10(clk, DCDataOut, data2EXE, clr, ld_data2exe);
	dff_64 dff11(clk, adjData, MEM_RD_data, clr, ld_mem_en);
	dff_2 dff12(clk, PRE_effsize, FH_mem_size, clr, ld_FH);
	dff_2 dff13(clk, PRE_unalign, FH_unalign, clr, ld_FH);
	and2$ and2(ld_FH, ~PRE_unalign[1], PRE_unalign[0]);
	//dff_2 dff14(clk, adjSize, MEM_RD_size, clr, ld_mem_en);
	////dff_32 dff16(clk, cmt2wb_data, nonevict_data, clr, 1'b1);
	////dff_15 dff17(clk, cmt2wb_addr, nonevict_addr, clr, 1'b1);
	assign nonevict_data = cmt2wb_data;
	assign nonevict_addr = cmt2wb_addr;
	dff_2 dff18(clk, PRE_effsize, SH_mem_size, clr, ld_SH);
	dff_2 dff19(clk, PRE_unalign, SH_unalign, clr, ld_SH);
	dff_32 dff20(clk, data2EXE, SecondHalf, clr, ld_SH);
	and2$ and1(ld_SH, PRE_unalign[1], ~PRE_unalign[0]);
	dff_6 dff21(clk, setId_in, setId, clr, ld_car);
	dff_4 dff22(clk, mem_we_in, mem_we, clr, ld_mem_we);
	////assign mem_we = mem_we_in;
	dff_1 dff23(clk, 1'b1, MEM_RReq, clr_req & ~IF_flush, ld_rreq);
	dff_1 dff24(clk, 1'b1, MEM_WReq, clr_req & ~IF_flush, ld_wreq);
	//dff_64 dff25(clk, PRE_WR_Data, MEM_WR_Data, clr, ld_mem_en);
	//dff_32 dff26(clk, PRE_WR_Data[31:0], DMA_Target, clr, ld_dmaTarget); // only lsb 15 bits in DMA_Target are valid though since it is a PA
	dff_32 dff26(clk, CMT_Data[31:0], DMA_Target, clr, ld_dmaTarget); // only lsb 15 bits in DMA_Target are valid though since it is a PA
	dff_16 dff27(clk, DMA_Size_dec, DMA_Size, clr, ld_dmaSize); // at most 4K, i.e. 12 bits are valid, store decremented value since 1 really means the current address
	//dff_1 dff28(clk, CMT_DMA_Init_temp, CMT_DMA_Init, clr_dma_init, ld_dma_init);
	dff_1 dff28(clk, clr_dma_init & CMT_DMA_Init_temp, CMT_DMA_Init, 1'b1, ld_dma_init);
	dff_1 dff29(clk, PRE_PCD, MEM_PCD, clr, ld_mem_en);
	//dff_1 dff30(clk, PRE_needW, MEM_CMT, clr, ld_mem_en);
	//dff_2 dff32(clk, PRE_size, MEM_WR_size, clr, ld_mem_en);
	//dff_2 dff32(clk, PRE_size, MEM_size, clr, ld_mem_en);
	dff_32 dff33(clk, PRE_WR_VA, MEM_WR_VA, clr, ld_mem_en);
	dff_32 dff34(clk, PRE_WR_PA1, MEM_WR_PA1, clr, ld_mem_en);
	dff_32 dff35(clk, PRE_WR_PA2, MEM_WR_PA2, clr, ld_mem_en);
	dff_32 dff36(clk, PRE_WR_PA3, MEM_WR_PA3, clr, ld_mem_en);
	dff_32 dff37(clk, PRE_CURRENT_EIP, MEM_CURRENT_EIP, clr, ld_mem_en);
	dff_32 dff38(clk, PRE_NEXT_EIP, MEM_NEXT_EIP, clr, ld_mem_en);
	dff_32 dff39(clk, PRE_REL_EIP, MEM_REL_EIP, clr, ld_mem_en);
	dff_32 dff40(clk, PRE_DISP, MEM_DISP, clr, ld_mem_en);
	dff_32 dff41(clk, PRE_IMM, MEM_IMM, clr, ld_mem_en);
	dff_32 dff42(clk, PRE_DEST_GPR, MEM_DEST_GPR, clr, ld_mem_en);
	dff_32 dff43(clk, PRE_SRC_GPR, MEM_SRC_GPR, clr, ld_mem_en);
	dff_16 dff44(clk, PRE_DEST_SEGR, MEM_DEST_SEGR, clr, ld_mem_en);
	dff_16 dff45(clk, PRE_SRC_SEGR, MEM_SRC_SEGR, clr, ld_mem_en);
	dff_64 dff46(clk, PRE_DEST_MMX, MEM_DEST_MMX, clr, ld_mem_en);
	dff_64 dff47(clk, PRE_SRC_MMX, MEM_SRC_MMX, clr, ld_mem_en);
	dff_128 dff48(clk, PRE_CS, MEM_CS, clr, ld_mem_en);
	dff_32 dff49(clk, PRE_EXP, MEM_EXP, clr, ld_mem_en);
    //assign commit = CMT & new_read_start; // if CMT comes in in the middle of an unaligned read, mask the CMT..
	and2$ and4(commit, CMT, new_read_start);

	// CS forwarding
	assign MEM_dest_gpr_sel = PRE_CS[`DEST_GPR_SEL];
	assign MEM_src_gpr_sel = PRE_CS[`SRC_GPR_SEL];
	assign MEM_dest_segr_sel = PRE_CS[`DEST_SEGR_SEL];
	assign MEM_dest_mmx_sel = PRE_CS[`DEST_MMX_SEL];
	//assign MEM_dest_gpr_wt = PRE_CS[`DEST_GPR_WT] & PRE_Valid;
	//assign MEM_src_gpr_wt = PRE_CS[`SRC_GPR_WT] & PRE_Valid;
	//assign MEM_dest_segr_wt = PRE_CS[`DEST_SEGR_WT] & PRE_Valid;
	//assign MEM_dest_mmx_wt = PRE_CS[`DEST_MMX_WT] & PRE_Valid;
	assign MEM_dest_gpr_type = PRE_CS[`DEST_GPR_TYPE];
	assign MEM_src_gpr_type = PRE_CS[`SRC_GPR_TYPE];
	assign M2P_MEM_WR = PRE_CS[`MEM_WRITE] & PRE_Valid;
	assign M2P_WR_VA = PRE_WR_VA;
	assign M2P_WR_SIZE = PRE_CS[`DATA_TYPE];
	and2$ and7_1(MEM_dest_gpr_wt, PRE_CS[`DEST_GPR_WT], PRE_Valid);
	and2$ and7_2(MEM_src_gpr_wt , PRE_CS[`SRC_GPR_WT], PRE_Valid);
	and2$ and7_3(MEM_dest_segr_wt , PRE_CS[`DEST_SEGR_WT], PRE_Valid);
	and2$ and7_4(MEM_dest_mmx_wt , PRE_CS[`DEST_MMX_WT], PRE_Valid);
    and2$ and7_5(MEM_set_cc, PRE_CS[`LOAD_CC], PRE_Valid);

	//assuming no unaligned access to MMIO page...
	wire PRE_unalign0_inv, PRE_unalign1_inv, PRE_uaSSE_inv;
	inv1$ inv2(PRE_unalign0_inv, PRE_unalign[0]);
	inv1$ inv3(PRE_unalign1_inv, PRE_unalign[1]);
	inv1$ inv4(PRE_uaSSE_inv, PRE_uaSSE);
	wire read_end0, read_end1;
	and2$ and6(read_end0, PRE_unalign0_inv, PRE_uaSSE_inv);
	and3$ and7(read_end1, PRE_unalign[1], PRE_unalign[0], PRE_uaSSE);
	or2$ or1(read_end, read_end0, read_end1);
	//assign read_end = (~PRE_unalign[0] & ~PRE_uaSSE) | (PRE_unalign[1] & PRE_unalign[0] & PRE_uaSSE);
	wire new_read_start0, new_read_start1;
	and2$ and8(new_read_start0, PRE_unalign1_inv, PRE_uaSSE_inv);
	and3$ and9(new_read_start1, PRE_unalign1_inv, PRE_unalign[0], PRE_uaSSE);
	or2$ or2(new_read_start, new_read_start0, new_read_start1);
	//assign new_read_start = (~PRE_unalign[1] & ~PRE_uaSSE) | (~PRE_unalign[1] & PRE_unalign[0] & PRE_uaSSE);

	//assign isException = PRE_EXP[1] | PRE_EXP[0];
	and2$ and5(isException, PRE_EXP[1], PRE_EXP[0]);

	add2_16 dec1(CMT_Data[15:0], 16'hFFFF, DMA_Size_dec, , );

    wire ld_dmaTarget_temp, ld_dmaSize_temp, CMT_DMA_Init_temp1;
	//mag_comp32 comp1(CMT_addr, 32'hFFFF0004, ld_dmaTarget);
	mag_comp32 comp1(CMT_addr, 32'hFFFF0004, ld_dmaTarget_temp);
    and2$ andz_1(ld_dmaTarget, ld_dmaTarget_temp, commit);
	//mag_comp32 comp2(CMT_addr, 32'hFFFF0008, ld_dmaSize);
	mag_comp32 comp2(CMT_addr, 32'hFFFF0008, ld_dmaSize_temp);
    and2$ andz_2(ld_dmaSize, ld_dmaSize_temp, commit);
	//mag_comp32 comp3(CMT_addr, 32'hFFFF000C, CMT_DMA_Init_temp);
	mag_comp32 comp3(CMT_addr, 32'hFFFF000C, CMT_DMA_Init_temp1);
    and2$ andz_3(CMT_DMA_Init_temp, CMT_DMA_Init_temp1, commit);

	DCTagCCLogic logic1(Tags, CCStatus, address, DA_WR, CMT_DMA_Init_temp, DChit, evict, DAIndex, LRB_wayId_in, LRB_address_in, evict_address_in, newCCStatus1, evict_wayId_in);
	DCDataLogic logic2(evict_wayId, DAdataOut, evict_data);
	LineRefillBuffeLogic logic3(LRB_wayId, LRB_address, LRB_dataIn, ld_LRB, LRB_back_wayId, LRB_back_address, memory_data_lrb_rot, clk, clr);
	WriteBufferLogic logic4(WB_mem_we, WB_address, WB_data, ld_WB, memory_we_wb, memory_address_wb, memory_data_wb, WB_Valid, clk, clr_wb, clr);
	DataInAdjustLogic logic5(CMT_PA1, CMT_PA2, CMT_PA3, CMT_DMA_Init_temp, DMA_Target, DMA_Size, CMT_Data, CMT_addr, CMT_size, ld_cnt, mux_mem_size, cmt2wb_data, cmt2wb_addr, check_done, mem_we_in, cnt_dec, clk, clr);//UnalignedWriteLogic 
	DataOutAdjustLogic logic6(dataFromDC, DCDataOut, PRE_effsize, lineOffset, PRE_unalign);
	CacheController logic7(PRE_PCD, PRE_MEM_Valid, PRE_Valid, PRE_WR, isException, IF_flush, commit, upc_helper, TA_WR, DA_WR, CC_WE, OE, ld_cnt, mux_mem_size, mux_ld_data2DC, mux_wb_data, mux_wb_addr, mux_wb_mem_we, mux_ld_cc, mux_wayId, mux_dataFromDC, ld_cc2DC, ld_data2DC, ld_LRB, ld_WB, ld_exe_data, ld_DAIndex, ld_rreq, ld_wreq, ld_mem_we, ld_dma_init, clr_req, cnt_dec, ld_data2exe, ld_car, stall, mux_address, mux_setId, clr_wb, clr_uaW, clr_dma_init, clk, clr, upc);
	UnalignAdjustLogic logic8(PRE_uaSSE, FirstHalf, SecondHalf, data2EXE, FH_mem_size, FH_unalign, SH_mem_size, SH_unalign, PRE_effsize, PRE_unalign, alignedData, alignedSize);
	MemSLVLogic logic9(upc, stall, memory_ready, check_done, CMT, PRE_Valid, PRE_MEM_Valid, PRE_PCD, WB_Valid, EXE_stall, MEM2Pre_stall, MEM2CMT_stall, read_end, MEM_Valid, ld_exe_data, ld_mem_en, IF_flush, clk, clr);//Stall, Load enable, Valid logic..
endmodule

