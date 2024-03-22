`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:19:54
// Design Name: 
// Module Name: numberDecoder
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


module numberDecoder(
    input [3:0] showCode,
    output reg [6:0] code
    );
    always @(showCode)
        begin
            case(showCode)
                4'd0: code <= 7'b100_0000;
                4'd1: code <= 7'b111_1001;
                4'd2: code <= 7'b010_0100;
                4'd3: code <= 7'b011_0000;
                4'd4: code <= 7'b001_1001;
                4'd5: code <= 7'b001_0010;
                4'd6: code <= 7'b000_0010;
                4'd7: code <= 7'b111_1000;
                4'd8: code <= 7'b000_0000;
                4'd9: code <= 7'b001_0000;
                
                4'ha: code <= 7'b000_1000;//ÏÔÊ¾ A
                4'hb: code <= 7'b000_1100;//ÏÔÊ¾ P
                4'hc: code <= 7'b100_0110;//ÏÔÊ¾ C
                default: code <= 7'b111_1111;
             endcase
        end
endmodule
