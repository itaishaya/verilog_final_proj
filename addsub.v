module register
#(
    parameter integer REG_WIDTH = 16
)
(
    input   wire                clk, rst, enable,
    input   wire[REG_WIDTH-1:0] din,
    output  reg [REG_WIDTH-1:0] dout
);
    always @(posedge clk or negedge rst) 
    begin
        if(!rst)
        begin
            dout <= 0;
        end
        else 
        begin
            if(enable)
            begin
                dout <= din;
            end
        end
    end
endmodule