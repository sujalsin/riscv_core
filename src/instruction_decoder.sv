module instruction_decoder (
    input  logic [31:0] instruction,
    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic [4:0]  rd,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [31:0] imm
);

    // RISC-V instruction fields
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Immediate value generation
    always_comb begin
        case (opcode)
            // I-type instructions
            7'b0000011,  // Load
            7'b0010011: begin  // ALU immediate
                imm = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type instructions
            7'b0100011: begin  // Store
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-type instructions
            7'b1100011: begin  // Branch
                imm = {{20{instruction[31]}}, instruction[7], instruction[30:25],
                      instruction[11:8], 1'b0};
            end

            // U-type instructions
            7'b0110111,  // LUI
            7'b0010111: begin  // AUIPC
                imm = {instruction[31:12], 12'b0};
            end

            // J-type instructions
            7'b1101111: begin  // JAL
                imm = {{12{instruction[31]}}, instruction[19:12],
                      instruction[20], instruction[30:21], 1'b0};
            end

            default: begin
                imm = 32'b0;
            end
        endcase
    end

endmodule
