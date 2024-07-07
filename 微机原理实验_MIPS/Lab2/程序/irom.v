`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/24 15:19:32
// Design Name: 
// Module Name: irom
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


`timescale 1ns / 1ps

module irom(
    input clk,
    input [4:0] addr,
    output reg [31:0] instr
    );
    reg [31:0] regs[0:31];
   always@(posedge clk)
   instr = regs [addr];
    
    initial
    $readmemh("E:/task.txt",regs,0,12); //expand
endmodule
