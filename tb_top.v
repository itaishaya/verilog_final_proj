`timescale 1ns/1ps

module tb_top;
    localparam integer REG_WIDTH = 16;
    localparam integer INSTRUCTION_WIDTH = 9;
    localparam integer COUNTER_WIDTH = 2;

    reg clk;
    reg rst;
    reg run;
    reg [REG_WIDTH-1:0] din;
    wire [REG_WIDTH-1:0] bus;
    wire done;

    top #(
        .REG_WIDTH(REG_WIDTH),
        .INSTRUCTION_WIDTH(INSTRUCTION_WIDTH),
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .run(run),
        .din(din),
        .bus(bus),
        .done(done)
    );

    always #5 clk = ~clk;

    task wait_for_t(input [COUNTER_WIDTH-1:0] tval);
        begin
            while (dut.COUNTER.t !== tval) @(negedge clk);
        end
    endtask

    task issue_mvi(
        input [2:0] dest,
        input [REG_WIDTH-1:0] imm
    );
        reg [INSTRUCTION_WIDTH-1:0] instr;
        begin
            instr = {3'b001, dest, 3'b000};
            wait_for_t(2'b00);
            din = {{(REG_WIDTH-INSTRUCTION_WIDTH){1'b0}}, instr};

            wait_for_t(2'b01);
            din = imm;
            #1;
            if (bus !== imm) begin
                $fatal(1, "MVI bus mismatch: expected %h, got %h", imm, bus);
            end
            if (!done) begin
                $fatal(1, "MVI done not asserted at t1");
            end
            @(posedge clk);
        end
    endtask

    task issue_mv(
        input [2:0] dest,
        input [2:0] src,
        input [REG_WIDTH-1:0] expected_bus
    );
        reg [INSTRUCTION_WIDTH-1:0] instr;
        begin
            instr = {3'b000, dest, src};
            wait_for_t(2'b00);
            din = {{(REG_WIDTH-INSTRUCTION_WIDTH){1'b0}}, instr};

            wait_for_t(2'b01);
            #1;
            if (bus !== expected_bus) begin
                $fatal(1, "MV bus mismatch: expected %h, got %h", expected_bus, bus);
            end
            if (!done) begin
                $fatal(1, "MV done not asserted at t1");
            end
            @(posedge clk);
        end
    endtask

    task issue_addsub(
        input [2:0] cmd,
        input [2:0] dest,
        input [2:0] src,
        input [REG_WIDTH-1:0] expected_result
    );
        reg [INSTRUCTION_WIDTH-1:0] instr;
        begin
            instr = {cmd, dest, src};
            wait_for_t(2'b00);
            din = {{(REG_WIDTH-INSTRUCTION_WIDTH){1'b0}}, instr};

            wait_for_t(2'b11);
            #1;
            if (bus !== expected_result) begin
                $fatal(1, "ADD/SUB bus mismatch: expected %h, got %h", expected_result, bus);
            end
            if (!done) begin
                $fatal(1, "ADD/SUB done not asserted at t3");
            end
            @(posedge clk);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        run = 1'b0;
        din = {REG_WIDTH{1'b0}};
        $monitor("t=%0t clk=%b rst=%b run=%b din=%h bus=%h done=%b tstep=%b",
                 $time, clk, rst, run, din, bus, done, dut.COUNTER.t);

        // Reset registers.
        repeat (2) @(posedge clk);
        rst = 1'b1;

        // Initialize the step counter to t0 for deterministic sequencing.
        force dut.COUNTER.t = 2'b00;
        @(posedge clk);
        release dut.COUNTER.t;

        run = 1'b1;

        // R0 <- 0x0005
        issue_mvi(3'b000, 16'h0005);
        // R1 <- R0
        issue_mv(3'b001, 3'b000, 16'h0005);

        // R2 <- 0x00A5
        issue_mvi(3'b010, 16'h00A5);
        // R3 <- R2
        issue_mv(3'b011, 3'b010, 16'h00A5);

        // R4 <- 0x0005
        issue_mvi(3'b100, 16'h0005);
        // R5 <- 0x0003
        issue_mvi(3'b101, 16'h0003);
        // R4 <- R4 + R5 = 0x0008
        issue_addsub(3'b010, 3'b100, 3'b101, 16'h0008);
        // R4 <- R4 - R5 = 0x0005
        issue_addsub(3'b011, 3'b100, 3'b101, 16'h0005);

        $display("tb_top completed");
        $stop;
    end

endmodule
