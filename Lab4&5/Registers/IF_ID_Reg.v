// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// IF/ID register for partitioning.
// Holds the fetched instruction and PC

module IF_ID_Reg(
    input         Clk,
    input         Reset,
    input         Stall,     // hold outputs when 1
    input         Flush,     // turn into NOP when 1
    input  [31:0] PC_in,
    input  [31:0] Instr_in,
    output reg [31:0] PC_out,
    output reg [31:0] Instr_out
);
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            PC_out    <= 32'b0;
            Instr_out <= 32'b0; // NOP
        end else if (Flush) begin
            PC_out    <= 32'b0;
            Instr_out <= 32'b0; // NOP
        end else if (!Stall) begin
            PC_out    <= PC_in;
            Instr_out <= Instr_in;
        end
    end
endmodule
