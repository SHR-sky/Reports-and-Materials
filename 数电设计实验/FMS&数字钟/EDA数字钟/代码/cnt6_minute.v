`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:14:42
// Design Name: 
// Module Name: cnt6_minute
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


module cnt6_minute(
    input bit10,
    input CLR_n,
    input isSetting,
    output reg [3:0] six,
    output reg bit6
);

always @(posedge bit10, posedge CLR_n) begin
    if(CLR_n) begin six <= 0; bit6 = 0; end
    else if(six == 4'd5) begin
        six <= 0;
        if(isSetting == 0)
            bit6 <= 1;
    end
    else begin
        six <= six + 1;
        bit6 <= 0;
    end
end
endmodule
