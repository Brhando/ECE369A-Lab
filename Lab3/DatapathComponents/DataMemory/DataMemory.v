`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - data_memory.v
// Description - 32-Bit wide data memory.
//
// INPUTS:-
// Address: 32-Bit address input port.
// WriteData: 32-Bit input port.
// Clk: 1-Bit Input clock signal.
// MemWrite: 1-Bit control signal for memory write.
// MemRead: 1-Bit control signal for memory read.
//
// OUTPUTS:-
// ReadData: 32-Bit registered output port.
//
// FUNCTIONALITY:-
// Design the above memory similar to the 'RegisterFile' model in the previous 
// assignment.  Create a 1K memory, for which we need 10 bits.  In order to 
// implement byte addressing, we will use bits Address[11:2] to index the 
// memory location. The 'WriteData' value is written into the address 
// corresponding to Address[11:2] in the positive clock edge if 'MemWrite' 
// signal is 1. 'ReadData' is the value of memory location Address[11:2] if 
// 'MemRead' is 1, otherwise, it is 0x00000000. The reading of memory is not 
// clocked.
//
// you need to declare a 2d array. in this case we need an array of 1024 (1K)  
// 32-bit elements for the memory.   
// for example,  to declare an array of 256 32-bit elements, declaration is: reg[31:0] memory[0:255]
// if i continue with the same declaration, we need 8 bits to index to one of 256 elements. 
// however , address port for the data memory is 32 bits. from those 32 bits, least significant 2 
// bits help us index to one of the 4 bytes within a single word. therefore we only need bits [9-2] 
// of the "Address" input to index any of the 256 words. 
////////////////////////////////////////////////////////////////////////////////

module DataMemory(Address, WriteData, Clk, MemWrite, MemRead, MemSize, MemSign, ReadData); 

    input [31:0] Address; 	// Input Address 
    input [31:0] WriteData; // Data that needs to be written into the address 
    input Clk;
    input MemWrite; 		// Control signal for memory write 
    input MemRead; 			// Control signal for memory read 
    input [1:0] MemSize;    //control signal for byte and half support
    input MemSign; //neg/pos
    
    // 1K x 32-bit memory array
    reg [31:0] mem [0:1023];
    
    integer i;
    initial begin
    // Initialize all memory locations to 0
    for (i = 0; i < 1024; i = i + 1)
        mem[i] = 32'h0000_0000;
    
    // Load initial data values from file
    $readmemh("data_memory.mem", mem);
end

    // Word address index (drop the low 2 bits for byte addressing)
    wire [9:0] word_addr = Address[11:2];
    
    output reg[31:0] ReadData; // Contents of memory location at Address

    // Combinational READ with byte/half support
    // MemSize: 00=word, 01=half, 10=byte
    // MemSign: 1=signed extend (lb/lh), 0=zero extend (lbu/lhu if you add later)
    wire [31:0] word_read = mem[word_addr];
    wire [1:0]  off    = Address[1:0];
    // aligned halves: off[1]==0 -> lower half, off[1]==1 -> upper half
    reg [15:0] half;
    reg [7:0] b; //holds the byte info
    reg [31:0] oldword, newword; // for writes
    
    always @* begin
        // defaults to avoid latch warnings
        half = 16'h0000;
        b    = 8'h00;
        if (!MemRead) begin
            ReadData = 32'h0000_0000;
        end else begin
            case (MemSize)
                2'b00: begin // word
                    ReadData = word_read;
                end
                2'b01: begin // half
                    half = off[1] ? word_read[31:16] : word_read[15:0];
                    ReadData = MemSign ? {{16{half[15]}}, half} : {16'b0, half}; // if true sign extend the first (16th) bit, otherwise 0 extend
                end
                2'b10: begin // byte
                    case (off)
                        2'b00: b = word_read[7:0];
                        2'b01: b = word_read[15:8];
                        2'b10: b = word_read[23:16];
                        2'b11: b = word_read[31:24];
                    endcase
                    ReadData = MemSign ? {{24{b[7]}}, b} : {24'b0, b}; //same as above; if true sign extend, otherwise 0 extend
                end
                default: ReadData = 32'h0000_0000;
            endcase
        end
    end

    // Sequential WRITE with mask/merge for byte/half
    always @(posedge Clk) begin
        if (MemWrite) begin
            oldword = mem[word_addr]; // read-modify-write
            case (MemSize)
                2'b00: begin // word
                    newword = WriteData;
                end
                2'b01: begin // half
                    // aligned halves: use off[1] to choose upper/lower
                    if (off[1] == 1'b0) begin
                        // write lower half
                        newword = {oldword[31:16], WriteData[15:0]};
                    end else begin
                        // write upper half
                        newword = {WriteData[15:0], oldword[15:0]};
                    end
                end
                2'b10: begin // byte
                    case (off)
                        2'b00: newword = {oldword[31:8],  WriteData[7:0]};
                        2'b01: newword = {oldword[31:16], WriteData[7:0], oldword[7:0]};
                        2'b10: newword = {oldword[31:24], WriteData[7:0], oldword[15:0]};
                        2'b11: newword = {WriteData[7:0], oldword[23:0]};
                    endcase
                end
                default: newword = oldword; // no change
            endcase
            mem[word_addr] <= newword;
        end
    end

endmodule
