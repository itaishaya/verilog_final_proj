module addsub
#(
    parameter integer REG_WIDTH = 16
)
(
    input wire add_sub,
    input wire[REG_WIDTH-1:0] a,b,
    output wire[REG_WIDTH-1:0] c
);

    assign c = add_sub ? a + b : a - b;
    
endmodule