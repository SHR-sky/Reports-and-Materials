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
    input showMode, //0Ϊ24Сʱ�ƣ�1Ϊ12Сʱ��
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
//              A����12Сʱ�ƣ�P����24С��
                begin
                    tubePos <= 8'b1111_1110;
                    //������ʱ������ʾ
                    if (isSettingAlarm) showCode <= 4'hd;
                    //��ʾʱ�����
                    else if (showMode == 0) begin showCode <= 4'hb; end
                    else if (showMode == 1) begin showCode <= 4'ha; end
                    k <= k + 1;
                end
            1:
//              ����ʱ��ʱ����ʾC
                begin
                    tubePos <= 8'b1111_1101;
                    if(isSettingAlarm)
                        showCode <= 4'hc;
                    else showCode <= 4'hd;
                    k <= k + 1;
                end
            2:
//              ��ʾ��ĸ�λ��������ʱ������ʾ
                begin
                    tubePos <= 8'b1111_1011;
                    if (isSettingAlarm) showCode <= 4'hd;
                    else begin
                        showCode <= second_ten;
                    end
                    k <= k + 1;
                end
            3:
//              ��ʾ���ʮλ��������ʱ������ʾ
                begin
                    tubePos <= 8'b1111_0111;
                    if (isSettingAlarm) showCode <= 4'hd;
                    else begin
                        showCode <= second_six;
                    end
                    k <= k + 1;
                end
            4:
//              ��ʾ�ֵĸ�λ
                begin
                    tubePos <= 8'b1110_1111;
                    if (isSettingAlarm) showCode <= alarm_minute_setting_ones;
                    else showCode <= minute_ten;
                    k <= k + 1;
                end
            5:
//              ��ʾ�ֵ�ʮλ
                begin
                    tubePos <= 8'b1101_1111;
                    if (isSettingAlarm) showCode <= alarm_minute_setting_tens;
                    else showCode <= minute_six;
                    k <= k + 1;
                end
            6:
//              ��ʾʱ�ĸ�λ
                begin
                    tubePos <= 8'b1011_1111;
                    if (isSettingAlarm) showCode <= alarm_hour_setting_ones;
                    else showCode <= hour_one;
                    k <= k + 1;
                end
            7:
//              ��ʾʱ��ʮλ
                begin
                    tubePos <= 8'b0111_1111;
                    if (isSettingAlarm) showCode <= alarm_hour_setting_tens;
                    else showCode <= hour_ten;
                    k <= k + 1;
                end
            8: 
//              ���㣬��һ��ѭ��
                k <= 0;
            endcase
        end
endmodule
