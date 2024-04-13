`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:44:56
// Design Name: 
// Module Name: regfile
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


module regfile(
    input clk,
    input rst,
    input RegWr,
    input [31:0] WriteData,
    input [4:0] RsAddr,
    input [4:0] RtAddr,
    input [4:0] WriteAddr,
    
    output [31:0] RsData,
    output [31:0] RtData
);

    reg [31:0] regs[0:31];
    assign RsData = regs[RsAddr];
    assign RtData = regs[RtAddr];
    integer i;

    // Ê±ÖÓÏÂ½µÑØÐ´¼Ä´æÆ÷
    always @(negedge clk or negedge rst) begin
        if (rst && RegWr)
            regs[WriteAddr] = WriteData;
        else if (!rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] = i * 4;
        end
    end
endmodule
