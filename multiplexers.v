module Multiplexers (
    input [15:0] R0, R1, R2, R3, R4, R5, R6, R7,
    input [15:0] Din,
    input [15:0] G,
    input R0_out, R1_out, R2_out, R3_out,
    input R4_out, R5_out, R6_out, R7_out,
    input G_out,
    input DIN_out,
    output reg [15:0] Bus
);

    // Concatenate all control signals into a 10-bit selection vector
    wire [9:0] sel;
    assign sel = {DIN_out, G_out, R7_out, R6_out, R5_out, R4_out, R3_out, R2_out, R1_out, R0_out};

    always @(*) begin
        case (1'b1) // Check which bit in the vector is set to 1
            sel[0]: Bus = R0;
            sel[1]: Bus = R1;
            sel[2]: Bus = R2;
            sel[3]: Bus = R3;
            sel[4]: Bus = R4;
            sel[5]: Bus = R5;
            sel[6]: Bus = R6;
            sel[7]: Bus = R7;
            sel[8]: Bus = G;
            sel[9]: Bus = Din;
            default: Bus = 16'bx; // "Don't care" or High Impedance (16'bz)
        endcase
    end

endmodule