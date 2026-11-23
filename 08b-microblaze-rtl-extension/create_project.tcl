# Vivado 2019.2. Run with -tclargs build to generate the bitstream and XSA.
set lab_dir [file dirname [file normalize [info script]]]
set base_project [file join $lab_dir .. 07-microblaze-processor 07-microblaze-processor.srcs]
set build_dir [file join $lab_dir build]
# A short build path can avoid Windows path length limits in generated IP files.
if {[info exists env(FPGA_08B_BUILD_DIR)]} {
    set build_dir [file normalize $env(FPGA_08B_BUILD_DIR)]
}
set project_name 08b-microblaze-rtl-extension
set project_file [file join $build_dir $project_name.xpr]

if {[file exists $project_file]} {
    open_project $project_file
} else {
    create_project $project_name $build_dir -part xc7a100tcsg324-1
    set_property target_language VHDL [current_project]
    add_files [list [file join $lab_dir src vga_framebuffer.vhd]]
    add_files -fileset constrs_1 [list \
        [file join $base_project constrs_1 new pins.xdc] \
        [file join $lab_dir constraints vga.xdc]]

    # Import a private copy of the lab 07 block design before extending it.
    import_files [list [file join $base_project sources_1 bd mb_system mb_system.bd]]
    set design_file [get_files mb_system.bd]
    open_bd_design $design_file

    set_property CONFIG.NUM_MI 5 [get_bd_cells axi_periph]
    set controller [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 framebuffer_ctrl]
    set_property -dict [list CONFIG.DATA_WIDTH 32 CONFIG.SINGLE_PORT_BRAM 1] $controller
    set ram [create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 framebuffer]
    set_property -dict [list CONFIG.use_bram_block BRAM_Controller CONFIG.Memory_Type True_Dual_Port_RAM \
        CONFIG.Assume_Synchronous_Clk true] $ram
    create_bd_cell -type module -reference vga_framebuffer vga

    connect_bd_intf_net [get_bd_intf_pins axi_periph/M04_AXI] [get_bd_intf_pins framebuffer_ctrl/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins framebuffer_ctrl/BRAM_PORTA] [get_bd_intf_pins framebuffer/BRAM_PORTA]
    foreach {vga_pin ram_pin} {
        bram_addr addrb
        bram_din  dinb
        bram_dout doutb
        bram_en   enb
        bram_rst  rstb
        bram_we   web
    } {
        connect_bd_net [get_bd_pins vga/$vga_pin] [get_bd_pins framebuffer/$ram_pin]
    }
    connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] \
        [get_bd_pins axi_periph/M04_ACLK] [get_bd_pins framebuffer_ctrl/s_axi_aclk] \
        [get_bd_pins framebuffer/clkb] [get_bd_pins vga/clk]
    connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
        [get_bd_pins axi_periph/M04_ARESETN] [get_bd_pins framebuffer_ctrl/s_axi_aresetn] [get_bd_pins vga/resetn]

    foreach output {red_o green_o blue_o hsync_o vsync_o} {
        make_bd_pins_external [get_bd_pins vga/$output]
        set_property name $output [get_bd_ports ${output}_0]
    }

    foreach master {microblaze_0 mdm_1} {
        assign_bd_address -offset 0xC0000000 -range 128K \
            -target_address_space [get_bd_addr_spaces $master/Data] \
            [get_bd_addr_segs framebuffer_ctrl/S_AXI/Mem0]
    }
    validate_bd_design
    save_bd_design
    set_property synth_checkpoint_mode None $design_file
    set wrapper [make_wrapper -files $design_file -top]
    add_files -norecurse [list $wrapper]
    set_property top mb_system_wrapper [current_fileset]
    update_compile_order -fileset sources_1
}

if {[info exists argv] && $argv eq "build"} {
    set synth_run [get_runs synth_1]
    set impl_run [get_runs impl_1]
    if {[get_property STATUS $impl_run] ne "write_bitstream Complete!" ||
        [get_property NEEDS_REFRESH $impl_run] || [get_property NEEDS_REFRESH $synth_run]} {
        if {[get_property STATUS $synth_run] eq "synth_design Complete!" &&
            ![get_property NEEDS_REFRESH $synth_run]} {
            reset_run $impl_run
        } else {
            reset_run $synth_run
        }
        launch_runs $impl_run -to_step write_bitstream -jobs 4
        wait_on_run $impl_run
        if {[get_property STATUS $impl_run] ne "write_bitstream Complete!"} {
            error "Bitstream generation failed. Check the synthesis and implementation run logs."
        }
    }
    open_run $impl_run
    set export_dir [file join $build_dir xsa-[pid]]
    file mkdir $export_dir
    set archive [file join $export_dir mb_system.xsa]
    write_hw_platform -fixed -include_bit -force -file $archive
    file rename -force $archive [file join $build_dir mb_system.xsa]
    file delete $export_dir
}
