module riscv_core_tb;
    // Testbench signals
    logic        clk;
    logic        rst_n;
    logic [31:0] instr_addr;
    logic [31:0] instruction;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic [31:0] data_rdata;
    logic        data_we;
    logic        data_re;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #10 rst_n = 1;
    end

    // Instantiate RISC-V core
    riscv_core i_core (
        .clk         (clk),
        .rst_n       (rst_n),
        .instr_addr  (instr_addr),
        .instruction (instruction),
        .data_addr   (data_addr),
        .data_wdata  (data_wdata),
        .data_rdata  (data_rdata),
        .data_we     (data_we),
        .data_re     (data_re)
    );

    // Instantiate instruction memory
    instruction_memory i_imem (
        .addr (instr_addr),
        .data (instruction)
    );

    // Instantiate data memory
    data_memory i_dmem (
        .clk   (clk),
        .addr  (data_addr),
        .wdata (data_wdata),
        .we    (data_we),
        .re    (data_re),
        .rdata (data_rdata)
    );

    // Monitor process
    initial begin
        $timeformat(-9, 2, " ns");
        
        // Wait for reset
        @(posedge rst_n);
        
        // Monitor register file changes
        forever @(posedge clk) begin
            if (i_core.i_regfile.wr_en && i_core.i_regfile.rd_addr != 0) begin
                $display("Time: %t - Register x%0d = 0x%8h", 
                    $time,
                    i_core.i_regfile.rd_addr,
                    i_core.i_regfile.rd_data
                );
            end
        end
    end

    // Monitor memory writes
    initial begin
        forever @(posedge clk) begin
            if (data_we) begin
                $display("Time: %t - Memory[0x%8h] = 0x%8h",
                    $time,
                    data_addr,
                    data_wdata
                );
            end
        end
    end

    // Test completion
    initial begin
        // Wait for reset
        @(posedge rst_n);
        
        // Run for 100 cycles
        repeat(100) @(posedge clk);
        
        // Print final register values
        $display("\nFinal Register Values:");
        for (int i = 1; i < 32; i++) begin
            $display("x%0d = 0x%8h", i, i_core.i_regfile.registers[i]);
        end
        
        // Print first 10 memory locations
        $display("\nFirst 10 Memory Locations:");
        for (int i = 0; i < 10; i++) begin
            $display("Memory[%0d] = 0x%8h", i, i_dmem.mem[i]);
        end
        
        $display("\nSimulation completed!");
        $finish;
    end

    // Generate VCD file
    initial begin
        $dumpfile("riscv_core_tb.vcd");
        $dumpvars(0, riscv_core_tb);
    end

endmodule
