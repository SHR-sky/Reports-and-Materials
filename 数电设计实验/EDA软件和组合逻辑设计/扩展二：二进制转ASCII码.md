# 扩展二：二进制转ASCII码

专业班级：**电信2204班**

姓名：        **阮振宇**

学号：        **U202214040**

## 实验名称

数码管译码显示

## 实验目的

1. 了解并掌握采用可编程逻辑器件实现数字电路与系统的方法
   
2. 学习并掌握采用Xilinx_Vivado 软件开发可编程器件的过程
   
3. 学习使用verilog HDL描述数字逻辑电路与系统的方法
   
4. 掌握分层次、分模块的电路设计方法，熟悉使用可编程器件实现数字系统的一般步骤。
   

## 实验元器件

**_电脑软件Vivado 2022.2_**

## 实验原理

![image-20240310234021424](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240310234021424.png)

查看手册后，得知数码管共阳极，即低电平点亮。
同时注意到，使能端ANX，当时钟频率为50HZ左右时，利用视觉暂留现象，数码管交替点亮，可以实现全部点亮效果

所以，对主时钟分频
```verilog
 localparam N = 18; //使用低16位对50Mhz的时钟进行分频(50MHZ/2^16)
 reg [N-1:0] regN; //高两位作为控制信号，低16位为计数器，对时钟进行分频
 reg [7:0] hex_in; //段选控制信号
 reg dp;

 always@(posedge clk, posedge reset)
 begin
  if(reset)
   regN <= 0;
  else
   regN <= regN + 1;
 end

```



交替点亮模块
```verilog
 always@(*) begin

  case(regN[N-1:N-2])
  
  2'b00:begin
   an = 4'b1110; //选中第1个数码管
   hex_in = hex0; //数码管显示的数字由hex_in控制，显示hex0输入的数字；
   dp = dp_in[0]; //控制该数码管的小数点的亮灭
  end

  2'b01:begin
   an = 4'b1101; //选中第二个数码管
   hex_in = hex1;
   dp = dp_in[1];
  end

  2'b10:begin
   an = 4'b1011;
   hex_in = hex2;
   dp = dp_in[2];
  end

  default:begin
   an = 4'b0111;
   hex_in = hex3;
   dp = dp_in[3];
  end

  endcase
 end

```

## 实验任务

按号分别实现下列项目之一

- 二进制-ASCII码转换表(p147,EDA实验内容2)

- 数码管译码显示

- 文字显示器（HELLO，HI，HAHA,HEHEA）
  

## 实验记录

### 模块设计

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: RZY
// 
// Create Date: 2024/03/11 23:14:22
// Design Name: RZY
// Module Name: four_asiic
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


module asiic(
    input clk,
    input reset,
    input [7:0] hex, //数码管显示的asiic码对应的二进制
    input [3:0] dp_in, //小数点控制
    output reg [7:0] an,   //片选
    output reg [7:0] sseg  //段选
    );
 
 localparam N = 18; //使用低16位对50Mhz的时钟进行分频(50MHZ/2^16)
 reg [N-1:0] regN; //高两位作为控制信号，低16位为计数器，对时钟进行分频
 reg [7:0] hex_in; //段选控制信号
 reg dp; 

 reg [7:0] hex0;
 reg [7:0] hex1; 
 reg [7:0] hex2; 
 reg [7:0] hex3;


 always@(posedge clk, posedge reset)
 begin
  if(reset)
   regN <= 0;
  else regN <= regN + 1;
 end
 
 //hex转hexn译码模块
 always@(*) begin
  
  if(hex == 8'b0001_0011) begin
  hex2 = 8'b0110_0100;
  hex1 = 8'b0100_0011;
  hex0 = 8'b0011_0011;
  hex3 = 8'b1111_1111;
  end
  else begin
  hex0 = hex;
  hex1 = 8'b1111_1111;
  hex2 = 8'b1111_1111;
  hex3 = 8'b1111_1111;
  end
  
  case(regN[N-1:N-2])
  2'b00:begin
   an <= 8'b1111_1110; //选中第1个数码管
   hex_in <= hex0; //数码管显示的数字由hex_in控制，显示hex0输入的数字；
   dp <= dp_in[0]; //控制该数码管的小数点的亮灭
  end
  2'b01:begin
   an <= 8'b1111_1101; //选中第二个数码管
   hex_in <= hex1;
   dp <= dp_in[1];
  end
  2'b10:begin
   an <= 8'b1111_1011;
   hex_in <= hex2;
   dp <= dp_in[2];
  end
  default:begin
   an <= 8'b1111_0111;
   hex_in <= hex3;
   dp <= dp_in[3];
  end
  endcase
  
 end


 always@(posedge clk)
 begin
  case(hex_in)
   8'b0011_0000: sseg[6:0] = 7'b100_0000; //共阳极数码管 0
   8'b0011_0001: sseg[6:0] = 7'b111_1001; //1
   8'b0011_0010: sseg[6:0] = 7'b010_0100; //2
   8'b0011_0011: sseg[6:0] = 7'b011_0000; //3
   8'b0011_0100: sseg[6:0] = 7'b001_1001; //4
   8'b0011_0101: sseg[6:0] = 7'b001_0010; //5
   8'b0011_0110: sseg[6:0] = 7'b000_0010; //6
   8'b0011_0111: sseg[6:0] = 7'b111_1000; //7
   8'b0011_1000: sseg[6:0] = 7'b000_0000; //8
   8'b0011_1001: sseg[6:0] = 7'b001_1000; //9
   8'b0100_0001: sseg[6:0] = 7'b000_1000; //A
   8'b0100_0010: sseg[6:0] = 7'b000_0011; //b
   8'b0100_0011: sseg[6:0] = 7'b100_0110; //C
   8'b0110_0100: sseg[6:0] = 7'b010_0001; //d
   8'b0100_0101: sseg[6:0] = 7'b000_0110; //E
   8'b0100_0110: sseg[6:0] = 7'b000_1110; //F
   8'b0100_1000: sseg[6:0] = 7'b000_1001; //H
   8'b1111_1111: sseg[6:0] = 7'b111_1111; //NULL
   default: sseg[6:0] = 7'b111_1111; //NULL
  endcase
  sseg[7] = dp;
 end

endmodule



```

### 仿真设计


```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: Zhengyu Ruan 
// 
// Create Date: 2024/02/28 16:23:09
// Design Name: Tube decoding display
// Module Name: number
// Project Name: number
// Target Devices: 
// Tool Versions: 2022.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module asiic(
    input clk,
    input reset,
    input [7:0] hex, //数码管显示的asiic码对应的二进制
    input [3:0] dp_in, //小数点控制
    output reg [7:0] an,   //片选
    output reg [7:0] sseg  //段选
    );


module test_assic();

reg clk;
reg reset;
reg [7:0] hex;
reg [3:0] dp_in;

wire [7:0] an;
wire [7:0] sseg;

asiic t1(
    .clk(clk),
    .reset(reset),
    .hex(hex),
    .dp_in(dp_in),
    .an(an),
    .sseg(sseg)
);

initial begin
    clk = 0;
    reset = 0;
    hex = 8'b0011_0001;
    dp_in = 3'b000;
    #10
    reset = 1;
    #10
    reset = 0;
    $stop;
end

always begin
#1 clk = ~clk;
end

endmodule

```

### 烧录下载

编写代码

![image-20240311120147810](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240311120147810.png)

绑定引脚，并且进行时序约束与综合

![image-20240311120253200](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240311120253200.png)

最后生成Bit流文件，连接开发板，烧录下载



### 实验结果分析

![image-20240307233657645](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240307233657645.png)

## 实验小结

