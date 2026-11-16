library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity tb is
end entity;

architecture test of tb is
    constant CLK_PERIOD : time := 10 ns;
    -- Shorten the scan and debounce delays while keeping the 100 MHz clock.
    constant SCAN_TICKS : positive := 128;
    constant DEBOUNCE_TICKS : positive := 256;
    constant SCAN_PERIOD : time := SCAN_TICKS * CLK_PERIOD;
    constant DEBOUNCE_TIME : time := DEBOUNCE_TICKS * CLK_PERIOD;
    constant BUTTON_SETTLE_TIME : time := DEBOUNCE_TIME + 1 us;

    subtype button_state is std_logic_vector(3 downto 0);
    constant RELEASED : button_state := "0000";
    constant BTNU : button_state := "0010";
    constant BTND : button_state := "0001";

    subtype segment_pattern is std_logic_vector(7 downto 0);
    constant SEG_0 : segment_pattern := x"03";
    constant SEG_1 : segment_pattern := x"9F";
    constant SEG_F : segment_pattern := x"71";
    type anode_patterns is array (0 to 3) of std_logic_vector(3 downto 0);
    constant ANODES : anode_patterns := ("1110", "1101", "1011", "0111");

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal buttons : button_state := RELEASED;
    signal an : std_logic_vector(3 downto 0);
    signal seg : segment_pattern;
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.top
        generic map (
            G_SCAN_DIV => SCAN_TICKS,
            G_DEBOUNCE_TICKS => DEBOUNCE_TICKS
        )
        port map (
            clk_i => clk,
            rst_i => rst,
            button_i => buttons,
            led7_an_o => an,
            led7_seg_o => seg
        );

    stimulus : process
        procedure check_display(expected_low : segment_pattern; test_name : string) is
            variable first_slot : time;
        begin
            wait until an = ANODES(0) for 5 * SCAN_PERIOD;
            first_slot := now;

            for digit in ANODES'range loop
                if digit > 0 then
                    wait on an for SCAN_PERIOD;
                end if;
                assert an = ANODES(digit) and now = first_slot + digit * SCAN_PERIOD
                    report test_name & ": invalid scan at digit " & integer'image(digit)
                    severity failure;

                wait for 1 ns;
                if digit = 0 then
                    assert seg = expected_low
                        report test_name & ": wrong rightmost digit" severity failure;
                else
                    assert seg = SEG_0
                        report test_name & ": expected zero at digit " & integer'image(digit)
                        severity failure;
                end if;
            end loop;
        end procedure;

        procedure press(button : button_state; expected_low : segment_pattern; test_name : string) is
        begin
            buttons <= button;
            wait for BUTTON_SETTLE_TIME;
            check_display(expected_low, test_name);
            buttons <= RELEASED;
            wait for BUTTON_SETTLE_TIME;
        end procedure;
    begin
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        check_display(SEG_0, "Initial reset");

        buttons <= BTNU;
        wait for DEBOUNCE_TIME / 2;
        buttons <= RELEASED;
        wait for BUTTON_SETTLE_TIME;
        check_display(SEG_0, "Short press is filtered");

        buttons <= BTNU;
        wait for BUTTON_SETTLE_TIME;
        check_display(SEG_1, "BTNU increments the counter");
        check_display(SEG_1, "Holding BTNU keeps the same value");

        buttons <= RELEASED;
        wait for DEBOUNCE_TIME / 2;
        buttons <= BTNU;
        wait for BUTTON_SETTLE_TIME;
        check_display(SEG_1, "Short release is filtered");
        buttons <= RELEASED;
        wait for BUTTON_SETTLE_TIME;

        press(BTND, SEG_0, "BTND decrements the counter");
        press(BTND, SEG_F, "Decrement wraps from 0 to F");
        press(BTNU, SEG_0, "Increment wraps from F to 0");
        press(BTNU or BTND, SEG_0, "Simultaneous BTNU and BTND keep the same value");

        press(BTNU, SEG_1, "BTNU increments after release");
        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        check_display(SEG_0, "Reset clears a nonzero count");

        report "PASS: PicoBlaze counter, reset, button filtering, and LED scan" severity note;
        finish;
        wait;
    end process;
end architecture;
