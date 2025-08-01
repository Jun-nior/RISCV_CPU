class base_env extends uvm_env;
    `uvm_component_utils(base_env)

    base_agent agt;
    im_agent im_agt;
    base_scoreboard scb;

    function new (string name = "base_env", uvm_component parent);
        super.new(name,parent);
    endfunction    

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        // agt = base_agent::type_id::create("agt",this);
        im_agt = im_agent::type_id::create("im_agt",this);
        scb = base_scoreboard::type_id::create("scb", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
    endfunction
endclass