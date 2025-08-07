module CPU_Top #(
    parameter ADDR_WIDTH = 32,
    parameter DAT_WIDTH = 32
) (
    input   clk,
    input   rst_n,

    //test-only purpose IM
    output  [ADDR_WIDTH - 1 : 0]    im_PC_o,
    output  [ADDR_WIDTH - 1 : 0]    im_next_PC_o,
    input   [ADDR_WIDTH - 1 : 0]    im_wdata_i,

    //monitor-capture-only purpose
    output  [4 : 0]                 rs1_o,
    output  [4 : 0]                 rs2_o,
    output  [4 : 0]                 rd_o,
    output  [ADDR_WIDTH - 1 : 0]    ALU_o,
    output  [ADDR_WIDTH - 1 : 0]    memory_data_o
);

logic   [ADDR_WIDTH - 1 : 0]    PC_top;
logic   [ADDR_WIDTH - 1 : 0]    im_top;
logic   [ADDR_WIDTH - 1 : 0]    ImmExt_top;
logic   [ADDR_WIDTH - 1 : 0]    adder1_o_top;
logic   [ADDR_WIDTH - 1 : 0]    adder2_o_top;
logic   [ADDR_WIDTH - 1 : 0]    ALU_o_top;
logic   [DAT_WIDTH - 1 : 0]     rdata1_top;
logic   [DAT_WIDTH - 1 : 0]     rdata2_top;
logic   [DAT_WIDTH - 1 : 0]     mux_o_ALU_top;
logic   [DAT_WIDTH - 1 : 0]     mux_o_PC_top;
logic   [DAT_WIDTH - 1 : 0]     rdata_mem_top;
logic   [DAT_WIDTH - 1 : 0]     mem_mux_data_o;
logic                           RegWrite_top;
logic                           ALUSrc_top;
logic                           zero_top;
logic                           and_o_top;
logic                           Branch_top;
logic                           MemRead_top;
logic                           MemWrite_top;
logic   [1:0]                   MemtoReg_top;
logic                           Jump_top;
logic   [1:0]                   ALUOp_top;
logic   [3:0]                   control_o_top;

Program_Counter PC (
    .clk(clk),
    .rst_n(rst_n),
    .PC_i(mux_o_PC_top),
    .PC_o(PC_top)
);

AdderPC Add1 (
    .PC_o(PC_top),
    .adder_o(adder1_o_top)
);

// Instruction_Memory IM (
//     .clk(clk),
//     .rst_n(rst_n),
//     .raddr(PC_top),
//     .im_o(im_top)
// );

assign im_PC_o = PC_top;
assign im_next_PC_o = mux_o_PC_top; // not PC_o since one cycle clock later the PC is updated (check the upcoming value for PC_o here instead)
assign im_top = im_wdata_i;

Register_File Registers (
    .clk(clk),
    .rst_n(rst_n),
    .rs1(im_top[19:15]),
    .rs2(im_top[24:20]),
    .rd(im_top[11:7]),
    .RegWrite(RegWrite_top),
    .wdata(mem_mux_data_o),
    .rdata1(rdata1_top),
    .rdata2(rdata2_top)
);

assign rs1_o    = im_top[19:15];
assign rs2_o    = im_top[24:20];
assign rd_o     = im_top[11:7];

Immediate_Generator ImmGen (
    .instruction(im_top),
    .opcode(im_top[6:0]),
    .ImmExt(ImmExt_top)
);

Control_Unit Control(
    .instruction(im_top[6:0]),
    .Branch(Branch_top),
    .MemRead(MemRead_top),
    .MemtoReg(MemtoReg_top[0]),
    .ALUOp(ALUOp_top),
    .MemWrite(MemWrite_top),
    .ALUSrc(ALUSrc_top),
    .RegWrite(RegWrite_top),
    .Jump(MemtoReg_top[1])
);

ALU_Control ALU_Control(
    .ALUOp(ALUOp_top),
    .func7(im_top[30]),
    .func3(im_top[14:12]),
    .control_o(control_o_top)
);

ALU ALU(
    .in1(rdata1_top),
    .in2(mux_o_ALU_top),
    .control_i(control_o_top),
    .ALU_o(ALU_o_top),
    .zero(zero_top)
);

assign ALU_o = ALU_o_top;
assign memory_data_o = mem_mux_data_o;

Mux ALU_mux (
    .sel(ALUSrc_top),
    .a(rdata2_top),
    .b(ImmExt_top),
    .mux_o(mux_o_ALU_top)
);

Adder Add2 (
    .in1(PC_top),
    .in2(ImmExt_top),
    .adder_o(adder2_o_top)
);

AND AND (
    .func3(im_top[14:12]),
    .jump(MemtoReg_top[1]),
    .branch(Branch_top),
    .zero(zero_top),
    .and_o(and_o_top)
);

Mux Adder_mux (
    .sel(and_o_top),
    .a(adder1_o_top),
    .b(adder2_o_top),
    .mux_o(mux_o_PC_top)
);

Data_Memory Data_Memory (
    .clk(clk),
    .rst_n(rst_n),
    .addr(ALU_o_top),
    .wdata(rdata2_top),
    .MemWrite(MemWrite_top),
    .MemRead(MemRead_top),
    .rdata(rdata_mem_top)
);

Mem_Mux Memory_mux (
    .sel(MemtoReg_top),
    .a(ALU_o_top),
    .b(rdata_mem_top),
    .c(adder1_o_top),
    .mux_o(mem_mux_data_o)
);

endmodule