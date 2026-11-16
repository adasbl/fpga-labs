# Nexys A7-100T pin assignments from the Digilent board definition.
set_property IOSTANDARD LVCMOS33 [get_ports *]

# Clock and active-low reset
set_property PACKAGE_PIN E3  [get_ports {sys_clock}]
set_property PACKAGE_PIN C12 [get_ports {reset}]

# USB UART
set_property PACKAGE_PIN C4  [get_ports {usb_uart_rxd}]
set_property PACKAGE_PIN D4  [get_ports {usb_uart_txd}]

# Active-low display segments A through G and DP
set_property PACKAGE_PIN T10 [get_ports {dual_seven_seg_led_disp_tri_o[0]}]
set_property PACKAGE_PIN R10 [get_ports {dual_seven_seg_led_disp_tri_o[1]}]
set_property PACKAGE_PIN K16 [get_ports {dual_seven_seg_led_disp_tri_o[2]}]
set_property PACKAGE_PIN K13 [get_ports {dual_seven_seg_led_disp_tri_o[3]}]
set_property PACKAGE_PIN P15 [get_ports {dual_seven_seg_led_disp_tri_o[4]}]
set_property PACKAGE_PIN T11 [get_ports {dual_seven_seg_led_disp_tri_o[5]}]
set_property PACKAGE_PIN L18 [get_ports {dual_seven_seg_led_disp_tri_o[6]}]
set_property PACKAGE_PIN H15 [get_ports {dual_seven_seg_led_disp_tri_o[7]}]

# Active-low display anodes, starting from the right
set_property PACKAGE_PIN J17 [get_ports {seven_seg_led_an_tri_o[0]}]
set_property PACKAGE_PIN J18 [get_ports {seven_seg_led_an_tri_o[1]}]
set_property PACKAGE_PIN T9  [get_ports {seven_seg_led_an_tri_o[2]}]
set_property PACKAGE_PIN J14 [get_ports {seven_seg_led_an_tri_o[3]}]
set_property PACKAGE_PIN P14 [get_ports {seven_seg_led_an_tri_o[4]}]
set_property PACKAGE_PIN T14 [get_ports {seven_seg_led_an_tri_o[5]}]
set_property PACKAGE_PIN K2  [get_ports {seven_seg_led_an_tri_o[6]}]
set_property PACKAGE_PIN U13 [get_ports {seven_seg_led_an_tri_o[7]}]

# Board LEDs
set_property PACKAGE_PIN H17 [get_ports {led_16bits_tri_o[0]}]
set_property PACKAGE_PIN K15 [get_ports {led_16bits_tri_o[1]}]
set_property PACKAGE_PIN J13 [get_ports {led_16bits_tri_o[2]}]
set_property PACKAGE_PIN N14 [get_ports {led_16bits_tri_o[3]}]
set_property PACKAGE_PIN R18 [get_ports {led_16bits_tri_o[4]}]
set_property PACKAGE_PIN V17 [get_ports {led_16bits_tri_o[5]}]
set_property PACKAGE_PIN U17 [get_ports {led_16bits_tri_o[6]}]
set_property PACKAGE_PIN U16 [get_ports {led_16bits_tri_o[7]}]
set_property PACKAGE_PIN V16 [get_ports {led_16bits_tri_o[8]}]
set_property PACKAGE_PIN T15 [get_ports {led_16bits_tri_o[9]}]
set_property PACKAGE_PIN U14 [get_ports {led_16bits_tri_o[10]}]
set_property PACKAGE_PIN T16 [get_ports {led_16bits_tri_o[11]}]
set_property PACKAGE_PIN V15 [get_ports {led_16bits_tri_o[12]}]
set_property PACKAGE_PIN V14 [get_ports {led_16bits_tri_o[13]}]
set_property PACKAGE_PIN V12 [get_ports {led_16bits_tri_o[14]}]
set_property PACKAGE_PIN V11 [get_ports {led_16bits_tri_o[15]}]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
