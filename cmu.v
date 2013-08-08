
// if stop = 1
// stop the clk
module cmu(
    clk_in,
    clk_out,
    stop,
    resume_n
);
    input clk_in;
    input stop;
    input resume_n;

    output clk_out;

    wire clk_stop_n;
    wire clk_stop_n_tmp;
    
    // if stop == 1 && resume_n = 1
    // then stop clock
    nand2$ nand_0(clk_stop_n_tmp, stop, resume_n);
    dff$ dff_clk(.clk(clk_in), .d(clk_stop_n_tmp), .q(clk_stop_n), .r(1'b1), .s(1'b1));
    // if resume_n = 0, clk_stop_n = 1
    nand2$ nand_1(clk_out, clk_stop_n, clk_in);
endmodule
