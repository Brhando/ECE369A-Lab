// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// HazardDetectionUnit.v
// Detects load-use hazard between ID and EX

module HazardDetectionUnit(
    input        MemRead_EX,   // lw in EX stage
    input  [4:0] rt_EX,        // destination of lw (rt)
    input  [4:0] ID_rs,        // rs field of instruction in ID
    input  [4:0] ID_rt,        // rt field of instruction in ID
    output reg   PCWrite,      // 0 = stall PC
    output reg   IF_ID_Write,  // 0 = stall IF/ID
    output reg   ID_EX_Flush   // 1 = insert bubble into EX
);
    always @* begin
        // default: no stall
        PCWrite     = 1'b1;
        IF_ID_Write = 1'b1;
        ID_EX_Flush = 1'b0;

        // load-use hazard:
        // lw in EX, and ID uses that register as a source
        if (MemRead_EX && (rt_EX != 5'd0) &&
           ((rt_EX == ID_rs) || (rt_EX == ID_rt))) begin
            PCWrite     = 1'b0; // freeze PC
            IF_ID_Write = 1'b0; // freeze IF/ID
            ID_EX_Flush = 1'b1; // bubble into EX
        end
    end
endmodule

