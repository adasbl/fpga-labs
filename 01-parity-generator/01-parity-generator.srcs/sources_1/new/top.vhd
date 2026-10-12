----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2026 12:59:16 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port (
        sw_i       : in  STD_LOGIC_VECTOR (7 downto 0);
        led7_an_o  : out STD_LOGIC_VECTOR (3 downto 0);
        led7_seg_o : out STD_LOGIC_VECTOR (7 downto 0)
    );
end top;

architecture Behavioral of top is
    signal parity : STD_LOGIC;
begin
    -- 0: parzysta liczba jedynek
    -- 1: nieparzysta liczba jedynek
    parity <= sw_i(0) xor sw_i(1) xor sw_i(2) xor sw_i(3) xor sw_i(4) xor sw_i(5) xor sw_i(6) xor sw_i(7);

    -- Anody s? aktywne stanem niskim.
    -- W??cz AN3, wy??cz AN2, AN1 i AN0.
    led7_an_o <= "0111";

    -- Kolejno?? bitów: A B C D E F G DP.
    -- Segmenty s? aktywne stanem niskim.
    led7_seg_o <= "01100001" when parity = '0' else  -- E
                  "00000011";                       -- O
end Behavioral;
