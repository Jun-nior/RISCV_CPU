`include "uvm_macros.svh"
import uvm_pkg::*;
import cpu_pkg::*;
`include "dut_if.sv"
module CPU_Top_tb_top;
    logic clk, rst_n;

    im_interface im_if (
        .clk(clk)
    ); // Instruction memory interface

    cpu_interface cpu_if (
        .clk(clk)
    );

    CPU_Top dut (
        .clk(clk),
        .rst_n(cpu_if.rst_n),
        .im_wdata_i(im_if.ins),
        .im_PC_o(im_if.PC_o),
        .im_next_PC_o(im_if.next_PC_o),
        .rs1_o(im_if.rs1),
        .rs2_o(im_if.rs2),
        .rd_o(im_if.rd),
        .ALU_o(im_if.ALU_o)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    // initial begin
    //     rst_n = 0;
    //     repeat(2) begin
    //         @(posedge clk);
    //     end
    //     rst_n = 1;

    //     // $finish;
    // end

    initial begin
        uvm_config_db#(virtual im_interface)::set(null,"*","im_vif",im_if);
        uvm_config_db#(virtual cpu_interface)::set(null,"*","cpu_vif",cpu_if);
        run_test("base_test");
    end

endmodule