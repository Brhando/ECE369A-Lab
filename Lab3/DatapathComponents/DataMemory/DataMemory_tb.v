`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - DataMemory_tb.v
// Description - Test the 'DataMemory.v' module.
////////////////////////////////////////////////////////////////////////////////

module DataMemory_tb(); 

    reg     [31:0]  Address;
    reg     [31:0]  WriteData;
	reg     [1:0]   MemSize; // 00=word, 01=half, 10=byte
	reg             MemSign; // sign/0-extend
    reg             Clk;
    reg             MemWrite;
    reg             MemRead;

    wire [31:0] ReadData;

    DataMemory u0(
        .Address(Address), 
        .WriteData(WriteData), 
        .Clk(Clk), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
		.ReadData(ReadData),
		.MemSize(MemSize),
		.MemSign(MemSign)
    ); 

	// Addresses (byte addresses). DUT indexes by Address[11:2].
    // word 0 -> 0x0000_0000
    // word 1 -> 0x0000_0004
    // last word (index 1023) -> (1023 << 2) = 0x0000_0FFC
    localparam [31:0] A0     = 32'h0000_0000;
	localparam [31:0] A2     = 32'h0000_0002;
    localparam [31:0] A4     = 32'h0000_0004;
    localparam [31:0] A8     = 32'h0000_0008;
    localparam [31:0] A_LAST = 32'h0000_0FFC; // 000...111111111100
	
	initial begin
		Clk <= 1'b0;
		forever #10 Clk <= ~Clk;
	end
	
	// Synchronous word write at Address (byte address); WriteData sampled on posedge.
    task write_word(input [31:0] byte_addr, input [31:0] data);
    begin
        @(negedge Clk);
        Address   <= byte_addr;
        WriteData <= data;
		MemSize   <= 2'b00;
        MemWrite  <= 1'b1;
        MemRead   <= 1'b0;
        @(posedge Clk); // perform the write
        @(negedge Clk);
        MemWrite  <= 1'b0;
    end
	endtask

	// sync half write (aligned): off[1]==0 -> lower half, off[1]==1 -> upper half
	task write_half(input [31:0] byte_addr, input [15:0] half);
    begin
	    @(negedge Clk);
	    Address   = byte_addr;
		WriteData = {16'h0000, half};  // DUT uses only [15:0]
	    MemSize   = 2'b01;
	    MemWrite  = 1'b1;
	    MemRead   = 1'b0;
		@(posedge Clk); //perform write
	    @(negedge Clk);
	    MemWrite  = 1'b0;
    end
    endtask

	// sync byte write
    task write_byte(input [31:0] byte_addr, input [7:0] b);
    begin
	    @(negedge Clk);
	    Address   = byte_addr;
	    WriteData = {24'h0, b};     // DUT uses only [7:0]
	    MemSize   = 2'b10;
	    MemWrite  = 1'b1;
	    MemRead   = 1'b0;
		@(posedge Clk); //perform write
	    @(negedge Clk);
	    MemWrite  = 1'b0;
    end
    endtask

	// Asynchronous read with expected value (MemRead=1)
    // async read expect (word)
    task read_word_expect(input [31:0] byte_addr, input [31:0] expected);
    begin
	    @(negedge Clk);
	    Address  = byte_addr;
	    MemSize  = 2'b00;
	    MemRead  = 1'b1;
	    MemWrite = 1'b0;
	    #1;
	    if (ReadData !== expected)
	      $display("[%0t] !!!FAIL WORD  @0x%08h got=0x%08h exp=0x%08h",
	                $time, byte_addr, ReadData, expected);
	    else
	      $display("[%0t] PASS WORD  @0x%08h = 0x%08h", $time, byte_addr, ReadData);
    end
    endtask

	// async read expect (half) with sign/zero control
    task read_half_expect(input [31:0] byte_addr, input sign, input [31:0] expected);
    begin
	    @(negedge Clk);
	    Address  = byte_addr;
	    MemSize  = 2'b01;
	    MemSign  = sign;
	    MemRead  = 1'b1;
	    MemWrite = 1'b0;
	    #1;
	    if (ReadData !== expected)
	      $display("[%0t] !!!FAIL HALF  @0x%08h sign=%0d got=0x%08h exp=0x%08h",
	                $time, byte_addr, sign, ReadData, expected);
	    else
	      $display("[%0t] PASS HALF  @0x%08h sign=%0d = 0x%08h",
	                $time, byte_addr, sign, ReadData);
    end
    endtask

	// async read expect (byte) with sign/zero control
    task read_byte_expect(input [31:0] byte_addr, input sign, input [31:0] expected);
    begin
	    @(negedge Clk);
	    Address  = byte_addr;
	    MemSize  = 2'b10;
	    MemSign  = sign;
	    MemRead  = 1'b1;
	    MemWrite = 1'b0;
	    #1;
	    if (ReadData !== expected)
	      $display("[%0t] !!!FAIL BYTE  @0x%08h sign=%0d got=0x%08h exp=0x%08h",
	                $time, byte_addr, sign, ReadData, expected);
	    else
	      $display("[%0t] PASS BYTE  @0x%08h sign=%0d = 0x%08h",
	                $time, byte_addr, sign, ReadData);
    end
    endtask

	//task for expected 0 when memread is 0
	task expect_zero_when_disabled(input [31:0] byte_addr);
    begin
        @(negedge Clk);
        Address <= byte_addr;
        MemWrite <= 1'b0;
        MemRead  <= 1'b0;
        #1; // combinational settle
        if (ReadData !== 32'h0000_0000) begin
			$display("[%0t] !!!FAIL @addr=0x%08h got=0x%08h exp=0x00000000!!!",
                     $time, byte_addr, ReadData);
        end else begin
            $display("[%0t] PASS @addr=0x%08h output zero as expected",
                     $time, byte_addr);
        end
    end
    endtask

	initial begin
        // init inputs
        Address   = 32'h0;
        WriteData = 32'h0;
        MemWrite  = 1'b0;
        MemRead   = 1'b0;
		MemSize   = 2'b00;
        MemSign   = 1'b0;
		
		// Let clock run a couple cycles
        repeat (2) @(posedge Clk);

		//MemRead=0 forces zero regardless of contents
        expect_zero_when_disabled(A0);
        expect_zero_when_disabled(A_LAST);

		//Write some words, then read them back
		write_word(A0,     32'hAABB_CCDD); //10101010101110111100110011011101
		write_word(A4,     32'h2222_2222); //0010001000100010...
		write_word(A8,     32'h3333_3333); //0011001100110011...
		write_word(A_LAST, 32'h4444_4444); //0100010001000100...

		read_word_expect(A0,     32'hAABB_CCDD);
		read_word_expect(A4,     32'h2222_2222);
		read_word_expect(A8,     32'h3333_3333);
		read_word_expect(A_LAST, 32'h4444_4444);

		// BYTE LOADS from 0xAABB_CCDD at A0 
	    // offsets: +0=DD, +1=CC, +2=BB, +3=AA
	    // zero-extend
	    read_byte_expect(A0+0, 1'b0, 32'h0000_00DD);
	    read_byte_expect(A0+1, 1'b0, 32'h0000_00CC);
	    read_byte_expect(A0+2, 1'b0, 32'h0000_00BB);
	    read_byte_expect(A0+3, 1'b0, 32'h0000_00AA);
		
	    // sign-extend (AA, BB have MSB=1 → FFFF_00xx)
	    read_byte_expect(A0+0, 1'b1, 32'hFFFF_FFDD);
        read_byte_expect(A0+1, 1'b1, 32'hFFFF_FFCC);
        read_byte_expect(A0+2, 1'b1, 32'hFFFF_FFBB);
        read_byte_expect(A0+3, 1'b1, 32'hFFFF_FFAA);
	
	    // HALF LOADS from 0xAABB_CCDD at A0 
	    // A0 lower half = CCDD; A0+2 upper half = AABB
	    // zero-extend
	    read_half_expect(A0,   1'b0, 32'h0000_CCDD);
	    read_half_expect(A2,   1'b0, 32'h0000_AABB);
	    // sign-extend (AABB has MSB=1 → FFFF_AABB; CCDD also has MSB=1 → FFFF_CCDD)
	    read_half_expect(A0,   1'b1, 32'hFFFF_CCDD);
	    read_half_expect(A2,   1'b1, 32'hFFFF_AABB);

		// --- BYTE/HALF STORES then verify word ---
	    // byte store at offset +1: replace CC with EE → AABB_EEDD
	    write_byte(A0+1, 8'hEE);
	    read_word_expect(A0, 32'hAABB_EEDD);
	
	    // half store low half with 0x1122 → AABB_1122
	    write_half(A0+0, 16'h1122);
	    read_word_expect(A0, 32'hAABB_1122);
	
	    // half store high half with 0x3344 at A0+2 → 3344_1122
	    write_half(A0+2, 16'h3344);
	    read_word_expect(A0, 32'h3344_1122);
	
	    // MemRead=0 → output zero again
	    expect_zero_when_disabled(A0);

		//Same-cycle write visibility
        //Show that value updates after the posedge where MemWrite is asserted.
        //Write new value to A4 and observe ReadData before/after edge.
        @(negedge Clk);
        Address   <= A4;
        MemRead   <= 1'b1;
        MemWrite  <= 1'b1;
        WriteData <= 32'h3333_3333;
        #1; // before clock edge; should still see the old value
		if (ReadData !== 32'h2222_2222) begin
			$display("[%0t] read-before-write expected old=0x2222_2222 got=0x%08h",
                     $time, ReadData);
        end else begin
            $display("[%0t] PASS pre-edge shows old value (read-before-write)", $time);
        end
        @(posedge Clk); // write happens here
        #1; // after edge, new value should be visible
		if (ReadData !== 32'h3333_3333) begin
			$display("[%0t] !!!FAIL post-edge got=0x%08h exp=0x3333_3333!!!", $time, ReadData);
        end else begin
			$display("[%0t] PASS post-edge shows new value 0x3333_3333", $time);
        end
		@(negedge Clk);
        MemWrite <= 1'b0;

		// MemRead=0 again should force 0 on output
        expect_zero_when_disabled(A4);

		// Done
        #20; //wait a beat
		$finish;

		
	end

endmodule

