module Control_Unit#(

) (
    input  [6:0] instruction,
    output       Branch,
    output       MemRead,
    output       MemtoReg,
    output [1:0] ALUOp,
    output       MemWrite,
    output       ALUSrc,
    output       RegWrite,
    output       Jump           // jal
);

logic        Branch_reg;
logic        MemRead_reg;
logic        MemtoReg_reg;
logic [1:0]  ALUOp_reg;
logic        MemWrite_reg;
logic        ALUSrc_reg;
logic        RegWrite_reg;
logic        Jump_reg;  

always_comb begin
    case (instruction)
        // R-type
        7'b0110011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0], Jump_reg} = 9'b001000100;
        end
        // I-type
        7'b0010011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0], Jump_reg} = 9'b101000000;
        end
        // Load-type
        7'b0000011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0], Jump_reg} = 9'b111100000;
        end
        // Store-type
        7'b0100011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0], Jump_reg} = 9'b100010000;
        end
        // Branch-type
        7'b1100011: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0], Jump_reg} = 9'b000001010;
        end
        7'b1101111: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0], Jump_reg} = 9'b001000001;
        end
        default: begin
            {ALUSrc_reg, MemtoReg_reg, RegWrite_reg, MemRead_reg, MemWrite_reg, Branch_reg, ALUOp_reg[1], ALUOp_reg[0], Jump_reg} = 9'b0;
        end
    endcase
end

assign Branch   = Branch_reg;
assign MemRead  = MemRead_reg;
assign MemtoReg = MemtoReg_reg;
assign ALUOp    = ALUOp_reg;
assign MemWrite = MemWrite_reg;
assign ALUSrc   = ALUSrc_reg;
assign RegWrite = RegWrite_reg;
assign Jump     = Jump_reg;

endmodule