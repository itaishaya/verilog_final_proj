module StepCounter (
    input clk,
    input clr,
    output reg [3:0] T  //register for T0, T1, T2 and T3
);
    reg [1:0] count = 2'b00;

    always @(posedge clk) begin
        if (clr)// reset count if clear was inputed
            count <= 2'b00;
        else
            count <= count + 1'b1;
    end

    // Decode the count to signals in the register
    always @(*) begin
        T = 4'b0000;
        case (count)
            2'b00: T[0] = 1'b1;
            2'b01: T[1] = 1'b1;
            2'b10: T[2] = 1'b1;
            2'b11: T[3] = 1'b1;
        endcase
    end
endmodule