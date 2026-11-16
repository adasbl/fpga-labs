library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        sys_clock                    : in  std_logic;
        reset                        : in  std_logic;
        usb_uart_rxd                 : in  std_logic;
        usb_uart_txd                 : out std_logic;
        dual_seven_seg_led_disp_tri_o : out std_logic_vector(7 downto 0);
        seven_seg_led_an_tri_o        : out std_logic_vector(7 downto 0);
        led_16bits_tri_o              : out std_logic_vector(15 downto 0)
    );
end entity top;

architecture rtl of top is
begin
    mb_system_i : entity work.mb_system
        port map (
            sys_clock                    => sys_clock,
            reset                        => reset,
            usb_uart_rxd                 => usb_uart_rxd,
            usb_uart_txd                 => usb_uart_txd,
            dual_seven_seg_led_disp_tri_o => dual_seven_seg_led_disp_tri_o,
            seven_seg_led_an_tri_o        => seven_seg_led_an_tri_o,
            led_16bits_tri_o              => led_16bits_tri_o
        );
end architecture rtl;
