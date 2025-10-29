`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2025 08:26:25 PM
// Design Name: 
// Module Name: ProgramCounter
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


module ProgramCounter (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] PCNext,
    output reg  [31:0] PC
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'd0;           // Reset to address 0
        else
            PC <= PCNext;          // Update PC on clock edge
    end

endmodule
