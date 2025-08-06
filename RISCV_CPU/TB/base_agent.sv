class base_agent #(
    type REQ = uvm_sequence_item,
    type RSP = REQ
) extends uvm_agent;

    typedef uvm_sequencer#(REQ, RSP) sequencer_t;
    typedef base_monitor#(REQ)       monitor_t;
    typedef base_driver#(REQ, RSP)   driver_t;

    driver_t    drv;
    sequencer_t sqr;
    monitor_t   mon;
    
    function new (string name = "base_agent", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction
endclass

class im_agent extends base_agent #(im_item);
    `uvm_component_utils(im_agent)

    function new (string name = "im_agent", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        mon = im_monitor::type_id::create("mon", this);
        if (is_active == UVM_ACTIVE) begin
            drv = im_driver::type_id::create("drv", this);
            sqr = uvm_sequencer#(im_item)::type_id::create("sqr", this);
        end
    endfunction
endclass

class reset_agent extends base_agent #(reset_item);
    `uvm_component_utils(reset_agent)

    function new (string name = "reset_agent", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        drv = reset_driver::type_id::create("drv", this);
        sqr = uvm_sequencer#(reset_item)::type_id::create("sqr", this);
    endfunction
endclass