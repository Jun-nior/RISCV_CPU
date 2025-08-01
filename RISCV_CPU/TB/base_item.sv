class base_item extends uvm_sequence_item;
    `uvm_object_utils(base_item)

    function new (string name = "base_item");
        super.new(name);
    endfunction
endclass

class im_item extends base_item;

    rand logic  [31:0]  instruction;
    logic       [31:0]  PC_o; // CPU returns here

    `uvm_object_utils_begin(im_item)
        `uvm_field_int(instruction, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(PC_o, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    function new (string name = "base_item");
        super.new(name);
    endfunction
endclass