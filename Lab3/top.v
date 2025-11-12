`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2025 01:28:05 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input wire Clk,
    input wire Reset,
    output wire [6:0] out7,
    output wire [7:0] en_out,
    output wire [31:0] PC_out,
    output wire [31:0] Data_out
    );
    //wire [31:0] PC_out, Data_out;
    wire RegWrite, MemRead;
    wire [1:0] RegDst, MemToReg, ALUSrc;
    wire [3:0] ALUControl;
    wire ExtOp, MemWrite;
    wire [1:0] MemSize;
    wire MemSign, Branch;
    wire [2:0] BranchType;
    wire Jump, JumpReg;
    wire clkdiv;
    wire [31:0] WriteData_WB;
    wire        RegWrite_WB;
    wire [1:0]  MemToReg_WB;
    wire [31:0] ReadData_WB;
    wire [31:0] ALUResult_WB;
    wire [31:0] PCPlus4_WB;
    wire [4:0]  DestReg_WB;
    
    wire [31:0] PC, Instr;
    InstructionMemory instructionMemory(
        .Address(PC),
        .Instruction(Instr)
    );
    wire [31:0] PCPlus4; 
    assign PCPlus4 = PC + 4;
    wire [31:0] ID_Instr, ID_PCPlus4;
    wire [31:0] PCNext;
    wire BranchTaken;
    wire Zero;
     
    wire        RegWrite_EX;
    wire [1:0]  MemToReg_EX;
    wire        MemRead_EX;
    wire        MemWrite_EX;
    wire [1:0]  MemSize_EX;
    wire        MemSign_EX;
    wire        Branch_EX;
    wire [2:0]  BranchType_EX;
    wire        Jump_EX;
    wire        JumpReg_EX;
    wire [1:0]  ALUSrc_EX;
    wire [3:0]  ALUControl_EX;
    wire [1:0]  RegDst_EX;

    wire [31:0] ReadData1_EX;
    wire [31:0] ReadData2_EX;
    wire [31:0] ImmExt_EX;
    wire [4:0]  rs_EX, rt_EX, rd_EX;
    wire [4:0]  shamt_EX;
    wire [31:0] PCPlus4_EX;
    wire [25:0] instr_index_EX;
    wire [31:0] ALUA;
    wire [31:0] ALUB;
    wire        RegWrite_MEM;
    wire [1:0]  MemToReg_MEM;
    wire        MemRead_MEM;
    wire        MemWrite_MEM;
    wire [1:0]  MemSize_MEM;
    wire        MemSign_MEM;
    wire        Branch_MEM;
    wire [2:0]  BranchType_MEM;
    wire        Jump_MEM;
    wire        JumpReg_MEM;
    wire [31:0] ALUResult_MEM;
    wire        Zero_MEM;
    wire [31:0] WriteData_MEM;
    wire [4:0]  DestReg_MEM;
    wire [31:0] BranchTarget_MEM;
    wire [31:0] JumpTarget_MEM;
    wire [31:0] PCPlus4_MEM;
    wire [31:0] Immediate;
    wire [31:0] ReadData1, ReadData2;
    wire [4:0] WriteReg_EX;
    wire [31:0] ALUResult_EX;
    wire [31:0] ReadData_MEM;
    wire Flush;    
    
    wire [31:0] Hi_out, Lo_out;      // Outputs from ALU
    reg [31:0] Hi_reg, Lo_reg;       // Hi/Lo registers (stored values)


    assign Flush = (Branch && BranchTaken) || Jump || JumpReg;
    
     Two4DigitDisplay TDD(
     .NumberA(PC_out[15:0]),
     .NumberB(Data_out[15:0]),
     .Clk(Clk),
     .out7(out7),
     .en_out(en_out)
     );
     
    ClkDiv clock_divider(
    .Clk(Clk),
    .Rst(Reset),
    .ClkOut(clkdiv)
);


    IF_ID_Reg IFID(
        .Clk(clkdiv),
        .Reset(Reset),
        .Stall(1'b0),
        .Flush(Flush),
        .PC_in(PCPlus4),
        .Instr_in(Instr),
        .PC_out(ID_PCPlus4),
        .Instr_out(ID_Instr)
    );
    
    
    
    RegisterFile RF(
        .ReadRegister1(ID_Instr[25:21]),
        .ReadRegister2(ID_Instr[20:16]),
        .WriteRegister(DestReg_WB),
        .WriteData(WriteData_WB),
        .Clk(clkdiv),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .RegWrite(RegWrite_WB)
    );

    // ---------- ID-stage bypass for branch compare & JR ----------
    wire [4:0] ID_rs = ID_Instr[25:21];
    wire [4:0] ID_rt = ID_Instr[20:16];

    // Minimal WB→ID bypass (works for most cases)
    wire [31:0] ID_rs_wb =
        (RegWrite_WB && DestReg_WB != 5'd0 && DestReg_WB == ID_rs) ? WriteData_WB : ReadData1;
    wire [31:0] ID_rt_wb =
        (RegWrite_WB && DestReg_WB != 5'd0 && DestReg_WB == ID_rt) ? WriteData_WB : ReadData2;

    // (Recommended) also include EX/MEM→ID for truly fresh ALU results
    wire [31:0] ID_rs_fwd =
        (RegWrite_MEM && DestReg_MEM != 5'd0 && DestReg_MEM == ID_rs) ? ALUResult_MEM : ID_rs_wb;
    wire [31:0] ID_rt_fwd =
        (RegWrite_MEM && DestReg_MEM != 5'd0 && DestReg_MEM == ID_rt) ? ALUResult_MEM : ID_rt_wb;

    // Equality used by BEQ/BNE (ID-stage)
    wire Zero_ID = (ID_rs_fwd == ID_rt_fwd);
    
    
     
    SignExtension SE(
        .in(ID_Instr[15:0]),
        .ExtOp(ExtOp),
        .out(Immediate)
    );
    
    ProgramCounter PCount(
    .clk(clkdiv),
    .rst(Reset),
    .PCNext(PCNext),
    .PC(PC)
    );
    

    Controller con(
        .instr(ID_Instr),
        
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .MemToReg(MemToReg),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .ExtOp(ExtOp),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemSize(MemSize),
        .MemSign(MemSign),
        .Branch(Branch),
        .BranchType(BranchType),
        .Jump(Jump),
        .JumpReg(JumpReg)
    );


   

    ID_EX_Reg IDEX(
        .Clk(clkdiv),
        .Reset(Reset),
        .Flush(1'b0),
        .instr_index_in(ID_Instr[25:0]),
        .RegWrite_in(RegWrite),
        .MemToReg_in(MemToReg),
        .MemRead_in(MemRead),
        .MemWrite_in(MemWrite),
        .MemSize_in(MemSize),
        .MemSign_in(MemSign),
        .Branch_in(Branch),
        .BranchType_in(BranchType),
        .Jump_in(Jump),
        .JumpReg_in(JumpReg),
        .ALUSrc_in(ALUSrc),
        .ALUControl_in(ALUControl),
        .RegDst_in(RegDst),
        .ReadData1_in(ReadData1),
        .ReadData2_in(ReadData2),
        .ImmExt_in(Immediate),
        .rs_in(ID_Instr[25:21]),
        .rt_in(ID_Instr[20:16]),
        .rd_in(ID_Instr[15:11]),
        .shamt_in(ID_Instr[10:6]),
        .PCPlus4_in(ID_PCPlus4),
        
        .RegWrite_out (RegWrite_EX),
        .MemToReg_out (MemToReg_EX),
        .MemRead_out  (MemRead_EX),
        .MemWrite_out (MemWrite_EX),
        .MemSize_out  (MemSize_EX),
        .MemSign_out  (MemSign_EX),
        .Branch_out   (Branch_EX),
        .BranchType_out(BranchType_EX),
        .Jump_out     (Jump_EX),
        .JumpReg_out  (JumpReg_EX),
        .ALUSrc_out   (ALUSrc_EX),
        .ALUControl_out(ALUControl_EX),
        .RegDst_out   (RegDst_EX),
        .instr_index_out(instr_index_EX),

        .ReadData1_out(ReadData1_EX),
        .ReadData2_out(ReadData2_EX),
        .ImmExt_out   (ImmExt_EX),
        .rs_out       (rs_EX),
        .rt_out       (rt_EX),
        .rd_out       (rd_EX),
        .shamt_out    (shamt_EX),
        .PCPlus4_out  (PCPlus4_EX)
    );
   
    // EX Stage: ALU B Mux (3-to-1)

assign ALUA =
    (ALUSrc_EX == 2'b10) ? ReadData2_EX :   // shifts: A <- rt (value to shift)
                           ReadData1_EX;    // normal ops: A <- rs
assign ALUB = 
    (ALUSrc_EX == 2'b00) ? ReadData2_EX :
    (ALUSrc_EX == 2'b01) ? ImmExt_EX :
    (ALUSrc_EX == 2'b10) ? {27'b0, shamt_EX} :
    32'b0;  // default

ALU32Bit alu(
    .A(ALUA),
    .B(ALUB),
    .ALUControl(ALUControl_EX),
    .ALUResult(ALUResult_EX),
    .Zero(Zero),
    .Hi(Hi_out),
    .Lo(Lo_out)
);

always @(posedge clkdiv) begin
    if (Reset) begin
        Hi_reg <= 32'b0;
        Lo_reg <= 32'b0;
    end
    else begin
        Hi_reg <= Hi_out;
        Lo_reg <= Lo_out;
    end
end

// NextPC instantiation
NextPC nextpc(
    .PC(PC),
    .PCPlus4(ID_PCPlus4),
    .rs_val(ID_rs_fwd),          // rs value for jr instruction
    .imm_ext(Immediate),            // sign-extended immediate
    .instr_index(ID_Instr[25:0]),   // for j/jal instructions
    .Branch(Branch),
    .BranchType(BranchType),
    .Jump(Jump),
    .JumpReg(JumpReg),
    .Zero(Zero_ID),
    .ALUResult(ID_rs_fwd),                  
    .PCNext(PCNext),
    .BranchTaken(BranchTaken)
);
    
    
    

assign WriteReg_EX = 
    (RegDst_EX == 2'b00) ? rt_EX :      // I-type uses rt
    (RegDst_EX == 2'b01) ? rd_EX :      // R-type uses rd
    (RegDst_EX == 2'b10) ? 5'd31 :      // jal uses $ra (register 31)
    5'd0;                                // default

// Declare EX/MEM pipeline register output wires



//    wire        RegWrite_WB;
//    wire [1:0]  MemToReg_WB;
//    wire [31:0] ReadData_WB;
//    wire [31:0] ALUResult_WB;
//    wire [31:0] PCPlus4_WB;
//    wire [4:0]  DestReg_WB;
// EX/MEM Register instantiation
EX_MEM_Reg EXMEM(
    .Clk(clkdiv),
    .Reset(Reset),
    .Flush(1'b0),  // Connect to your flush logic later if needed
    
    // WB control signals
    .RegWrite_in(RegWrite_EX),
    .MemToReg_in(MemToReg_EX),
    
    // MEM control signals
    .MemRead_in(MemRead_EX),
    .MemWrite_in(MemWrite_EX),
    .MemSize_in(MemSize_EX),
    .MemSign_in(MemSign_EX),
    .Branch_in(Branch_EX),
    .BranchType_in(BranchType_EX),
    .Jump_in(Jump_EX),
    .JumpReg_in(JumpReg_EX),
    
    // Data from EX stage
    .ALUResult_in(ALUResult_EX),
    .ConFlag_in(Zero),              // Your ALU's Zero flag
    .WriteData_in(ReadData2_EX),    // rt value for store operations
    .DestReg_in(WriteReg_EX),       // Destination register after RegDst mux
    .BranchTarget_in(32'b0),        // Not used (NextPC calculates this)
    .JumpTarget_in(32'b0),          // Not used (NextPC calculates this)
    .PCPlus4_in(PCPlus4_EX),        // For jal writeback
    
    // Outputs to MEM stage
    .RegWrite_out(RegWrite_MEM),
    .MemToReg_out(MemToReg_MEM),
    .MemRead_out(MemRead_MEM),
    .MemWrite_out(MemWrite_MEM),
    .MemSize_out(MemSize_MEM),
    .MemSign_out(MemSign_MEM),
    .Branch_out(Branch_MEM),
    .BranchType_out(BranchType_MEM),
    .Jump_out(Jump_MEM),
    .JumpReg_out(JumpReg_MEM),
    .ALUResult_out(ALUResult_MEM),
    .ConFlag_out(Zero_MEM),
    .WriteData_out(WriteData_MEM),
    .DestReg_out(DestReg_MEM),
    .BranchTarget_out(BranchTarget_MEM),
    .JumpTarget_out(JumpTarget_MEM),
    .PCPlus4_out(PCPlus4_MEM)
    
    
);

   

DataMemory DM(
    .Address(ALUResult_MEM),
    .WriteData(WriteData_MEM),
    .Clk(clkdiv),
    .MemWrite(MemWrite_MEM),
    .MemRead(MemRead_MEM),
    .MemSize(MemSize_MEM),      
    .MemSign(MemSign_MEM),      
    .ReadData(ReadData_MEM)
);
    
    



    MEM_WB_Reg MEMWB(
    .Clk(clkdiv),
    .Reset(Reset),
    
    // Control signals in
    .RegWrite_in(RegWrite_MEM),
    .MemToReg_in(MemToReg_MEM),
    
    // Data in
    .ReadData_in(ReadData_MEM),      // From Data Memoryv
    .ALUResult_in(ALUResult_MEM),    // From EX/MEM register
    .PCPlus4_in(PCPlus4_MEM),        // From EX/MEM register
    .DestReg_in(DestReg_MEM),        // From EX/MEM register
    
    // Control signals out
    .RegWrite_out(RegWrite_WB),
    .MemToReg_out(MemToReg_WB),
    
    // Data out
    .ReadData_out(ReadData_WB),
    .ALUResult_out(ALUResult_WB),
    .PCPlus4_out(PCPlus4_WB),
    .DestReg_out(DestReg_WB)
);



    assign WriteData_WB = 
        (MemToReg_WB == 2'b00) ? ALUResult_WB :   // Arithmetic/logic instructions
        (MemToReg_WB == 2'b01) ? ReadData_WB :    // Load instructions (lw, lh, lb)
        (MemToReg_WB == 2'b10) ? PCPlus4_WB :     // JAL instruction (return address)
        32'b0; 
    
    
    assign PC_out = PC;
    assign Data_out = RegWrite_WB ? WriteData_WB : 32'b0;
endmodule
