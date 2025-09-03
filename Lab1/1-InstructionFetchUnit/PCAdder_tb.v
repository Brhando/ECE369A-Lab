`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 1 
// Module - PCAdder_tb.v
// Description - Test the 'PCAdder.v' module.
////////////////////////////////////////////////////////////////////////////////

module PCAdder_tb();

    reg [31:0] PCResult;

    wire [31:0] PCAddResult;

	integer i; //declare i here; used in the for loop below

    PCAdder u0(
        .PCResult(PCResult), 
        .PCAddResult(PCAddResult)
    );
	
	initial begin
	
		PCResult = 32'd0; // set initially to 0
		
		for(i = 0; i < 10; i = i + 1) begin //walk through 10 values (0, 4, 8, etc.)
			//#0 is enough => 1 delta cycle, and the chip is purely combinational
			#0 $display("PC = %0d PC+4 = %0d", PCResult, PCAddResult); //set pcresult to 0 => should add 4 (PCAddResult should = 4) $display shows result
			PCResult = PCResult + 32'd4; //increment by 4
		end
		$finish;
		
	end

endmodule

