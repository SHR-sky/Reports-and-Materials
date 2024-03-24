`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:16:04
// Design Name: 
// Module Name: cnt_hour
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


module cnt_hour(
    input bit6_minute,
    input CLR_n,
    input showMode,
    input isSetting,
    input hour_setting,
    output reg [3:0] hour_ten,
    output reg [3:0] hour_one
);

wire clk;
assign clk = bit6_minute | (hour_setting & isSetting);

always @(posedge clk, posedge CLR_n) begin
    if(CLR_n) begin hour_ten <= 0; hour_one <= 0; end
    else begin
        if(showMode == 0) begin
            if(hour_one == 4'd9) begin hour_one <= 0; hour_ten <= hour_ten + 1; end
            else if (hour_one == 4'd3 && hour_ten == 4'd2) begin hour_one <= 0; hour_ten <= 0; end
            else hour_one <= hour_one + 1;
        end
        else if(showMode == 1) begin
            if(hour_one == 4'd9) begin hour_one <= 0; hour_ten <= hour_ten + 1; end
            else if (hour_one == 4'd2 && hour_ten == 4'd1) begin hour_one <= 1; hour_ten <= 0; end
            else hour_one <= hour_one + 1;
        end
    end
end
endmodule
