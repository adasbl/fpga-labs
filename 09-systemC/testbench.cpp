#include "design.h"
#include <bitset>
#include <iostream>

int sc_main(int, char*[]) {
    sc_clock clk_i("clk_i", 20, SC_NS, 0.5, 10, SC_NS);
    sc_signal<bool> rst_i("rst_i");
    sc_signal<sc_uint<3>> led_o("led_o");

    gray_counter dut("dut");
    dut.clk_i(clk_i);
    dut.rst_i(rst_i);
    dut.led_o(led_o);

    sc_trace_file* trace = sc_create_vcd_trace_file("gray_counter");
    if (!trace) {
        return 1;
    }
    trace->set_time_unit(1, SC_NS);
    sc_trace(trace, clk_i, "clk_i");
    sc_trace(trace, rst_i, "rst_i");
    sc_trace(trace, led_o, "led_o");

    int errors = 0;
    auto check_at = [&](unsigned ns, unsigned expected) {
        sc_start(sc_time(ns, SC_NS) - sc_time_stamp());
        const unsigned actual = led_o.read().to_uint();
        if (actual != expected) {
            ++errors;
            std::cerr << ns << " ns: led_o = " << std::bitset<3>(actual)
                      << ", expected " << std::bitset<3>(expected) << '\n';
        }
    };

    rst_i.write(true);
    check_at(1, 0);
    check_at(11, 0);
    sc_start(9, SC_NS); // 20 ns
    rst_i.write(false);
    check_at(21, 0);

    // Pelny cykl i dwa kroki nastepnego. Sprawdzamy oba zbocza zegara.
    const unsigned expected[] = {1, 3, 2, 6, 7, 5, 4, 0, 1, 3};
    unsigned rising_edge = 30;
    for (unsigned state : expected) {
        check_at(rising_edge + 1, state);
        check_at(rising_edge + 11, state);
        rising_edge += 20;
    }

    sc_start(4, SC_NS); // 225 ns, miedzy zboczami
    rst_i.write(true);
    check_at(226, 0);
    check_at(231, 0);
    sc_start(14, SC_NS); // 245 ns
    rst_i.write(false);
    check_at(246, 0);
    check_at(251, 1);
    check_at(271, 3);
    sc_start(10, SC_NS);

    sc_close_vcd_trace_file(trace);
}
