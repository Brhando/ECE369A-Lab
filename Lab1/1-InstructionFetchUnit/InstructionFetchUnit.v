`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Team Members:
// Overall percent effort of each team meber: 
// 
// ECE369A - Computer Architecture
// Laboratory 3 (PostLab)
// Module - InstructionFetchUnit.v
// Description - Fetches the instruction from the instruction memory based on 
//               the program counter (PC) value.
// INPUTS:-
// Reset: 1-Bit input signal. 
// Clk: Input clock signal.
//
// OUTPUTS:-
// Instruction: 32-Bit output instruction from the instruction memory. 
//              Decimal value diplayed 
// PCResult: 32-Bit output PCResult from the program counter. 
//              Decimal value diplayed 
// FUNCTIONALITY:-
// Please connect up the following implemented modules to create this
// 'InstructionFetchUnit':-
//   (a) ProgramCounter.v
//   (b) PCAdder.v
//   (c) InstructionMemory.v
// Connect the modules together in a testbench so that the instruction memory
// outputs the contents of the next instruction indicated by the memory location
// in the PC at every clock cycle. Please initialize the instruction memory with
// some preliminary values for debugging purposes.
//
// @@ The 'Reset' input control signal is connected to the program counter (PC) 
// register which initializes the unit to output the first instruction in 
// instruction memory.
// @@ The 'Instruction' output port holds the output value from the instruction
// memory module.
// @@ The 'Clk' input signal is connected to the program counter (PC) register 
// which generates a continuous clock pulse into the module.
////////////////////////////////////////////////////////////////////////////////

module InstructionFetchUnit(
    input         Reset,
    input         Clk,
    output [15:0] PCResult,      // 16-bit for display
    output [15:0] Instruction    // 16-bit for display
);
    // Internal 32-bit datapath signals
    wire [31:0] pc;        // current PC
    wire [31:0] pc_next;   // PC + 4
    wire [31:0] instr;     // 32-bit instruction from ROM

    // PC register: loads pc_next on each rising edge (reset -> 0)
    ProgramCounter u_pc (
        .Address  (pc_next),
        .Reset    (Reset),
        .Clk      (Clk),
        .PCResult (pc)
    );

    // PC + 4 adder
    PCAdder u_adder (
        .PCResult    (pc),
        .PCAddResult (pc_next)
    );

    // Instruction ROM, byte-addressed; uses full 32-bit PC as address
    InstructionMemory u_imem (
        .Address     (pc),
        .Instruction (instr)
    );

    // Drop upper 16 bits for the 7-seg display
    assign PCResult    = pc[15:0];
    assign Instruction = instr[15:0];
    
endmodule

