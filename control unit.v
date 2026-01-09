module control_unit (
    input wire clk, rst, run,
    input wire [8:0] ir,          // instruction format: [8:6] III (cmd), [5:3] xxx (dest), [2:0] yyy (source)
    input wire [1:0] t,           // time steps t0, t1, t2, t3
    output reg clr, done,
    output reg r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out, g_out, din_out,
    output reg r0_in, r1_in, r2_in, r3_in, r4_in, r5_in, r6_in, r7_in, a_in, g_in, ir_in
);

    // internal signals for instruction decoding
    wire [2:0] cmd = ir[8:6];
    wire [2:0] dest   = ir[5:3];
    wire [2:0] source = ir[2:0];

    // instruction cmds
    localparam mv  = 3'b000,
               mvi = 3'b001,
               add = 3'b010,
               sub = 3'b011;

    always @(*) begin
        // default values - all control signals inactive
        {r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out, g_out, din_out} = 10'b0;
        {r0_in, r1_in, r2_in, r3_in, r4_in, r5_in, r6_in, r7_in, a_in, g_in, ir_in} = 11'b0;
        done = 1'b0;
        clr = 1'b0;

        case (t)
            2'b00: begin // t0: instruction fetch phase
                ir_in = 1'b1;
                din_out = 1'b1; // load instruction from din into ir
                if (!run) clr = 1'b1; // stay at t0 if run is not asserted
            end

            2'b01: begin // t1: execution for mv/mvi or setup for add/sub
                case (cmd)
                    mv: begin // copy out_register to in_register
                        // select source register for the bus
                        case (source)
                            3'b000: r0_out = 1'b1; 3'b001: r1_out = 1'b1;
                            3'b010: r2_out = 1'b1; 3'b011: r3_out = 1'b1;
                            3'b100: r4_out = 1'b1; 3'b101: r5_out = 1'b1;
                            3'b110: r6_out = 1'b1; 3'b111: r7_out = 1'b1;
                        endcase
                        // select destination register to load from bus
                        case (dest)
                            3'b000: r0_in = 1'b1; 3'b001: r1_in = 1'b1;
                            3'b010: r2_in = 1'b1; 3'b011: r3_in = 1'b1;
                            3'b100: r4_in = 1'b1; 3'b101: r5_in = 1'b1;
                            3'b110: r6_in = 1'b1; 3'b111: r7_in = 1'b1;
                        endcase
                        done = 1'b1; clr = 1'b1; // finish instruction
                    end

                    mvi: begin // load immediate value from din to in_register
                        din_out = 1'b1;
                        case (dest)
                            3'b000: r0_in = 1'b1; 3'b001: r1_in = 1'b1;
                            3'b010: r2_in = 1'b1; 3'b011: r3_in = 1'b1;
                            3'b100: r4_in = 1'b1; 3'b101: r5_in = 1'b1;
                            3'b110: r6_in = 1'b1; 3'b111: r7_in = 1'b1;
                        endcase
                        done = 1'b1; clr = 1'b1;
                    end

                    add, sub: begin // load in_register into register a
                        case (dest)
                            3'b000: r0_out = 1'b1; 3'b001: r1_out = 1'b1;
                            3'b010: r2_out = 1'b1; 3'b011: r3_out = 1'b1;
                            3'b100: r4_out = 1'b1; 3'b101: r5_out = 1'b1;
                            3'b110: r6_out = 1'b1; 3'b111: r7_out = 1'b1;
                        endcase
                        a_in = 1'b1;
                    end
                endcase
            end

            2'b10: begin // t2: alu operation (a + out_register or a - out_register)
                // place out_register on bus, alu performs calculation, store in g
                case (source)
                    3'b000: r0_out = 1'b1; 3'b001: r1_out = 1'b1;
                    3'b010: r2_out = 1'b1; 3'b011: r3_out = 1'b1;
                    3'b100: r4_out = 1'b1; 3'b101: r5_out = 1'b1;
                    3'b110: r6_out = 1'b1; 3'b111: r7_out = 1'b1;
                endcase
                g_in = 1'b1;
            end

            2'b11: begin // t3: store alu result from g into in_register
                g_out = 1'b1;
                case (dest)
                    3'b000: r0_in = 1'b1; 3'b001: r1_in = 1'b1;
                    3'b010: r2_in = 1'b1; 3'b011: r3_in = 1'b1;
                    3'b100: r4_in = 1'b1; 3'b101: r5_in = 1'b1;
                    3'b110: r6_in = 1'b1; 3'b111: r7_in = 1'b1;
                endcase
                done = 1'b1; clr = 1'b1;
            end
        endcase
    end
endmodule