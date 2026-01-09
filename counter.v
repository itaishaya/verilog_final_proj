module counter
#(
    parameter integer COUNTER_WIDTH = 2
)
(
    input wire clk,
    input wire clr,
    output reg [COUNTER_WIDTH-1:0] t  //register for T0, T1, T2 and T3
);

    always @(posedge clk) begin
        if (clr)// reset count if clear was inputed
            t <= 2'b00;
        else
            t <= t + 2'b1;
    end
    
endmodule