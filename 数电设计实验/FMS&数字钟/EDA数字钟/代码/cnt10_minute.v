`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:13:48
// Design Name: 
// Module Name: cnt10_minute
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


module cnt10_minute (
    input bit6,
    input CLR_n,
    input isSetting,
    input minute_setting,
    output reg [3:0] ten,
    output reg bit10
);

wire clk;
assign clk =bit6 | (minute_setting & isSetting);

always @(posedge clk, posedge CLR_n) begin
    if (CLR_n) begin bit10 <= 0; ten <= 0; end
    else if(ten == 4'd9) begin
        ten <= 0;
        bit10 <= 1;
    end
    else begin
        ten <= ten +1;
        bit10 <= 0; 
    end
end

endmodule

