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

    Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff);//switch输入·
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

