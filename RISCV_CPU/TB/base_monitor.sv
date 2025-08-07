class base_monitor #(type T= uvm_sequence_item) extends uvm_monitor;
    `uvm_component_utils(base_monitor)
    uvm_analysis_port #(T) item_collected_port;

    function new (string name = "base_monitor", uvm_component parent);
        super.new(name,parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
endclass

class im_monitor extends base_monitor #(im_item);
    `uvm_component_utils(im_monitor)

    virtual im_interface    im_vif;
    virtual cpu_interface   cpu_vif;

    function new (string name = "im_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual im_interface)::get(this,"","im_vif",im_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for im_vif")
        end
        if (!uvm_config_db#(virtual cpu_interface)::get(this,"","cpu_vif",cpu_vif)) begin
             `uvm_fatal("NOVIF", "Cannot get virtual interface handle for im_vif")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        im_item item;
        @(posedge cpu_vif.rst_n);
        @(posedge im_vif.tb_cb);
        forever begin
            @(im_vif.tb_cb);
            item = im_item::type_id::create("item");
            item.rs1 = im_vif.tb_cb.rs1;
            item.rs2 = im_vif.tb_cb.rs2;
            item.rd = im_vif.tb_cb.rd;
            item.ALU_o = im_vif.tb_cb.ALU_o;
            item.PC_o = im_vif.tb_cb.PC_o;
            item.next_PC_o = im_vif.tb_cb.next_PC_o;
            item.mem_data_o = im_vif.tb_cb.mem_data_o;
            item.instruction = im_vif.ins;
            `uvm_info(get_type_name(), $sformatf("Monitor get: \n%s", item.sprint()), UVM_HIGH)
            item_collected_port.write(item);
        end
    endtask
endclass