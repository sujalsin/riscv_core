module register_file (
    input  logic        clk,
    input  logic        rst_n,
    // Read ports
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    // Write port
    input  logic        wr_en,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_data
);

    // Register file with 32 registers
    logic [31:0] registers [32];

    // Asynchronous read
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : registers[rs2_addr];

    // Synchronous write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end else if (wr_en && rd_addr != 5'b0) begin
            // Write data to register (x0 is hardwired to 0)
            registers[rd_addr] <= rd_data;
        end
    end

endmodule
