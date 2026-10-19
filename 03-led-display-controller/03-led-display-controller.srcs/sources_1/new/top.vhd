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
