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
        `uvm_info(get_type_name(), "Push item to scb", UVM_HIGH)
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
        logic signed [31:0] signed_imm;
        logic signed [31:0] expected_result;
        logic [2:0] funct3;
        opcode = cur_packet.instruction[6:0];
        case(opcode)
            // R-type
            7'b0110011: begin
                logic       funct7_5;
                `uvm_info(get_type_name(), "Decoding R-type instruction", UVM_HIGH)
                e_rd = cur_packet.instruction[11:7];
                e_rs1 = cur_packet.instruction[19:15];
                e_rs2 = cur_packet.instruction[24:20];
                funct3   = cur_packet.instruction[14:12];
                funct7_5 = cur_packet.instruction[30];

                case ({funct7_5, funct3})
                    4'b0_000: expected_result = mem[e_rs1] + mem[e_rs2]; // ADD
                    4'b1_000: expected_result = mem[e_rs1] - mem[e_rs2]; // SUB
                    4'b0_111: expected_result = mem[e_rs1] & mem[e_rs2]; // AND
                    4'b0_110: expected_result = mem[e_rs1] | mem[e_rs2]; // OR
                    4'b0_100: expected_result = mem[e_rs1] ^ mem[e_rs2]; // XOR
                    default: begin
                        `uvm_error("FAIL", $sformatf("Unsupported R-type funct7/funct3: %b_%b", funct7_5, funct3))
                        is_match = 0;
                    end
                endcase

                if (e_rd != cur_packet.rd || 
                    e_rs1 != cur_packet.rs1 ||
                    e_rs2 != cur_packet.rs2 ||
                    expected_result != cur_packet.ALU_o) begin
                    is_match = 0;
                end
                if (is_match) mem[e_rd] = expected_result; 
            end
            // I-type
            7'b0010011: begin
                `uvm_info(get_type_name(), "Decoding I-type instruction", UVM_HIGH)
                e_rd  = cur_packet.instruction[11:7];
                e_rs1 = cur_packet.instruction[19:15];
                e_imm = cur_packet.instruction[31:20];
                funct3 = cur_packet.instruction[14:12];

                signed_imm = {{20{e_imm[11]}}, e_imm};

                case(funct3)
                    3'b000: expected_result = mem[e_rs1] + signed_imm; // ADDI
                    3'b111: expected_result = mem[e_rs1] & signed_imm; // ANDI
                    3'b110: expected_result = mem[e_rs1] | signed_imm; // ORI
                    3'b100: expected_result = mem[e_rs1] ^ signed_imm; // XORI
                    default: begin
                        `uvm_error("FAIL", $sformatf("Unsupported I-type funct3: %b", funct3))
                        is_match = 0;
                    end
                endcase
                if (e_rd != cur_packet.rd || e_rs1 != cur_packet.rs1 || expected_result != cur_packet.ALU_o) begin
                    is_match = 0;
                end
                if (is_match) mem[e_rd] = expected_result;
            end
            7'b1100011: begin
                logic signed [12:0] e_b_imm;
                logic signed [31:0] signed_b_imm;
                logic [31:0] e_next_PC;
                bit branch_taken;

                `uvm_info(get_type_name(), "Decoding B-type instruction", UVM_HIGH)

                e_rs1 = cur_packet.instruction[19:15];
                e_rs2 = cur_packet.instruction[24:20];

                e_b_imm[12]   = cur_packet.instruction[31];
                e_b_imm[11]   = cur_packet.instruction[7];
                e_b_imm[10:5] = cur_packet.instruction[30:25];
                e_b_imm[4:1]  = cur_packet.instruction[11:8];
                e_b_imm[0]    = 1'b0;

                signed_b_imm = {{19{e_b_imm[12]}}, e_b_imm};
                funct3 = cur_packet.instruction[14:12];
                case (funct3)
                    3'b000: // BEQ
                        branch_taken = (mem[e_rs1] == mem[e_rs2]);
                    3'b001: // BNE
                        branch_taken = (mem[e_rs1] != mem[e_rs2]);
                    default: begin
                        `uvm_error("FAIL", $sformatf("Unsupported B-type funct3: %b", funct3))
                        is_match = 0;
                    end
                endcase

                if (is_match) begin
                    if (branch_taken) begin
                        e_next_PC = cur_packet.PC_o + signed_b_imm;
                    end else begin
                        e_next_PC = cur_packet.PC_o + 4;
                    end

                    if (e_rs1 != cur_packet.rs1 || 
                        e_rs2 != cur_packet.rs2 || 
                        e_next_PC != cur_packet.next_PC_o) begin
                        is_match = 0;
                    end
                end
            end
            7'b1101111: begin
                logic signed [20:0] e_j_imm;
                logic signed [31:0] signed_j_imm;
                logic [31:0] e_next_PC;
                logic [31:0] e_link_addr; // PC+4

                `uvm_info(get_type_name(), "Decoding J-type instruction", UVM_HIGH)
                
                // 1. Giải mã các trường từ item DỰ KIẾN
                e_rd = cur_packet.instruction[11:7];
                
                // Tái cấu trúc giá trị tức thời 21-bit có dấu từ mã lệnh
                e_j_imm[20]    = cur_packet.instruction[31];
                e_j_imm[19:12] = cur_packet.instruction[19:12];
                e_j_imm[11]    = cur_packet.instruction[20];
                e_j_imm[10:1]  = cur_packet.instruction[30:21];
                e_j_imm[0]     = 1'b0;

                signed_j_imm = {{11{e_j_imm[20]}}, e_j_imm};

                e_next_PC = cur_packet.PC_o + signed_j_imm;
                e_link_addr = cur_packet.PC_o + 4;
                if (e_rd != cur_packet.rd || 
                    e_next_PC != cur_packet.next_PC_o ||
                    e_link_addr != cur_packet.mem_data_o) begin // So sánh giá trị ghi lại
                    is_match = 0;
                    // `uvm_info(get_type_name(), $sformatf("JAL Mismatch Details:\n"
                    //     , "\t- RD Addr:   exp=%0d, act=%0d\n", e_rd, cur_packet.rd
                    //     , "\t- Next PC:   exp=0x%h, act=0x%h\n", e_next_PC, cur_packet.next_PC_o
                    //     , "\t- Link Addr: exp=0x%h, act=0x%h", e_link_addr, cur_packet.mem_data_o), UVM_LOW)
                end
                
                // 4. Cập nhật mô hình bộ nhớ nếu so sánh đúng
                if (is_match) begin
                    mem[e_rd] = e_link_addr;
                end
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