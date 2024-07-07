#include <stdio.h>
#include "xil_io.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xintc_l.h"
#include "xtmrctr_l.h"
#include "xparameters.h"

int main()
{

	char button = 0x0;
	int a,b;

	//GPIO输入输出配置
	Xil_Out16(XPAR_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);		//配置GPIO_0通道1的16位开关为输入
	Xil_Out16(XPAR_GPIO_0_BASEADDR+XGPIO_TRI2_OFFSET,0X0);	//配置GPIO_0通道2的16位LED灯为输出

	while(1)
	{
		while((Xil_In8(XPAR_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET)&0x1f)!=0)  //循环检测按键是否按下
		{
			button = Xil_In8(XPAR_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET)&0x1f;		//读入按键值

			while((Xil_In8(XPAR_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET)&0x1f)!=0);		//等到无按键输入
			switch(button)
			{
			case 0x1:	//BTNC 读入开关
				a=Xil_In16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA_OFFSET);
				Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,a);
				break;
			case 0x8:	//BTNR 读入另一组开关
				b=Xil_In16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA_OFFSET);
				Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,b);
				break;
			case 0x2:	//BTNU 加法
				Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,a+b);
				break;
			case 0x10:	//BTND 乘法
				Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR+XGPIO_DATA2_OFFSET,a*b);
				break;
			default:
				break;
			}
		}
	}
}
