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

    // Control / Data signals
//    wire [31:0] PC_out;
//    wire [31:0] Data_out;
    wire RegWrite, MemRead;
    wire [1:0] RegDst, MemToReg, ALUSrc;
    wire [3:0] ALUControl;
    wire ExtOp, MemWrite;
    wire [1:0] MemSize;
    wire MemSign, Branch;
    wire [2:0] BranchType;
    wire Jump, JumpReg;
    wire clkdiv;

    // WB stage outputs
    wire [31:0] WriteData_WB;
    wire RegWrite_WB;
    wire [1:0] MemToReg_WB;
    wire [31:0] ReadData_WB;
    wire [31:0] ALUResult_WB;
    wire [31:0] PCPlus4_WB;
    wire [4:0]  DestReg_WB;

    // IF stage
    wire [31:0] PC, Instr;

    InstructionMemory instructionMemory(
        .Address(PC),
        .Instruction(Instr)
    );

    wire [31:0] PCPlus4;
    assign PCPlus4 = PC + 4;

    // ID stage
    wire [31:0] ID_Instr, ID_PCPlus4;
    wire [31:0] PCNext;
    wire        BranchTaken;
    wire        Zero;

    // EX stage control
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

    // EX stage data
    wire [31:0] ReadData1_EX;
    wire [31:0] ReadData2_EX;
    wire [31:0] ImmExt_EX;
    wire [4:0]  rs_EX, rt_EX, rd_EX;
    wire [4:0]  shamt_EX;
    wire [31:0] PCPlus4_EX;
    wire [25:0] instr_index_EX;

    wire [31:0] ALUA;
    wire [31:0] ALUB;

    // MEM stage
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
    
    // Forwarding / hazard wires
    wire [1:0] ForwardA, ForwardB;
    wire       PCWrite;
    wire       IF_ID_Write;
    wire       ID_EX_Flush;

    // Other signals
    wire [31:0] Immediate;
    wire [31:0] ReadData1, ReadData2;
    wire [4:0]  WriteReg_EX;
    wire [31:0] ALUResult_EX;
    wire [31:0] ReadData_MEM;
    wire        Flush;

    // HI/LO registers
    wire [31:0] Hi_out, Lo_out;
    reg  [31:0] Hi_reg, Lo_reg;

    // Flush logic (control resolved in ID stage)
    // Only flush when we're not stalling due to a hazard
    //assign Flush = PCWrite && ((Branch && BranchTaken) || Jump || JumpReg);
assign Flush = (Branch && BranchTaken) || Jump || JumpReg;
    
    // Display
    Two4DigitDisplay TDD(
        .NumberA(PC_out[15:0]),
        .NumberB(Data_out[15:0]),
        .Clk(Clk),
        .out7(out7),
        .en_out(en_out)
    );

    // Clock divider
//    ClkDiv clock_divider(
//        .Clk(Clk),
//        .Rst(Reset),
//        .ClkOut(clkdiv)
//    );
assign clkdiv = Clk;

    // IF/ID Pipeline Register
    IF_ID_Reg IFID(
        .Clk(clkdiv),
        .Reset(Reset),
        .Stall(~IF_ID_Write), // 1 = stall
        .Flush(Flush),
        .PC_in(PCPlus4),
        .Instr_in(Instr),
        .PC_out(ID_PCPlus4),
        .Instr_out(ID_Instr)
    );

    // Register File
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

    // ID-stage bypass for branch and JR
    wire [4:0] ID_rs = ID_Instr[25:21];
    wire [4:0] ID_rt = ID_Instr[20:16];

    // WB/ID forwarding
    wire [31:0] ID_rs_wb =
        (RegWrite_WB && DestReg_WB != 5'd0 && DestReg_WB == ID_rs) ?
            WriteData_WB : ReadData1;

    wire [31:0] ID_rt_wb =
        (RegWrite_WB && DestReg_WB != 5'd0 && DestReg_WB == ID_rt) ?
            WriteData_WB : ReadData2;

    // EX/MEM  ID forwarding
    wire [31:0] mem_result_for_id =
        (MemToReg_MEM == 2'b01) ? ReadData_MEM : ALUResult_MEM;

    wire [31:0] ID_rs_fwd =
        (RegWrite_MEM && DestReg_MEM != 5'd0 && DestReg_MEM == ID_rs) ?
            mem_result_for_id : ID_rs_wb;

    wire [31:0] ID_rt_fwd =
        (RegWrite_MEM && DestReg_MEM != 5'd0 && DestReg_MEM == ID_rt) ?
            mem_result_for_id : ID_rt_wb;

    // BEQ/BNE compare in ID stage
    wire Zero_ID = (ID_rs_fwd == ID_rt_fwd);

    // Sign extension
    SignExtension SE(
        .in(ID_Instr[15:0]),
        .ExtOp(ExtOp),
        .out(Immediate)
    );

    // Program Counter
    wire [31:0] PCNext_stall;
    //assign PCNext_stall = PCWrite ? PCNext : PC;  // if stall, hold PC
    assign PCNext_stall = (PCWrite || Flush) ? PCNext : PC;
    ProgramCounter PCount(
        .clk(clkdiv),
        .rst(Reset),
        .PCNext(PCNext_stall),
        .PC(PC)
    );

    // Controller
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

    // ID/EX Pipeline Register
    ID_EX_Reg IDEX(
        .Clk(clkdiv),
        .Reset(Reset),
        .Flush(ID_EX_Flush || Flush), //flush on load-use hazard 
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
        .rs_in(ID_rs),
        .rt_in(ID_rt),
        .rd_in(ID_Instr[15:11]),
        .shamt_in(ID_Instr[10:6]),
        .PCPlus4_in(ID_PCPlus4),

        .RegWrite_out(RegWrite_EX),
        .MemToReg_out(MemToReg_EX),
        .MemRead_out(MemRead_EX),
        .MemWrite_out(MemWrite_EX),
        .MemSize_out(MemSize_EX),
        .MemSign_out(MemSign_EX),
        .Branch_out(Branch_EX),
        .BranchType_out(BranchType_EX),
        .Jump_out(Jump_EX),
        .JumpReg_out(JumpReg_EX),
        .ALUSrc_out(ALUSrc_EX),
        .ALUControl_out(ALUControl_EX),
        .RegDst_out(RegDst_EX),

        .instr_index_out(instr_index_EX),
        .ReadData1_out(ReadData1_EX),
        .ReadData2_out(ReadData2_EX),
        .ImmExt_out(ImmExt_EX),
        .rs_out(rs_EX),
        .rt_out(rt_EX),
        .rd_out(rd_EX),
        .shamt_out(shamt_EX),
        .PCPlus4_out(PCPlus4_EX)
    );
    
    // Forwarding Unit
    ForwardingUnit fwd(
        .RegWrite_MEM(RegWrite_MEM),
        .DestReg_MEM(DestReg_MEM),
        .RegWrite_WB(RegWrite_WB),
        .DestReg_WB(DestReg_WB),
        .rs_EX(rs_EX),
        .rt_EX(rt_EX),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    // Hazard Detection (load-use stall)
    HazardDetectionUnit hdu(
        .MemRead_EX(MemRead_EX),
        .rt_EX(rt_EX),
        .ID_rs(ID_rs),
        .ID_rt(ID_rt),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .ID_EX_Flush(ID_EX_Flush)
    );

    // EX Stage ALU (with forwarding)
    wire [31:0] srcA_EX = ReadData1_EX;
    wire [31:0] srcB_EX = ReadData2_EX;

    wire [31:0] fwdA_EX =
        (ForwardA == 2'b00) ? srcA_EX :
        (ForwardA == 2'b10) ? ALUResult_MEM :
        (ForwardA == 2'b01) ? WriteData_WB :
                              srcA_EX;

    wire [31:0] fwdB_EX =
        (ForwardB == 2'b00) ? srcB_EX :
        (ForwardB == 2'b10) ? ALUResult_MEM :
        (ForwardB == 2'b01) ? WriteData_WB :
                              srcB_EX;

    // Preserve original ALUSrc behavior, but applied to the
    // forwarded operands instead of the raw register values
    assign ALUA =
        (ALUSrc_EX == 2'b10) ? fwdB_EX :  // for variable shifts etc.
                               fwdA_EX;

    assign ALUB =
        (ALUSrc_EX == 2'b00) ? fwdB_EX :
        (ALUSrc_EX == 2'b01) ? ImmExt_EX :
        (ALUSrc_EX == 2'b10) ? {27'b0, shamt_EX} :
                               32'b0;

    ALU32Bit alu(
        .A(ALUA),
        .B(ALUB),
        .ALUControl(ALUControl_EX),
        .ALUResult(ALUResult_EX),
        .Zero(Zero),
        .Hi(Hi_out),
        .Lo(Lo_out)
    );

    // HI/LO Update
    always @(posedge clkdiv) begin
        if (Reset) begin
            Hi_reg <= 32'b0;
            Lo_reg <= 32'b0;
        end else begin
            Hi_reg <= Hi_out;
            Lo_reg <= Lo_out;
        end
    end

    // NextPC Unit
    NextPC nextpc(
        .PC(PC),
        .PCPlus4(PCPlus4), //change
        .PCPlus4_branch(ID_PCPlus4),
        .rs_val(ID_rs_fwd),
        .imm_ext(Immediate),
        .instr_index(ID_Instr[25:0]),
        .Branch(Branch),
        .BranchType(BranchType),
        .Jump(Jump),
        .JumpReg(JumpReg),
        .Zero(Zero_ID),
        .PCNext(PCNext),
        .BranchTaken(BranchTaken)
    );

    // Destination register selection
    assign WriteReg_EX =
        (RegDst_EX == 2'b00) ? rt_EX :
        (RegDst_EX == 2'b01) ? rd_EX :
        (RegDst_EX == 2'b10) ? 5'd31 :
                               5'd0;

    // EX/MEM Pipeline Register
    EX_MEM_Reg EXMEM(
        .Clk(clkdiv),
        .Reset(Reset),
        .Flush(1'b0),

        .RegWrite_in(RegWrite_EX),
        .MemToReg_in(MemToReg_EX),

        .MemRead_in(MemRead_EX),
        .MemWrite_in(MemWrite_EX),
        .MemSize_in(MemSize_EX),
        .MemSign_in(MemSign_EX),
        .Branch_in(Branch_EX),
        .BranchType_in(BranchType_EX),
        .Jump_in(Jump_EX),
        .JumpReg_in(JumpReg_EX),

        .ALUResult_in(ALUResult_EX),
        .ConFlag_in(Zero),
        .WriteData_in(fwdB_EX),
        .DestReg_in(WriteReg_EX),
        .BranchTarget_in(32'b0),
        .JumpTarget_in(32'b0),
        .PCPlus4_in(PCPlus4_EX),

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

    // Data Memory
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

    // MEM/WB Pipeline Register
    MEM_WB_Reg MEMWB(
        .Clk(clkdiv),
        .Reset(Reset),

        .RegWrite_in(RegWrite_MEM),
        .MemToReg_in(MemToReg_MEM),

        .ReadData_in(ReadData_MEM),
        .ALUResult_in(ALUResult_MEM),
        .PCPlus4_in(PCPlus4_MEM),
        .DestReg_in(DestReg_MEM),

        .RegWrite_out(RegWrite_WB),
        .MemToReg_out(MemToReg_WB),

        .ReadData_out(ReadData_WB),
        .ALUResult_out(ALUResult_WB),
        .PCPlus4_out(PCPlus4_WB),
        .DestReg_out(DestReg_WB)
    );

    // Writeback mux
    assign WriteData_WB =
        (MemToReg_WB == 2'b00) ? ALUResult_WB :
        (MemToReg_WB == 2'b01) ? ReadData_WB :
        (MemToReg_WB == 2'b10) ? PCPlus4_WB :
                                 32'b0;

    // Outputs: show PC of the instruction being written back
    assign PC_out   = PCPlus4_WB - 32'd4;
    assign Data_out = RegWrite_WB ? WriteData_WB : 32'b0;

endmodule