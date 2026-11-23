#include "../framebuffer.h"
#include "xuartlite_l.h"

enum {
    FRACTION_BITS = 12,
    ONE = 1 << FRACTION_BITS,
    ESCAPE_SQUARED = 4 * ONE * ONE,
    MAX_ITERATIONS = 48,
    GRAPH_HEIGHT = FRAME_HEIGHT - 16,
    RAMP_TOP = GRAPH_HEIGHT + 4,
    RAMP_BOTTOM = FRAME_HEIGHT - 4
};

typedef struct {
    int32_t real_center;
    int32_t imag_center;
    int32_t step;
    int32_t julia_real;
    int32_t julia_imag;
    int is_julia;
} Fractal;

static const Fractal mandelbrot = {
    .real_center = -ONE / 2,
    .step = 35
};

static const Fractal julia = {
    .step = 35,
    .julia_real = -4 * ONE / 5,
    .julia_imag = 39 * ONE / 250,
    .is_julia = 1
};

static const uint8_t palette[] = {
    0x02, 0x07, 0x0b, 0x0f, 0x17, 0x1b, 0x3f, 0x5f,
    0x7e, 0x9d, 0xbd, 0xfc, 0xf8, 0xf0, 0xe8, 0xc4,
    0xa1, 0x81, 0x61, 0x42, 0x22
};

static unsigned int escape_time(int32_t real, int32_t imag,
                                int32_t c_real, int32_t c_imag)
{
    for (unsigned int step = 0; step < MAX_ITERATIONS; ++step) {
        int32_t real_squared = real * real;
        int32_t imag_squared = imag * imag;

        if (real_squared + imag_squared > ESCAPE_SQUARED) {
            return step;
        }

        imag = (2 * real * imag) / ONE + c_imag;
        real = (real_squared - imag_squared) / ONE + c_real;
    }
    return MAX_ITERATIONS;
}

static uint8_t color_at(const Fractal *fractal, unsigned int x, unsigned int y)
{
    int32_t real = fractal->real_center + ((int32_t)x - FRAME_WIDTH / 2) * fractal->step;
    int32_t imag = fractal->imag_center + (GRAPH_HEIGHT / 2 - (int32_t)y) * fractal->step;
    unsigned int steps;

    if (fractal->is_julia) {
        steps = escape_time(real, imag, fractal->julia_real, fractal->julia_imag);
    } else {
        steps = escape_time(0, 0, real, imag);
    }

    return steps == MAX_ITERATIONS ? 0 : palette[steps % sizeof(palette)];
}

static void draw_fractal(const Fractal *fractal)
{
    for (unsigned int y = 0; y < GRAPH_HEIGHT; ++y) {
        for (unsigned int word = 0; word < FRAME_WORDS_PER_ROW; ++word) {
            unsigned int x = word * PIXELS_PER_WORD;
            uint32_t pixels = framebuffer_pack(color_at(fractal, x, y),
                                               color_at(fractal, x + 1, y),
                                               color_at(fractal, x + 2, y),
                                               color_at(fractal, x + 3, y));
            framebuffer_write(word, y, pixels);
        }
    }
}

static void draw_palette(void)
{
    for (unsigned int y = GRAPH_HEIGHT; y < FRAME_HEIGHT; ++y) {
        for (unsigned int word = 0; word < FRAME_WORDS_PER_ROW; ++word) {
            uint8_t color = 0;
            if (y >= RAMP_TOP && y < RAMP_BOTTOM) {
                color = palette[word * sizeof(palette) / FRAME_WORDS_PER_ROW];
            }
            framebuffer_write(word, y, framebuffer_pack(color, color, color, color));
        }
    }
}

static void print_controls(void)
{
    const char *text = "\r\nFractal viewer: M = Mandelbrot, J = Julia\r\n";

    while (*text != '\0') {
        XUartLite_SendByte(XPAR_AXI_UARTLITE_0_BASEADDR, (uint8_t)*text++);
    }
}

int main(void)
{
    draw_palette();
    print_controls();
    draw_fractal(&mandelbrot);

    for (;;) {
        uint8_t key = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);

        switch (key) {
        case 'm':
        case 'M':
            draw_fractal(&mandelbrot);
            break;
        case 'j':
        case 'J':
            draw_fractal(&julia);
            break;
        }
    }
}
