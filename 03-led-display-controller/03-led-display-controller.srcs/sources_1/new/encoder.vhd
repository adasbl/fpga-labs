library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Enkoder szesnastkowy i pamiec czterech niezaleznych cyfr.
entity encoder is
    port (
        clk_i   : in  STD_LOGIC;
        btn_i   : in  STD_LOGIC_VECTOR (3 downto 0);
        sw_i    : in  STD_LOGIC_VECTOR (7 downto 0);
        digit_o : out STD_LOGIC_VECTOR (31 downto 0)
    );
end encoder;

architecture Behavioral of encoder is
    type segment_memory is array (0 to 3) of STD_LOGIC_VECTOR (6 downto 0);
    signal memory : segment_memory := (others => (others => '1'));
    signal segments : STD_LOGIC_VECTOR (6 downto 0);
    signal btn_meta, btn_sync : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal sw_meta, sw_sync : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of btn_meta, btn_sync, sw_meta, sw_sync : signal is "TRUE";
begin
    -- Dwa stopnie synchronizacji wejsc z plytki do zegara 100 MHz.
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            btn_meta <= btn_i;
            btn_sync <= btn_meta;
            sw_meta <= sw_i;
            sw_sync <= sw_meta;
            for i in 0 to 3 loop
                if btn_sync(i) = '1' then
                    memory(i) <= segments;
                end if;
            end loop;
        end if;
    end process;

    -- Kolejnosc bitow: A B C D E F G; '0' zapala segment.
    with sw_sync(3 downto 0) select
        segments <= "0000001" when "0000", -- 0
                    "1001111" when "0001", -- 1
                    "0010010" when "0010", -- 2
                    "0000110" when "0011", -- 3
                    "1001100" when "0100", -- 4
                    "0100100" when "0101", -- 5
                    "0100000" when "0110", -- 6
                    "0001111" when "0111", -- 7
                    "0000000" when "1000", -- 8
                    "0000100" when "1001", -- 9
                    "0001000" when "1010", -- A
                    "1100000" when "1011", -- b
                    "0110001" when "1100", -- C
                    "1000010" when "1101", -- d
                    "0110000" when "1110", -- E
                    "0111000" when "1111", -- F
                    "1111111" when others;

    -- Kropki zaleza od przelacznikow, niezaleznie od zapisu cyfr.
    digit_o <= memory(3) & (not sw_sync(7)) &
               memory(2) & (not sw_sync(6)) &
               memory(1) & (not sw_sync(5)) &
               memory(0) & (not sw_sync(4));
end Behavioral;
