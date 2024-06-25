#include <stdio.h>
#include "xil_io.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xintc_l.h"
#include "xtmrctr_l.h"
#include "xparameters.h"

#define RESET_VALUE 100000 - 2
#define XPAR_AXI_TIMER_0_INTERRUPT_MASK 4U

void display(char segcode[], short tmp[], short position, int k)
{
    for (int i = 0; i < 8; i++)
    {
        Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA2_OFFSET, segcode[tmp[(i + k) % 8]]); // 先展示一个
        Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_DATA_OFFSET, position);                   // 先展示下一个
        for (int j = 0; j < 10000; j++)
            ; // for循环在这卡一会儿，显示一下
        position = position >> 1;
    }
}

int main()
{
    unsigned short lastSwitchState, currentSwitchState;             // 存上次的状态和这次的
    unsigned short led;                                             // output to LED
    Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI_OFFSET, 0xffff); // 按钮输入
    Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);   // LED输出

    unsigned short currentBtn, lastBtn, realBtn;
    char segcode[6] = {0xc6, 0xc1, 0xc7, 0x88, 0xc0, 0xff}; // 段码
    short tmp[8] = {5, 5, 5, 5, 5, 5, 5, 5};
    int k = 0;
    short position = 0xff7f;
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI_OFFSET, 0x0);
    Xil_Out8(XPAR_AXI_GPIO_1_BASEADDR + XGPIO_TRI2_OFFSET, 0x0);
    Xil_Out16(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_TRI_OFFSET, 0x1f);
    while (1)
    {
        lastSwitchState = currentSwitchState;
        currentSwitchState = Xil_In16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA_OFFSET) & 0xffff; // 读取新状态
        if (lastSwitchState != currentSwitchState)                                            // 如果真的改变了
        {
            led = currentSwitchState;
        }

        Xil_Out16(XPAR_AXI_GPIO_0_BASEADDR + XGPIO_DATA2_OFFSET, led); // 输出到LED

        display(segcode, tmp, position, k); // 数码管显示
        position = 0xff7f;
        currentBtn = Xil_In8(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET) & 0x1f; // 低五位
        if (currentBtn)
        {
            while (currentBtn) // 没更新一直卡在这
            {
                display(segcode, tmp, position, k);
                currentBtn = (Xil_In8(XPAR_AXI_GPIO_2_BASEADDR + XGPIO_DATA_OFFSET) & 0x1f);
                realBtn = (currentBtn ^ lastBtn) & lastBtn; // 当且仅当按下到未按下，realBtn不为0，使得跳出循环
                lastBtn = currentBtn;
                if (realBtn)
                {
                    break;
                }
            }

            switch (realBtn)
            {
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
