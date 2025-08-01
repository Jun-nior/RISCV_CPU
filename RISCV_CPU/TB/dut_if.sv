interface cpu_interface(input logic clk);
    logic rst_n;
endinterface

interface im_interface(input logic clk, rst_n);
    logic   [31:0]  PC_o; // CPU -> TB
    logic   [31:0]  ins;  // TB -> CPU

    clocking tb_cb @(posedge clk);
        input PC_o;
        output ins;
    endclocking

    modport DUT (
        output PC_o,
        input ins
    );
endinterface