`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 12:38:48 PM
// Design Name: 
// Module Name: Top
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


module Top(Reset, Clk, out7, en_out

    );
    input Reset, Clk;
    wire ClkOut;
    wire [31:0] Instruction, PCResult;
    output [6:0] out7; //seg a, b, ... g
    output [7:0] en_out;
    
    ClkDiv clk(
    .Clk(Clk),
    .Rst(0),
    .ClkOut(ClkOut));
    
    InstructionFetchUnit IFU(
    .Instruction(Instruction),
    .PCResult(PCResult),
    .Reset(Reset),
    .Clk(ClkOut));
    
    Two4DigitDisplay TDD(
    .NumberA(Instruction[15:0]),
    .NumberB(PCResult[15:0]),
    .Clk(Clk),
    .out7(out7),
    .en_out(en_out)
    );
endmodule
