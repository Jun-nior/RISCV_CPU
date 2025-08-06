class base_sequence #(type REQ = uvm_sequence_item, RSP = REQ) extends uvm_sequence#(REQ, RSP);
    `uvm_object_utils(base_sequence)

    function new (string name = "base_sequence");
        super.new(name);
    endfunction

endclass

class im_add_sequence extends base_sequence#(im_item);
    `uvm_object_utils(im_add_sequence)

    function new (string name = "im_add_sequence");
        super.new(name);
    endfunction

    virtual task body();
        // `uvm_do_with(req, {
        //     inst_type == ADD;
        //     rs1 == 3;
        //     rs2 == 5;
        //     rd  == 10;
        // })
        // `uvm_do_with(req, {
        //     inst_type == ADDI;
        //     rs1 == 12;
        //     imm == 10;
        //     rs2 == 0;
        //     rd  == 11;
        // })
        repeat(1000) begin
            `uvm_do(req)
        end
        `uvm_info(get_type_name(), "Finish creating add instruction", UVM_LOW)
    endtask
endclass

class reset_sequence extends base_sequence#(reset_item);
    `uvm_object_utils(reset_sequence)

    function new (string name = "reset_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_do_with(req, {
            rst_n == 0;
        })
        `uvm_do_with(req, {
            rst_n == 1;
        })
        `uvm_info(get_type_name(), "Finish reset", UVM_LOW)
    endtask
endclass