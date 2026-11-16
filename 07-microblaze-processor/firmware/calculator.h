#ifndef CALCULATOR_H
#define CALCULATOR_H

#include <stdbool.h>
#include <stdint.h>

enum { DISPLAY_DIGITS = 8 };

typedef struct {
    int32_t x;
    int32_t y;
    int32_t z;
    int32_t t;
    bool entering;
    bool negative_entry;
    bool lift_on_digit;
    bool error;
    bool previous_cr;
} Calculator;

/* Returns true when the display and stack LEDs should be updated. */
bool calculator_key(Calculator *calc, uint8_t key);

/* Active-high segment masks, starting at the rightmost digit (AN0). */
void calculator_display(const Calculator *calc, uint8_t segments[DISPLAY_DIGITS]);
uint8_t calculator_leds(const Calculator *calc);

#endif
