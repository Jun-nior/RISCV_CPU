module ALU_Control #(

) (
    input   [1:0]   ALUOp,
    input           func7,
    input   [2:0]   func3,
    output  [3:0]   control_o
);

logic [3:0] control_o_reg;

// always @(*) begin
//     case ({ALUOp, func7, func3})
//         6'b00_0_000: begin 
//             control_o_reg = 4'b0010;
//         end
//         6'b01_0_000: begin // BEQ
//             control_o_reg = 4'b0110;
//         end
//         6'b10_0_000: begin // ADD
//             control_o_reg = 4'b0010;
//         end
//         6'b10_1_000: begin // SUB
//             control_o_reg = 4'b0110;
//         end
//         6'b10_0_111: begin // AND
//             control_o_reg = 4'b0000;
//         end
//         6'b10_0_110: begin // OR
//             control_o_reg = 4'b0001;
//         end
//         6'b00_0_010: begin // lw
//             control_o_reg = 4'b0010;
//         end
//         default: begin
//             control_o_reg = 4'bxxxx;
//         end
//     endcase
// end

always_comb begin
    case (ALUOp)
        // ALUOp for ADDI, LW, SW 
        2'b00: control_o_reg = 4'b0010; // ADD

        // ALUOp for BEQ 
        2'b01: control_o_reg = 4'b0110; // SUB

        // ALUOp for R-type
        2'b10: begin
            case ({func7, func3})
                4'b0_000: control_o_reg = 4'b0010; // ADD
                4'b1_000: control_o_reg = 4'b0110; // SUB
                4'b0_111: control_o_reg = 4'b0000; // AND
                4'b0_110: control_o_reg = 4'b0001; // OR
                default:  control_o_reg = 4'bxxxx;
            endcase
        end
        default: control_o_reg = 4'bxxxx;
    endcase
end

assign control_o = control_o_reg;

endmodule