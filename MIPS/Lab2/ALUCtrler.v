`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:47:24
// Design Name: 
// Module Name: ALUCtrler
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


module ALUCtrler(
    input [1:0] ALUOp,
    input [5:0] func,

    output reg [3:0] ALUCtrl
);

    always @(ALUOp, func) begin
        casex ({ALUOp,func})
            8'b00xx_xxxx: ALUCtrl = 4'b0010;    //加(lw,sw)
            8'b01xx_xxxx: ALUCtrl = 4'b0110;    //减(beq)
            8'b10xx_0000: ALUCtrl = 4'b0010;    //加(add)
            8'b10xx_0010: ALUCtrl = 4'b0110;    //减(sub)
            8'b10xx_0100: ALUCtrl = 4'b0000;    //与(and)
            8'b10xx_0101: ALUCtrl = 4'b0001;    //或(or)
            8'b10xx_1010: ALUCtrl = 4'b0111;    //小于设置(slt)
            default: ALUCtrl = 4'b0000;
        endcase
    end
endmodule
