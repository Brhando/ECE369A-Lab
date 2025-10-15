`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - ALU32Bit.v
// Description - 32-Bit wide arithmetic logic unit (ALU).
//
// INPUTS:-
// ALUControl: N-Bit input control bits to select an ALU operation.
// A: 32-Bit input port A.
// B: 32-Bit input port B.
//
// OUTPUTS:-
// ALUResult: 32-Bit ALU result output.
// ZERO: 1-Bit output flag. 
//
// FUNCTIONALITY:-
// Design a 32-Bit ALU, so that it supports all arithmetic operations 
// needed by the MIPS instructions given in Labs5-8.docx document. 
//   The 'ALUResult' will output the corresponding result of the operation 
//   based on the 32-Bit inputs, 'A', and 'B'. 
//   The 'Zero' flag is high when 'ALUResult' is '0'. 
//   The 'ALUControl' signal should determine the function of the ALU 
//   You need to determine the bitwidth of the ALUControl signal based on the number of 
//   operations needed to support. 
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, ALUResult, ConFlag, Hi, Lo);

	input [3:0] ALUControl; // control bits for ALU operation
                                // you need to adjust the bitwidth as needed
	input [31:0] A, B;	    // inputs

	output reg [31:0] ALUResult;	// answer
	output reg [31:0] Hi;
	output reg [31:0] Lo;
	output reg ConFlag; //1 bit register used to store output for conditionals


    reg [63:0] temp64;
    /* Please fill in the implementation here... */
    always @(*) begin
    
        ALUResult = A;
        Hi = 0;
        Lo = 0;
        ConFlag = 0;
        
        
        
        case (ALUControl)
    //add: add, addi, lw (lw $t0, 8($s0)   A = base memory address = $s0, B = offset = 8, ALUResult = address to load word from, $t0 is set externally using address computed in ALU ),
    //sw (sw $s0, 8($t0) A = word to store = $s0, B = offset = 8, ALUResult = address to store word in, $s0 the word that will be saved in the copmuted memory address [done externally]),
    //lb, lh, sh, sb these work the same as sw and lw, one byte or two bytes handled externally 
    4'd0: ALUResult = A + B;
    
    
    //sub: sub
    4'd1: ALUResult = A - B;
    
    
    //mult: mult
    4'd2: begin 
        temp64 = $signed(A) * $signed(B);
        Hi = temp64[63:32];
        Lo = temp64[31:0];
    end
    //slt: slt
    4'd3: ALUResult = (A < B) ? 32'd1 : 32'd0;
    
    //sltb: blez (A = register input, B = 1), bltz (A = register input, B = 0)
    4'd4: ConFlag = (A < B);
    
    //sgtb: bgez (A = register input, B = -1), bgtz (A = register input, B = 0) 
    4'd5: ConFlag = (A > B);
    
    //seqb: beq
    4'd6: ConFlag = (A == B);
    
    //sneb: bne
    4'd7: ConFlag = ( A != B);
    
    //and: and, andi
    4'd8: ALUResult = A & B;
    
    //or: or, ori
    4'd9: ALUResult = A | B;
    
    //nor: nor
    4'd10: ALUResult = ~(A | B);
    
    //xor: xor, xori
    4'd11: ALUResult = A ^ B;

    //sll: sll ( B is original number, A is shift amount )
    4'd12: ALUResult = B << A[4:0];
    
    //srl: srl ( B is original number, A is shift amount )
    4'd13: ALUResult = B >> A[4:0];
    
    default: begin 
    ALUResult = 0; 
    Hi = 0; 
    Lo = 0; 
    ConFlag = 0; 
    end
    endcase
end
endmodule

