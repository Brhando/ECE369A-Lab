`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Names: Brandon Sisco, Griffith Wiele, Gavin Hernandez
// Module - SignExtension.v
// Description - Sign extension module.
////////////////////////////////////////////////////////////////////////////////
module SignExtension(in, out);

    /* A 16-Bit input word */
    input [15:0] in;
    
    /* A 32-Bit output word */
    output reg [31:0] out;
    
    always @(*) begin
        // If the sign bit (bit 15) is 1, fill the top 16 bits with 1s
        if (in[15] == 1'b1) begin
            out[31:16] = 16'b1111_1111_1111_1111;
        end
        // If the sign bit is 0, fill the top 16 bits with 0s
        else begin
            out[31:16] = 16'b0000_0000_0000_0000;
        end

        // The bottom 16 bits are always just the original input
        out[15:0] = in;
    end

endmodule

