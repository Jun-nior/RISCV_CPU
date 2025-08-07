interface cpu_interface(input logic clk);
    logic rst_n;

    clocking tb_cb @(posedge clk);
        output rst_n;
    endclocking
endinterface

interface im_interface(input logic clk);
    logic   [31:0]  PC_o; // CPU -> TB
    logic   [31:0]  next_PC_o; // CPU -> TB
    logic   [31:0]  ins;  // TB -> CPU
    logic   [4:0]   rs1;
    logic   [4:0]   rs2;
    logic   [4:0]   rd;
    logic   [31:0]  ALU_o;
    logic   [31:0]  mem_data_o;

    clocking tb_cb @(posedge clk);
        input PC_o, next_PC_o, rs1, rs2, rd, ALU_o, mem_data_o;
        output ins;
    endclocking

    modport DUT (
        output PC_o, next_PC_o, rs1, rs2, rd, ALU_o, mem_data_o,
        input ins
    );
endinterface