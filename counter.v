module step_counter (
    input clk,
    input clr,
    output reg [1:0] t //2 bits: 00, 01, 10, 11
);
    always @(posedge clk) begin
        if (clr)
            t <= 2'b00;
        else
            t <= t + 1'b1;
    end
endmodule