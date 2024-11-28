module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       reg_write,
    output logic       mem_read,
    output logic       mem_write,
    output logic       branch,
    output logic       jump,
    output logic [1:0] alu_src,
    output logic [3:0] alu_op
);

    // Opcode definitions
    localparam LOAD      = 7'b0000011;
    localparam STORE     = 7'b0100011;
    localparam BRANCH    = 7'b1100011;
    localparam JALR      = 7'b1100111;
    localparam JAL       = 7'b1101111;
    localparam OP_IMM    = 7'b0010011;
    localparam OP        = 7'b0110011;
    localparam AUIPC     = 7'b0010111;
    localparam LUI       = 7'b0110111;

    always_comb begin
        // Default control signals
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        alu_src   = 2'b00;
        alu_op    = 4'b0000;

        case (opcode)
            LOAD: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_src   = 2'b01;  // Use immediate
            end

            STORE: begin
                mem_write = 1'b1;
                alu_src   = 2'b01;  // Use immediate
            end

            BRANCH: begin
                branch = 1'b1;
                alu_src = 2'b00;    // Use register
                case (funct3)
                    3'b000:  alu_op = 4'b0001;  // BEQ
                    3'b001:  alu_op = 4'b0001;  // BNE
                    3'b100:  alu_op = 4'b1000;  // BLT
                    3'b101:  alu_op = 4'b1000;  // BGE
                    3'b110:  alu_op = 4'b1001;  // BLTU
                    3'b111:  alu_op = 4'b1001;  // BGEU
                    default: alu_op = 4'b0000;
                endcase
            end

            OP_IMM: begin
                reg_write = 1'b1;
                alu_src   = 2'b01;  // Use immediate
                case (funct3)
                    3'b000:  alu_op = 4'b0000;  // ADDI
                    3'b010:  alu_op = 4'b1000;  // SLTI
                    3'b011:  alu_op = 4'b1001;  // SLTIU
                    3'b100:  alu_op = 4'b0100;  // XORI
                    3'b110:  alu_op = 4'b0011;  // ORI
                    3'b111:  alu_op = 4'b0010;  // ANDI
                    3'b001:  alu_op = 4'b0101;  // SLLI
                    3'b101:  alu_op = (funct7[5]) ? 4'b0111 : 4'b0110;  // SRAI/SRLI
                    default: alu_op = 4'b0000;
                endcase
            end

            OP: begin
                reg_write = 1'b1;
                alu_src   = 2'b00;  // Use register
                case (funct3)
                    3'b000:  alu_op = (funct7[5]) ? 4'b0001 : 4'b0000;  // SUB/ADD
                    3'b010:  alu_op = 4'b1000;  // SLT
                    3'b011:  alu_op = 4'b1001;  // SLTU
                    3'b100:  alu_op = 4'b0100;  // XOR
                    3'b110:  alu_op = 4'b0011;  // OR
                    3'b111:  alu_op = 4'b0010;  // AND
                    3'b001:  alu_op = 4'b0101;  // SLL
                    3'b101:  alu_op = (funct7[5]) ? 4'b0111 : 4'b0110;  // SRA/SRL
                    default: alu_op = 4'b0000;
                endcase
            end

            JAL, JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                alu_src   = 2'b10;  // Use PC
            end

            AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 2'b11;  // Use PC and immediate
            end

            LUI: begin
                reg_write = 1'b1;
                alu_src   = 2'b01;  // Use immediate
            end

            default: begin
                reg_write = 1'b0;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                branch    = 1'b0;
                jump      = 1'b0;
                alu_src   = 2'b00;
                alu_op    = 4'b0000;
            end
        endcase
    end

endmodule
