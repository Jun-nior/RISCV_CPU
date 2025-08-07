module Mem_Mux #(
    parameter DAT_WIDTH = 32   
) (
    input       [1:0]               sel,
    input       [DAT_WIDTH - 1 : 0] a,
    input       [DAT_WIDTH - 1 : 0] b,
    input       [DAT_WIDTH - 1 : 0] c,
    output      [DAT_WIDTH - 1 : 0] mux_o
);

assign mux_o = (sel == 2'b00) ? a : (sel == 2'b01) ? b : c;

endmodule