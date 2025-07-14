module Adder#(
    parameter ADDR_WIDTH = 32
) (
    input [ADDR_WIDTH - 1 : 0] PC_out,
    output [ADDR_WIDTH - 1 : 0] Adder_out
)

assign Adder_out = PC_out + 4;

endmodule