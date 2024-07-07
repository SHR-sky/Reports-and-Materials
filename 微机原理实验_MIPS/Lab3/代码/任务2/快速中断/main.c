#include <stdio.h>
#include "xil_io.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xintc_l.h"
#include "xtmrctr_l.h"
#include "xparameters.h"

int RESET_VALUE = 100000-2;

int number[8] = {1,2,3,4,5,6,7,8};

void segTimerCounterHandler(void) __attribute__ ((fast_interrupt));
void btnHandler(void) __attribute__ ((fast_interrupt));
void switchHandler(void) __attribute__ ((fast_interrupt));
int i = 0;

int flag;

char segcode[17] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x83, 0xf8, 0x80, 0x90, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e, 0xff};

int k = 0;
short pos = 0xff7f;

int main()
{
    /*外设GPIO初始化*/
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);  // LED输出
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);  // 按钮输出
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK);	// GPIO0中断使能
	Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_GIE_OFFSET, XGPIO_GIE_GINTR_ENABLE_MASK);	// 中断输出使能
    
    Xil_Out32(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI_OFFSET, 0x0);  // 段码输出
	Xil_Out32(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);  // 位码输出
    
	Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_TRI_OFFSET, 0x1f);  // 按钮输入
    Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_IER_OFFSET, XGPIO_IR_CH1_MASK);  // GPIO2中断使能
	Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_GIE_OFFSET, XGPIO_GIE_GINTR_ENABLE_MASK);  // 中断输出使能

    /*外设定时器初始化*/
    // 停止计数
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET,
	              Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) & ~XTC_CSR_ENABLE_TMR_MASK);
	// 写预制数
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TLR_OFFSET, RESET_VALUE);  // write TLR, preset counter value
	//装载预制值
	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET,
	              Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) | XTC_CSR_LOAD_MASK);  

	Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET,
	              (Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET) & ~XTC_CSR_LOAD_MASK)
	              | XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_ENABLE_INT_MASK | XTC_CSR_DOWN_COUNT_MASK);

    /*INTC初始化*/
    // 清除中断标志位
    Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IAR_OFFSET, XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK| 
                  XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK | XPAR_AXI_TIMER_0_INTERRUPT_MASK); 
    // 中断输入使能
	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_IER_OFFSET, XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK| 
                  XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK | XPAR_AXI_TIMER_0_INTERRUPT_MASK);  
    // 中断输出使能
	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR + XIN_MER_OFFSET, XIN_INT_MASTER_ENABLE_MASK | XIN_INT_HARDWARE_ENABLE_MASK);
    // 中断模式选择
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IMR_OFFSET,XPAR_AXI_TIMER_0_INTERRUPT_MASK | XPAR_AXI_GPIO_0_IP2INTC_IRPT_MASK | XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK);
    // 中断向量表填写
    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IVAR_OFFSET + 4 * XPAR_INTC_0_TMRCTR_0_VEC_ID,
              (unsigned int)segTimerCounterHandler);	//中断函数
	    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IVAR_OFFSET + 4 * XPAR_AXI_INTC_0_AXI_GPIO_2_IP2INTC_IRPT_INTR,
                  (unsigned int)btnHandler);	//中断函数
	    Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IVAR_OFFSET + 4 * XPAR_AXI_INTC_0_AXI_GPIO_0_IP2INTC_IRPT_INTR,
                  (unsigned int)switchHandler);	//中断函数
    
    /*CPU初始化*/
	microblaze_enable_interrupts();  // 允许 microbalze 中断
	return 0; 
}


void segTimerCounterHandler()
{
	Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA_OFFSET, pos);
	//xil_printf("OK\n");
	Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA2_OFFSET, segcode[number[i]]);

    pos = pos >> 1;
    i++;
    if (i == 8)
    {
        i = 0;
        pos = 0xff7f;
    }
    Xil_Out32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET, Xil_In32(XPAR_AXI_TIMER_0_BASEADDR + XTC_TCSR_OFFSET));
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

	if(flag == 0)
	    {
	    	unsigned char out = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET) & 0xff;
	    	unsigned char position_bit = 0x80;
	    	for(int j = 0; j < 8; j++ )
	    	{
	    		number[j] = (out & position_bit) >> (7-j);
	    		position_bit = position_bit >> 1;
	    		if(position_bit == 0)
	    		{
	    			position_bit = 0x80;
	    		}
	    	}
	    }

    if(flag == 1)
    {
    	unsigned short out = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET);
    	unsigned short position_bit = 0xf000;
    	for(int j=0;j<4;j++)
    	{
    		number[j] = (position_bit & out) >> (3-j)*4;
    		position_bit = position_bit >> 4;
    		if(position_bit == 0)
    		{
    			position_bit = 0xf000;
    		}
    	}
    	number[4] = number[5] = number[6] = number[7] = 16;
    }

    if(flag == 2)
    {
    	unsigned short out = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET);
    	unsigned short rear = 0;

    	for(int j = 0; j<5 ;j++)
    	{
    		rear = out % 10;
    		number[4-j] = rear;
    		out = out / 10;
    	}

    	number[5] = number[6] = number[7] = 16;
    }

    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_ISR_OFFSET, Xil_In32(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_ISR_OFFSET));
}
