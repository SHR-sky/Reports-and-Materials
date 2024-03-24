`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:18:58
// Design Name: 
// Module Name: display
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


module display(
    input five_hundred_HZ,
    input showMode, //0为24小时制，1为12小时制
    input isSettingAlarm,
    input [3:0] alarm_minute_setting_ones,
    input [3:0] alarm_minute_setting_tens,
    input [3:0] alarm_hour_setting_ones,
    input [3:0] alarm_hour_setting_tens,
    input [3:0] second_ten,
    input [3:0] second_six,
    input [3:0] minute_ten,
    input [3:0] minute_six,
    input [3:0] hour_ten,
    input [3:0] hour_one,
    output reg [7:0] tubePos,
    output reg [3:0] showCode
    );

    integer k = 0;

    always @(posedge five_hundred_HZ) begin
        case(k)
            0:
//              A代表12小时制，P代表24小制
                begin
                    tubePos <= 8'b1111_1110;
                    //设闹钟时，不显示
                    if (isSettingAlarm) showCode <= 4'hd;
                    //显示时间进制
                    else if (showMode == 0) begin showCode <= 4'hb; end
                    else if (showMode == 1) begin showCode <= 4'ha; end
                    k <= k + 1;
                end
            1:
//              当设时钟时，显示C
                begin
                    tubePos <= 8'b1111_1101;
                    if(isSettingAlarm)
                        showCode <= 4'hc;
                    else showCode <= 4'hd;
                    k <= k + 1;
                end
            2:
//              显示秒的个位，设闹钟时，不显示
                begin
                    tubePos <= 8'b1111_1011;
                    if (isSettingAlarm) showCode <= 4'hd;
                    else begin
                        showCode <= second_ten;
                    end
                    k <= k + 1;
                end
            3:
//              显示秒的十位，设闹钟时，不显示
                begin
                    tubePos <= 8'b1111_0111;
                    if (isSettingAlarm) showCode <= 4'hd;
                    else begin
                        showCode <= second_six;
                    end
                    k <= k + 1;
                end
            4:
//              显示分的个位
                begin
                    tubePos <= 8'b1110_1111;
                    if (isSettingAlarm) showCode <= alarm_minute_setting_ones;
                    else showCode <= minute_ten;
                    k <= k + 1;
                end
            5:
//              显示分的十位
                begin
                    tubePos <= 8'b1101_1111;
                    if (isSettingAlarm) showCode <= alarm_minute_setting_tens;
                    else showCode <= minute_six;
                    k <= k + 1;
                end
            6:
//              显示时的个位
                begin
                    tubePos <= 8'b1011_1111;
                    if (isSettingAlarm) showCode <= alarm_hour_setting_ones;
                    else showCode <= hour_one;
                    k <= k + 1;
                end
            7:
//              显示时的十位
                begin
                    tubePos <= 8'b0111_1111;
                    if (isSettingAlarm) showCode <= alarm_hour_setting_tens;
                    else showCode <= hour_ten;
                    k <= k + 1;
                end
            8: 
//              归零，下一轮循环
                k <= 0;
            endcase
        end
endmodule
