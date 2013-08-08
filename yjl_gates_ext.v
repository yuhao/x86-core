//==========================================
//==========================================

module adder4b(out, in0, in1, cin);
    input [3:0] in0;
    input [3:0] in1;
    input       cin;
    output [3:0] out;
  
    assign out = in0 + in1 + cin;
endmodule

module adder16b(out, in0, in1, cin);
    input [15:0] in0;
    input [15:0] in1;
    input       cin;
    output [15:0] out;
  
    assign out = in0 + in1 + cin;
endmodule

module adder32b(out, in0, in1);
    input [31:0] in0;
    input [31:0] in1;
    output [31:0] out;
  
    assign out = in0 + in1;
endmodule

// increment in by one, when flag is 1 
module incrementer2b(out, in, flag);
    input           flag;
    input [1:0]     in;
    output [1:0]    out;

    wire [1:0] inc_tmp;
    assign inc_tmp = in + 2'b1;

    mux2_2(out, in, inc_tmp, flag);

endmodule


// SHIFT
//module lshift128b(out, in, shift_length);
//    input  [127:0] in;
//    input  [3:0]   shift_length;    // 0-16 byte
//
//    output [127:0] out;
//    
//    /* Replace the Behavioral Code Below */
//    assign out = in << shift_length; 
//endmodule

// shift the in[127:0] by byte-wise amount
module lshift128b_8(out, in, shift_length);
    input  [127:0] in;
    input  [3:0]   shift_length;    // 0-16 byte

    output [127:0] out;
    
    /* Replace the Behavioral Code Below */
    wire [256:0] tmp;
    assign tmp = in << (shift_length * 8);
    assign out = tmp[127:0]; 

endmodule


// dec until in == 0
// if 0, stop subtracting
module decrementer4b(out, in);
   input [3:0] in;
   output [3:0] out;
   
   wire stop_flag;
   cmp4b cmp_0(stop_flag, in, 4'b0); 
   assign out = (stop_flag)? 4'b0 : in -1;
endmodule

module adder2b(out, in0, in1);
    input [1:0] in0;
    input [1:0] in1;
    output [1:0] out;
  
    assign out = in0 + in1;
endmodule


module adder3b(out, in0, in1);
    input [2:0] in0;
    input [2:0] in1;
    output [2:0] out;
  
    assign out = in0 + in1;
endmodule


