// Brandon Sisco, Gavin Hernandez, Griffith Wiele
// 33%, 33%, 33%
// NextPC.v
module ForwardingUnit(
    input        RegWrite_MEM,
    input  [4:0] DestReg_MEM,
    input        RegWrite_WB,
    input  [4:0] DestReg_WB,
    input  [4:0] rs_EX,
    input  [4:0] rt_EX,
    output reg [1:0] ForwardA,     // 00: ID/EX, 10: EX/MEM, 01: MEM/WB
    output reg [1:0] ForwardB,     // for ALU B when it uses a register
    output reg [1:0] ForwardStore  // for store data path (rt value)
);
    always @* begin
        // defaults
        ForwardA     = 2'b00;
        ForwardB     = 2'b00;
        ForwardStore = 2'b00;

        // A: rs_EX
        if (RegWrite_MEM && DestReg_MEM != 5'd0 && DestReg_MEM == rs_EX)
            ForwardA = 2'b10;
        else if (RegWrite_WB && DestReg_WB != 5'd0 && DestReg_WB == rs_EX)
            ForwardA = 2'b01;

        // B: rt_EX (when ALU uses a register on B)
        if (RegWrite_MEM && DestReg_MEM != 5'd0 && DestReg_MEM == rt_EX)
            ForwardB = 2'b10;
        else if (RegWrite_WB && DestReg_WB != 5'd0 && DestReg_WB == rt_EX)
            ForwardB = 2'b01;

        // Store data uses the rt value as well
        if (RegWrite_MEM && DestReg_MEM != 5'd0 && DestReg_MEM == rt_EX)
            ForwardStore = 2'b10;
        else if (RegWrite_WB && DestReg_WB != 5'd0 && DestReg_WB == rt_EX)
            ForwardStore = 2'b01;
    end
endmodule

