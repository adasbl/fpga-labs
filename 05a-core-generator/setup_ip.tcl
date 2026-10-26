# Uruchom w Vivado: source <katalog_projektu>/setup_ip.tcl
set project_dir [file dirname [file normalize [info script]]]
if {[current_project -quiet] eq ""} {
    open_project [file join $project_dir 05a-core-generator.xpr]
}
set_property part xc7a100tcsg324-1 [current_project]
set_property target_language VHDL [current_project]
set ip_dir [file join $project_dir 05a-core-generator.srcs sources_1 ip]
file mkdir $ip_dir

if {[get_ips -quiet char_mem] eq ""} {
    create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
        -module_name char_mem -dir $ip_dir
}
if {[get_property IS_LOCKED [get_ips char_mem]]} {
    upgrade_ip [get_ips char_mem]
}
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_ROM} \
    CONFIG.Write_Width_A {8} \
    CONFIG.Write_Depth_A {4096} \
    CONFIG.Read_Width_A {8} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortA_Output_of_Memory_Core {false} \
    CONFIG.Use_RSTA_Pin {false} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File [file join $project_dir chargen.coe] \
] [get_ips char_mem]

if {[get_ips -quiet fifo_mem] eq ""} {
    create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 \
        -module_name fifo_mem -dir $ip_dir
}
set_property -dict [list \
    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
    CONFIG.Input_Data_Width {8} \
    CONFIG.Input_Depth {64} \
    CONFIG.Output_Data_Width {8} \
    CONFIG.Output_Depth {64} \
    CONFIG.Performance_Options {Standard_FIFO} \
    CONFIG.Reset_Pin {false} \
] [get_ips fifo_mem]

generate_target all [get_ips {char_mem fifo_mem}]
set_property top top [get_filesets sources_1]
set_property top tb [get_filesets sim_1]
set_property used_in_synthesis false [get_files */sim_1/new/tb.vhd]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
