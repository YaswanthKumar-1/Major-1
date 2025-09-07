
`timescale 1ns/1ps

module fir_filter_booth_cska #(
    parameter N = 16, 
    parameter N_TAPS = 8
)(
    input clk,
    input rst,
    input signed [N-1:0] x_in,
    output signed [2*N-1:0] y_out
);

 
    reg signed [N-1:0] coeffs [0:N_TAPS-1];
    initial begin
        coeffs[0] = 16'sd1;
        coeffs[1] = 16'sd2;
        coeffs[2] = 16'sd3;
        coeffs[3] = 16'sd4;
        coeffs[4] = 16'sd3;
        coeffs[5] = 16'sd2;
        coeffs[6] = 16'sd1;
        coeffs[7] = 16'sd0;
    end

  
    reg signed [N-1:0] shift_reg [0:N_TAPS-1];
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < N_TAPS; i = i + 1)
                shift_reg[i] <= 0;
        end else begin
            for (i = N_TAPS-1; i > 0; i = i - 1)
                shift_reg[i] <= shift_reg[i-1];
            shift_reg[0] <= x_in;
        end
    end

    // ---------------------------
    // Booth Multipliers
    // ---------------------------
    wire signed [2*N-1:0] products [0:N_TAPS-1];
    genvar j;
    generate
        for (j = 0; j < N_TAPS; j = j + 1) begin : mult_stage
            radix8_booth_multiplier #(.N(N)) booth_mul (
                .multiplicand(shift_reg[j]),
                .multiplier(coeffs[j]),
                .product(products[j])
            );
        end
    endgenerate

 
    wire signed [2*N-1:0] sum_stage [0:N_TAPS];
    assign sum_stage[0] = {2*N{1'b0}};

    generate
        for (genvar k = 0; k < N_TAPS; k = k + 1) begin : add_stage
            cska_top #(.N(2*N), .BLOCK_SIZE(4)) cska_add (
                .A(sum_stage[k]),
                .B(products[k]),
                .Cin(1'b0),
                .Sum(sum_stage[k+1]),
                .Cout() 
            );
        end
    endgenerate

    assign y_out = sum_stage[N_TAPS];

endmodule
