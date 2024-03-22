`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/21 21:31:26
// Design Name: 
// Module Name: alarm_bing
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


module alarm_bing(
    input [3:0] alarm_minute_setting_ones,
    input [3:0] alarm_minute_setting_tens,
    input [3:0] alarm_hour_setting_ones,
    input [3:0] alarm_hour_setting_tens,

    input one_HZ,

    input [3:0] second_six,
    input [3:0] second_ten,
    input [3:0] minute_six,
    input [3:0] minute_ten,
    input [3:0] hour_one,
    input [3:0] hour_ten,

    output reg bing
);

always @(posedge one_HZ) begin
    if({alarm_hour_setting_tens, alarm_hour_setting_ones, alarm_minute_setting_tens, alarm_minute_setting_ones} == {hour_ten, hour_one, minute_ten, minute_six} && second_six == 0 && second_ten == 0)
    begin
        bing <= 1;
    end
    else bing <= 0;
end

endmodule
