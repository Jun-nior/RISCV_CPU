module ALU_Control #(

) (
    input   [1:0]   ALUOp,
    input           func7,
    input   [2:0]   func3,
    output  [3:0]   control_o
);

logic [3:0] control_o_reg;

always @(*) begin
    case ({ALUOp, func7, func3})
        6'b00_0_000: begin
            control_o_reg = 4'b0010;
        end
        6'b01_0_000: begin
            control_o_reg = 4'b0110;
        end
        6'b10_0_000: begin
            control_o_reg = 4'b0010;
        end
        6'b10_1_000: begin
            control_o_reg = 4'b0110;
        end
        6'b10_0_111: begin
            control_o_reg = 4'b0000;
        end
        6'b10_0_110: begin
            control_o_reg = 4'b0001;
        end
        6'b00_0_010: begin // lw
            control_o_reg = 4'b0010;
        end
        default: begin
            control_o_reg = 4'bxxxx;
        end
    endcase
end

assign control_o = control_o_reg;

endmodule