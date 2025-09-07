`timescale 1ns/1ps

module tb_fir;
    reg clk, rst;
    reg signed [15:0] x_in;
    wire signed [31:0] y_out;

    // Instantiate FIR filter
    fir_filter_booth_cska uut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_out(y_out)
    );

    // Clock generation: 100 MHz (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $monitor("t=%0dns, x_in=%d, y_out=%d", $time, x_in, y_out);

        rst = 1; x_in = 0;
        #10 rst = 0;

        #10 x_in = 16'sd1;
        #10 x_in = 16'sd2;
        #10 x_in = 16'sd3;
        #10 x_in = 16'sd4;
        #10 x_in = 16'sd0;
        #100 $finish;
    end
endmodule
