`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:49:11
// Design Name: 
// Module Name: ALU
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


module ALU (
    input signed [31:0] inputA,
    input signed [31:0] inputB,
    input [3:0] ALUCtrl,

    output reg signed [31:0] ALUResult,
    output reg zero //零标志位，标志运算结果为0
);
    
    always @(inputA, inputB, ALUCtrl) begin
        case (ALUCtrl)
            4'b0110:    //减法
                begin
                    ALUResult = inputA - inputB;
                    zero = (ALUResult == 0)? 1 : 0;
                end
            4'b0010:    //加法
                begin
                    ALUResult = inputA + inputB;
                    zero = 0;
                end
            4'b0000:    //与运算
                begin
                    ALUResult = inputA & inputB;
                    zero = 0;
                end
            4'b0001:    //或运算
                begin
                    ALUResult = inputA | inputB;
                    zero = 0;
                end
            4'b0111:    //判断大小 slt
                begin
                    ALUResult = (inputA < inputB)? 1 : 0;
                    zero = 0;
                end
            default:
                begin
                    ALUResult = 0;
                    zero = 0;
                end 
        endcase
    end
endmodule
