#ifndef GRAY_COUNTER_H
#define GRAY_COUNTER_H

#include "systemc.h"

SC_MODULE(gray_counter) {
    sc_in<bool> clk_i{"clk_i"};
    sc_in<bool> rst_i{"rst_i"};
    sc_out<sc_uint<3>> led_o{"led_o"};

    SC_CTOR(gray_counter) {
        SC_METHOD(update);
        sensitive << clk_i.pos() << rst_i.pos();
        dont_initialize();
    }

private:
    sc_uint<3> gray = 0;

    void update() {
        if (rst_i.read()) {
            gray = 0;
        } else {
            switch (gray.to_uint()) {
                case 0b000: gray = 0b001; break;
                case 0b001: gray = 0b011; break;
                case 0b011: gray = 0b010; break;
                case 0b010: gray = 0b110; break;
                case 0b110: gray = 0b111; break;
                case 0b111: gray = 0b101; break;
                case 0b101: gray = 0b100; break;
                case 0b100: gray = 0b000; break;
            }
        }
        led_o.write(gray);
    }
};

#endif
