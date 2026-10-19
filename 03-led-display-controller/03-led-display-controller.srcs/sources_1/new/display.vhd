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
