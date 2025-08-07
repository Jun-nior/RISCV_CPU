module AND (
    input [2:0] func3, // for bne & beq
    input       jump,  // for jal
    input       branch,
    input       zero,
    output      and_o
);

assign and_o =  (func3 == 3'b000 & !jump) ? (branch & zero) :   // BEQ
                (func3 == 3'b001 & !jump) ? (branch & !zero) :  // BNE   
                (jump) ? 1'b1 : 1'b0;                           // JAL

endmodule