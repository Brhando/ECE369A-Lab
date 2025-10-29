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

integer i;

    // 1K x 32-bit ROM
    reg [31:0] rom [0:1023];
//    initial begin
//    // Hardcode a simple test program
//    rom[0]  = 32'h20080005;  // addi $t0, $zero, 5
//    rom[1]  = 32'h00000000;  // nop
//    rom[2]  = 32'h00000000;  // nop  
//    rom[3]  = 32'h00000000;  // nop
//    rom[4]  = 32'h00000000;  // nop
//    rom[5]  = 32'h00000000;  // nop
//    rom[6]  = 32'h2009000A;  // addi $t1, $zero, 10
//    rom[7]  = 32'h00000000;  // nop
//    rom[8]  = 32'h00000000;  // nop
//    rom[9]  = 32'h00000000;  // nop
//    rom[10] = 32'h00000000;  // nop
//    rom[11] = 32'h00000000;  // nop
//    rom[12] = 32'h01095020;  // add $t2, $t0, $t1  (result = 15)
    
//    // Fill rest with NOPs
//    for (i = 13; i < 1024; i = i + 1)
//        rom[i] = 32'h00000000;
    
//    $display("Instruction memory hardcoded for testing");
//end
    // Drop byte index [1:0]; we only address words
    wire [9:0] widx = Address[11:2];

    // Initialize ROM
    
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
