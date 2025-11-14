// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// ForwardingUnit.v
// Handles EX and MEM forwarding for ALU operands

module ForwardingUnit(
    input        RegWrite_MEM,
    input  [4:0] DestReg_MEM,
    input        RegWrite_WB,
    input  [4:0] DestReg_WB,
    input  [4:0] rs_EX,
    input  [4:0] rt_EX,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @* begin
        // defaults: no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // EX hazard (from MEM stage)
        if (RegWrite_MEM && (DestReg_MEM != 5'd0) && (DestReg_MEM == rs_EX))
            ForwardA = 2'b10;

        if (RegWrite_MEM && (DestReg_MEM != 5'd0) && (DestReg_MEM == rt_EX))
            ForwardB = 2'b10;

        // MEM hazard (from WB stage) – only if MEM stage didn't already forward
        if (RegWrite_WB && (DestReg_WB != 5'd0) &&
            !(RegWrite_MEM && (DestReg_MEM != 5'd0) && (DestReg_MEM == rs_EX)) &&
             (DestReg_WB == rs_EX))
            ForwardA = 2'b01;

        if (RegWrite_WB && (DestReg_WB != 5'd0) &&
            !(RegWrite_MEM && (DestReg_MEM != 5'd0) && (DestReg_MEM == rt_EX)) &&
             (DestReg_WB == rt_EX))
            ForwardB = 2'b01;
    end
endmodule

