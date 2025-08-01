class base_driver #(type REQ = uvm_sequence_item, RSP = REQ) extends uvm_driver#(REQ, RSP);
    `uvm_component_utils(base_driver)

    function new (string name = "base_driver", uvm_component parent);
        super.new(name,parent);
    endfunction

endclass

class im_driver extends base_driver#(im_item);
    `uvm_component_utils(im_driver)
    virtual im_interface im_vif;

    function new (string name = "im_driver", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual im_interface)::get(this, "", "im_vif", im_vif)) begin
            `uvm_fatal("NOVIF", "Cannot get virtual interface handle for im_vif")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(), "Driver get add instruction", UVM_LOW)
            @(im_vif.tb_cb);
            seq_item_port.item_done();
        end
    endtask
endclass