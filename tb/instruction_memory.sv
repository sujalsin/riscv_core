module instruction_memory (
    input  logic [31:0] addr,
    output logic [31:0] data
);

    // Instruction memory storage
    logic [31:0] mem [1024];  // 4KB instruction memory

    // Asynchronous read
    assign data = mem[addr[11:2]];  // Word-aligned access

    // Initialize with test program
    initial begin
        // Simple test program:
        // 1. Load immediate values into registers
        // 2. Perform arithmetic operations
        // 3. Store result to memory
        // 4. Branch and jump test

        // addi x1, x0, 10          # x1 = 10
        mem[0] = 32'h00A00093;
        
        // addi x2, x0, 20          # x2 = 20
        mem[1] = 32'h01400113;
        
        // add x3, x1, x2           # x3 = x1 + x2 = 30
        mem[2] = 32'h002081B3;
        
        // sub x4, x2, x1           # x4 = x2 - x1 = 10
        mem[3] = 32'h40208233;
        
        // and x5, x1, x2           # x5 = x1 & x2
        mem[4] = 32'h0020F2B3;
        
        // or x6, x1, x2            # x6 = x1 | x2
        mem[5] = 32'h0020E333;
        
        // xor x7, x1, x2           # x7 = x1 ^ x2
        mem[6] = 32'h0020C3B3;
        
        // slt x8, x1, x2           # x8 = (x1 < x2) ? 1 : 0
        mem[7] = 32'h0020A433;
        
        // sw x3, 0(x0)             # Store x3 to memory[0]
        mem[8] = 32'h00302023;
        
        // lw x9, 0(x0)             # Load memory[0] into x9
        mem[9] = 32'h00002483;
        
        // beq x1, x4, 2            # Branch if x1 equals x4
        mem[10] = 32'h00408163;
        
        // jal x10, 8               # Jump and link
        mem[11] = 32'h00800517;
        
        // Fill rest with NOPs (addi x0, x0, 0)
        for (int i = 12; i < 1024; i++) begin
            mem[i] = 32'h00000013;
        end
    end

endmodule
