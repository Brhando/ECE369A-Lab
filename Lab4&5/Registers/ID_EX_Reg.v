// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// ID/EX register for partitioning.
// Carries EX/MEM/WB control and ID data to EX

module ID_EX_Reg(
    input         Clk,
    input         Reset,
    input         Flush, // squash control (insert bubble) when 1

    // WB control
    input         RegWrite_in,
    input  [1:0]  MemToReg_in,

    // MEM control
    input         MemRead_in,
    input         MemWrite_in,
    input  [1:0]  MemSize_in,
    input         MemSign_in,
    input         Branch_in,
    input  [2:0]  BranchType_in,
    input         Jump_in,
    input         JumpReg_in,

    // EX control
    input  [1:0]  ALUSrc_in,
    input  [3:0]  ALUControl_in,
    input  [1:0]  RegDst_in,

    // Data
    input  [31:0] ReadData1_in, // rs
    input  [31:0] ReadData2_in, // rt
    input  [31:0] ImmExt_in,    // sign/zero-extended imm16
    input  [4:0]  rs_in, rt_in, rd_in,
    input  [4:0]  shamt_in,
    input  [31:0] PCPlus4_in,

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
    output reg [1:0]  ALUSrc_out,
    output reg [3:0]  ALUControl_out,
    output reg [1:0]  RegDst_out,
    output reg [31:0] ReadData1_out,
    output reg [31:0] ReadData2_out,
    output reg [31:0] ImmExt_out,
    output reg [4:0]  rs_out, rt_out, rd_out,
    output reg [4:0]  shamt_out,
    output reg [31:0] PCPlus4_out
);
    // "NOP" control = all zeros
    // asynchronous reset
    always @(posedge Clk or posedge Reset) begin 
        if (Reset) begin
            {RegWrite_out, MemToReg_out, MemRead_out, MemWrite_out, MemSize_out,
             MemSign_out, Branch_out, BranchType_out, Jump_out, JumpReg_out,
             ALUSrc_out, ALUControl_out, RegDst_out} <= 'b0;
            ReadData1_out <= 32'b0;
            ReadData2_out <= 32'b0;
            ImmExt_out    <= 32'b0;
            rs_out        <= 5'b0;
            rt_out        <= 5'b0;
            rd_out        <= 5'b0;
            shamt_out     <= 5'b0;
            PCPlus4_out   <= 32'b0;
        end else if (Flush) begin
            {RegWrite_out, MemToReg_out, MemRead_out, MemWrite_out, MemSize_out,
             MemSign_out, Branch_out, BranchType_out, Jump_out, JumpReg_out,
             ALUSrc_out, ALUControl_out, RegDst_out} <= 'b0; // bubble
            ReadData1_out <= 32'b0;
            ReadData2_out <= 32'b0;
            ImmExt_out    <= 32'b0;
            rs_out        <= 5'b0;
            rt_out        <= 5'b0;
            rd_out        <= 5'b0;
            shamt_out     <= 5'b0;
            PCPlus4_out   <= 32'b0;
        end else begin
            RegWrite_out   <= RegWrite_in;
            MemToReg_out   <= MemToReg_in;
            MemRead_out    <= MemRead_in;
            MemWrite_out   <= MemWrite_in;
            MemSize_out    <= MemSize_in;
            MemSign_out    <= MemSign_in;
            Branch_out     <= Branch_in;
            BranchType_out <= BranchType_in;
            Jump_out       <= Jump_in;
            JumpReg_out    <= JumpReg_in;
            ALUSrc_out     <= ALUSrc_in;
            ALUControl_out <= ALUControl_in;
            RegDst_out     <= RegDst_in;
            ReadData1_out  <= ReadData1_in;
            ReadData2_out  <= ReadData2_in;
            ImmExt_out     <= ImmExt_in;
            rs_out         <= rs_in;
            rt_out         <= rt_in;
            rd_out         <= rd_in;
            shamt_out      <= shamt_in;
            PCPlus4_out    <= PCPlus4_in;
        end
    end
endmodule
