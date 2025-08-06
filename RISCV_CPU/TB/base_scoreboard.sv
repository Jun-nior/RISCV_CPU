class base_scoreboard #(type T = uvm_sequence_item) extends uvm_scoreboard;
    `uvm_component_utils(base_scoreboard)

    uvm_analysis_imp #(T, base_scoreboard #(T)) item_collected_export;
    T packet[$];

    function new (string name = "base_scoreboard", uvm_component parent);
        super.new(name,parent);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    function void write(T item);
        packet.push_back(item);
        `uvm_info(get_type_name(), "Push item to scb", UVM_LOW)
    endfunction
endclass

class im_scoreboard extends base_scoreboard #(im_item);
    `uvm_component_utils(im_scoreboard)

    im_item cur_packet;
    int mem[32];

    function new (string name = "im_scoreboard", uvm_component parent);
        super.new(name,parent);
        for (int i = 0;i < 32; i++) begin
            mem[i] = i;
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            wait(packet.size()!=0);
            cur_packet = packet.pop_front();
            compare(cur_packet);
        end
    endtask

    task compare(im_item cur_packet);
        bit is_match = 1;
        logic [6:0] opcode;
        logic [4:0] e_rs1, e_rs2, e_rd;
        logic signed [11:0] e_imm;

        opcode = cur_packet.instruction[6:0];
        case(opcode)
            // R-type
            7'b0110011: begin
                `uvm_info(get_type_name(), "Decoding R-type instruction", UVM_LOW)
                e_rd = cur_packet.instruction[11:7];
                e_rs1 = cur_packet.instruction[19:15];
                e_rs2 = cur_packet.instruction[24:20];

                if (e_rd != cur_packet.rd || 
                    e_rs1 != cur_packet.rs1 ||
                    e_rs2 != cur_packet.rs2 ||
                    mem[e_rs1] + mem[e_rs2] != cur_packet.ALU_o) begin
                    is_match = 0;
                end
                mem[e_rd] = mem[e_rs1] + mem[e_rs2];
            end
            // I-type
            7'b0010011: begin
                `uvm_info(get_type_name(), "Decoding I-type instruction", UVM_LOW)
                e_rd  = cur_packet.instruction[11:7];
                e_rs1 = cur_packet.instruction[19:15];
                e_imm = cur_packet.instruction[31:20];
                if (e_rd != cur_packet.rd || 
                    e_rs1 != cur_packet.rs1 ||
                    mem[e_rs1] + e_imm != cur_packet.ALU_o) begin
                    is_match = 0;
                end
                mem[e_rd] = mem[e_rs1] + e_imm;
            end
            default: begin
                `uvm_error("FAIL", $sformatf("Unknown opcode 0x%h, skipping comparison", opcode))
                is_match = 0;
            end
        endcase
        if (is_match) begin
            `uvm_info("PASS", "SCOREBOARD PASS: Item matched", UVM_LOW)
        end else begin
            `uvm_error("FAIL", "SCOREBOARD FAIL: Item mismatch")
            `uvm_info(get_type_name(), $sformatf("Mismatch details:\nDecoded Expected: opcode=0x%h, rd=%d, rs1=%d, rs2=%d, imm=%d\nActual Packet:\n%s",
                                                 opcode, e_rd, e_rs1, e_rs2, e_imm, cur_packet.sprint()), UVM_LOW)
        end
    endtask
endclass