module Program_Counter#(
    parameter ADDR_WIDTH = 32  
) (
    input                           clk,
    input                           rst_n,
    input   [ADDR_WIDTH - 1 : 0]    PC_in,
    output  [ADDR_WIDTH - 1 : 0]    PC_out
)

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        PC_out <= 'b0;
    end else begin
        PC_out <= PC_in;
    end
end 

endmodule