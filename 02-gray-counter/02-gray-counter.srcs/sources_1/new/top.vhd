library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port (
        clk_i : in  STD_LOGIC;
        rst_i : in  STD_LOGIC;
        led_o : out STD_LOGIC_VECTOR (2 downto 0)
    );
end top;

architecture Behavioral of top is
    signal gray : STD_LOGIC_VECTOR (2 downto 0);
begin
    led_o <= gray;

    process (clk_i, rst_i)
    begin
        -- Reset asynchroniczny, aktywny stanem wysokim.
        if rst_i = '1' then
            gray <= "000";
        elsif rising_edge(clk_i) then
            -- W kazdym kroku zmienia sie tylko jeden bit.
            case gray is
                when "000" => gray <= "001";
                when "001" => gray <= "011";
                when "011" => gray <= "010";
                when "010" => gray <= "110";
                when "110" => gray <= "111";
                when "111" => gray <= "101";
                when "101" => gray <= "100";
                when "100" => gray <= "000";
                when others => gray <= "000";
            end case;
        end if;
    end process;
end Behavioral;
