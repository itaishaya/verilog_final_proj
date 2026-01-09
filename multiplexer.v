module multiplexer 
#(
    parameter integer REG_WIDTH = 16
)
(
    input wire [REG_WIDTH-1:0] r0, r1, r2, r3, r4, r5, r6, r7,
    input wire [REG_WIDTH-1:0] din,
    input wire [REG_WIDTH-1:0] g,
    input wire r0_out, r1_out, r2_out, r3_out,
    input wire r4_out, r5_out, r6_out, r7_out,
    input wire g_out,
    input wire din_out,
    output reg [REG_WIDTH-1:0] bus
);

    // Concatenate all control signals into a 10-bit selection vector
    wire [9:0] sel;
    assign sel = {din_out, g_out, r7_out, r6_out, r5_out, r4_out, r3_out, r2_out, r1_out, r0_out};

    always @(*) begin
        case (1'b1) // Check which bit in the vector is set to 1
            sel[0]: bus = r0;
            sel[1]: bus = r1;
            sel[2]: bus = r2;
            sel[3]: bus = r3;
            sel[4]: bus = r4;
            sel[5]: bus = r5;
            sel[6]: bus = r6;
            sel[7]: bus = r7;
            sel[8]: bus = g;
            sel[9]: bus = din;
            default: bus = 16'bx; // "Don't care" or High Impedance (16'bz)
        endcase
    end

endmodule