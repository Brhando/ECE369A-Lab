`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 
// Module - InstructionMemory_tb.v
// Description - Test the 'InstructionMemory_tb.v' module.
////////////////////////////////////////////////////////////////////////////////

module InstructionMemory_tb(); 

    wire [31:0] Instruction;

    reg [31:0] Address;

	InstructionMemory u0(
		.Address(Address),
        .Instruction(Instruction)
	);

	//define a task to test Address and Instruction at multiple values
	task check(input [31:0] address_bytes);
		begin
			Address = adress_bytes; #1; //wait a cycle
			$display("Address = %0d Index = %0d Instruction = %0d", Address, Address[8:2], Instruction);
		end
	endtask
	
	initial begin

		//utilize the task to check Instruction at multiple values of Address; Address is byte index, so we use multiples of 4
		check(32'd0); //index 0 - 3
		check(32'd4); //index 4 - 7
		check(32'd8);
		check(32'd12);
		check(32'd16);
		check(32'd20);
		check(32'd40);
		
	end

endmodule

