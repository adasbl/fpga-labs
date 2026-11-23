library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity tb is
end entity tb;

architecture test of tb is
    constant CLOCK_PERIOD : time := 10 ns;
    constant PIXEL_PERIOD : time := 40 ns;
    constant LINE_PERIOD : time := 800 * PIXEL_PERIOD;
    constant FRAME_PERIOD : time := 525 * LINE_PERIOD;
    constant DEBOUNCE_CYCLES : positive := 8;
    constant BUTTON_TIME : time := (DEBOUNCE_CYCLES + 4) * CLOCK_PERIOD;

    constant BTNL : natural := 3;
    constant BTNC : natural := 2;
    constant BTNR : natural := 1;
    constant BTND : natural := 0;
    constant BLACK : std_logic_vector(3 downto 0) := x"0";
    constant WHITE : std_logic_vector(3 downto 0) := x"F";

    signal clk : std_logic := '0';
    signal sw : std_logic_vector(7 downto 0) := (others => '0');
    signal btn : std_logic_vector(3 downto 0) := (others => '0');
    signal red, green, blue : std_logic_vector(3 downto 0);
    signal hsync, vsync : std_logic;
begin
    clk <= not clk after CLOCK_PERIOD / 2;

    dut : entity work.top
        generic map (DEBOUNCE_CYCLES => DEBOUNCE_CYCLES)
        port map (
            clk_i => clk,
            sw_i => sw,
            btn_i => btn,
            red_o => red,
            green_o => green,
            blue_o => blue,
            hsync_o => hsync,
            vsync_o => vsync
        );

    stimulus : process
        variable frame_start : time := CLOCK_PERIOD / 2 + PIXEL_PERIOD / 2;

        procedure press(button : natural; setting : natural) is
        begin
            sw <= std_logic_vector(to_unsigned(setting, sw'length));
            btn(button) <= '1';
            wait for BUTTON_TIME;
            btn(button) <= '0';
            wait for BUTTON_TIME;
        end procedure;

        procedure redraw is
        begin
            press(BTND, 0);
            -- 147456 clocks to clear RAM, then up to 65536 DDS sample pairs.
            wait for 3 ms;
            wait until falling_edge(vsync);
            wait for (525 - 490) * LINE_PERIOD + PIXEL_PERIOD / 2;
            frame_start := now;
        end procedure;

        procedure check_pixel(x, y : natural; color : std_logic_vector(3 downto 0)) is
        begin
            wait for frame_start + y * LINE_PERIOD + x * PIXEL_PERIOD - now;
            assert red = color and green = color and blue = color
                report "Unexpected RGB at (" & integer'image(x) & ", " & integer'image(y) & ")"
                severity failure;
        end procedure;
    begin
        report "Startup circle";
        check_pixel(320, 176, WHITE);
        check_pixel(256, 240, WHITE);
        check_pixel(320, 240, BLACK);
        check_pixel(384, 240, WHITE);
        check_pixel(320, 304, WHITE);
        check_pixel(650, 304, BLACK);

        report "Epicycloid: f1 = 1, f2 = 3, A = 48, B = 16";
        press(BTNL, 1);
        press(BTNC, 3);
        press(BTNR, 16#34#);
        redraw;
        check_pixel(320, 176, WHITE);
        check_pixel(356, 238, WHITE);
        check_pixel(352, 240, WHITE);
        check_pixel(384, 240, BLACK);

        report "Curtate epicycloid: B = 8";
        press(BTNR, 16#32#);
        redraw;
        check_pixel(320, 176, BLACK);
        check_pixel(320, 184, WHITE);
        check_pixel(360, 240, WHITE);

        report "Prolate epicycloid: B = 24";
        press(BTNR, 16#36#);
        redraw;
        check_pixel(320, 168, WHITE);
        check_pixel(320, 184, BLACK);
        check_pixel(344, 240, WHITE);

        report "Rose: f1 = 1, f2 = 7, A = B = 48";
        press(BTNC, 7);
        press(BTNR, 16#3C#);
        redraw;
        check_pixel(320, 144, WHITE);
        check_pixel(320, 176, BLACK);
        check_pixel(231, 240, WHITE);
        check_pixel(256, 240, BLACK);
        check_pixel(320, 240, WHITE);
        check_pixel(384, 240, BLACK);
        check_pixel(409, 240, WHITE);
        check_pixel(320, 336, WHITE);

        report "Epitrochoid: f1 = 3, f2 = 31";
        press(BTNL, 3);
        press(BTNC, 31);
        redraw;
        check_pixel(252, 172, WHITE);
        check_pixel(272, 192, BLACK);
        check_pixel(320, 240, WHITE);

        report "Epitrochoid: f1 = 30, f2 = 31";
        press(BTNL, 30);
        redraw;
        check_pixel(272, 192, WHITE);
        check_pixel(320, 240, WHITE);

        report "Zero-phase restart: f1 = f2 = 0, A = 64, B = 60";
        press(BTNL, 0);
        press(BTNC, 0);
        press(BTNR, 16#4F#);
        redraw;
        check_pixel(272, 192, BLACK);
        for x in 0 to 799 loop
            if x = 324 then
                check_pixel(x, 240, WHITE);
            else
                check_pixel(x, 240, BLACK);
            end if;
        end loop;

        report "Clipping: zero-frequency point at x = 560 is outside the drawing area";
        press(BTNR, 16#F0#);
        redraw;
        for y in 0 to 524 loop
            for x in 0 to 799 loop
                check_pixel(x, y, BLACK);
            end loop;
        end loop;

        report "PASS: epitrochoids, controls, phase reset, clipping and VGA";
        finish;
        wait;
    end process;

    sync_check : process
        variable pulse_start : time;
    begin
        wait until falling_edge(hsync);
        pulse_start := now;
        wait until rising_edge(hsync);
        assert now - pulse_start = 96 * PIXEL_PERIOD report "Wrong HSYNC width" severity failure;
        wait until falling_edge(hsync);
        assert now - pulse_start = LINE_PERIOD report "Wrong line period" severity failure;

        wait until falling_edge(vsync);
        pulse_start := now;
        wait until rising_edge(vsync);
        assert now - pulse_start = 2 * LINE_PERIOD report "Wrong VSYNC width" severity failure;
        wait until falling_edge(vsync);
        assert now - pulse_start = FRAME_PERIOD report "Wrong frame period" severity failure;
        wait;
    end process;

    watchdog : process
    begin
        wait for 190 ms;
        assert false report "Testbench timed out" severity failure;
        wait;
    end process;
end architecture test;
