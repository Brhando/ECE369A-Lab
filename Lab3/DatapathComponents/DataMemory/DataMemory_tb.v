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
        .ReadData(ReadData)
    ); 

	// Addresses (byte addresses). DUT indexes by Address[11:2].
    // word 0 -> 0x0000_0000
    // word 1 -> 0x0000_0004
    // last word (index 1023) -> (1023 << 2) = 0x0000_0FFC
    localparam [31:0] A0     = 32'h0000_0000;
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
        MemWrite  <= 1'b1;
        MemRead   <= 1'b0;
        @(posedge Clk); // perform the write
        @(negedge Clk);
        MemWrite  <= 1'b0;
    end
	endtask

	// Asynchronous read with expected value (MemRead=1)
    task read_expect(input [31:0] byte_addr, input [31:0] expected);
    begin
        @(negedge Clk);
        Address <= byte_addr;
        MemWrite <= 1'b0;
        MemRead  <= 1'b1;
        #1; // allow combinational settle
        if (ReadData !== expected) begin
			$display("[%0t] !!!FAILED @addr=0x%08h got=0x%08h exp=0x%08h!!!",
                     $time, byte_addr, ReadData, expected);
        end else begin
            $display("[%0t] PASS @addr=0x%08h = 0x%08h",
                     $time, byte_addr, ReadData);
        end
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

		// Let clock run a couple cycles
        repeat (2) @(posedge Clk);

		//MemRead=0 forces zero regardless of contents
        expect_zero_when_disabled(A0);
        expect_zero_when_disabled(A_LAST);

		//Write some words, then read them back
		write_word(A0,     32'h1111_1111); //0001000100010001...
		write_word(A4,     32'h2222_2222); //0010001000100010...
		write_word(A8,     32'h3333_3333); //0011001100110011...
		write_word(A_LAST, 32'h4444_4444); //0100010001000100...

		read_expect(A0,     32'h1111_1111);
		read_expect(A4,     32'h2222_2222);
		read_expect(A8,     32'h3333_3333);
		read_expect(A_LAST, 32'h4444_4444);

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

