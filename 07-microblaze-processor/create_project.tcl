# Vivado 2019.2. Run with -tclargs build to generate the bitstream and XSA.
# Set DIGILENT_BOARD_REPO to the board_files directory if needed.
set lab_dir [file dirname [file normalize [info script]]]
set build_dir [file join $lab_dir build]
set project_name 07-microblaze-processor
set board digilentinc.com:nexys-a7-100t:part0:1.3

if {[info exists ::env(DIGILENT_BOARD_REPO)]} {
    set_param board.repoPaths [list [file normalize $::env(DIGILENT_BOARD_REPO)]]
}
if {[llength [get_board_parts -quiet $board]] != 1} {
    error "Install board part $board or set DIGILENT_BOARD_REPO to Digilent's new/board_files directory."
}

create_project -force $project_name $build_dir -part xc7a100tcsg324-1
set_property BOARD_PART $board [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]
create_bd_design mb_system

proc ip {name core properties} {
    set cell [create_bd_cell -type ip -vlnv xilinx.com:ip:$core $name]
    if {[llength $properties]} {
        set_property -dict $properties $cell
    }
}

ip microblaze_0 microblaze:11.0 {
    CONFIG.C_DEBUG_ENABLED 2 CONFIG.C_D_AXI 1 CONFIG.C_D_LMB 1 CONFIG.C_I_LMB 1
    CONFIG.C_USE_BARREL 1 CONFIG.C_USE_DIV 1 CONFIG.C_USE_HW_MUL 1
}
ip mdm_1 mdm:3.2 {
    CONFIG.C_ADDR_SIZE 32 CONFIG.C_DBG_MEM_ACCESS 1 CONFIG.C_M_AXI_ADDR_WIDTH 32
}
ip clk_wiz_0 clk_wiz:6.0 {
    CONFIG.USE_BOARD_FLOW true CONFIG.CLK_IN1_BOARD_INTERFACE sys_clock
    CONFIG.RESET_BOARD_INTERFACE reset CONFIG.RESET_TYPE ACTIVE_LOW CONFIG.RESET_PORT resetn
}
ip proc_sys_reset_0 proc_sys_reset:5.0 {}
ip axi_gpio_0 axi_gpio:2.0 {
    CONFIG.USE_BOARD_FLOW true CONFIG.GPIO_BOARD_INTERFACE dual_seven_seg_led_disp
    CONFIG.GPIO2_BOARD_INTERFACE seven_seg_led_an
    CONFIG.C_IS_DUAL 1 CONFIG.C_GPIO_WIDTH 8 CONFIG.C_GPIO2_WIDTH 8
    CONFIG.C_ALL_OUTPUTS 1 CONFIG.C_ALL_OUTPUTS_2 1
    CONFIG.C_DOUT_DEFAULT 0x000000FF CONFIG.C_DOUT_DEFAULT_2 0x000000FF
}
ip axi_gpio_1 axi_gpio:2.0 {
    CONFIG.USE_BOARD_FLOW true CONFIG.GPIO_BOARD_INTERFACE led_16bits
    CONFIG.C_GPIO_WIDTH 16 CONFIG.C_ALL_OUTPUTS 1
}
ip axi_uartlite_0 axi_uartlite:2.0 {
    CONFIG.USE_BOARD_FLOW true CONFIG.UARTLITE_BOARD_INTERFACE usb_uart
    CONFIG.C_BAUDRATE 9600 CONFIG.C_DATA_BITS 8 CONFIG.C_USE_PARITY 0
}
ip axi_timer_0 axi_timer:2.0 {}
ip axi_periph axi_interconnect:2.1 {CONFIG.NUM_SI 2 CONFIG.NUM_MI 4}

# Dual-port BRAM is shared by the instruction and data buses. The debugger
# gets its own LMB bus to the data-side memory controller.
set memory [create_bd_cell -type hier local_memory]
current_bd_instance $memory
foreach bus {DLMB ILMB DEBUG_LMB} {
    create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 $bus
}
create_bd_pin -dir I -type clk LMB_Clk
create_bd_pin -dir I -type rst SYS_Rst
ip dlmb lmb_v10:3.0 {}
ip ilmb lmb_v10:3.0 {}
ip debug_lmb lmb_v10:3.0 {}
ip data_ctrl lmb_bram_if_cntlr:4.0 {CONFIG.C_ECC 0 CONFIG.C_NUM_LMB 2}
ip instr_ctrl lmb_bram_if_cntlr:4.0 {CONFIG.C_ECC 0}
ip bram blk_mem_gen:8.4 {
    CONFIG.Memory_Type True_Dual_Port_RAM CONFIG.use_bram_block BRAM_Controller
}
foreach {first second} {
    DLMB dlmb/LMB_M                 dlmb/LMB_Sl_0 data_ctrl/SLMB
    ILMB ilmb/LMB_M                 ilmb/LMB_Sl_0 instr_ctrl/SLMB
    DEBUG_LMB debug_lmb/LMB_M       debug_lmb/LMB_Sl_0 data_ctrl/SLMB1
    data_ctrl/BRAM_PORT bram/BRAM_PORTA
    instr_ctrl/BRAM_PORT bram/BRAM_PORTB
} {
    connect_bd_intf_net [get_bd_intf_pins $first] [get_bd_intf_pins $second]
}
connect_bd_net [get_bd_pins {LMB_Clk dlmb/LMB_Clk ilmb/LMB_Clk debug_lmb/LMB_Clk data_ctrl/LMB_Clk instr_ctrl/LMB_Clk}]
connect_bd_net [get_bd_pins {SYS_Rst dlmb/SYS_Rst ilmb/SYS_Rst debug_lmb/SYS_Rst data_ctrl/LMB_Rst instr_ctrl/LMB_Rst}]
current_bd_instance /

foreach {port interface pin} {
    dual_seven_seg_led_disp gpio axi_gpio_0/GPIO
    seven_seg_led_an gpio axi_gpio_0/GPIO2
    led_16bits gpio axi_gpio_1/GPIO
    usb_uart uart axi_uartlite_0/UART
} {
    create_bd_intf_port -mode Master -vlnv xilinx.com:interface:${interface}_rtl:1.0 $port
    connect_bd_intf_net [get_bd_intf_ports $port] [get_bd_intf_pins $pin]
}
create_bd_port -dir I -type clk -freq_hz 100000000 sys_clock
set_property CONFIG.POLARITY ACTIVE_LOW [create_bd_port -dir I -type rst reset]
connect_bd_net [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]
connect_bd_net [get_bd_ports reset] [get_bd_pins {clk_wiz_0/resetn proc_sys_reset_0/ext_reset_in}]

foreach {first second} {
    microblaze_0/DEBUG    mdm_1/MBDEBUG_0
    microblaze_0/DLMB     local_memory/DLMB
    microblaze_0/ILMB     local_memory/ILMB
    microblaze_0/M_AXI_DP axi_periph/S00_AXI
    mdm_1/LMB_0          local_memory/DEBUG_LMB
    mdm_1/M_AXI          axi_periph/S01_AXI
} {
    connect_bd_intf_net [get_bd_intf_pins $first] [get_bd_intf_pins $second]
}
set clocks {clk_wiz_0/clk_out1 microblaze_0/Clk local_memory/LMB_Clk mdm_1/M_AXI_ACLK
            proc_sys_reset_0/slowest_sync_clk axi_periph/ACLK axi_periph/S00_ACLK axi_periph/S01_ACLK}
set resets {proc_sys_reset_0/peripheral_aresetn mdm_1/M_AXI_ARESETN
            axi_periph/ARESETN axi_periph/S00_ARESETN axi_periph/S01_ARESETN}
foreach {cell port address} {
    axi_gpio_0     M00 0x40000000
    axi_gpio_1     M01 0x40010000
    axi_uartlite_0 M02 0x40600000
    axi_timer_0    M03 0x41C00000
} {
    connect_bd_intf_net [get_bd_intf_pins axi_periph/${port}_AXI] [get_bd_intf_pins $cell/S_AXI]
    lappend clocks axi_periph/${port}_ACLK $cell/s_axi_aclk
    lappend resets axi_periph/${port}_ARESETN $cell/s_axi_aresetn
    foreach master {microblaze_0 mdm_1} {
        assign_bd_address -target_address_space [get_bd_addr_spaces $master/Data] \
            -offset $address -range 64K [get_bd_addr_segs $cell/S_AXI/Reg]
    }
}
connect_bd_net [get_bd_pins $clocks]
connect_bd_net [get_bd_pins $resets]
connect_bd_net [get_bd_pins {clk_wiz_0/locked proc_sys_reset_0/dcm_locked}]
connect_bd_net [get_bd_pins {mdm_1/Debug_SYS_Rst proc_sys_reset_0/mb_debug_sys_rst}]
connect_bd_net [get_bd_pins {proc_sys_reset_0/mb_reset microblaze_0/Reset}]
connect_bd_net [get_bd_pins {proc_sys_reset_0/bus_struct_reset local_memory/SYS_Rst}]

foreach {space segment} {
    microblaze_0/Data        local_memory/data_ctrl/SLMB/Mem
    microblaze_0/Instruction local_memory/instr_ctrl/SLMB/Mem
    mdm_1/Data               local_memory/data_ctrl/SLMB1/Mem
} {
    assign_bd_address -target_address_space [get_bd_addr_spaces $space] \
        -offset 0x00000000 -range 64K [get_bd_addr_segs $segment]
}

validate_bd_design
save_bd_design
set bd [get_files mb_system.bd]
set wrapper [make_wrapper -files $bd -top]
add_files -norecurse [list $wrapper]
set_property TOP mb_system_wrapper [current_fileset]
update_compile_order -fileset sources_1

if {[info exists argv] && $argv eq "build"} {
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    if {[get_property STATUS [get_runs impl_1]] ne "write_bitstream Complete!"} {
        error "Bitstream generation failed. Check the logs in $build_dir."
    }
    open_run impl_1
    write_hw_platform -fixed -include_bit -force -file [file join $build_dir mb_system.xsa]
}
