library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity tb is
end entity;

architecture test of tb is
    constant CLK_PERIOD : time := 10 ns;
    -- Shorten the delays while keeping the 100 MHz clock.
    constant SCAN_TICKS : positive := 64;
    constant DEBOUNCE_TICKS : positive := 256;
    constant LONG_PRESS_TICKS : positive := 4096;
    constant BLINK_TICKS : positive := 512;
    constant SCAN_PERIOD : time := SCAN_TICKS * CLK_PERIOD;
    constant FRAME_PERIOD : time := 4 * SCAN_PERIOD;
    constant DEBOUNCE_TIME : time := DEBOUNCE_TICKS * CLK_PERIOD;
    constant LONG_PRESS_TIME : time := LONG_PRESS_TICKS * CLK_PERIOD;
    constant BLINK_PERIOD : time := 2 * BLINK_TICKS * CLK_PERIOD;
    constant BUTTON_SETTLE_TIME : time := DEBOUNCE_TIME + 1 us;

    subtype button_state is std_logic_vector(3 downto 0);
    constant RELEASED : button_state := "0000";
    constant BTNU : button_state := "0010";
    constant BTND : button_state := "0001";
    constant BTNL : button_state := "1000";
    constant BTNR : button_state := "0100";

    subtype segment_pattern is std_logic_vector(7 downto 0);
    type hex_patterns is array (0 to 15) of segment_pattern;
    constant HEX_SEGMENTS : hex_patterns := (
        x"03", x"9F", x"25", x"0D", x"99", x"49", x"41", x"1F",
        x"01", x"09", x"11", x"C1", x"63", x"85", x"61", x"71"
    );
    subtype display_word is std_logic_vector(15 downto 0);
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
            G_DEBOUNCE_TICKS => DEBOUNCE_TICKS,
            G_LONG_PRESS_TICKS => LONG_PRESS_TICKS,
            G_BLINK_TICKS => BLINK_TICKS
        )
        port map (
            clk_i => clk,
            rst_i => rst,
            button_i => buttons,
            led7_an_o => an,
            led7_seg_o => seg
        );

    stimulus : process
        procedure check_display(expected : display_word; test_name : string;
                                selected : integer := -1) is
            variable first_slot : time;
            variable expected_seg : segment_pattern;
            variable saw_blank, saw_visible : boolean := false;
        begin
            -- Observe a full blink cycle, including when all digits should stay visible.
            for frame in 1 to BLINK_PERIOD / FRAME_PERIOD + 2 loop
                wait until an = ANODES(0) for FRAME_PERIOD + SCAN_PERIOD;
                first_slot := now;

                for digit in ANODES'range loop
                    if digit > 0 then
                        wait on an for SCAN_PERIOD;
                    end if;
                    assert an = ANODES(digit) and now = first_slot + digit * SCAN_PERIOD
                        report test_name & ": invalid scan at digit " & integer'image(digit)
                        severity failure;

                    wait for 1 ns;
                    expected_seg := HEX_SEGMENTS(to_integer(unsigned(expected(4 * digit + 3 downto 4 * digit))));
                    if digit = selected and seg = x"FF" then
                        saw_blank := true;
                    else
                        assert seg = expected_seg
                            report test_name & ": wrong segments at digit " & integer'image(digit)
                            severity failure;
                        if digit = selected then
                            saw_visible := true;
                        end if;
                    end if;
                end loop;
            end loop;
            assert selected = -1 or (saw_blank and saw_visible)
                report test_name & ": selected digit did not blink" severity failure;
        end procedure;

        procedure press(button : button_state; duration : time := BUTTON_SETTLE_TIME) is
        begin
            buttons <= button;
            wait for duration;
            buttons <= RELEASED;
            wait for BUTTON_SETTLE_TIME;
        end procedure;
    begin
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        check_display(x"0000", "Initial reset");
        press(BTNU);
        press(BTNL);
        check_display(x"0000", "Display mode ignores a short press");

        buttons <= BTNL;
        wait for 2 * LONG_PRESS_TIME + BUTTON_SETTLE_TIME;
        check_display(x"0000", "Long BTNL enters edit mode once", 0);
        buttons <= RELEASED;
        wait for BUTTON_SETTLE_TIME;
        check_display(x"0000", "Releasing long BTNL keeps the selection", 0);

        press(BTNU, DEBOUNCE_TIME / 2);
        check_display(x"0000", "Short input pulse is filtered", 0);

        buttons <= BTNU;
        wait for BUTTON_SETTLE_TIME;
        check_display(x"0001", "BTNU increments once while held", 0);

        buttons <= RELEASED;
        wait for DEBOUNCE_TIME / 2;
        buttons <= BTNU;
        wait for BUTTON_SETTLE_TIME;
        check_display(x"0001", "Short release is filtered", 0);
        buttons <= RELEASED;
        wait for BUTTON_SETTLE_TIME;

        press(BTND);
        check_display(x"0000", "BTND decrements the selected digit", 0);
        press(BTND);
        check_display(x"000F", "Decrement wraps from 0 to F", 0);
        press(BTNU);
        check_display(x"0000", "Increment wraps from F to 0", 0);
        press(BTNU or BTND);
        check_display(x"0000", "Simultaneous BTNU and BTND keep the same value", 0);

        press(BTNU);
        press(BTNL);
        press(BTNU);
        check_display(x"0011", "BTNL selects the second digit", 1);
        press(BTNL);
        press(BTND);
        check_display(x"0F11", "BTNL selects the third digit", 2);
        press(BTNL);
        press(BTNU);
        check_display(x"1F11", "BTNL selects the fourth digit", 3);
        press(BTNL);
        check_display(x"1F11", "BTNL wraps to the rightmost digit", 0);
        press(BTNR);
        check_display(x"1F11", "BTNR wraps to the leftmost digit", 3);
        press(BTNR);
        press(BTNU);
        check_display(x"1011", "BTNR selects the next digit to the right", 2);

        press(BTNL, LONG_PRESS_TIME + BUTTON_SETTLE_TIME);
        press(BTND);
        check_display(x"1011", "Long BTNL exits edit mode and preserves the value");
        press(BTNL, LONG_PRESS_TIME + BUTTON_SETTLE_TIME);
        check_display(x"1011", "Reentering edit mode selects the rightmost digit", 0);

        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        press(BTNU);
        check_display(x"0000", "Reset clears all digits and returns to display mode");

        report "PASS: PicoBlaze digit editor, mode switching, button filtering, and LED scan" severity note;
        finish;
        wait;
    end process;
end architecture;
