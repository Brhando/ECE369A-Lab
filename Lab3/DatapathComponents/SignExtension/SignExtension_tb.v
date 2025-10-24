`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// Module - SignExtension_tb.v
// Description - Test the sign extension module.
////////////////////////////////////////////////////////////////////////////////

module SignExtension_tb();

    reg	[15:0] in;
	reg ExtOp;
    wire [31:0]	out;

    SignExtension u0(
		.in(in), .ExtOp(ExtOp), .out(out)
    );
        
    initial begin
		// set initial ExtOp value to 1 and check sign extension
		ExtOp <= 1'b1;
		#100 in <= 16'h0004;// should get 32'h0000_0004
		#20 $display("ext=%h, in=%h, out=%h", ExtOp, in, out);

		#100 in <= 16'h7000;// should get 32'h0000_7000
		#20 $display("ext=%h, in=%h, out=%h", ExtOp, in, out);

		#100 in <= 16'h9000; //should get 32'hFFFF_9000
		#20 $display("ext=%h, in=%h, out=%h", ExtOp, in, out);
			
		#100 in <= 16'hF000; //should get 32'hFFFF_F000
		#20 $display("ext=%h, in=%h, out=%h", ExtOp, in, out);

		// set ExtOp to 0 and check sign extension
		#20 ExtOp <= 1'b0;
		#100 in <= 16'hF000; //should get 32'h0000_F000
		#20 $display("ext=%h, in=%h, out=%h", ExtOp, in, out);

		#100 in <= 16'h8800; //should get 32'h0000_8800
		#20 $display("ext=%h, in=%h, out=%h", ExtOp, in, out);

		#100 in <= 16'h0002;//should get 32'h0000_0002
		#20 $display("ext=%h, in=%h, out=%h", ExtOp, in, out); //should get 000...0000000000000010 

	 end

endmodule
