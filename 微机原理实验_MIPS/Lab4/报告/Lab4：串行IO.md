# 实验四：串行IO接口设计



## 实验名称

串行IO接口设计
## 实验目的

- 掌握GPIO IP核的工作原理和使用方法
- 掌握中断控制方式的IO接口设计原理
- 掌握UART IP核通信
- 掌握SPI IP核通信以及AD与DA模块
## 实验仪器

**Vivado 2022.2、Vitis 2022.2**
## 实验任务

- 理解UART串行通信协议以及接口设计

- 理解SPI串行通信协议，掌握SPI串行接口设计

- 掌握串行DA接口设计，掌握串行AD接口设计

## 实验原理

### 硬件电路框图

![](https://github.com/HUSTerCH/Base/raw/master/circuitDesign/%E5%BE%AE%E6%9C%BA%E5%8E%9F%E7%90%86/ex4/%E4%B8%B2%E8%A1%8CIO%E7%94%B5%E8%B7%AF%E6%A1%86%E5%9B%BE.png)

根据硬件电框图搭建的硬件平台整体框图如下：

![image-20240526113642392](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240526113642392.png)

### 软件流程图

![image-20240526121202591](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240526121202591.png)

## 实验源码

### SPI AD

```c
/*
SPI AD
*/
#include "xil_io.h"
#include "xil_exception.h"
#include "xintc_l.h"
#include "xspi_l.h"
#include "xtmrctr_l.h"
#include "xgpio_l.h"
#include "xparameters.h"

int RESET_VALUE = 100000000/0xfff-2;
void My_ISR() __attribute__((interrupt_handler));
u16 volt=0;

void switchHandler();   //开关中断
void timerHandler();    //按键中断
void volt_get();

int main()
{
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_IISR_OFFSET, Xil_In32(XPAR_SPI_1_BASEADDR+XSP_IISR_OFFSET));
	RESET_VALUE = 100000000/0xfff-2;
	// 复位
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_SRR_OFFSET,XSP_SRR_RESET_MASK);
	//设定SPI接口的通信模式，设定SPI为主设备，CPOL=1,CPHA-0,时钟相位180°，自动方式，高位优先传送
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_CR_OFFSET,XSP_CR_ENABLE_MASK| XSP_CR_MASTER_MODE_MASK | XSP_CR_CLK_POLARITY_MASK
				| XSP_CR_TXFIFO_RESET_MASK | XSP_CR_RXFIFO_RESET_MASK);
	// 使能一下
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_SSR_OFFSET,~(0x1));
	// 发一个，启动
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_DTR_OFFSET,0x0);
	//GPIO中断使能
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_TRI_OFFSET,0xffff);//开关switch设置为输入
	Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_TRI2_OFFSET,0X0);      //LED设置为输出
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_IER_OFFSET,XGPIO_IR_CH1_MASK);//GPIO_0中断使能
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_GIE_OFFSET,XGPIO_GIE_GINTR_ENABLE_MASK);//GPIO_0全局中断使能
	//定时器初始化
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET
              ,Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)&~XTC_CSR_ENABLE_TMR_MASK);//写TCSR，停止定时器
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TLR_OFFSET,RESET_VALUE);//写TLR，预置计数初值
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET
		                  ,Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)|XTC_CSR_LOAD_MASK);//装载计数初值
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET
		               ,(Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)&~XTC_CSR_LOAD_MASK)\		|XTC_CSR_ENABLE_TMR_MASK|XTC_CSR_AUTO_RELOAD_MASK|XTC_CSR_ENABLE_INT_MASK|XTC_CSR_DOWN_COUNT_MASK);//开始计时 

	//中断控制器intr0中断源使能
	Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IER_OFFSET,
	  		XPAR_AXI_TIMER_0_INTERRUPT_MASK|
	  		XPAR_AXI_QUAD_SPI_1_IP2INTC_IRPT_MASK|
	  		XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK);     //开放定时器T0及SPI中断

  	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_MER_OFFSET,
            XIN_INT_MASTER_ENABLE_MASK|XIN_INT_HARDWARE_ENABLE_MASK);
	//处理器中断使能
	microblaze_enable_interrupts();

	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_IIER_OFFSET,XSP_INTR_TX_EMPTY_MASK);
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_DGIER_OFFSET,XSP_GINTR_ENABLE_MASK);

	//启动传输，发送数据0
	Xil_Out16(XPAR_AXI_QUAD_SPI_1_BASEADDR+XSP_DTR_OFFSET,0); //启动SPI传输，产生时钟和片选信号
	//while(1);
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_DTR_OFFSET,0x0);
	return 0;
}

void My_ISR()
{
    int status;
    status=Xil_In32(XPAR_AXI_INTC_0_BASEADDR+XIN_ISR_OFFSET);   //读入中断状态
   if((status&XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)==XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK)
   {
       switchHandler();   //如果开关产生了中断，则进入开关中断服务函数
   }
    else if((status&XPAR_AXI_TIMER_0_INTERRUPT_MASK)==XPAR_AXI_TIMER_0_INTERRUPT_MASK)
   {
      timerHandler();    //如果定时器产生了中断，则进入定时器中断服务函数
   }
   if((status&XPAR_AXI_QUAD_SPI_1_IP2INTC_IRPT_MASK)==XPAR_AXI_QUAD_SPI_1_IP2INTC_IRPT_MASK)
   {
	   volt_get();
   }
   Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_IAR_OFFSET,status);
}

void switchHandler() //开关中断服务程序
{
    int sw;
    sw = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA_OFFSET);   //读入开关值
   	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,sw);   //把开关的状态反映到LED上
   	Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_ISR_OFFSET,0x01);
   	int min=10000000;   //最短时间0.1s 100ms 最长为12.8s 12800ms
   	RESET_VALUE=((sw&0x0000ffff)*19378+min)/0xfff-2;   //步进值19378=（最大时长12_8000_0000-最小时长1000_0000）/2^16（=65536） 每拨动一个开关加一个步进时长
   	//读入的开关值sw一定要与上0x0000ffff保存低16位，否则会自动有符号数扩展，装载进去的值就会是个负的
   	
    //此处开关改变定时器的预置值，重新装载
   	int status=Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET);
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,status&(~XTC_CSR_ENABLE_TMR_MASK));
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TLR_OFFSET,RESET_VALUE);  //为定时器装载改变后的预置值
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET)|XTC_CSR_LOAD_MASK);
   	status=(status&(~XTC_CSR_LOAD_MASK))|XTC_CSR_ENABLE_TMR_MASK;
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,status);
}

void volt_get()
{
	volt = Xil_In16(XPAR_SPI_1_BASEADDR+XSP_DRR_OFFSET) & 0xfff;// 启动SPI，读取AD值
	Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,0x8);  // 普通中断模式，手动清中断
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_IISR_OFFSET, Xil_In32(XPAR_SPI_1_BASEADDR+XSP_IISR_OFFSET));
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_DTR_OFFSET,0x0);
}

void timerHandler() //AD
{
    //清定时器中断，不然一直中断周期会不对
	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET));
	Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,0x8);  // 普通中断模式，手动清中断
		xil_printf("the volt is %d \r\n",volt);
		Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_DTR_OFFSET,0x0);
}

```

### 拓展部分 UART

```c
/*
串口
*/

#include "xil_io.h"
#include "stdio.h"
#include "xgpio_l.h"
#include "xintc_l.h"
#include "xuartlite_l.h"

void UART1_RECV()__attribute__((fast_interrupt));
void UART2_RECV()__attribute__((fast_interrupt));
void BtnHandler()__attribute__((fast_interrupt));
void SwtHandler()__attribute__((fast_interrupt));

//中断服务程序
char scancode[5][2]={{0x1,0xc6},{0x2,0xc1},{0x4,0xc7},{0x8,0x88},{0x10,0xa1}};
int main()
{
    Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);//switch输入
    Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);//LED输出

    // 开关中断开启
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_IER_OFFSET,XGPIO_IR_CH1_MASK);// 中断输入
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_GIE_OFFSET,XGPIO_GIE_GINTR_ENABLE_MASK);// 中断输出


    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI_OFFSET, 0x0);// 位码输出
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);// 段码输出

    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA_OFFSET, 0xfe);// 段码初值

    // 按钮中断开启
    Xil_Out8(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_TRI_OFFSET, 0x1f);// 按键为输入
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR+XGPIO_IER_OFFSET,XGPIO_IR_CH1_MASK);
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR+XGPIO_GIE_OFFSET,XGPIO_GIE_GINTR_ENABLE_MASK);

    //串口初始化
    Xil_Out32(XPAR_AXI_UARTLITE_1_BASEADDR+XUL_CONTROL_REG_OFFSET,
            XUL_CR_ENABLE_INTR|XUL_CR_FIFO_RX_RESET|XUL_CR_FIFO_TX_RESET);
    Xil_Out32(XPAR_AXI_UARTLITE_2_BASEADDR+XUL_CONTROL_REG_OFFSET,
            XUL_CR_ENABLE_INTR|XUL_CR_FIFO_RX_RESET|XUL_CR_FIFO_TX_RESET);

    // INTC
    // 清除中断
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,
            Xil_In32(XPAR_INTC_0_BASEADDR+XIN_ISR_OFFSET));

    // 输入使能
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IER_OFFSET,XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK|XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK|
            XPAR_AXI_UARTLITE_1_INTERRUPT_MASK|XPAR_AXI_UARTLITE_2_INTERRUPT_MASK);//使能

    // 快速中断
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IMR_OFFSET,XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK|XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK|
            XPAR_AXI_UARTLITE_1_INTERRUPT_MASK|XPAR_AXI_UARTLITE_2_INTERRUPT_MASK);//工作模式

    // 输出使能
    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_MER_OFFSET,XIN_INT_MASTER_ENABLE_MASK|XIN_INT_HARDWARE_ENABLE_MASK);//允许中断输出

    // 填中断向量表
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IVAR_OFFSET+4*XPAR_INTC_0_GPIO_2_VEC_ID,(u32)BtnHandler);
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IVAR_OFFSET+4*XPAR_INTC_0_GPIO_0_VEC_ID,(u32)SwtHandler);
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IVAR_OFFSET+4*XPAR_INTC_0_UARTLITE_1_VEC_ID,(u32)UART1_RECV);
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IVAR_OFFSET+4*XPAR_INTC_0_UARTLITE_2_VEC_ID,(u32)UART2_RECV);
    microblaze_enable_interrupts();	//microblaze中断开放
    return 0;
}

void BtnHandler()
{
    uint8_t btncode=Xil_In8(XPAR_AXI_GPIO_2_BASEADDR+XGPIO_DATA_OFFSET);
    if(btncode)
    {
    	//将按键值写入UART2的发送FIFO，发到UART1
    	Xil_Out32(XPAR_AXI_UARTLITE_2_BASEADDR+XUL_TX_FIFO_OFFSET,btncode);
    }

    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR+XGPIO_ISR_OFFSET,
            Xil_In32(XPAR_AXI_GPIO_2_BASEADDR+XGPIO_ISR_OFFSET));	//清除中断
}

void SwtHandler(){
    //将开关写入UART1的发送FIFO，发到UART2
    Xil_Out32(XPAR_AXI_UARTLITE_1_BASEADDR+XUL_TX_FIFO_OFFSET,Xil_In32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA_OFFSET));
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_ISR_OFFSET,Xil_In32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_ISR_OFFSET));   //清除中断
}

void UART2_RECV()
{
	// 如果收到信息
    if( (Xil_In32(XPAR_AXI_UARTLITE_2_BASEADDR+XUL_STATUS_REG_OFFSET) & XUL_SR_RX_FIFO_VALID_DATA) == XUL_SR_RX_FIFO_VALID_DATA )
        Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,
                Xil_In32(XPAR_AXI_UARTLITE_2_BASEADDR+XUL_RX_FIFO_OFFSET));
}

void UART1_RECV()
{
	// 如果收到信息
    if( (Xil_In32(XPAR_AXI_UARTLITE_1_BASEADDR+XUL_STATUS_REG_OFFSET) & XUL_SR_RX_FIFO_VALID_DATA) == XUL_SR_RX_FIFO_VALID_DATA )
    {
        uint8_t btncode = Xil_In8(XPAR_AXI_UARTLITE_1_BASEADDR+XUL_RX_FIFO_OFFSET);
        for(int i=0;i<5;i++)
        {
            if(btncode==scancode[i][0])
            {
            	// 判断得到是哪个按键，然后赋对应段码
                btncode = scancode[i][1];
                Xil_Out32(XPAR_AXI_GPIO_1_BASEADDR+XGPIO_DATA2_OFFSET,btncode);
                break;
            }
        }
    }
}

```

## 实验结果

### AD部分
利用计算机串口工具，查看串口打印出的电压值。首先将输入接地，输出值为0，再将输入接VCC，输出值为4095。

![Snipaste_2024-05-22_17-29-12](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/Snipaste_2024-05-22_17-29-12.png)



![image-20240528163255604](https://cdn.jsdelivr.net/gh/SHR-sky/Picture@main/Pic/image-20240528163255604.png)



### 扩展部分

首先断开UART2的TX和UART的RT之间的连线，拨动开关和按下按键，LED灯和数码管都没变化。
连接上连接UART2的TX和UART的RT之间的连线后，再次拨动开关，对应的LED灯被点亮，按下开关后数码管亮起了最近按下的开关对应的字符，所以实验结果满足要求。

## 实验小结

本次实验在已有硬件平台的基础上，加入了SPI IP核和UART IP核，并且学习了引出管脚和管脚约束。再次复习了AD采样和DA生成波形的过程。并且，复习了SPI中断的配置。