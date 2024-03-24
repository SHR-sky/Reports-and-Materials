`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:17:08
// Design Name: 
// Module Name: alarm
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

module alarm (
    input CLR_n,
    input isSettingAlarm,
    input hour_setting,

    output reg [3:0] alarm_hour_setting_ones,
    output reg [3:0] alarm_hour_setting_tens
);

wire clk = isSettingAlarm & hour_setting;

always @(posedge clk, posedge CLR_n) begin
    if(CLR_n) begin
        alarm_hour_setting_ones <= 0;
        alarm_hour_setting_tens <= 0;
    end
    else if(alarm_hour_setting_ones == 4'd9) begin
        alarm_hour_setting_ones <= 0;
        alarm_hour_setting_tens <= alarm_hour_setting_tens + 1;
    end
    else if (alarm_hour_setting_ones == 4'd3 && alarm_hour_setting_tens == 4'd2) begin
        alarm_hour_setting_ones <= 0;
        alarm_hour_setting_tens <= 0;
    end
    else alarm_hour_setting_ones <= alarm_hour_setting_ones + 1;
end


endmodule