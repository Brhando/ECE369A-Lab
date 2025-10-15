`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - RegisterFile.v
// Description - Test the register_file
// Suggested test case - First write arbitrary values into 
// the saved and temporary registers (i.e., register 8 through 25). Then, 2-by-2, 
// read values from these registers.
////////////////////////////////////////////////////////////////////////////////


module RegisterFile_tb();

	reg [4:0] ReadRegister1;
	reg [4:0] ReadRegister2;
	reg	[4:0] WriteRegister;
	reg [31:0] WriteData;
	reg RegWrite;
	reg Clk;

	wire [31:0] ReadData1;
	wire [31:0] ReadData2;


	RegisterFile u0(
		.ReadRegister1(ReadRegister1), 
		.ReadRegister2(ReadRegister2), 
		.WriteRegister(WriteRegister), 
		.WriteData(WriteData), 
		.RegWrite(RegWrite), 
		.Clk(Clk), 
		.ReadData1(ReadData1), 
		.ReadData2(ReadData2)
	);

	
    // 20 ns period clock
    initial begin
        Clk = 1'b0;
        forever #10 Clk = ~Clk;
    end

	// Simple task to perform a write on the rising edge (posedge of clk)
    task write_reg;
        input [4:0]  addr;
        input [31:0] data;
	    begin
	        @(negedge Clk);               // set up during the low phase
	        RegWrite      = 1'b1;
	        WriteRegister = addr;
	        WriteData     = data;
	        @(posedge Clk);               // commit here (posedge write)
	        #1;
	        RegWrite      = 1'b0;
        end
    endtask

    // Task to set read addresses and print results
    task read_pair;
	    input [4:0] r1;
	    input [4:0] r2;
	    begin
	        @(posedge Clk);               // present addresses first half
	        ReadRegister1 = r1;
	        ReadRegister2 = r2;
	        @(negedge Clk);               // read data becomes valid here
	        #1;
	        $display("[%0t] Read r%0d=0x%08h | r%0d=0x%08h",
	                 $time, r1, ReadData1, r2, ReadData2);
	    end
    endtask

    integer i;
    initial begin
        // Defaults
        ReadRegister1 = 5'd0;
        ReadRegister2 = 5'd0;
        WriteRegister = 5'd0;
        WriteData     = 32'd0;
        RegWrite      = 1'b0;

        // Wait a tad for DUT init
        @(posedge Clk);

        // 1) Verify $zero ignores writes
		write_reg(5'd0, 32'hAAAAAAAA); // should be ignored
        read_pair(5'd0, 5'd0);         // expect both 0

        // 2) Write registers 8..25 with a recognizable pattern
        for (i = 8; i <= 25; i = i + 1) begin
            write_reg(i[4:0], {24'h0, i[7:0]} + 32'h1000_0000); // 0x1000_00ii
        end

        // 3) Read back 2-by-2 (8&9, 10&11, ..., 24&25)
        for (i = 8; i <= 24; i = i + 2) begin
            read_pair(i[4:0], (i+1)[4:0]);
        end

        // 4) Same-cycle write & read behavior check:
        //    After a write at posedge, a read in the *next* half-cycle should see the data.
        write_reg(5'd5, 32'hA5A5_5A5A);
        read_pair(5'd5, 5'd0); // expect A5A55A5A and 0

        // 5) Overwrite a register and re-read
		write_reg(5'd9, 32'hBBBBBBBB);
        read_pair(5'd9, 5'd10);

        $display("Testbench completed at t=%0t", $time);
        #10;
        $finish;
    end

endmodule
