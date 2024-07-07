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

	// 清一下
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_SRR_OFFSET,XSP_SRR_RESET_MASK);

	//设定SPI接口的通信模式，设定SPI为主设备，CPOL=1,CPHA-0,时钟相位180°，自动方式，高位优先传送
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_CR_OFFSET,XSP_CR_ENABLE_MASK| XSP_CR_MASTER_MODE_MASK | XSP_CR_CLK_POLARITY_MASK
				| XSP_CR_TXFIFO_RESET_MASK | XSP_CR_RXFIFO_RESET_MASK);

	// 使能一下·
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_SSR_OFFSET,~(0x1));

	// 随便发一个
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
		               ,(Xil_In32(XPAR_AXI_TIMER_0_BASEADDR+XTC_TCSR_OFFSET)&~XTC_CSR_LOAD_MASK)\
		               |XTC_CSR_ENABLE_TMR_MASK|XTC_CSR_AUTO_RELOAD_MASK|XTC_CSR_ENABLE_INT_MASK|XTC_CSR_DOWN_COUNT_MASK);//开始计时 自主获取允许中断减计数 */

	//中断控制器intr0中断源使能
	  Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IER_OFFSET,
	  		XPAR_AXI_TIMER_0_INTERRUPT_MASK|
	  		XPAR_AXI_QUAD_SPI_1_IP2INTC_IRPT_MASK|
	  		XPAR_AXI_GPIO_2_IP2INTC_IRPT_MASK);     //开放定时器T0及SPI中断

	Xil_Out32(XPAR_AXI_INTC_0_BASEADDR+XIN_MER_OFFSET,XIN_INT_MASTER_ENABLE_MASK|XIN_INT_HARDWARE_ENABLE_MASK);
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
   	//主程序中的是定时器初始化，此处开关改变了定时器的预置值，故需要重新装载
   	int status=Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET);
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,status&(~XTC_CSR_ENABLE_TMR_MASK));
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TLR_OFFSET,RESET_VALUE);  //为定时器装载改变后的预置值
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET)|XTC_CSR_LOAD_MASK);
   	status=(status&(~XTC_CSR_LOAD_MASK))|XTC_CSR_ENABLE_TMR_MASK;
   	Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,status);
}

void volt_get()
{

	volt = Xil_In16(XPAR_SPI_1_BASEADDR+XSP_DRR_OFFSET) & 0xfff;//启动SPI
	Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,0x8);  //普通中断模式，手动清中断
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_IISR_OFFSET, Xil_In32(XPAR_SPI_1_BASEADDR+XSP_IISR_OFFSET));
	Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_DTR_OFFSET,0x0);
}

void timerHandler() //AD
{

		Xil_Out32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET,Xil_In32(XPAR_TMRCTR_0_BASEADDR+XTC_TCSR_OFFSET));//清定时器中断，不然一直中断周期会不对
		Xil_Out32(XPAR_INTC_0_BASEADDR+XIN_IAR_OFFSET,0x8);  //普通中断模式，手动清中断

		//float cc = volt / 4095 *3.3;
		xil_printf("the volt is %d \r\n",volt);
		Xil_Out32(XPAR_SPI_1_BASEADDR+XSP_DTR_OFFSET,0x0);
}
