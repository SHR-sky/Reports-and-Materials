# 实验七：EDA多功能数字钟

专业班级：**电信2204班** 

姓名：        **阮振宇** 

学号：        **U202214040**

## 实验名称

EDA多功能数字钟

## 实验目的：

- 了解数字钟的功能要求及设计方法；
- 了解CPLD/FPGA的一般结构及开发步骤；
- 掌握ISE 13.4软件的使用；
- 熟悉用FPGA器件取代传统的中规模集成器件实现数字电路与系统的方法。

## 实验仪器

***Vivado2022.2，Nexys4 DDR 开发板，Visual Studio Code***

## 实验任务

### 基础

- 设计多功能数字钟，使用组合逻辑，能显示小时，分钟，秒

- 小时为24进制，分和秒用60进制

- 可以调整小时，分的时间

### 提高

- 可以切换12/24小时制
- 可以设定任意时刻闹钟
- 整点报数（几点LED灯就闪烁几次）

### 验收

- 教师现场要求增加功能

## 实验原理

### 自顶向下的设计模式

   先设计顶层总框图,该框图由若干个具有特定功能的源模块组成。下一步针对这些具有不同功能的模块进行设计,对于有些功能复杂的模块,还可以将该模块继续化分为若干个功能子模块，这样就形成模块套模块的层次化设计方法。

### 数字钟整体框图

![Base/数字钟整体设计框图.png at master · HUSTerCH/Base · GitHub](https://github.com/HUSTerCH/Base/raw/master/circuitDesign/ex7/%E6%95%B0%E5%AD%97%E9%92%9F%E6%95%B4%E4%BD%93%E8%AE%BE%E8%AE%A1%E6%A1%86%E5%9B%BE.png)

## 实验代码

**注：代码缩进和注释均进行过调整，和实际项目地址中的代码略有差别**

**GitHub项目地址**

### Clock.v

```verilog
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

```

### divider.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:07:46
// Design Name: 
// Module Name: divider
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


module divider(
    input CP,
    input CLR_n,
    output one_HZ,
    output five_hundred_HZ
);


//分频模块
reg [17:0] cnt_500;
reg [15:0] cnt_1;
reg CP_out_500;
reg CP_out_1;

always @(posedge CP, posedge CLR_n) begin
    if (CLR_n) CP_out_500 <=0;
    else if(cnt_500 == 18'd50000 - 18'd1)    //0.1MHZ分频，得到1000HZ信号
        begin
            CP_out_500 <= ~CP_out_500;
            cnt_500 <= 0;
        end
     else begin
            cnt_500 <= cnt_500 + 1;
            CP_out_500 <= CP_out_500;
     end
 end


always @(posedge CP_out_500, posedge CLR_n) begin
    if (CLR_n) CP_out_1<=0;
    else if(cnt_1 == 16'd500 - 16'd1)    //1000HZ分频，得到1HZ信号
        begin
            CP_out_1 <= ~CP_out_1;
            cnt_1 <= 0;
        end
        else
        begin
            cnt_1 <= cnt_1 + 1;
            CP_out_1 <= CP_out_1;
        end
    end


assign one_HZ = CP_out_1;
assign five_hundred_HZ = CP_out_500;

endmodule

```

### cnt10_timer.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:08:49
// Design Name: 
// Module Name: cnt10_timer
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


module cnt10_timer (
    input one_HZ,
    input CLR_n,
    input isSetting,
    output reg [3:0] second_ten,
    output reg bit10
);


always @(posedge one_HZ or posedge CLR_n or posedge isSetting) begin
    if (CLR_n) begin 
        bit10 <= 0; 
        second_ten <= 0; 
    end
    else if (isSetting) begin 
        second_ten <= 0;
        bit10 <= 0; 
    end
    else if (second_ten == 4'd9) begin
        second_ten <= 0;
        bit10 <= 1;
    end
    else begin
        second_ten <= second_ten + 1;
        bit10 <= 0; 
    end
end

endmodule

```

### cnt10_minute.v

```verilog
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
```

### cnt6_timer.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:12:25
// Design Name: 
// Module Name: cnt6_timer
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


module cnt6_timer(
    input bit10,
    input CLR_n,
    output reg [3:0] six,
    output reg bit6
);

always @(posedge bit10, posedge CLR_n) begin
    if(CLR_n) begin six <= 0; bit6 <= 0; end
    else if(six == 4'd5) begin
        six <= 0;
        bit6 <= 1;
    end
    else begin
        six <= six + 1;
        bit6 <= 0;
    end
end

endmodule

```

### cnt6_minute.v

```verilog
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

```

### cnt_hour.v

```verilog
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

```

### alarm.v

```verilog
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
```

### alarm_min.v

```verilog
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

```

### alarm_bing.v

```verilog
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

```

### int_time.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/21 21:31:50
// Design Name: 
// Module Name: int_time
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


module int_time(
    input one_HZ,
    input CLR_n,

    input [3:0] second_six,
    input [3:0] second_ten,
    input [3:0] minute_six,
    input [3:0] minute_ten,
    input [3:0] hour_one,
    input [3:0] hour_ten,

    output reg led_int

);


reg [3:0] real_time;


always @(posedge one_HZ, posedge CLR_n) begin
    if(CLR_n) begin led_int <= 0; real_time <= 0; end
    else if (real_time == 0 && second_six == 0 && second_ten == 0 && minute_six == 0 && minute_ten == 0) begin
        real_time <= (hour_one + hour_ten * 10) * 2 - 1;
    end
    else if(real_time) begin
        led_int = ~led_int;
        real_time <= real_time - 1;
    end
    else if (real_time == 0) begin
        led_int <= 0;
    end
end

endmodule

```

### led_bing.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/21 21:31:03
// Design Name: 
// Module Name: led_bing
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


module led_bing(
    input CLR_n,
    input bing,
    input botton,
    input one_HZ,

    output reg led_alarm

);


reg flag;

always @(posedge one_HZ, posedge bing, posedge botton, posedge CLR_n) begin
    if(CLR_n) begin led_alarm <= 0; flag <= 0; end 
    else if (botton) begin led_alarm <= 0; flag <= 0; end
    else if(bing) begin 
        flag <= 1;
    end
    else if(flag) begin 
        led_alarm <= ~led_alarm;        
    end
end

endmodule

```

### display.v

```verilog
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

```

### numberDecoder.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:19:54
// Design Name: 
// Module Name: numberDecoder
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


module numberDecoder(
    input [3:0] showCode,
    output reg [6:0] code
    );
    always @(showCode)
        begin
            case(showCode)
                4'd0: code <= 7'b100_0000;
                4'd1: code <= 7'b111_1001;
                4'd2: code <= 7'b010_0100;
                4'd3: code <= 7'b011_0000;
                4'd4: code <= 7'b001_1001;
                4'd5: code <= 7'b001_0010;
                4'd6: code <= 7'b000_0010;
                4'd7: code <= 7'b111_1000;
                4'd8: code <= 7'b000_0000;
                4'd9: code <= 7'b001_0000;
                
                4'ha: code <= 7'b000_1000;//A
                4'hb: code <= 7'b000_1100;//P
                4'hc: code <= 7'b100_0110;//C
                default: code <= 7'b111_1111;
             endcase
        end
endmodule

```



### 仿真



```verilog


```

### 约束文件 clock_test.xdc

```xml-doc
set_property IOSTANDARD LVCMOS33 [get_ports {code[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {code[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {code[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {code[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {code[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {code[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {code[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {tubePos[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports CLR_n]
set_property IOSTANDARD LVCMOS33 [get_ports CP]
set_property IOSTANDARD LVCMOS33 [get_ports dot]
set_property IOSTANDARD LVCMOS33 [get_ports hour_setting]
set_property IOSTANDARD LVCMOS33 [get_ports isSetting]
set_property IOSTANDARD LVCMOS33 [get_ports isSettingAlarm]
set_property IOSTANDARD LVCMOS33 [get_ports minute_setting]
set_property IOSTANDARD LVCMOS33 [get_ports showMode]
set_property PACKAGE_PIN J17 [get_ports {tubePos[0]}]
set_property PACKAGE_PIN J18 [get_ports {tubePos[1]}]
set_property PACKAGE_PIN T9 [get_ports {tubePos[2]}]
set_property PACKAGE_PIN J14 [get_ports {tubePos[3]}]
set_property PACKAGE_PIN P14 [get_ports {tubePos[4]}]
set_property PACKAGE_PIN T14 [get_ports {tubePos[5]}]
set_property PACKAGE_PIN K2 [get_ports {tubePos[6]}]
set_property PACKAGE_PIN U13 [get_ports {tubePos[7]}]
set_property PACKAGE_PIN N17 [get_ports CLR_n]
set_property PACKAGE_PIN E3 [get_ports CP]
set_property PACKAGE_PIN H15 [get_ports dot]
set_property PACKAGE_PIN P17 [get_ports hour_setting]
set_property PACKAGE_PIN V10 [get_ports isSetting]
set_property PACKAGE_PIN U11 [get_ports isSettingAlarm]
set_property PACKAGE_PIN M17 [get_ports minute_setting]
set_property PACKAGE_PIN U12 [get_ports showMode]
set_property PACKAGE_PIN T10 [get_ports {code[0]}]
set_property PACKAGE_PIN R10 [get_ports {code[1]}]
set_property PACKAGE_PIN K16 [get_ports {code[2]}]
set_property PACKAGE_PIN K13 [get_ports {code[3]}]
set_property PACKAGE_PIN P15 [get_ports {code[4]}]
set_property PACKAGE_PIN T11 [get_ports {code[5]}]
set_property PACKAGE_PIN L18 [get_ports {code[6]}]

create_clock -period 10.000 -name CP -waveform {0.000 5.000} [get_ports CP]
create_clock -period 100.000 -name minute_setting [get_ports minute_setting]
create_clock -period 100.000 -name hour_setting [get_ports hour_setting]


set_property IOSTANDARD LVCMOS33 [get_ports botton]
set_property PACKAGE_PIN M18 [get_ports botton]
set_property PACKAGE_PIN V11 [get_ports led_alarm]
set_property IOSTANDARD LVCMOS33 [get_ports led_alarm]

set_property IOSTANDARD LVCMOS33 [get_ports led_int]
set_property PACKAGE_PIN H17 [get_ports led_int]

```

### 代码分析

   

## 实验小结



**一次难忘，但收获巨大的实验！**

                                                                                             **2023年3月22日 阮振宇 于 华中科技大学**