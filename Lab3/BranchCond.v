// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// BranchCond.v : decides whether to take the branch

module BranchCond(
    input  [31:0] rs_val,
    input         Zero,
    input [31:0] ALUResult,      
    input  [2:0]  BranchType,    // 000=beq 001=bne 010=bgtz 011=blez 100=bltz 101=bgez
    output reg    take
);
    wire rs_neg  = rs_val[31];
    wire rs_zero = (rs_val == 32'b0);

    always @* begin
        case (BranchType)
            3'b000: take = Zero;                          // beq
            3'b001: take = ~Zero;                         // bne
            3'b010: take = (~rs_neg) && (~rs_zero);       // bgtz
            3'b011: take = rs_neg  ||  rs_zero;           // blez
            3'b100: take = rs_neg;                        // bltz
            3'b101: take = (~rs_neg) || rs_zero;          // bgez
            default: take = 1'b0;
        endcase
    end
endmodule