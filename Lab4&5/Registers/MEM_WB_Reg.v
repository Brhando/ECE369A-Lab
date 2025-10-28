// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// EX/MEM register for partitioning.
// Carries WB control and values into the final writeback mux

module MEM_WB_Reg(
    input         Clk,
    input         Reset,

    // WB control
    input         RegWrite_in,
    input  [1:0]  MemToReg_in,

    // Data from MEM
    input  [31:0] ReadData_in,   // DataMemory output
    input  [31:0] ALUResult_in,
    input  [31:0] PCPlus4_in,    // for jal
    input  [4:0]  DestReg_in,

    // Outputs
    output reg        RegWrite_out,
    output reg [1:0]  MemToReg_out,
    output reg [31:0] ReadData_out,
    output reg [31:0] ALUResult_out,
    output reg [31:0] PCPlus4_out,
    output reg [4:0]  DestReg_out
);
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            RegWrite_out  <= 1'b0;
            MemToReg_out  <= 2'b00;
            ReadData_out  <= 32'b0;
            ALUResult_out <= 32'b0;
            PCPlus4_out   <= 32'b0;
            DestReg_out   <= 5'b0;
        end else begin
            RegWrite_out  <= RegWrite_in;
            MemToReg_out  <= MemToReg_in;
            ReadData_out  <= ReadData_in;
            ALUResult_out <= ALUResult_in;
            PCPlus4_out   <= PCPlus4_in;
            DestReg_out   <= DestReg_in;
        end
    end
endmodule

