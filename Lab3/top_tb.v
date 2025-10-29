`timescale 1ns / 1ps

module top_tb();
    // Clock and reset
    reg clk;
    reg rst;
    
    // Outputs from DUT
    wire [31:0] PC_out;
    wire [31:0] Data_out;
    
    // Instantiate the Device Under Test (DUT)
    top DUT(
        .clk(clk),
        .rst(rst),
        .PC_out(PC_out),
        .Data_out(Data_out)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    integer cycle_count;
    integer i;
    
    initial begin
        $display("========================================");
        $display("Starting MIPS Pipeline Simulation");
        $display("========================================");
        
        // Initialize signals
        rst = 1;
        cycle_count = 0;
        
        // Hold reset for 2 clock cycles
        #15;
        rst = 0;
        $display("Reset released at time %0t", $time);
        $display("");
        
        // Monitor PC and WriteData for 100 clock cycles
        $display("Cycle | Time (ns) | PC (hex) | PC (dec) | WriteData (hex) | WriteData (dec)");
        $display("------|-----------|----------|----------|-----------------|----------------");
        
        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            
            // Display every clock cycle
            $display("%5d | %9d | %8h | %8d | %15h | %14d", 
                     cycle_count, $time, PC_out, PC_out, Data_out, Data_out);
            
            // Check for specific milestones
            if (PC_out == 32'h00000000 && cycle_count > 5) begin
                $display("\n*** WARNING: PC stuck at 0 after %0d cycles! ***\n", cycle_count);
            end
            
            // Stop if we reach the infinite loop at end
            if (PC_out == 32'h000001e0) begin // PC=480 (end loop)
                $display("\n========================================");
                $display("Reached end of program at cycle %0d", cycle_count);
                $display("========================================");
                #50;
                $finish;
            end
        end
        
        $display("\n========================================");
        $display("Simulation completed after %0d cycles", cycle_count);
        $display("========================================");
        $finish;
    end
    
    // Additional monitoring for debugging
    initial begin
        $monitor("Time=%0t | PC=%h | Data_out=%h", $time, PC_out, Data_out);
    end
    
    // Timeout watchdog
    initial begin
        #10000; // 10 microseconds timeout
        $display("\n========================================");
        $display("ERROR: Simulation timeout!");
        $display("========================================");
        $finish;
    end

endmodule