module ALU #(
    
) (
    input           [31:0]  in1,
    input           [31:0]  in2,
    input           [3:0]   control_i,
    output signed   [31:0]  ALU_o,
    output                  zero
);

logic   [31:0]  ALU_o_reg;
logic           zero_reg;

always @(control_i or in1 or in2) begin
    case (control_i)
        4'b0000: begin
            ALU_o_reg = in1 & in2;
            zero_reg = 0;
        end
        4'b0001: begin
            ALU_o_reg = in1 | in2;
            zero_reg = 0;
        end
        4'b0010: begin
            ALU_o_reg = in1 + in2;
            zero_reg = 0;
        end
        4'b0110: begin
            ALU_o_reg = in1 - in2;
            zero_reg = (in1 == in2) ? 1 : 0;
        end
        4'b0100: begin
            ALU_o_reg = in1 ^ in2;
            zero_reg = 0;
        end
        default: begin
            zero_reg = 0;
            ALU_o_reg = 0;
        end
    endcase
end

assign ALU_o = ALU_o_reg;
assign zero = zero_reg;

endmodule