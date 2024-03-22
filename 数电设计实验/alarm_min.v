`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/22 01:13:22
// Design Name: 
// Module Name: alarm_min
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


module alarm_min(
    input CLR_n,
    input isSettingAlarm,
    input minute_setting,

    output reg [3:0] alarm_minute_setting_ones,
    output reg [3:0] alarm_minute_setting_tens
    );

wire clk = isSettingAlarm & minute_setting;
    always @(posedge clk, posedge CLR_n) begin
    if(CLR_n) begin
        alarm_minute_setting_ones <= 0;
        alarm_minute_setting_tens <= 0;
    end
    else if(alarm_minute_setting_ones == 4'd9) begin
        alarm_minute_setting_ones <= 0;
        if(alarm_minute_setting_tens == 4'd5) begin
            alarm_minute_setting_tens <= 0;
        end
        else begin
            alarm_minute_setting_tens <= alarm_minute_setting_tens + 1;
        end
    end
    else alarm_minute_setting_ones <= alarm_minute_setting_ones + 1; 
end

endmodule
