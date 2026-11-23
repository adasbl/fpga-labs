#include "calculator.h"

#define MAX_MAGNITUDE INT32_C(9999999)

static const uint8_t digit_segments[] = {
    0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f
};

static void lift_stack(Calculator *calc)
{
    calc->t = calc->z;
    calc->z = calc->y;
    calc->y = calc->x;
}

static void enter_digit(Calculator *calc, int digit)
{
    if (!calc->entering) {
        if (calc->lift_on_digit) {
            lift_stack(calc);
        }
        calc->x = 0;
        calc->entering = true;
        calc->negative_entry = false;
    }

    int32_t magnitude = calc->x < 0 ? -calc->x : calc->x;
    magnitude = magnitude * 10 + digit;
    if (magnitude > MAX_MAGNITUDE) {
        return;
    }
    calc->x = calc->negative_entry ? -magnitude : magnitude;
}

static void binary_operation(Calculator *calc, uint8_t key)
{
    int64_t result;
    switch (key) {
    case '+':
        result = calc->y + calc->x;
        break;
    case '-':
        result = calc->y - calc->x;
        break;
    case '*':
        result = (int64_t)calc->y * calc->x;
        break;
    case '/':
        if (calc->x == 0) {
            calc->error = true;
            return;
        }
        result = calc->y / calc->x;
        break;
    default:
        return;
    }

    if (result < -MAX_MAGNITUDE || result > MAX_MAGNITUDE) {
        calc->error = true;
        return;
    }
    calc->x = (int32_t)result;
    calc->y = calc->z;
    calc->z = calc->t;
}

bool calculator_key(Calculator *calc, uint8_t key)
{
    bool skip_lf = key == '\n' && calc->previous_cr;
    calc->previous_cr = key == '\r';
    if (skip_lf) {
        return false;
    }

    if (key == 'C' || key == 'c') {
        calc->x = 0;
        calc->entering = false;
        calc->negative_entry = false;
        calc->lift_on_digit = false;
        calc->error = false;
        return true;
    }
    if (calc->error) {
        return false;
    }

    if (key >= '0' && key <= '9') {
        enter_digit(calc, key - '0');
        return true;
    }
    if (key == 'S' || key == 's') {
        calc->x = -calc->x;
        if (calc->entering) {
            calc->negative_entry = !calc->negative_entry;
        }
        return true;
    }

    int32_t old_x = calc->x;
    switch (key) {
    case '\r':
    case '\n':
        lift_stack(calc);
        break;
    case 'X':
    case 'x':
        calc->x = calc->y;
        calc->y = old_x;
        break;
    case 'R':
    case 'r':
        calc->x = calc->y;
        calc->y = calc->z;
        calc->z = calc->t;
        calc->t = old_x;
        break;
    case '+':
    case '-':
    case '*':
    case '/':
        binary_operation(calc, key);
        break;
    default:
        return false;
    }
    calc->entering = false;
    calc->lift_on_digit = key != '\r' && key != '\n';
    return true;
}

void calculator_display(const Calculator *calc, uint8_t segments[DISPLAY_DIGITS])
{
    if (calc->error) {
        /* E, r, r, o, r on positions AN6 through AN2. */
        static const uint8_t error_segments[] = {0, 0, 0x50, 0x5c, 0x50, 0x50, 0x79, 0};
        for (int digit = 0; digit < DISPLAY_DIGITS; ++digit) {
            segments[digit] = error_segments[digit];
        }
        return;
    }

    uint32_t magnitude = (uint32_t)(calc->x < 0 ? -calc->x : calc->x);
    segments[0] = digit_segments[magnitude % 10];
    for (int digit = 1; digit < DISPLAY_DIGITS - 1; ++digit) {
        magnitude /= 10;
        segments[digit] = magnitude ? digit_segments[magnitude % 10] : 0;
    }
    bool show_minus = calc->x < 0 || (calc->entering && calc->negative_entry);
    segments[DISPLAY_DIGITS - 1] = show_minus ? 0x40 : 0;
}

uint8_t calculator_leds(const Calculator *calc)
{
    return (uint8_t)((calc->y != 0) * 4 + (calc->z != 0) * 2 + (calc->t != 0));
}
