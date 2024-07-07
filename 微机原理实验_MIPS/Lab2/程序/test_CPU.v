`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/07 21:09:55
// Design Name: 
// Module Name: test_CPU
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


module test_CPU();

reg clk;
reg rst;

CPU t1(
    .clk(clk),
    .rst(rst)
);

initial begin

clk = 0;
rst = 1;
#0.1
rst = 0;
#0.1
rst = 1;
#100
$stop;
end


always begin

#1 clk = ~clk;

end

endmodule
