#ifndef FRAMEBUFFER_H
#define FRAMEBUFFER_H

#include <stdint.h>
#include "xil_io.h"
#include "xparameters.h"

enum {
    FRAME_WIDTH = 384,
    FRAME_HEIGHT = 341,
    PIXELS_PER_WORD = 4,
    FRAME_WORDS_PER_ROW = FRAME_WIDTH / PIXELS_PER_WORD
};

static inline uint32_t framebuffer_pack(uint8_t first, uint8_t second,
                                        uint8_t third, uint8_t fourth)
{
    return (uint32_t)first | ((uint32_t)second << 8)
           | ((uint32_t)third << 16) | ((uint32_t)fourth << 24);
}

static inline void framebuffer_write(unsigned int x_word, unsigned int y,
                                     uint32_t pixels)
{
    unsigned int offset = (y * FRAME_WORDS_PER_ROW + x_word) * sizeof(uint32_t);
    Xil_Out32(XPAR_FRAMEBUFFER_CTRL_S_AXI_BASEADDR + offset, pixels);
}

#endif
