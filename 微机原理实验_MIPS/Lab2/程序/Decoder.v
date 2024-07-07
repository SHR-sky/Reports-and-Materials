`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:43:49
// Design Name: 
// Module Name: Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Decoder(
    input [5:0] Op,

    output [1:0] ALUOp,
    output RegDst,
    output RegWr,
    output ALUSrc,
    output MemWr,
    output jump,
    output branch,
    output Mem2Reg,
    output wb
);

    reg [8:0] code;

    assign RegDst = code[8];
    assign ALUSrc = code[7];
    assign Mem2Reg = code[6];
    assign RegWr = code[5];
    assign MemWr = code[4];
    assign branch = code[3];
    assign jump = code[2];
    assign ALUOp = code[1:0];
    
    assign wb = Op[5] & (~Op[4]) & (~Op[3]) & (~Op[2]) & (~Op[1]) & (~Op[0]) ;

    always @(Op) begin
        case(Op)
            6'b00_0010:code = 9'bxxx0_001_xx;
            6'b00_0000:code = 9'b1001_000_10;
            6'b10_0011:code = 9'b0111_000_00;
            6'b10_1011:code = 9'bx1x0_100_00;
            6'b00_0100:code = 9'bx0x0_010_01;
            6'b00_1000:code = 9'b01x1_000_00;
            6'b00_1101:code = 9'b0101_000_10;
            6'b10_0000:code = 9'b0111_000_00;   //lb
            default: code = 9'b0000_000_00;
        endcase
    end
endmodule
