module riscv_core (
    input  logic        clk,
    input  logic        rst_n,
    // Instruction memory interface
    output logic [31:0] instr_addr,
    input  logic [31:0] instruction,
    // Data memory interface
    output logic [31:0] data_addr,
    output logic [31:0] data_wdata,
    input  logic [31:0] data_rdata,
    output logic        data_we,
    output logic        data_re
);

    // Internal signals
    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] pc_plus4;
    logic [31:0] alu_result;
    logic [31:0] reg_rdata1;
    logic [31:0] reg_rdata2;
    logic [31:0] imm_value;
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic        zero_flag;
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        branch;
    logic        jump;
    logic [1:0]  alu_src;
    logic [3:0]  alu_op;
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [4:0]  rd;
    logic [4:0]  rs1;
    logic [4:0]  rs2;

    // PC logic
    assign pc_plus4 = pc + 32'd4;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;
        end else begin
            pc <= next_pc;
        end
    end

    // Next PC calculation
    always_comb begin
        if (jump) begin
            next_pc = alu_result;
        end else if (branch && zero_flag) begin
            next_pc = pc + imm_value;
        end else begin
            next_pc = pc_plus4;
        end
    end

    // Instruction memory interface
    assign instr_addr = pc;

    // Instantiate instruction decoder
    instruction_decoder i_decoder (
        .instruction (instruction),
        .opcode      (opcode),
        .funct3      (funct3),
        .funct7      (funct7),
        .rd          (rd),
        .rs1         (rs1),
        .rs2         (rs2),
        .imm         (imm_value)
    );

    // Instantiate control unit
    control_unit i_control (
        .opcode    (opcode),
        .funct3    (funct3),
        .funct7    (funct7),
        .reg_write (reg_write),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .branch    (branch),
        .jump      (jump),
        .alu_src   (alu_src),
        .alu_op    (alu_op)
    );

    // Instantiate register file
    register_file i_regfile (
        .clk      (clk),
        .rst_n    (rst_n),
        .rs1_addr (rs1),
        .rs2_addr (rs2),
        .rs1_data (reg_rdata1),
        .rs2_data (reg_rdata2),
        .wr_en    (reg_write),
        .rd_addr  (rd),
        .rd_data  (mem_read ? data_rdata : alu_result)
    );

    // ALU operand selection
    always_comb begin
        case (alu_src)
            2'b00:   alu_operand_a = reg_rdata1;        // Register
            2'b01:   alu_operand_a = reg_rdata1;        // Immediate
            2'b10:   alu_operand_a = pc;                // PC (for JAL/JALR)
            2'b11:   alu_operand_a = pc;                // PC (for AUIPC)
            default: alu_operand_a = reg_rdata1;
        endcase

        case (alu_src)
            2'b00:   alu_operand_b = reg_rdata2;        // Register
            2'b01:   alu_operand_b = imm_value;         // Immediate
            2'b10:   alu_operand_b = 32'd4;             // PC + 4 (for JAL/JALR)
            2'b11:   alu_operand_b = imm_value;         // Immediate (for AUIPC)
            default: alu_operand_b = reg_rdata2;
        endcase
    end

    // Instantiate ALU
    alu i_alu (
        .operand_a (alu_operand_a),
        .operand_b (alu_operand_b),
        .alu_op    (alu_op),
        .result    (alu_result),
        .zero_flag (zero_flag)
    );

    // Data memory interface
    assign data_addr  = alu_result;
    assign data_wdata = reg_rdata2;
    assign data_we    = mem_write;
    assign data_re    = mem_read;

endmodule
