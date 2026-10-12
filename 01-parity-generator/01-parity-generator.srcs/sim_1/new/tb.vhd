----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2026 01:06:07 PM
-- Design Name: 
-- Module Name: tb - Behavioral
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

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is
    signal sw_i       : STD_LOGIC_VECTOR (7 downto 0)
                      := (others => '0');
    signal led7_an_o  : STD_LOGIC_VECTOR (3 downto 0);
    signal led7_seg_o : STD_LOGIC_VECTOR (7 downto 0);
begin
    dut : entity work.top
        port map (
            sw_i       => sw_i,
            led7_an_o  => led7_an_o,
            led7_seg_o => led7_seg_o
        );

    process
    begin
        -- Co 100 ms w??cz kolejny prze??cznik.
        for i in 0 to 7 loop
            wait for 100 ms;
            sw_i(i) <= '1';
        end loop;

        -- Zachowaj ko?cowy stan przez kolejne 100 ms.
        wait for 100 ms;
        wait;
    end process;
end Behavioral;
