#include "calculator.h"

#include "xgpio_l.h"
#include "xparameters.h"
#include "xtmrctr_l.h"
#include "xuartlite_l.h"

#define DISPLAY_GPIO XPAR_AXI_GPIO_0_BASEADDR
#define LED_GPIO XPAR_AXI_GPIO_1_BASEADDR
#define UART XPAR_AXI_UARTLITE_0_BASEADDR
#define TIMER XPAR_AXI_TIMER_0_BASEADDR
#define SEGMENTS XGPIO_DATA_OFFSET
#define ANODES (XGPIO_DATA_OFFSET + XGPIO_CHAN_OFFSET)

/* 250 us per digit gives a refresh rate of 500 Hz for the whole display. */
#define DIGIT_TICKS (XPAR_AXI_TIMER_0_CLOCK_FREQ_HZ / 4000u)

int main(void)
{
    Calculator calc = {0};
    uint8_t segments[DISPLAY_DIGITS];
    uint8_t digit = DISPLAY_DIGITS - 1;

    XGpio_WriteReg(DISPLAY_GPIO, ANODES, 0xff);
    XGpio_WriteReg(DISPLAY_GPIO, SEGMENTS, 0xff);
    XGpio_WriteReg(LED_GPIO, XGPIO_DATA_OFFSET, 0);
    XUartLite_SetControlReg(UART, XUL_CR_FIFO_RX_RESET);
    calculator_display(&calc, segments);

    XTmrCtr_SetLoadReg(TIMER, 0, 0);
    XTmrCtr_SetControlStatusReg(TIMER, 0, XTC_CSR_LOAD_MASK);
    XTmrCtr_SetControlStatusReg(TIMER, 0, XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_AUTO_RELOAD_MASK);
    uint32_t last_refresh = XTmrCtr_GetTimerCounterReg(TIMER, 0) - DIGIT_TICKS;

    for (;;) {
        uint32_t now = XTmrCtr_GetTimerCounterReg(TIMER, 0);
        if (now - last_refresh >= DIGIT_TICKS) {
            last_refresh = now;
            digit = (digit + 1u) % DISPLAY_DIGITS;
            XGpio_WriteReg(DISPLAY_GPIO, ANODES, 0xff);
            XGpio_WriteReg(DISPLAY_GPIO, SEGMENTS, 0xffu ^ segments[digit]);
            if (segments[digit]) {
                XGpio_WriteReg(DISPLAY_GPIO, ANODES, 0xffu ^ (1u << digit));
            }
        }

        if (!XUartLite_IsReceiveEmpty(UART)) {
            uint8_t key = (uint8_t)XUartLite_ReadReg(UART, XUL_RX_FIFO_OFFSET);
            if (calculator_key(&calc, key)) {
                calculator_display(&calc, segments);
                XGpio_WriteReg(LED_GPIO, XGPIO_DATA_OFFSET, calculator_leds(&calc));
            }
        }
    }
}
