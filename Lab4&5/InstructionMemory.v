`timescale 1ns / 1ps
// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// ECE369A - InstructionMemory
// 32-bit word ROM, byte-addressed input, combinational read.
// Depth = 1024 words; index = Address[11:2].

module InstructionMemory(
    input  wire [31:0] Address,     // byte address (PC)
    output wire [31:0] Instruction
);
    // 1K x 32-bit ROM
    reg [31:0] rom [0:1023];
    
    // Drop byte index [1:0]; we only address words
    wire [9:0] widx = Address[11:2];

    // Initialize ROM
    integer i;
    initial begin
        // Fill with zeros first
        for (i = 0; i < 1024; i = i + 1)
            rom[i] = 32'h0000_0000;

        // Load program from HEX file (must be in simulation directory)
        $readmemh("instruction_memory.mem", rom);
    end

    // Combinational read output
    assign Instruction = rom[widx];

endmodule
