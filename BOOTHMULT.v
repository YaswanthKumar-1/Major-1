`timescale 1ns/1ps
module radix8_booth_multiplier #(parameter N = 16)(
    input  signed [N-1:0] multiplicand,
    input  signed [N-1:0] multiplier,
    output signed [2*N-1:0] product
);

    localparam G = (N + 2) / 3;

    wire [N:0] y_ext;
    assign y_ext = {multiplier[N-1], multiplier};

    wire signed [2*N-1:0] partial_products [0:G-1];

    genvar i;
    generate
        for (i = 0; i < G; i = i + 1) begin : booth_block
            // Directly extract 4 bits from y_ext for Booth encoding
            wire [3:0] y_segment;
            assign y_segment[0] = (3*i == 0) ? 1'b0 : y_ext[3*i-1];
            assign y_segment[1] = y_ext[3*i];
            assign y_segment[2] = (3*i+1 > N) ? y_ext[N] : y_ext[3*i+1];
            assign y_segment[3] = (3*i+2 > N) ? y_ext[N] : y_ext[3*i+2];

            reg signed [2*N-1:0] booth_out;

            always @(*) begin
                case (y_segment)
                    4'b0000, 4'b1111: booth_out = 0;
                    4'b0001, 4'b0010: booth_out = multiplicand;
                    4'b0011, 4'b0100: booth_out = multiplicand <<< 1;
                    4'b0101, 4'b0110: booth_out = multiplicand + (multiplicand <<< 1);
                    4'b0111:          booth_out = multiplicand <<< 2;
                    4'b1000:          booth_out = -(multiplicand <<< 2);
                    4'b1001, 4'b1010: booth_out = -(multiplicand + (multiplicand <<< 1));
                    4'b1011, 4'b1100: booth_out = -(multiplicand <<< 1);
                    4'b1101, 4'b1110: booth_out = -multiplicand;
                    default:          booth_out = 0;
                endcase
            end

            assign partial_products[i] = booth_out <<< (3*i);
        end
    endgenerate

    reg signed [2*N-1:0] final_sum;
    integer k;
    always @(*) begin
        final_sum = 0;
        for (k = 0; k < G; k = k + 1)
            final_sum = final_sum + partial_products[k];
    end

    assign product = final_sum;

endmodule
