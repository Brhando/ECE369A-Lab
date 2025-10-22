// Controller for MIPS subset (ECE369A Labs 4-5)
// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// - Outputs cover WB/MEM/EX/Branch/Jump controls
// - 4-bit ALUControl (textbook mapping)
// - Byte/Half load/store via MemSize/MemSign
// - Uses 2-bit RegDst, 2-bit MemToReg, 2-bit ALUSrc
//   RegDst: 00=rt, 01=rd, 10=$ra
//   MemToReg: 00=ALU, 01=DM, 10=PC+8
//   ALUSrc: 00=rt, 01=imm, 10=shamt

module Controller(
  input  wire [31:0] instr,

  // WB
  output reg         RegWrite,
  output reg  [1:0]  RegDst,      // 00 rt, 01 rd, 10 ra
  output reg  [1:0]  MemToReg,    // 00 ALU, 01 DM, 10 PC+8

  // EX
  output reg  [1:0]  ALUSrc,      // 00 rt, 01 imm, 10 shamt
  output reg  [3:0]  ALUControl,  // final 4-bit ALU op
  output reg         ExtOp,       // 1=sign, 0=zero (for immediates)

  // MEM
  output reg         MemRead,
  output reg         MemWrite,
  output reg  [1:0]  MemSize,     // 00 word, 01 half, 10 byte
  output reg         MemSign,     // 1=sign-extend on load (lb/lh); 0=zero-extend (if you add lbu/lhu later)

  // BR/JUMP
  output reg         Branch,
  output reg  [2:0]  BranchType,  // 000 beq, 001 bne, 010 bgtz, 011 blez, 100 bltz, 101 bgez
  output reg         Jump,        // j, jal
  output reg         JumpReg      // jr
);

  // Fields
  wire [5:0] op    = instr[31:26];
  wire [4:0] rt    = instr[20:16];
  wire [5:0] funct = instr[5:0];
  // wire [4:0] shamt = instr[10:6]; // used in datapath when ALUSrc==10

  // Opcodes
  localparam OP_RTYPE = 6'h00;// 0
  localparam OP_J     = 6'h02, OP_JAL  = 6'h03; // 2 or 3
  localparam OP_BEQ   = 6'h04, OP_BNE  = 6'h05; // 4 or 5
  localparam OP_BLEZ  = 6'h06, OP_BGTZ = 6'h07; // 6 or 7
  localparam OP_ADDI  = 6'h08, OP_SLTI = 6'h0A; // 8 or 10
  localparam OP_ANDI  = 6'h0C, OP_ORI  = 6'h0D, OP_XORI = 6'h0E; // 12 or 13 or 14
  localparam OP_LB    = 6'h20, OP_LH   = 6'h21; //32 or 33
  localparam OP_LW    = 6'h23; // 35
  localparam OP_SB    = 6'h28, OP_SH   = 6'h29; // 40 or 41
  localparam OP_SW    = 6'h2B; // 43
  localparam OP_REGIMM= 6'h01; // BLTZ/BGEZ via rt field (decimal 1)

  // RT (funct)
  localparam F_ADD=6'h20, F_SUB=6'h22, F_AND=6'h24, F_OR=6'h25, F_XOR=6'h26, F_NOR=6'h27;
  localparam F_SLT=6'h2A;
  localparam F_SLL=6'h00, F_SRL=6'h02;
  localparam F_MUL=6'h18; // per lab subset: "mul" (low 32)
  localparam F_JR =6'h08;

  // BranchType encodings
  localparam BT_BEQ = 3'b000, BT_BNE = 3'b001, BT_BGTZ=3'b010,
             BT_BLEZ= 3'b011, BT_BLTZ=3'b100, BT_BGEZ=3'b101;

  // ALUControl encodings (4-bit)
  localparam ALU_AND=4'b0000, ALU_OR =4'b0001, ALU_ADD=4'b0010,
             ALU_XOR=4'b0011, ALU_NOR=4'b0100, ALU_SLL=4'b0101,
             ALU_SUB=4'b0110, ALU_SLT=4'b0111, ALU_SRL=4'b1000,
             ALU_MUL=4'b1001, ALU_SGTB=4'b1010, ALU_SLTB=4'b1011,
             ALU_BEQ=4'b1100, ALU_BNE=4'b1101;

  // Defaults helper
  task set_defaults;
  begin
    RegWrite  = 1'b0;
    RegDst    = 2'b00;
    MemToReg  = 2'b00;
    ALUSrc    = 2'b00;
    ALUControl= ALU_ADD;
    ExtOp     = 1'b1;     // sign-extend by default
    MemRead   = 1'b0;
    MemWrite  = 1'b0;
    MemSize   = 2'b00;
    MemSign   = 1'b1;     // signed by default for lb/lh
    Branch    = 1'b0;
    BranchType= BT_BEQ;
    Jump      = 1'b0;
    JumpReg   = 1'b0;
  end
  endtask

  always @* begin
    set_defaults();

    case (op)

      //R-TYPE
      OP_RTYPE: begin
        case (funct)
          F_ADD: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_ADD;
          end
          F_SUB: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_SUB;
          end
          F_AND: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_AND;
          end
          F_OR:  begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_OR;
          end
          F_XOR: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_XOR;
          end
          F_NOR: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_NOR;
          end
          F_SLT: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_SLT;
          end
          F_SLL: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b10; ALUControl = ALU_SLL;
          end
          F_SRL: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b10; ALUControl = ALU_SRL;
          end
          F_MUL: begin
            RegWrite   = 1'b1; RegDst = 2'b01; ALUSrc = 2'b00; ALUControl = ALU_MUL;
          end
          F_JR:  begin
            JumpReg    = 1'b1; // PC <- rs
          end
          default: begin
            // NOP / unsupported funct -> no writes
          end
        endcase
      end

      // J / JAL 
      OP_J:   begin Jump = 1'b1; end
      OP_JAL: begin
        Jump      = 1'b1;
        RegWrite  = 1'b1;
        RegDst    = 2'b10;  // $ra
        MemToReg  = 2'b10;  // PC+8 path in WB mux
      end

      // Branches
      OP_BEQ: begin Branch=1'b1; BranchType=BT_BEQ; ALUControl=ALU_BEQ; end
      OP_BNE: begin Branch=1'b1; BranchType=BT_BNE; ALUControl=ALU_BNE; end
      OP_BLEZ:begin Branch=1'b1; BranchType=BT_BLEZ; ALUControl=ALU_SLTB; end
      OP_BGTZ:begin Branch=1'b1; BranchType=BT_BGTZ; ALUControl=ALU_SGTB; end

      OP_REGIMM: begin
        // rt selects BLTZ/BGEZ
        Branch = 1'b1; ALUControl = ALU_SUB;
        case (rt)
          5'b00000: BranchType = BT_BLTZ; // bltz
          5'b00001: BranchType = BT_BGEZ; // bgez
          if(BranchType == BT_BLTZ) begin
            ALUControl = ALU_SLTB;
          end else if (BranchType == BT_BGEZ) begin
            ALUControl = ALU_SGTB;
          end 
          default:  Branch = 1'b0; // unsupported REGIMM variants
        endcase
      end

      // Immediates
      OP_ADDI: begin
        RegWrite   = 1'b1; RegDst=2'b00; MemToReg=2'b00;
        ALUSrc     = 2'b01; ExtOp=1'b1; ALUControl=ALU_ADD;
      end
      OP_SLTI: begin
        RegWrite   = 1'b1; RegDst=2'b00; MemToReg=2'b00;
        ALUSrc     = 2'b01; ExtOp=1'b1; ALUControl=ALU_SLT;
      end
      OP_ANDI: begin
        RegWrite   = 1'b1; RegDst=2'b00; MemToReg=2'b00;
        ALUSrc     = 2'b01; ExtOp=1'b0; ALUControl=ALU_AND; // zero-extend
      end
      OP_ORI:  begin
        RegWrite   = 1'b1; RegDst=2'b00; MemToReg=2'b00;
        ALUSrc     = 2'b01; ExtOp=1'b0; ALUControl=ALU_OR;  // zero-extend
      end
      OP_XORI: begin
        RegWrite   = 1'b1; RegDst=2'b00; MemToReg=2'b00;
        ALUSrc     = 2'b01; ExtOp=1'b0; ALUControl=ALU_XOR; // zero-extend
      end

      // Loads
      OP_LW: begin
        RegWrite=1'b1; RegDst=2'b00; MemToReg=2'b01;
        MemRead =1'b1; MemSize=2'b00; MemSign=1'b1;
        ALUSrc  =2'b01; ExtOp=1'b1; ALUControl=ALU_ADD; // base+imm
      end
      OP_LH: begin
        RegWrite=1'b1; RegDst=2'b00; MemToReg=2'b01;
        MemRead =1'b1; MemSize=2'b01; MemSign=1'b1;
        ALUSrc  =2'b01; ExtOp=1'b1; ALUControl=ALU_ADD;
      end
      OP_LB: begin
        RegWrite=1'b1; RegDst=2'b00; MemToReg=2'b01;
        MemRead =1'b1; MemSize=2'b10; MemSign=1'b1;
        ALUSrc  =2'b01; ExtOp=1'b1; ALUControl=ALU_ADD;
      end

      // Stores
      OP_SW: begin
        MemWrite=1'b1; MemSize=2'b00;
        ALUSrc  =2'b01; ExtOp=1'b1; ALUControl=ALU_ADD;
      end
      OP_SH: begin
        MemWrite=1'b1; MemSize=2'b01;
        ALUSrc  =2'b01; ExtOp=1'b1; ALUControl=ALU_ADD;
      end
      OP_SB: begin
        MemWrite=1'b1; MemSize=2'b10;
        ALUSrc  =2'b01; ExtOp=1'b1; ALUControl=ALU_ADD;
      end

      default: begin
        // unsupported opcode: keep safe defaults (no write/branch/jump)
      end
    endcase
  end

endmodule
