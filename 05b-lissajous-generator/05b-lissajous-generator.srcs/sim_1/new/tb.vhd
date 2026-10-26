library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Proste wymuszenia do recznego ogladania przebiegow; bez automatycznych ocen.
-- Symulacja korzysta z wygenerowanych IP video_mem i singen.
entity tb is
end entity;

architecture Behavioral of tb is
    signal clk : std_logic := '0';
    signal sw : std_logic_vector(7 downto 0) := (others => '0');
    signal btn : std_logic_vector(3 downto 0) := (others => '0');
    signal red, green, blue : std_logic_vector(3 downto 0);
    signal hsync, vsync : std_logic;
begin
    clk <= not clk after 5 ns;
    dut : entity work.top
        port map (clk_i => clk, sw_i => sw, btn_i => btn,
                  red_o => red, green_o => green, blue_o => blue,
                  hsync_o => hsync, vsync_o => vsync);

    process
        procedure press(constant button : natural; constant value : natural) is
        begin
            sw <= std_logic_vector(to_unsigned(value, 8));
            wait for 1 us;
            btn(button) <= '1';
            wait for 20 ms;
            btn(button) <= '0';
            wait for 20 ms;
        end procedure;
    begin
        wait for 20 ms; -- Ustawienia poczatkowe: okrag.
        press(3, 1);   -- BTNL: X = 1.
        press(2, 2);   -- BTNC: Y = 2.
        press(1, 0);   -- BTNR: faza Y = 0.
        press(0, 0);   -- BTND: czyszczenie obrazu i restart DDS.
        wait for 20 ms;
        press(1, 64);  -- Faza Y = pi/2.
        press(0, 0);
        wait for 20 ms;
        press(1, 192); -- Faza Y = 3*pi/2.
        press(0, 0);
        wait;
    end process;
end architecture;
