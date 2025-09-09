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


module Top(
    input  wire Clk,   // match XDC
    input  wire Reset,       // active-high pushbutton (rename to match XDC)
    output wire [6:0] out7,  // seven-seg segments a..g
    output wire [7:0] en_out 
);
    //Slow the system clock so the display updates at a human-visible rate
    wire ClkOut;
    ClkDiv u_div (
        .Clk    (Clk),
        .Rst    (Reset),
        .ClkOut (ClkOut)
    );

    //Run the IFU on the same divided clock
    wire [15:0] pc16;
    wire [15:0] instr16;

    InstructionFetchUnit IFU (
        .Reset       (Reset),
        .Clk         (ClkOut),
        .PCResult    (pc16),     //IFU already outputs 16-bit values
        .Instruction (instr16)
    );

    // Drive the dual 4-digit HEX display
    Two4DigitDisplay disp (
        .Clk     (ClkOut),
        .NumberA (instr16),  // show Instruction on the left 4 digits
        .NumberB (pc16),     // show PC on the right 4 digits
        .out7    (out7),
        .en_out  (en_out)
    );
endmodule
