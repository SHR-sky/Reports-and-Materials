`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:06:16
// Design Name: 
// Module Name: EDA_clock
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


module EDA_clock(
    input CP,
    input CLR_n,
    input showMode,
    input isSettingAlarm,
    input isSetting,
    input minute_setting,
    input hour_setting,
    input botton,
    output [7:0] tubePos,
    output [6:0] code,
    output dot,
    output led_alarm,
    output led_int
);

wire one_HZ;
wire five_hundred_HZ;

wire [3:0] second_ten;
wire [3:0] second_six;

wire bit10_second;
wire bit6_second;

wire [3:0] minute_ten;
wire [3:0] minute_six;

wire bit10_minute;
wire bit6_minute;

wire [3:0] hour_ten;
wire [3:0] hour_one;

wire bit10_hour;

wire [3:0] showCode;

wire [3:0] alarm_minute_setting_ones;
wire [3:0] alarm_minute_setting_tens;
wire [3:0] alarm_hour_setting_ones;
wire [3:0] alarm_hour_setting_tens;

wire bing;


// 获得需要的信号
divider U1(.CP(CP),.CLR_n(CLR_n),.one_HZ(one_HZ),.five_hundred_HZ(five_hundred_HZ));

// 获得秒的数值
cnt10_timer U2(.one_HZ(one_HZ),.CLR_n(CLR_n),.isSetting(isSetting),.second_ten(second_ten),.bit10(bit10_second));
cnt6_timer U3(.bit10(bit10_second),.CLR_n(CLR_n),.six(second_six),.bit6(bit6_second));

// 获得分的数值
cnt10_minute U4(.bit6(bit6_second),.CLR_n(CLR_n),.isSetting(isSetting),.minute_setting(minute_setting),.ten(minute_ten),.bit10(bit10_minute));
cnt6_minute U5(.bit10(bit10_minute),.CLR_n(CLR_n),.isSetting(isSetting),.six(minute_six),.bit6(bit6_minute));

// 获得时的数值
cnt_hour U6(.bit6_minute(bit6_minute),.CLR_n(CLR_n),.showMode(showMode),.isSetting(isSetting),.hour_setting(hour_setting),.hour_ten(hour_ten),.hour_one(hour_one));

// 小数点都不显示
assign dot = 1;

// 闹钟设置
alarm U7(.CLR_n(CLR_n),.isSettingAlarm(isSettingAlarm),.hour_setting(hour_setting),
.alarm_hour_setting_ones(alarm_hour_setting_ones),.alarm_hour_setting_tens(alarm_hour_setting_tens));

alarm_min U8(.CLR_n(CLR_n),.isSettingAlarm(isSettingAlarm),.minute_setting(minute_setting),
.alarm_minute_setting_ones(alarm_minute_setting_ones),.alarm_minute_setting_tens(alarm_minute_setting_tens));

// 闹钟判断
alarm_bing U9(.alarm_minute_setting_ones(alarm_minute_setting_ones),.alarm_minute_setting_tens(alarm_minute_setting_tens),.alarm_hour_setting_ones(alarm_hour_setting_ones),
.alarm_hour_setting_tens(alarm_hour_setting_tens),.one_HZ(one_HZ),.second_six(second_six),.second_ten(second_ten),.minute_six(minute_six),.minute_ten(minute_ten),.hour_one(hour_one),.hour_ten(hour_ten),.bing(bing));

// 闹钟响
led_bing U10(.CLR_n(CLR_n),.bing(bing),.botton(botton),.one_HZ(one_HZ),.led_alarm(led_alarm));

// 整点报时
int_time U11(.one_HZ(one_HZ),.CLR_n(CLR_n),.second_six(second_six),.second_ten(second_ten),.minute_six(minute_six),.minute_ten(minute_ten),.hour_one(hour_one),.hour_ten(hour_ten),.led_int(led_int));





//译码为显示内容
display U12(.five_hundred_HZ(five_hundred_HZ),.showMode(showMode),.isSettingAlarm(isSettingAlarm),
.alarm_minute_setting_ones(alarm_minute_setting_ones),.alarm_minute_setting_tens(alarm_minute_setting_tens),
.alarm_hour_setting_ones(alarm_hour_setting_ones),.alarm_hour_setting_tens(alarm_hour_setting_tens),
.second_ten(second_ten),.second_six(second_six),.minute_ten(minute_ten),.minute_six(minute_six),
.hour_ten(hour_ten),.hour_one(hour_one),.tubePos(tubePos),.showCode(showCode));

// 最终显示
numberDecoder U13(.showCode(showCode),.code(code));

endmodule
