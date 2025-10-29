// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// NextPC.v
module NextPC(
    input  [31:0] PC,
    input  [31:0] PCPlus4,
    input  [31:0] rs_val,          // for jr and sign/zero branches
    input  [31:0] imm_ext,         // sign-extended imm16 (for branch target)
    input  [25:0] instr_index,     // instr[25:0] (j/jal)
    input         Branch,          // from Controller
    input  [2:0]  BranchType,      
    input         Jump,            // j or jal
    input         JumpReg,         // jr
    input         Zero,
    input  [31:0] ALUResult,        
    output [31:0] PCNext,
    output        BranchTaken
);
    wire [31:0] offset_sl2  = {imm_ext[29:0], 2'b00};
    wire [31:0] branch_tgt  = PCPlus4 + offset_sl2;
    wire [31:0] jump_tgt    = {PCPlus4[31:28], instr_index, 2'b00};

    BranchCond bc(
        .rs_val(rs_val),
        .Zero(Zero),
        .ALUResult(ALUResult),
        .BranchType(BranchType),
        .take(BranchTaken)
    );

    wire [31:0] after_branch = (Branch && BranchTaken) ? branch_tgt : PCPlus4;
    wire [31:0] after_jump   = Jump ? jump_tgt : after_branch;
    assign PCNext            = JumpReg ? rs_val : after_jump;
endmodule

