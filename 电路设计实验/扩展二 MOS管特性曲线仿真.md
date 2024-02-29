# 扩展二 MOS管特性曲线仿真

## 实验名称

MOS管特性曲线仿真

## 实验目的

通过软件仿真，进一步了解MOS管的特性，研究$I_{DQ}$与$V_{gs}、V_{ds}$的关系，并且掌握软件DC Sweep的操作方法。

## 实验原理及任务

采用软件Multisim搭建如下电路图，$V_{1}$和$V_{2}$进行变化，从而控制静态工作点形成曲线

![image-20231029182223839](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231029182223839.png)

## 实验过程
在Multisim中选择DC Sweep，对电源$V_{1}$和$V_{2}$进行扫描，使$V_{1}$在0到16V变化，$V_{2}$在0到60V间变化。

![image-20231029223908468](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231029223908468.png)

得到如下曲线

![image-20231029171852005](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231029171852005.png)

在Multisim中选择DC Sweep，将电源$V_{2}$定为8V对电源$V_{1}$和进行扫描，使$V_{1}$在0到4V变化，得到MOS管共源极转移曲线。

![image-20231029225139455](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231029225139455.png)

曲线如下

![image-20231029225104146](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20231029225104146.png)

## 实验小结

通过本实验，我熟练了电路的仿真过程，并且对MOS管有了更深的认识。在本次实验中，使用了双变量DC Sweep扫描，得到了MOS管的特性曲线。

