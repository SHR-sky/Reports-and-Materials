# 最好不要使用IP核！

Viavdo的ROM核存在100ps的锁存器时延，虽然不影响结果，但是验收时可能不通过！



# ROM——IP核设计流程

### by S.H.R



**首先，项目管理中选择IP核**

![image-20240406231047941](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406231047941.png)



**下滑，找到Memory & Storage Elements**

![image-20240406231319750](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406231319750.png)



**选项中找Block Memory Generator，双击后，开始编辑ROM**

![image-20240406231411214](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406231411214.png)



**给IP核取名，并且选择Single Port ROM**

![image-20240406231603021](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406231603021.png)



---------

* Single Port RAM ：单口RAM，IP 核包括 地址端口、时钟端口、输入数据端口、输出数据端口、时钟使能、写使能。
* Simple Dual Port RAM ：简单双口RAM，IP 核包括 两个彼此独立的端口，其中一个端口负责写入数据，另一个负责读出数据。 
* True Dual Port RAM ：真正双口RAM，IP 核包括两个独立的端口，并且每个端口都可读可写。
* Single Port ROM ：单口ROM，IP 核包括 地址端口、时钟端口、时钟使能、输出数据端口。
* Dual Port ROM ：双口ROM，IP 核有两个彼此独立的端口。

--------



**由于该实验只需要32个存储单元 或者说 由于地址线应该为5根，所以Depth为32（2^5），由于输出的instr为32位，所以位宽Width选为32。同时，注意不需要使能端，取消勾选。同时，取消勾选Primitives Output Register，不需要延迟缓冲，避免多一个周期**

![image-20240406231713688](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406231713688.png)



------------



具体原理解释：

![image](https://img2023.cnblogs.com/blog/2829072/202312/2829072-20231229154256461-1727194245.png#pic_center)



```markdown
Write First Mode
这种模式下，写操作的优先级高于读操作，它的时序如上所示：
（已经取消勾选使能端）

CLKA 为时钟
DINA 为写入的数据总线
DOUTA 为读出的数据总线
ADDRA 为地址总线

1、ENA 信号一直为 1，即，一直使能；

2、第一个虚线，也就是 CLKA 的上升沿位置，采到 ENA 为 1，同时 WEA 为 0，则代表为 READ 时序，同时，在这个上升沿，采集到 ADDRA 上为 aa（ADDRA 为并行地址总线），那么就会在获取到 aa 这个地址中的值后（经过了一点延时），将数据打到 DOUTA[15:0] 上，所以这里可以看到 DOUTA 上是 MEM(aa)，也就是 aa 这个 RAM 地址中存储的数据；

3、第二个虚线，CLKA 上升沿的时候，同样会检测 ENA 和 WEA，此刻，它们都为 1，则代表 WRITE 时序来了，此刻采集到写入数据总线 DINA 上的数据为 1111，地址总线上是 bb，那么此刻是将地址 bb 的值放到 DOUTA 上呢，还是直接将 DINA 的值放到 DOUTA 上呢，这个 Operating Mode 就是解决这个问题的，在 Write First Mode 的情况下，DINA 的 1111 数据直接被送到了 DOUTA 总线上，同时，MEM(bb) 的内容被写入 1111,；

4、第三个虚线，CLKA 上升沿的时候，同理，2222 数据被直接写到 MEM(cc)，同时被输出到 DOUTA 上

5、第四个虚线，CLKA 上升沿的时候，WEA 信号被拉到 0，但是 ENA 信号还是 1，说明当前不存在 WRITE了，只有 READ 时序，那么会将 ADDRA 上采集到的 dd 地址的数据读出到 DOUTA 上；

但此IP核只用于读，所以相当于WEA一直为0
```

-----------

**此处，选择已经写好的coe文件即可。复位引脚等一律不需要。**

![image-20240406233010101](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406233010101.png)

该文件由Mars导出机械码后，编写得到

```coe
memory_initialization_radix=16;
memory_initialization_vector=
00432020
2085002c
8c440004
ac450008
00831022
00831025
00831024
34420037
0083102a
10630001
8c620000
10640001
ac620000
08000000;
```

**点击加号还能看到引脚及其位宽**

![image-20240406234151393](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406234151393.png)

**如此，便完成了IP核设计，想查看具体内容，此处单击打开即可。它的使用和其他模块一样，直接实例化引用即可**

![image-20240406233206613](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240406233206613.png)

















