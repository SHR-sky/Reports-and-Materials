# 实验二：简单指令集MIPS单周期微处理器设计



## 实验名称

简单指令集MIPS单周期微处理器设计

## 实验目的

1. 了解微处理器的基本结构
   
2. 掌握哈佛结构的计算机工作原理
   
3. 学会设计简单的微处理器
   
4. 了解软件控制硬件工作的基本原理
   

## 实验仪器

**_Vivado2018.03 、Mars MIPS汇编编译器、Visual Studio Code Insiders_**

## 实验任务

**全部采用Verilog 硬件描述语言**设计实现简单指令集MIPS 微处理器，要求：

- 指令存储器在时钟上升沿读出指令，
  
- 指令指针的修改、寄存器文件写入、数据存储器数据写入都在时钟下降沿完成
  
- 完成完整设计代码输入、各模块完整功能仿真，整体仿真，验证所有指令执行情况。
  

**且：**

- 假定所有通用寄存器复位时取值都为各自寄存器编号乘以4；
  
- PC寄存器初始值为0；
  
- 数据存储器和指令存储器容量大小为32*32，且地址都从0开始；
  
- 指令存储器初始化时装载测试MIPS汇编程序的机器指令
  
- 数据存储器所有存储单元的初始值为其对应地址的取值。数据存储器的地址都是4的整数倍。
  

仿真以下MIPS汇编语言程序段的执行流程：

```nasm
main:
add $4,$2,$3
lw $4,4($2)
sw $5,8($2)
sub $2,$4,$3
or $2,$4,$3
and $2,$4,$3
slt $2,$4,$3
beq $3,$3,equ
lw $2,0($3)

equ:
beq $3,$4,exit
sw $2,0($3)

exit:
j main
```

另：各个小组所属成员需扩展实现各小组要求扩展的指令：

- 1）addi，ori；

- 2）lb，lbu，lh，lhu；

- 3）bne；bltz；bgez；

- 4）jal，jr; 

- 5） sb,sh;

- 6）sll,srl;sllv,srlv;

并在汇编程序中添加相应指令仿真验证该指令执行是否正确。

## 实验过程&源码

### 生成机器码和iromIP核

根据上述要求和学号，选择lb指令，并将其添加进汇编指令代码中，如下：

```nasm
main:
add $4,$2,$3
lw $4,4($2)
lb $6,5($2)
sw $5,8($2)
sub $2,$4,$3
or $2,$4,$3
and $2,$4,$3
slt $2,$4,$3
beq $3,$3,equ
lw $2,0($3)

equ:
beq $3,$4,exit
sw $2,0($3)

exit:
j main
```

用mars软件转换机器码如下：

```binary
00432020
8c440004
80460005
ac450008
00831022
00831025
00831024
0083102a
10630001
8c620000
10640001
ac620000
08000000
```

生成如下.coe文件：

iromIP.coe

```binary
memory_initialization_radix=16;
memory_initialization_vector=
00432020
8c440004
ac450008
00831022
00831025
00831024
0083102a
10630001
8c620000
10640001
ac620000
08000000;
```

使用Block Memory Generator生成IP核，命名为iromIP，并且选择Single Port ROM

![image-20240406231603021](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406231603021.png)

由于该实验只需要32个存储单元 或者说 由于地址线应该为5根，所以Depth为32（$2^5$），由于输出的instr为32位，所以位宽Width选为32。同时，注意不需要使能端，取消勾选。同时，取消勾选Primitives Output Register，不需要延迟缓冲，避免多一个周期。

![image-20240406231713688](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406231713688.png)

### 译码器

然后，根据下表，编写译码器

![image-20240407205918248](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240407205918248.png)

#### 第一级译码器

![image-20240404222245448](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240404222245448.png)

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:43:49
// Design Name: 
// Module Name: Decoder
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


module Decoder(
    input [5:0] Op,

    output [1:0] ALUOp,
    output RegDst,
    output RegWr,
    output ALUSrc,
    output MemWr,
    output jump,
    output branch,
    output Mem2Reg,
    output wb
);

    reg [8:0] code;

    assign RegDst = code[8];
    assign ALUSrc = code[7];
    assign Mem2Reg = code[6];
    assign RegWr = code[5];
    assign MemWr = code[4];
    assign branch = code[3];
    assign jump = code[2];
    assign ALUOp = code[1:0];
    
    assign wb = Op[5] & (~Op[4]) & (~Op[3]) & (~Op[2]) & (~Op[1]) & (~Op[0]) ;

    always @(Op) begin
        case(Op)
            6'b00_0010:code = 9'bxxx0_001_xx;
            6'b00_0000:code = 9'b1001_000_10;
            6'b10_0011:code = 9'b0111_000_00;
            6'b10_1011:code = 9'bx1x0_100_00;
            6'b00_0100:code = 9'bx0x0_010_01;
            6'b00_1000:code = 9'b01x1_000_00;
            6'b00_1101:code = 9'b0101_000_10;
            6'b10_0000:code = 9'b0111_000_00;   //lb
            default: code = 9'b0000_000_00;
        endcase
    end
endmodule

```

#### 第二级译码器

直接生成ALUCtr信号，控制ALU

![image-20240404222152391](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240404222152391.png)

```verilog
module ALUCtrler(
    input [1:0] ALUOp,
    input [5:0] func,

    output reg [3:0] ALUCtrl
);

    always @(ALUOp, func) begin
        casex ({ALUOp,func})
            8'b00xx_xxxx: ALUCtrl = 4'b0010;    //加(lw,sw,lb)
            8'b01xx_xxxx: ALUCtrl = 4'b0110;    //减(beq)
            8'b10xx_0000: ALUCtrl = 4'b0010;    //加(add)
            8'b10xx_0010: ALUCtrl = 4'b0110;    //减(sub)
            8'b10xx_0100: ALUCtrl = 4'b0000;    //与(and)
            8'b10xx_0101: ALUCtrl = 4'b0001;    //或(or)
            8'b10xx_1010: ALUCtrl = 4'b0111;    //小于设置(slt)
            default: ALUCtrl = 4'b0000;
        endcase
    end
endmodule
```

根据微处理器结构图，继续完成其他部分

![image-20240407210138719](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240407210138719.png)

### 寄存器文件

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:44:56
// Design Name: 
// Module Name: regfile
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


module regfile(
    input clk,
    input rst,
    input RegWr,
    input [31:0] WriteData,
    input [4:0] RsAddr,
    input [4:0] RtAddr,
    input [4:0] WriteAddr,
    
    output [31:0] RsData,
    output [31:0] RtData
);

    reg [31:0] regs[0:31];
    assign RsData = regs[RsAddr];
    assign RtData = regs[RtAddr];
    integer i;

    // 时钟下降沿写寄存器
    always @(negedge clk or negedge rst) begin
        if (rst && RegWr)
            regs[WriteAddr] = WriteData;
        else if (!rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] = i * 4;
        end
    end
endmodule

```



### 数据储存器

```verilog
module Dram(
    input clk,
    input wb,
    input [4:0] addr,
    input [1:0] lb,
    input [31:0] WriteData,
    input MemWr,

    output reg [31:0] ReadData

);
    //数据存储器输出
    reg [31:0] regs[0:31];  //32个32位的寄存器
    always @(addr)begin
       if(wb)begin
            case (lb[1:0])
                2'b00:
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][7:0]}; // LB 3:0
                    else if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][7:0]}; // LB 3:0
                end
                2'b01: 
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][15:8]}; // LB 7:4
                    else if (regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][15:8]}; // LB 7:4
                end
                2'b10: 
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][23:16]}; // LB 11:8
                    else if (regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][23:16]}; // LB 11:8
                end
                2'b11: 
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][31:24]}; // LB 15:12
                    else if (regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][31:24]}; // LB 15:12
                end
            endcase
       end
       else begin
            ReadData = regs[addr];
       end
    end

    //数据存储器写入
    always @(negedge clk) begin
        if(MemWr) regs[addr] = WriteData;
    end

    //数据存储器初始化
    integer i;
    initial begin
        for(i=0;i<32;i=i+1) begin
            regs[i] = i*4;
        end
    end
endmodule
```

最后，一些数据选择部分，定义在CPU模块中

### CPU

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:41:41
// Design Name: 
// Module Name: CPU
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


module CPU(
    input clk,
    input rst
);

    wire [31:0] TempPC,RsData,RtData,ALUIn,ALUResult,MemReadData,instr,WriteData,JumpPC,SequencePC,BranchPC;
    wire [31:0] Imm32,ImmL2,MuxPC;
    wire [27:0] PsudeoPC;
    wire [4:0] WriteAddr;
    wire [1:0] ALUO;
    wire [3:0] ALUCtrl;

    wire zero,MemWr,RegWr,RegDst,ALUSrc,jump,branch,Mem2Reg,BranchZ;
    
    wire wb;
    
    reg [31:0] PC;

    assign PsudeoPC = {instr[25:0],2'b00};  //j指令，将低26位补00
    assign JumpPC = {SequencePC[31:28],PsudeoPC};   //用PC指针前四位补全
    assign SequencePC = PC + 4; //加4,保证程序计数器（PC总指着下一条指令）
    assign BranchPC = ImmL2 + SequencePC;   //得到偏移后的地址
    assign MuxPC = BranchZ ? BranchPC : SequencePC; //分支条件选指针（sw/lw 或者 +4）
    assign TempPC = jump ? JumpPC : MuxPC;  //下一个PC是分支跳转还是j指令

    assign BranchZ = branch & zero; //控制分支
    assign ImmL2 = {Imm32[29:0],2'b00}; //乘4，字节地址
    assign Imm32 = {instr[15] ? 16'hffff : 16'h0 , instr[15:0]};    //符号扩展，将偏移量变为偏移地址
    assign ALUIn = ALUSrc ? Imm32 : RtData; //选择源寄存器还是立即数参与运算
    assign WriteAddr = jump ? 5'b1_1111:RegDst ? instr[15:11] : instr[20:16];   //如果不是j指令，那么赋寄存器的地址
    assign WriteData = jump ? PC + 4 : Mem2Reg ? MemReadData : ALUResult;   //如果是j指令，那么把PC加4,执行下一条指令;非j指令情况下，决定是从rom中读取还是ALU计算得到
    
    //指令存储器
    iromIP U1(clk,PC[6:2],instr);

    //译码
    Decoder U2(.Op(instr[31:26]),.ALUOp(ALUOp),.RegDst(RegDst),.RegWr(RegWr),.ALUSrc(ALUSrc),.MemWr(MemWr),.jump(jump),.branch(branch),.Mem2Reg(Mem2Reg),.wb(wb));
    ALUCtrler U3(.ALUOp(ALUOp),.func((ALUSrc && instr[31:26] == 6'b00_1101)?6'bxx_0101:instr[5:0]),.ALUCtrl(ALUCtrl));
    
    //寄存器文件
    regfile U4(.clk(clk),.rst(rst),.RegWr(RegWr),.WriteData(WriteData),.RsAddr(instr[25:21]),.RtAddr(instr[20:16]),.WriteAddr(WriteAddr),.RsData(RsData),.RtData(RtData));
    
    //ALU操作
    ALU U5(.inputA(RsData),.inputB(ALUIn),.ALUCtrl(ALUCtrl),.ALUResult(ALUResult),.zero(zero));
    
    //数据存储器
    Dram U6(.clk(clk),.wb(wb),.addr(ALUResult[6:2]),.lb(ALUResult[1:0]),.WriteData(RtData),.MemWr(MemWr),.ReadData(MemReadData));
    
    always @(negedge clk or negedge rst) begin
        // 初始化指针
        if (!rst) PC <= 0;
        // clk下降沿改变PC指针
        else if (instr[25:21] == 5'b1_1111) PC <= RsData;
        else PC <= TempPC;
    end

endmodule
```

### 代码分析

在顶层文件MIPS_CPU.v中，定义了各种数据通路，并对各模块都进行了实例化，数据储存器使用的是Verilog编写的Dram.v，指令储存器iromip使用的是生成的IP核

CPU中各模块：

- 读取指令在时钟上升沿

```verilog
// 指令存储器
iromIP U1(CLK,PC[6:2],Instr);
```

- PC指针修改在时钟下降沿

```verilog
always @(negedge clk) begin
    // 初始化指针
    if (rst) PC <= 0;
    // clk下降沿改变PC指针
    else if (instr[25:21] == 5'b1_1111) PC <= RsData;
    else PC <= TempPC;
end
```

- 寄存器文件写入在时钟下降沿

```verilog
regfile U4(.clk(clk), .rst(rst), .RegWr(RegWr), .WriteData(WriteData), .RsAddr(instr[25:21]), .RtAddr(instr[20:16]), .WriteAddr(WriteAddr), .RsData(RsData), .RtData(RtData));

	always @(negedge clk) begin
        if (!rst && RegWr)
            regs[WriteAddr] = WriteData;
        else if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] = i * 4;
        end
    end
```

- 数据存储器数据写入都在时钟下降沿
- 并且储存器中加入wb信号，由于lw和lb译码后的控制信号完全相同用于区分lw和lb

```verilog
//数据存储器
    Dram U6(.clk(clk), .addr(ALUResult[6:2]), .WriteData(RtData), .MemWr(MemWr), .ReadData(MemReadData));

/********************/

//Dram部分代码
	always @(negedge clk) begin
        if(MemWr) regs[addr] = WriteData;
    end
```

### 仿真代码

#### test_CPU.v

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/07 21:09:55
// Design Name: 
// Module Name: test_CPU
// Project Name: x
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

module test_CPU();

reg clk;
reg rst;

CPU t1(
    .clk(clk),
    .rst(rst)
);

initial begin
clk = 0;
rst = 1;
#1
rst = 0;
#1
rst = 1;
#100
$stop;
end

always begin
#1 clk = ~clk;
end

endmodule
```

得到仿真波形

### 仿真分析

对MIPS_CPU的仿真得到如上波形，由图可知，addra的值，即PC的值，在时钟下降沿改变，取一个周期，从0ns开始分析：

第一条指令`add $4,$2,$3`，我们可看到，\$2，\$3的值已被赋值为8，12。然后，在第一个时钟下降沿，即PC为00结束时，即得到的ALUResult为0x14，即20，**执行正确**。

![image-20240410200514510](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240410200514510.png)

其他指令同理：

然后分析指令lb，指令`lb $6,5($2) `。可以看到，6000ns时，下降沿，执行指令，由于采用字节地址，\$2中的值为8，加上5后，指向iromIP储存器中的第13个字节，由于一个寄存器4字节，所以指向三号寄存器的第一个字节，即值为c（12），加载进去。可以观察到，下降沿时，寄存器中的值确实变为了c（12），**执行正确**；

![image-20240410200556981](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240410200556981.png)



![image-20240410201715636](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240410201715636.png)



## 总结

这次实验中，我使用Verilog，在Vivado平台上，搭建了流水线型CPU。
这次实验极大地锻炼了我分模块建模的能力，让我更加熟悉了微处理器的结果，并且在仿真分析的过程中，让我更好地理解了内存地址之间的关系。




