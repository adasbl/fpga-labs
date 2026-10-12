library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb is
end tb;

architecture Behavioral of tb is
    signal clk_i : STD_LOGIC := '0';
    signal rst_i : STD_LOGIC := '0';
    signal led_o : STD_LOGIC_VECTOR (2 downto 0);
begin
    dut : entity work.top
        port map (
            clk_i => clk_i,
            rst_i => rst_i,
            led_o => led_o
        );

    clk_i <= not clk_i after 10 ns;

    process
    begin
        -- Reset na poczatku symulacji.
        rst_i <= '1';
        wait for 20 ns;
        rst_i <= '0';

        -- Wszystkie stany, potem reset miedzy zboczami zegara.
        wait for 205 ns;
        rst_i <= '1';
        wait for 20 ns;
        rst_i <= '0';
        wait;
    end process;
end Behavioral;
