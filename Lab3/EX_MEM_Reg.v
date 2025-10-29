// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// EX/MEM register for partitioning.
// Carries MEM+WB control and EX results to MEM

module EX_MEM_Reg(
    input         Clk,
    input         Reset,
    input         Flush, 

    // WB control
    input         RegWrite_in,
    input  [1:0]  MemToReg_in,

    // MEM control (includes branch/jump info if you evaluate in MEM)
    input         MemRead_in,
    input         MemWrite_in,
    input  [1:0]  MemSize_in,
    input         MemSign_in,
    input         Branch_in,
    input  [2:0]  BranchType_in,
    input         Jump_in,
    input         JumpReg_in,

    // Data from EX
    input  [31:0] ALUResult_in,
    input         ConFlag_in,       // from your ALU (beq/bne true)
    input  [31:0] WriteData_in,     // rt value to store
    input  [4:0]  DestReg_in,       // after RegDst mux
    input  [31:0] BranchTarget_in,  // PC+4 + (imm<<2)
    input  [31:0] JumpTarget_in,    // {PC+4[31:28], idx26, 2'b00}
    input  [31:0] PCPlus4_in,       // for jal writeback

    // Outputs
    output reg        RegWrite_out,
    output reg [1:0]  MemToReg_out,
    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg [1:0]  MemSize_out,
    output reg        MemSign_out,
    output reg        Branch_out,
    output reg [2:0]  BranchType_out,
    output reg        Jump_out,
    output reg        JumpReg_out,
    output reg [31:0] ALUResult_out,
    output reg        ConFlag_out,
    output reg [31:0] WriteData_out,
    output reg [4:0]  DestReg_out,
    output reg [31:0] BranchTarget_out,
    output reg [31:0] JumpTarget_out,
    output reg [31:0] PCPlus4_out
);
    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            {RegWrite_out, MemToReg_out, MemRead_out, MemWrite_out, MemSize_out,
             MemSign_out, Branch_out, BranchType_out, Jump_out, JumpReg_out} <= 'b0;
            ALUResult_out   <= 32'b0;
            ConFlag_out     <= 1'b0;
            WriteData_out   <= 32'b0;
            DestReg_out     <= 5'b0;
            BranchTarget_out<= 32'b0;
            JumpTarget_out  <= 32'b0;
            PCPlus4_out     <= 32'b0;
        end else if (Flush) begin
            {RegWrite_out, MemToReg_out, MemRead_out, MemWrite_out, MemSize_out,
             MemSign_out, Branch_out, BranchType_out, Jump_out, JumpReg_out} <= 'b0;
            ALUResult_out   <= 32'b0;
            ConFlag_out     <= 1'b0;
            WriteData_out   <= 32'b0;
            DestReg_out     <= 5'b0;
            BranchTarget_out<= 32'b0;
            JumpTarget_out  <= 32'b0;
            PCPlus4_out     <= 32'b0;
        end else begin
            RegWrite_out    <= RegWrite_in;
            MemToReg_out    <= MemToReg_in;
            MemRead_out     <= MemRead_in;
            MemWrite_out    <= MemWrite_in;
            MemSize_out     <= MemSize_in;
            MemSign_out     <= MemSign_in;
            Branch_out      <= Branch_in;
            BranchType_out  <= BranchType_in;
            Jump_out        <= Jump_in;
            JumpReg_out     <= JumpReg_in;
            ALUResult_out   <= ALUResult_in;
            ConFlag_out     <= ConFlag_in;
            WriteData_out   <= WriteData_in;
            DestReg_out     <= DestReg_in;
            BranchTarget_out<= BranchTarget_in;
            JumpTarget_out  <= JumpTarget_in;
            PCPlus4_out     <= PCPlus4_in;
        end
    end
endmodule

