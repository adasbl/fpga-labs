library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Sterownik czterech cyfr; segmenty aktywne stanem '0'.
-- digit_i: AN3 & AN2 & AN1 & AN0, po 8 bitow ABCDEFG DP.
entity display is
    generic (clk_div : positive := 100000);
    port (
        clk_i      : in  STD_LOGIC;
        rst_i      : in  STD_LOGIC;
        digit_i    : in  STD_LOGIC_VECTOR (31 downto 0);
        led7_an_o  : out STD_LOGIC_VECTOR (3 downto 0);
        led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0)
    );
end display;

architecture Behavioral of display is
    signal counter : natural range 0 to clk_div - 1 := 0;
    signal selected_digit : natural range 0 to 3 := 0;
begin
    -- 100 MHz / 100000 = zmiana cyfry co 1 ms.
    process (clk_i, rst_i)
    begin
        if rst_i = '1' then
            counter <= 0;
            selected_digit <= 0;
        elsif rising_edge(clk_i) then
            if counter = clk_div - 1 then
                counter <= 0;
                if selected_digit = 3 then
                    selected_digit <= 0;
                else
                    selected_digit <= selected_digit + 1;
                end if;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process (rst_i, selected_digit, digit_i)
    begin
        if rst_i = '1' then
            led7_an_o <= "0000";
            led7_seg_o <= "00000000";
        else
            case selected_digit is
                when 0 =>
                    led7_an_o <= "1110";
                    led7_seg_o <= digit_i(7 downto 0);
                when 1 =>
                    led7_an_o <= "1101";
                    led7_seg_o <= digit_i(15 downto 8);
                when 2 =>
                    led7_an_o <= "1011";
                    led7_seg_o <= digit_i(23 downto 16);
                when 3 =>
                    led7_an_o <= "0111";
                    led7_seg_o <= digit_i(31 downto 24);
            end case;
        end if;
    end process;
end Behavioral;

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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    generic (clk_div : positive := 100000);
    port (
        clk_i      : in  STD_LOGIC;
        btn_i      : in  STD_LOGIC_VECTOR (3 downto 0);
        sw_i       : in  STD_LOGIC_VECTOR (7 downto 0);
        led7_an_o  : out STD_LOGIC_VECTOR (3 downto 0);
        led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0)
    );
end top;

architecture Behavioral of top is
    signal digit : STD_LOGIC_VECTOR (31 downto 0);
begin
    encoder_inst : entity work.encoder
        port map (
            clk_i => clk_i,
            btn_i => btn_i,
            sw_i => sw_i,
            digit_o => digit
        );

    -- Interfejs top z instrukcji nie ma resetu. Reset podbloku
    -- display jest dostepny do ponownego uzycia i testowany w tb.
    display_inst : entity work.display
        generic map (clk_div => clk_div)
        port map (
            clk_i => clk_i,
            rst_i => '0',
            digit_i => digit,
            led7_an_o => led7_an_o,
            led7_seg_o => led7_seg_o
        );
end Behavioral;
