module data_memory (
    input  logic        clk,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic        we,
    input  logic        re,
    output logic [31:0] rdata
);

    // Data memory storage
    logic [31:0] mem [1024];  // 4KB data memory

    // Initialize memory
    initial begin
        for (int i = 0; i < 1024; i++) begin
            mem[i] = 32'h0;
        end
    end

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr[11:2]] <= wdata;
        end
    end

    // Asynchronous read
    assign rdata = re ? mem[addr[11:2]] : 32'h0;

endmodule
