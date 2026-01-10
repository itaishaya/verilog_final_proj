module top
#(
    parameter integer REG_WIDTH = 16,
    parameter integer INSTRUCTION_WIDTH = 9,
    parameter integer COUNTER_WIDTH = 2
)
(
    input wire clk, rst, run,
    input wire[REG_WIDTH-1:0] din,
    output wire [REG_WIDTH-1:0] bus,
    output wire done
);
    //* Registers instantiation

    // Useful signals for registers connection to the ALU and multiplexer
    wire[REG_WIDTH-1:0] d0_out, d1_out, d2_out, d3_out, d4_out, d5_out, d6_out, d7_out;
    wire[REG_WIDTH-1:0] a_out, g_data_out;
    wire[REG_WIDTH-1:0] alu_out;
    wire[INSTRUCTION_WIDTH-1:0] ir_out;
    wire[INSTRUCTION_WIDTH-1:0] ir_data;

    wire[REG_WIDTH-1:0] bus_sig;
    wire add_sub;


    //! Control unit signals

    //* Registers enables
    wire r0_in, r1_in, r2_in, r3_in, r4_in, r5_in, r6_in, r7_in;

    //* Multiplexer signal
    // Registers selects
    wire r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out;
    wire g_out, din_out;

    // Counter signals
    wire [COUNTER_WIDTH-1:0] t;
    wire clr;


    assign bus = bus_sig;

    // Assigment of the IR register - lower 9 bits of the din input
    assign ir_data = din[INSTRUCTION_WIDTH-1:0];


    // R0 register
    register R0(
        .clk(clk),
        .rst(rst),
        .enable(r0_in),
        .din(bus_sig),
        .dout(d0_out)
    );

    // R1 register
    register R1(
        .clk(clk),
        .rst(rst),
        .enable(r1_in),
        .din(bus_sig),
        .dout(d1_out)
    );

    // R2 register
    register R2(
        .clk(clk),
        .rst(rst),
        .enable(r2_in),
        .din(bus_sig),
        .dout(d2_out)
    );

    // R3 register
    register R3(
        .clk(clk),
        .rst(rst),
        .enable(r3_in),
        .din(bus_sig),
        .dout(d3_out)
    );
    
    // R4 register
    register R4(
        .clk(clk),
        .rst(rst),
        .enable(r4_in),
        .din(bus_sig),
        .dout(d4_out)
    );

    // R5 register
    register R5(
        .clk(clk),
        .rst(rst),
        .enable(r5_in),
        .din(bus_sig),
        .dout(d5_out)
    );

    // R6 register
    register R6(
        .clk(clk),
        .rst(rst),
        .enable(r6_in),
        .din(bus_sig),
        .dout(d6_out)
    );

    // R7 register
    register R7(
        .clk(clk),
        .rst(rst),
        .enable(r7_in),
        .din(bus_sig),
        .dout(d7_out)
    );

    // A register - before ALU for sub and add operations
    // A register
    register A(
        .clk(clk),
        .rst(rst),
        .enable(a_in),
        .din(bus_sig),
        .dout(a_out)
    );

    // G register - after ALU for sub and add operations
    // G register
    register G(
        .clk(clk),
        .rst(rst),
        .enable(g_in),
        .din(alu_out),
        .dout(g_data_out)
    );


    //*ALU instance
    addsub ADDSUB (
        .add_sub(add_sub),
        .a(a_out),
        .b(bus_sig),
        .c(alu_out)
    );

    //* IR register - before control unit
    register IR(
        .clk(clk),
        .rst(rst),
        .enable(ir_in),
        .din(ir_data),
        .dout(ir_out)
    );


    //* Step counter instance
    counter COUNTER(
        .clk(clk),
        .clr(clr),
        .t(t)
    );

    //* Multiplexer instance
    multiplexer MULTIPLEXER(
        .r0(d0_out),
        .r1(d1_out),
        .r2(d2_out),
        .r3(d3_out),
        .r4(d4_out),
        .r5(d5_out),
        .r6(d6_out),
        .r7(d7_out),
        .din(din),
        .g(g_data_out),
        .r0_out(r0_out), .r1_out(r1_out), .r2_out(r2_out), .r3_out(r3_out),
        .r4_out(r4_out), .r5_out(r5_out), .r6_out(r6_out), .r7_out(r7_out),
        .g_out(g_out),
        .din_out(din_out),
        .bus(bus_sig)
    );

    //* Control unit connections
	control_unit CONTROL_UNIT (
	    .clk(clk),
        .rst(rst),
        .run(run),

        // Instruction register output → control unit instruction input
        .ir(ir_out),

        // Time counter
        .t(t),

        // Control signals returned by CU
        .clr(clr),
        .done(done),

        // Outputs selecting which register drives the bus
        .r0_out(r0_out),
        .r1_out(r1_out),
        .r2_out(r2_out),
        .r3_out(r3_out),
        .r4_out(r4_out),
        .r5_out(r5_out),
        .r6_out(r6_out),
        .r7_out(r7_out),
        .g_out(g_out),
        .din_out(din_out),

        // Write-enable signals for registers
        .r0_in(r0_in),
        .r1_in(r1_in),
        .r2_in(r2_in),
        .r3_in(r3_in),
        .r4_in(r4_in),
        .r5_in(r5_in),
        .r6_in(r6_in),
        .r7_in(r7_in),
        .a_in(a_in),
        .g_in(g_in),
        .ir_in(ir_in),
        .add_sub(add_sub)
	);
    
    
endmodule
