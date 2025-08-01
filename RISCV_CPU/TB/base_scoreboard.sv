class base_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(base_scoreboard)

    function new (string name = "base_scoreboard", uvm_component parent);
        super.new(name,parent);
    endfunction    

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask
endclass