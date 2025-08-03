class base_item extends uvm_sequence_item;
    `uvm_object_utils(base_item)

    function new (string name = "base_item");
        super.new(name);
    endfunction
endclass

class im_item extends base_item;
    typedef enum {ADD, ADDI} inst_type_e;

    rand inst_type_e    inst_type;
    rand logic [4:0]    rs1;
    rand logic [4:0]    rs2;
    rand logic [4:0]    rd;
    rand logic [11:0]   imm; // random value for addi

    rand logic [31:0]   instruction;
    logic [31:0]        PC_o;

    constraint c_build_instruction {
        solve inst_type before instruction;
        (inst_type == ADD) -> {
            instruction == {7'b0000000, rs2, rs1, 3'b000, rd, 7'b0110011};
            imm == 0;
        }
        (inst_type == ADDI) -> {
            instruction == {imm, rs1, 3'b000, rd, 7'b0010011};
            rs2 == 0;
        }
    }

    `uvm_object_utils_begin(im_item)
        `uvm_field_enum(inst_type_e, inst_type, UVM_ALL_ON)
        `uvm_field_int(rs1, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(rs2, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(rd, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(imm, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(instruction, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(PC_o, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    function new (string name = "im_item");
        super.new(name);
    endfunction
endclass

class reset_item extends base_item;
    rand logic rst_n;
    `uvm_object_utils_begin(reset_item)
        `uvm_field_int(rst_n, UVM_ALL_ON)
    `uvm_object_utils_end
    function new (string name = "reset_item");
        super.new(name);
    endfunction
endclass