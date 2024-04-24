# 实验二：MOS管放大电路

专业班级：

姓名：       

学号：        

## 实验名称

MOS管放大电路

## 实验目的

- 了解MOS管共源放大电路工作原理

- 掌握共源放大电路参数调整方法

- 掌握共源放大电路的基本原理与参数测量方法

- 掌握分立元件复杂电路搭建与调试方法

## 实验元器件

***MOSFET晶体管：2N7000；***

***电阻：1kΩ，5.1kΩ，100kΩ；***

***电容：1μF，4.7μF，47μF；***

***电位器：500kΩ***

## 实验原理

### MOSFET共源极放大电路

![image-20231023184815757](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231023184815757.png)

- 上图为N沟道增强型 MOSFET 共源极放大电路，其静态工作点可由下式估算：

$$
V_{GSQ} = \frac{R_{g2}}{R_{g1}+R_{g2}}×V_{DD}-I_{DQ}(R_{s_{2}}+R_{s_{2}})
$$

$$
I_{DQ}=K_n(V_{GS}-V_{TN})^2
$$

$$
V_{DSQ}=V_{DD}-I_{DQ}(R_{s_{2}}+R_{s_{2}})
$$

- 电路动态性能指标可由下式估算：

$$
A_v=-g_mR_d
$$

$$
R_i=R_{g1}//R_{g2}
$$

$$
R_o=R_d
$$

- 查询数据手册，可得出$V_{TN}$和某静态工作点Q下的$g_m$。

$$
对于MOS管 \; 2N7000，当I_D=200mA\, 时，g_m=100mS,则由上式可得
\\K_n=\frac{(g'_m/2)^2}{I_D}=12.5mA/V^2
$$

而由式$V_{DSQ}=V_{DD}-I_{DQ}(R_d+R_s)g_m$，即可得到是电路静态工作点下MOS管的电导$g_m$

并且对$V_{DS}$求$i_D$的偏导可得下式
$$
r_{ds}=\frac{∂v_{DS}}{∂i_D}|_{V_{GS}}=\lambda K_{n}(V_{GS}-V_{TN})^2=\frac{g_m^2}{4K_{n}}
$$

联立，可求得

$$
g_m=g'_m\sqrt{\frac{I_{DQ}}{I_D}}
$$

即

$$
g_m=10\sqrt{\frac{I_{DQ}}{2}} ms
$$

此外$V_{TN}$在0.8-3V之间，这里取$V_{TN}$=1.75V

设置静态工作点时，调整电位器$R_p$，使$V_p$为5-6V

## 实验任务

### 1.  Multisim仿真

#### （1） 模拟直流静态工作点
​    ![image-20231024124739441](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024124739441.png)

电路工作在饱和区，符合条件。

静态工作点:

IDQ=1.35mA

VGSQ=3.52V

VDSQ=5.04V

#### （2） AC sweep得到输入输出电压曲线

![image-20231024125306132](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024125306132.png)



![image-20231024125350120](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024125350120.png)


#### （3） AC模式得到幅频特性曲线

**中频增益：** AV=26.344dB=22.617>10符合要求

**上限频率：** fH=1.354MHz>100KHz符合要求

**下限频率：** fL=19.26Hz<100Hz符合要求

![image-20231024125603490](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024125603490.png)


![image-20231024125741114](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024125741114.png)


![image-20231024125848046](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024125848046.png)


#### （4） AC模式测量输入阻抗

Ri=68.21KΩ>50KΩ符合要求
![image-20231024130027721](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024130027721.png)

#### （5） AC模式测量输出阻抗

Ro=5.0257KΩ<5.1KΩ符合     要求

 ![image-20231024130455119](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024130455119.png)

由上述仿真实验可以得到，该电路符合实验要求。

#### （6） Interactive模式观察失真现象

**饱和失真：**
 ![image-20231024130804890](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024130804890.png)


**截止失真：**

![image-20231024131356479](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024131356479.png)

### 插板实验

#### 一、测试静态工作点

- 按照图连接后，检查无误后接通电源。

- 用数字万用表的直流电压档测量电路的$V_D$（漏极对地电压）

- 调整电位器$R_P$，使$V_D$为5~6V

- 再测出电路的$V_G$（栅极对地电压）和$V_S$（源极对地电压），填入下表中，并计算静态工作点Q（$I_{DQ}$、$V_{GSQ}$、$V_{DSQ}$）。

![image-20231023190239880](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231023190239880.png)

***注意：接下来的测试不要再改动静态工作点***

#### 二、性能测试：放大电路的输入、输出波形和通带电压增益

- 按照下图搭建放大电路实验测试平台
- 调整信号源，使其输出峰一峰值为30mV、频率为1kHz 的正弦波，作为放大电路的$v_i$,分别用示波器的两个通道同时测试$v_i$和$v_o$
- 在实验报告上定量画出$v_i$和$v_o$的波形（时间轴上下对齐）

![image-20231023190440574](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231023190440574.png)

#### 三、测试放大电路的输入电阻

- 采用在输入回路中串入已知电阻的方法测量输入电阻。

- 由于MOSFET放大电路的输入电阻较大，所以当测量仪器的输入电阻不够大时，采用直接串入电阻的方法可能存在较大误差，改用如图所示的测量输出电压的方法更好

- R取值尽量与$R_i$接近(此处可取R=51 KΩ)。信号源仍旧输出峰峰值30mV、1kHz正弦波

- 用示波器的一个通道始终监视$v_i$波形，用另一个通道先后测量开关S闭合和断开时对应的输出电压$v_{o1}$和$v_{o2}$，则输入电阻为

  $$
  R_i=\frac{v_{o2}}{v_{o1}-v_{o2}}R
  $$

- 测量过程要保证$v_o$不出现失真现象

![image-20231023191458734](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231023191458734.png)

#### 四、测试放大电路的输出电阻

- 采用改变负载的方法测试输出电阻。

- 分别测试负载开路输出电压$v'_o$和接入已知负载$R_L$时的输出电压$v_o$测量过程同样要保证$v_o$不出现失真现象。实际上在表3.3.3 中已得到$v'_o$和$v_o$则输出电阻为

  $$
  R_o=\frac{v'_o-v_o}{v'_o}×R_L
  $$

  $R_L$越接近$R_o$误差越小

![image-20231023191420023](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231023191420023.png)



#### 五、测试放大电路的通频带

- 在图3.3.6 中，输入$v_i$为峰-峰值30mV、1kHz的正弦波，用示波器的一个通道始终监视输入波形的峰-峰值，用另一个通道测出输出波形的峰-峰值。

- 保持输入波形峰峰值不变，调节信号源的频率，逐渐提高信号的频率，观测输出波形的幅值变化，并相应适时调节示波器水平轴的扫描速率，保证始终能清晰观测到正常的正弦波。

- **持续提高**信号频率，直到输出波形峰-峰值降为1kHz时的**0.707倍**，此时信号的频率即为上限频率$f_H$，记录该频率;

- 类似地，**逐渐降低**信号频率，直到输出波形峰峰值降为1kHz时的**0.707 倍**，此时的频率即为信号频率$f_L$，记录该频率，完成下表；

- **要特别注意，测试过程必须时刻监视输入波形峰-峰值，若有变化，需调整信号源的输出幅值，保持$v_i$的峰-峰值始终为30mV。**

  **通频带(带宽)为BW=$f_H$-$f_L$。**
  ![image-20231024150626150](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024150626150.png)


#### 六、观察失真波形

- 调整信号源频率调回1kHz，分别用示波器的两个通道同时观测$v_i$和$v_o$，不断调整电位器$R_P$，观察$v_o$波形的变化，直至出现明显的非线性失真。

- 定性画出失真波形形状，并用万用表的直流电压档测量电路的$V_D$、$V_G$和$V_S$填入下表，计算静态工作点Q（$I_{DQ}$、$V_{GSQ}$、$V_{DSQ}$）。

- 再反方向调整$R_P$，直至$v_o$波形出现另一种非线性失真现象，再次测量静态工作点，完成下表内容。（注意，如果调不出失真现象，可以适当增大输入信号的幅值，再调整$R_P$，该实验可增大到$600mV_{pp}$）

## 实验记录

#### 一、测试静态工作点

记录如下：

![image-20231024201252722](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024201252722.png)

#### 二、测试放大电路的输入、输出波形和通带电压增益

示波器图示如下：

![image-20231024195445980](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024195445980.png)


电压增益 
$$
A_V=\frac{Vo}{Vi}=\frac{823.4mV}{31.62mV}=26.04
$$

#### 三、测试放大电路的输入电阻

实验测量示波器图示如下：

![image-20231024234349547](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024234349547.png)



![image-20231024234522677](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024234522677.png)


由
$$
R_i=\frac{v_{o2}}{v_{o1}-v_{o2}}R
$$

有

$$
R_i=\frac{56.72}{101.3-56.72}×50k=63.58k
$$

又

理论值$R_i$=($R_{g1}$+$R_p$)//$R_{g2}$=**58.33k**

则相对误差为

$$
\frac{63.58-58.33}{58.33}=9.01\%
$$

#### 四、 测试放大电路的输出电阻

实验示波器测量图示如下：

![image-20231024234219612](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024234219612.png)



![image-20231024234301316](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024234301316.png)


由

$$
R_o'=\frac{v'_o-v_o}{v'_o}×R_L
$$

有

$$
R_o'=\frac{100.6-56}{100.6}×5.1k=2.244kΩ	\\
R_o'=\frac{R_o*R_L}{R_o+R_L}	\\
则R_o=4.007kΩ,满足要求
$$

#### 五、测试放大电路的通频带

实验示波器测量图示如下：

![image-20231024200418304](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024200418304.png)

$$
1kHz,v_{opp}=823.4mV
$$

![image-20231024200319887](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024200319887.png)

$$
22Hz,v_{opp}=580.3mV
$$

![image-20231024200235284](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024200235284.png)

$$
1.03MHz,v_{opp}=588.0mV
$$

实验记录表如下：

![image-20231024201307700](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024201307700.png)



#### 六、观察失真波形

实验示波器测量图示如下：

![](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024201326465.png)

$$
截止失真
$$
![image-20231024201404709](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024201404709.png)

$$
饱和失真
$$

实验记录表如下

![image-20231024201716127](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231024201716127.png)


## 实验小结

这次实验增强了我对MOSFET的理解，亲身学习并调试出了两种失真波形，复习并更好的理解了模电的知识,实验过程中发现理解实验原理，掌握MOS管的工作原理和相关计算方法以及相关仪器的使用方法至关重要。