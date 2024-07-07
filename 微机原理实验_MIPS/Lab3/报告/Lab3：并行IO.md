# 实验三：并行IO接口设计



## 实验名称

并行IO接口设计

## 实验目的

- 掌握GPIO IP核的工作原理和使用方法
- 掌握中断控制方式的IO接口设计原理
- 掌握中断程序设计方法
- 掌握IO接口程序控制方法

## 实验仪器

***Vivado 2022.2、Vitis 2022.2***

## 实验任务

- 所有实验任务要求分别采用程序控制方式、中断方式,中断方式时, GPIO输入、延时都采用中断实现。
  - 嵌入式计算机系统将独立按键以及独立开关作为输入设备, LED灯、七段数码管作为输出设备。LED灯实时显示独立开光对应位状态,同时8个七段数码管实时显示最近按下的独立按键位置编码字符( C,U,L,D,R)。
  - 程序控制方式提示:程序以七段数码管动态显示控制循环为主体,在循环体内的延时函数内读取开关值更新LED、读取按键值更新段码。
  - 扩展：实现向左移位显示

## 实验原理

### 硬件电路框图

![Base/硬件电路框图1.png at master · HUSTerCH/Base · GitHub](https://github.com/HUSTerCH/Base/raw/master/circuitDesign/%E5%BE%AE%E6%9C%BA%E5%8E%9F%E7%90%86/ex3/%E7%A1%AC%E4%BB%B6%E7%94%B5%E8%B7%AF%E6%A1%86%E5%9B%BE1.png)

![Base/硬件电路框图2.png at master · HUSTerCH/Base · GitHub](https://github.com/HUSTerCH/Base/raw/master/circuitDesign/%E5%BE%AE%E6%9C%BA%E5%8E%9F%E7%90%86/ex3/%E7%A1%AC%E4%BB%B6%E7%94%B5%E8%B7%AF%E6%A1%86%E5%9B%BE2.png)

根据硬件电框图搭建的硬件平台整体框图如下：

![image-20240518145736240](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240518145736240.png)

### 软件流程图

![image-20240515164738826](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240515164738826.png)

## 实验源码

### 程序控制方式

```c
#include <stdio.h>
#include "xil_io.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xintc_l.h"
#include "xtmrctr_l.h"
#include "xparameters.h"

#define RESET_VALUE 100000-2
#define XPAR_AXI_TIMER_0_INTERRUPT_MASK 4U

void display(char segcode[], short tmp[], short position, int k) {
    for (int i = 0; i < 8; i++) {
        Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA2_OFFSET, segcode[tmp[(i + k) % 8]]);  // 先展示一个
        Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA_OFFSET, position);  // 先展示下一个
        for (int j = 0; j < 10000; j++) ;  // for循环在这卡一会儿，显示一下
        position = position >> 1;
    }
}

int main() {
    unsigned short lastSwitchState, currentSwitchState;  //存上次的状态和这次的
    unsigned short led;  // output to LED
    Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);  // 按钮输入
    Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);  // LED输出

    unsigned short currentBtn, lastBtn, realBtn;
    char segcode[6] = {0xc6, 0xc1, 0xc7, 0x88, 0xc0, 0xff};  // 段码
    short tmp[8] = {5, 5, 5, 5, 5, 5, 5, 5};
    int k = 0;
    short position = 0xff7f;
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI_OFFSET, 0x0);
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);
    Xil_Out16(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_TRI_OFFSET, 0x1f);
    while (1) {
        lastSwitchState = currentSwitchState;
        currentSwitchState = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET) & 0xffff;	// 读取新状态
        if (lastSwitchState != currentSwitchState) //如果真的改变了
        {
            led = currentSwitchState;
        }

        Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA2_OFFSET, led);  //输出到LED

        display(segcode, tmp, position, k);  // 数码管显示
        position = 0xff7f;
        currentBtn = Xil_In8(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET) & 0x1f;	// 低五位
        if (currentBtn)
        {
            while (currentBtn) //没更新一直卡在这
            {
                display(segcode, tmp, position, k);
                currentBtn = (Xil_In8(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET) & 0x1f);
                realBtn = (currentBtn ^ lastBtn) & lastBtn;  // 当且仅当按下到未按下，realBtn不为0，使得跳出循环
                lastBtn = currentBtn;
                if (realBtn) {
                    break;
                }
            }

            switch (realBtn) {
            case 0x01:
                tmp[k] = 0;
                k = (k + 1) % 8;
                break;

            case 0x02:
                tmp[k] = 1;
                k = (k + 1) % 8;
                break;

            case 0x04:
                tmp[k] = 2;
                k = (k + 1) % 8;
                break;

            case 0x08:
                tmp[k] = 3;
                k = (k + 1) % 8;
                break;

            case 0x10:
                tmp[k] = 4;
                k = (k + 1) % 8;
                break;
            }
        }
    }
    return 0;
}


```

### 中断控制方式

```c
#include <stdio.h>
#include "xil_io.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xintc_l.h"
#include "xtmrctr_l.h"
#include "xparameters.h"

#define RESET_VALUE 100000-2
#define XPAR_AXI_TIMER_0_INTERRUPT_MASK 4U

void segTimerCounterHandler();
void btnHandler();
void switchHandler();
void My_ISR() __attribute__((interrupt_handler));
int i = 0;

int flag;

unsigned short currentBtn, lastBtn, realBtn;
char segcode[6] = {0xc6, 0xc1, 0xc7, 0x88, 0xc0, 0xff};
short tmp[8] = {5, 5, 5, 5, 5, 5, 5, 5};
int k = 0;
short pos = 0xff7f;

int main() {
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);  // LED输入
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);  // 开关输入
    Xil_Out32(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI_OFFSET, 0x0);  // 段码输出
    Xil_Out32(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);  // 位码输出
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_TRI_OFFSET, 0x1f);  // 按钮输入
    
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK);	// GPIO中断使能
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_GIE_OFFSET, XGPIO_GIE_GINTR_ENABLE_MASK);

	Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK);  // GPIO中断使能
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_GIE_OFFSET, XGPIO_GIE_GINTR_ENABLE_MASK);

	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IER_OFFSET, XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK | XPAR_AXI_TIMER_0_INTERRUPT_MASK);  // 中断使能
    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_MER_OFFSET, XIN_INT_MASTER_ENABLE_MASK | XIN_INT_HARDWARE_ENABLE_MASK | XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK);

    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET,
              Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) & ~XTC_CSR_ENABLE_TMR_MASK);  // 停止计数

    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TLR_OFFSET, RESET_VALUE);  // 写预制数

    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET,
              Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) | XTC_CSR_LOAD_MASK);

    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET,
              (Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) & ~XTC_CSR_LOAD_MASK)
              | XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_ENABLE_INT_MASK | XTC_CSR_DOWN_COUNT_MASK);

    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_MER_OFFSET, XIN_INT_MASTER_ENABLE_MASK | XIN_INT_HARDWARE_ENABLE_MASK);
    microblaze_enable_interrupts();  // microbalze中断使能
    return 0;
}

void My_ISR() {
    int status;
    status = Xil_In32(XPAR_AXI_INTC_0_BASEADDR + XIN_ISR_OFFSET);

    int tcsr;
    tcsr=Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET);

    if((status & XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK) == XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)
    {
            switchHandler();
    }

    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IAR_OFFSET, status);

    if ((status & XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK) == XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK)
    {
            btnHandler();
    }


    if ((tcsr&XTC_CSR_INT_OCCURED_MASK)==XTC_CSR_INT_OCCURED_MASK)
    {
        segTimerCounterHandler();
        Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TIMER_COUNTER_OFFSET+XTC_TCSR_OFFSET,tcsr|XTC_CSR_INT_OCCURED_MASK);
    }

    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IAR_OFFSET, status);
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,XPAR_AXI_TIMER_0_INTERRUPT_MASK);
}

void segTimerCounterHandler() {
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA2_OFFSET, segcode[flag]);
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA_OFFSET, pos);
    pos = pos >> 1;
    i++;
    if (i == 8) {
        i = 0;
        pos = 0xff7f;
    }
    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET, Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET));  // clear interrupt
}

void btnHandler() {
    int btncode;
    btncode = Xil_In32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET);
    switch (btncode) {
    case 0x01:
        flag = 0;

        break;
    case 0x02:
        flag = 1;

        break;
    case 0x04:
        flag = 2;

        break;
    case 0x08:
        flag = 3;

        break;
    case 0x10:
        flag = 4;

        break;
    }
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_ISR_OFFSET, Xil_In32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_ISR_OFFSET));
}

void switchHandler() {
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA2_OFFSET, Xil_In32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET));

    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_ISR_OFFSET, Xil_In32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_ISR_OFFSET));
}

```

## 实验结果

实验效果如下：

![IMG_20240516_213615](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/IMG_20240516_213615.jpg)

## 实验小结

​	本次实验中，我通过普通中断方式和程序控制的方式，实现了独立按键以及独立开关作为输入设备， LED灯、七段数码管作为输出设备，LED灯实时显示独立开光对应位状态，同时8个七段数码管实时显示最近按下的独立按键位置编码字符( C,U,L,D,R)的功能。

​	这次实验让我学习了软核的编写，能够自己搭建硬件平台，将外设与CPU进行组合，并且能够在硬件平台的基础上，对软核进行编写，从而实现外设的功能以及中断控制和程序控制。