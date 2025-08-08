class base_coverage extends uvm_subscriber #(im_item);
    `uvm_component_utils(base_coverage)

    im_item trans;

    covergroup instr_mix_type;
        cp_inst_type: coverpoint trans.inst_type;
    endgroup

    covergroup reg_usage_cg;
        cp_rs1: coverpoint trans.rs1;
        cp_rs2: coverpoint trans.rs2;
        cp_rd:  coverpoint trans.rd;
        cross_reg: cross cp_rs1, cp_rs2, cp_rd;
    endgroup

    function new(string name = "base_coverage", uvm_component parent = null);
        super.new(name, parent);
        instr_mix_type = new();
        reg_usage_cg = new();
    endfunction

    function void write(im_item t);
        this.trans = t;
        instr_mix_type.sample();
        reg_usage_cg.sample();
    endfunction
endclass