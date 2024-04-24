# 实验二：EDA软件使用与组合逻辑设计

专业班级：

姓名：       

学号：      

## 实验名称

EDA软件使用与组合逻辑设计

## 实验目的

1. 了解并掌握采用可编程逻辑器件实现数字电路与系统的方法

2. 学习并掌握采用Xilinx_ISE 软件 / vivado软件开发可编程器件的过程

3. 学习使用verilog HDL描述数字逻辑电路与系统的方法

4. 掌握分层次、分模块的电路设计方法，熟悉使用可编程器件实现数字系统和仿真的一般步骤。

## 实验元器件

***电脑软件Vivado 2022.2***（win11 不支持 ISE）

## 实验原理

### 传统数字系统设计

![image-20240310233315367](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240310233315367.png)

### 现代数字系统的设计

![image-20240310233217644](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240310233217644.png)


## 实验任务

按号分别实现下列项目之一（**三种编程方式形式实现**）

- 四位大小比较器（三灯指示，大于、等于、小于）
- 3线-8线译码器
- 8线-3线优先编码器

## 实验记录

### 8线-3线优先编码器
### 行为级型

#### muxtwo.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: Zhengyu Ruan 
// 
// Create Date: 2024/02/28 16:23:09
// Design Name: muxtwo
// Module Name: muxtwo
// Project Name: muxtwo
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
module encoder(
    input [7:0] botton,
    input reset,
    input EN,

    output reg [2:0] out
);

always @(*) begin
    if(rst == 1) begin out <= 0; end
    else begin
        if(!EN) begin out <= out; end
        else begin
            casex (botton)
            8'b0000_0000:out <= 3'b000;
            8'b1xxx_xxxx:out <= 3'b111;
            8'b01xx_xxxx:out <= 3'b110;
            8'b001x_xxxx:out <= 3'b101;
            8'b0001_xxxx:out <= 3'b100;
            8'b0000_1xxx:out <= 3'b011;
            8'b0000_01xx:out <= 3'b010;
            8'b0000_001x:out <= 3'b001;
            8'b0000_0001:out <= 3'b000;
            default:out <= 3'b000;
            endcase
        end  
    end
end

endmodule

```

#### testbench.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: Zhengyu Ruan 
// 
// Create Date: 2024/02/28 16:23:09
// Design Name: muxtwo
// Module Name: muxtwo
// Project Name: muxtwo
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
module test_encoder();
reg [7:0] x;
wire [2:0] y;

encoder_1 t1(
    .x(x),
    .y(y)
);

initial begin
    x = 8'b0000_0001;
    #81
    $stop;
end

always begin
   #10 x = x<<1;
end

endmodule
```

#### wave

![image-20240315114504575](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240315114504575.png)

### 数据流建模

#### muxtwo.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: Zhengyu Ruan 
// 
// Create Date: 2024/02/28 16:23:09
// Design Name: muxtwo
// Module Name: muxtwo
// Project Name: muxtwo
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

module encoder_1(
    input [7:0] x,
    output [2:0] y
);

assign y[2] = x[4] & x[5] & x[6] & x[7];
assign y[1] = ~(~x[2]&x[4]&x[5] | ~x[3]&x[4]&x[5] | ~x[6] | ~x[7]);
assign y[0] = ~(~x[1]&x[2]&x[4]&x[6] | ~x[3]&x[4]&x[6] | ~x[5]&x[6] |x[7])

endmodule
```

#### testbench.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: Zhengyu Ruan 
// 
// Create Date: 2024/02/28 16:23:09
// Design Name: muxtwo
// Module Name: muxtwo
// Project Name: muxtwo
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
module test_encoder();
reg [7:0] x;
wire [2:0] y;

encoder_1 t1(
    .x(x),
    .y(y)
);

initial begin
    x = 8'b0000_0001;
    #81
    $stop;
end

always begin
   #10 x = x<<1;
end

endmodule
```

#### wave
![image-20240315114504575](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240315114504575.png)


### 门级建模

#### muxtwo.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: Zhengyu Ruan 
// 
// Create Date: 2024/02/28 16:23:09
// Design Name: muxtwo
// Module Name: muxtwo
// Project Name: muxtwo
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

module encoder_2(
    input [6:0] x,
    output [2:0] y
);

wire x1n,x2n,x3n,x5n,x6n,x7n;
wire s1,s2,s3,s4,s5;

not N1(x1n,x[1]);
not N2(x2n,x[2]);
not N3(x3n,x[3]);
not N4(x5n,x[5]);
not N5(x6n,x[6]);
not N6(x7n,x[7]);

and U1(y[2],x[4],x[5],x[6],x[7]);
and U2(s1,x2n,x[4],x[5]);
and U3(s2,x3n,x[4],x[5]);
and U4(s3,x1n,x[2],x[4],x[6]);
and U5(s4,x5n,x[6]);

or O1(y1n,s1,s2,x6n,x7n);
or O2(y0n,s3,s4,s5,x[7]);

not N8(y[1],y1n);
not N9(y[0],y0n);

endmodule
```

#### testbench.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HUST
// Engineer: Zhengyu Ruan 
// 
// Create Date: 2024/02/28 16:23:09
// Design Name: muxtwo
// Module Name: muxtwo
// Project Name: muxtwo
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
module test_encoder();
reg [7:0] x;
wire [2:0] y;

encoder_1 t1(
    .x(x),
    .y(y)
);

initial begin
    x = 8'b0000_0001;
    #81
    $stop;
end

always begin
   #10 x = x<<1;
end

endmodule
```

#### wave

![image-20240315114504575](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240315114504575.png)

### 仿真实验结果分析

由以上对的三种不同建模以及测试波形可得，三种方式的输出结果相同，均成功实现了的功能



### 下载实现

如图，对8-3编码器进行建模

![image-20240315114315272](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240315114315272.png)

然后，进行引脚约束

![image-20240315114244595](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240315114244595.png)

查看手册

![image-20240310234021424](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240310234021424.png)


选择SW0到SW7为输入
选择LED0到LED2为编码结果
绑定引脚后，生成Bit流文件，更新驱动，烧录


## 实验小结

通过本实验，我重新熟悉了verilog语言的三种编写方法，并复习了vivado的使用方法。