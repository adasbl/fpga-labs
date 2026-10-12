library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb is
end tb;

architecture Behavioral of tb is
    signal clk_i      : STD_LOGIC := '0';
    signal btn_i      : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal sw_i       : STD_LOGIC_VECTOR (7 downto 0) := x"AA";
    signal led7_an_o  : STD_LOGIC_VECTOR (3 downto 0);
    signal led7_seg_o : STD_LOGIC_VECTOR (7 downto 0);
    signal finished  : boolean := false;
begin
    -- Zegar 100 MHz; zatrzymuje sie po zakonczeniu scenariusza.
    clk_i <= not clk_i after 5 ns when not finished else '0';

    dut : entity work.top
        port map (
            clk_i => clk_i,
            btn_i => btn_i,
            sw_i => sw_i,
            led7_an_o => led7_an_o,
            led7_seg_o => led7_seg_o
        );

    process
    begin
        -- SW7..4 = 1010: poczatkowo swieca dwie kropki.
        -- SW3..0 = 1010: pierwsza wpisywana cyfra to A.
        wait for 1 ms;

        btn_i <= "1000";       -- BTNL: wpisz A do AN3
        wait for 1 ms;
        btn_i <= "0000";
        wait for 1 ms;
        sw_i <= x"52";         -- cyfra 2, zmiana kropek na 0101
        wait for 1 ms;

        btn_i <= "0100";       -- BTNC: wpisz 2 do AN2
        wait for 1 ms;
        btn_i <= "0000";
        wait for 1 ms;
        sw_i <= x"FF";         -- cyfra F, wszystkie kropki wlaczone
        wait for 1 ms;

        btn_i <= "0010";       -- BTNR: wpisz F do AN1
        wait for 1 ms;
        btn_i <= "0000";
        wait for 1 ms;
        sw_i <= x"F5";         -- cyfra 5, bez zmiany kropek
        wait for 1 ms;

        btn_i <= "0001";       -- BTND: wpisz 5 do AN0
        wait for 1 ms;
        btn_i <= "0000";
        wait for 1 ms;
        sw_i <= x"09";         -- kropki gasna; zapisane A2F5 pozostaje
        wait for 1 ms;

        wait for 4 ms;         -- pelny obieg czterech zapisanych cyfr
        finished <= true;
        wait;
    end process;
end Behavioral;
