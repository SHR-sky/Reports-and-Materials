## 硬件平台搭建

### 板载包支持

电路设计实验中已经导入过了N4 DDR的板载支持包

## 硬件设计

![](Pasted%20image%2020240425181308.png)

该实验不需要采用Verilog构建硬件电路，采用Vivado自带的IP核

接下来步骤参考
左老师视频教程
[课程门户-章节详情 (chaoxing.com)](https://mooc1.chaoxing.com/mooc-ans/nodedetailcontroller/visitnodedetail?courseId=216913273&knowledgeId=406507336&enc=&mooc2=1)

需要注意的是，本实验中的集线器，位深选择8 ($2^3$) 即可，表示有三个输入

硬核的设计只有这一点不同，跟着视频就可以非常简单地搭建好平台了

## 软核设计

软核上，由于Vivado版本较高，配套使用的的也不是SDK了，而是Xilinx的官方IDE Vitis。所以，此处主要说明Vitis的使用

![](Pasted%20image%2020240425182115.png)

此处新建应用工程

然后，选择之前Vivado导出的xas文件建立新的硬件平台

![](Pasted%20image%2020240425182200.png)

之后，取好工程名后，一路默认，模板直接选择空即可。（如果你想检查串口是否正常，输出你的hello world，可以选择 hello world 模板）

>此处注意一下，如果硬件有任何改动，需要重新生成bit流，并且导出，最好直接overwrite原文件
>之后，右键此处，选择更新硬件


![](Pasted%20image%2020240425182409.png)

最后，你会得到如下工程，右键src，即可新建你的main.c文件，开始写工程了

![](Pasted%20image%2020240425182704.png)

## 编译、烧录与结果查看

编译工程，直接点击锤子🔨图标即可

![](Pasted%20image%2020240425182828.png)
编译成功后，右击上图框选工程（就是你的应用工程），在Run As 中直接Launch即可

这里以 hello world 为例

![](Pasted%20image%2020240425183018.png)

当我们烧进去之后，开发板会在串口打印信息。我们该怎么看呢？
找到下图选项，打开终端，设置串口

![](Pasted%20image%2020240425183237.png)


![](Pasted%20image%2020240425183305.png)![](Pasted%20image%2020240425183358.png)

波特率默认为9600，其余不管。

然后，就可以看到信息了。当然，采用串口助手也是可以的。甚至可以采用windows终端，或者pyhon脚本，作出很多好玩的串口效果



## 一些问题

目前，我所遇到的问题就是 xgpio库缺失，手动添加路径即可

这是因为没有在程序标明xgpio.h的位置。做过嵌入式的应该挺熟悉了。

File->Properties->Paths and Symbols。点击Add。

添加如下目录

>D:\\vivado\\Vitis\\2022.2\\data\\embeddedsw\\XilinxProcessorIPLib\\drivers

当然了，适当根据你的路径修改
注意，如果不勾选全部应用的话，那只会应用到当前工程中

![](Pasted%20image%2020240425183826.png)
