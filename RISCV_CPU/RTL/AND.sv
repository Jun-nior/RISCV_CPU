module AND (
    input [2:0] func3, // for bne & beq
    input       branch,
    input       zero,
    output      and_o
);

assign and_o =  (func3 == 3'b000) ? (branch & zero) :   
                (func3 == 3'b001) ? (branch & !zero) :     
                1'b0;

endmodule