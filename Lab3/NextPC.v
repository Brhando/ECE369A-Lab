module NextPC(
    input  wire [31:0] PC,         // current PC (for jump index upper bits)
    input  wire [31:0] PCPlus4,    // PC + 4 of *ID-stage* instruction
    input  wire [31:0] rs_val,     // forwarded rs value from ID stage
    input  wire [31:0] imm_ext,    // sign-extended immediate from ID
    input  wire [25:0] instr_index,
    input  wire        Branch,
    input  wire [2:0]  BranchType, // 000 beq, 001 bne, 010 bgtz, 011 blez, 100 bltz, 101 bgez
    input  wire        Jump,
    input  wire        JumpReg,
    input  wire        Zero,       // equality flag for BEQ/BNE (ID stage compare)
    output reg  [31:0] PCNext,
    output reg         BranchTaken
);

    wire [31:0] offset_sl2 = {imm_ext[29:0], 2'b00};      // imm << 2
    wire [31:0] branch_tgt = PCPlus4 + offset_sl2;        // PC+4 + offset

    // Jump target (J / JAL)
    wire [31:0] jump_tgt = { PCPlus4[31:28], instr_index, 2'b00 };

    // Sign info for REGIMM / BGTZ / BLEZ
    wire rs_neg  = rs_val[31];
    wire rs_zero = (rs_val == 32'd0);

    // Decide if branch condition is satisfied
    always @* begin
        BranchTaken = 1'b0;
        case (BranchType)
            3'b000: BranchTaken =  Zero;                         // BEQ
            3'b001: BranchTaken = ~Zero;                         // BNE
            3'b010: BranchTaken = (~rs_neg) & (~rs_zero);        // BGTZ  (rs > 0)
            3'b011: BranchTaken =  rs_neg | rs_zero;             // BLEZ  (rs <= 0)
            3'b100: BranchTaken =  rs_neg;                       // BLTZ  (rs < 0)
            3'b101: BranchTaken = (~rs_neg) | rs_zero;           // BGEZ  (rs >= 0)
            default: BranchTaken = 1'b0;
        endcase
    end

    always @* begin
        // Default: fall-through
        PCNext = PCPlus4;

        // Branch
        if (Branch && BranchTaken)
            PCNext = branch_tgt;

        // Jump (j/jal) overrides branch
        if (Jump)
            PCNext = jump_tgt;

        // JumpReg (jr) overrides everything
        if (JumpReg)
            PCNext = rs_val;
    end

endmodule