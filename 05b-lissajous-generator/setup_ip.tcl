# Uruchom w Vivado: source <katalog_projektu>/setup_ip.tcl
set project_dir [file dirname [file normalize [info script]]]
if {[current_project -quiet] eq ""} {
    open_project [file join $project_dir 05b-lissajous-generator.xpr]
}
set_property part xc7a100tcsg324-1 [current_project]
set_property target_language VHDL [current_project]
set ip_dir [file join $project_dir 05b-lissajous-generator.srcs sources_1 ip]
file mkdir $ip_dir

if {[get_ips -quiet video_mem] eq ""} {
    create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
        -module_name video_mem -dir $ip_dir
}
set_property -dict [list \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Write_Width_A {1} \
    CONFIG.Write_Depth_A {147456} \
    CONFIG.Read_Width_A {1} \
    CONFIG.Read_Width_B {1} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Core {false} \
    CONFIG.Use_RSTA_Pin {false} \
    CONFIG.Use_RSTB_Pin {false} \
] [get_ips video_mem]

if {[get_ips -quiet singen] eq ""} {
    create_ip -name dds_compiler -vendor xilinx.com -library ip -version 6.0 \
        -module_name singen -dir $ip_dir
}
set_property -dict [list \
    CONFIG.PartsPresent {Phase_Generator_and_SIN_COS_LUT} \
    CONFIG.Parameter_Entry {System_Parameters} \
    CONFIG.Channels {2} \
    CONFIG.DDS_Clock_Rate {100} \
    CONFIG.Spurious_Free_Dynamic_Range {65} \
    CONFIG.Frequency_Resolution {1000} \
    CONFIG.Noise_Shaping {None} \
    CONFIG.Phase_Increment {Programmable} \
    CONFIG.Phase_offset {Programmable} \
    CONFIG.Output_Selection {Sine} \
    CONFIG.Has_Phase_Out {false} \
    CONFIG.Has_ACLKEN {true} \
    CONFIG.Has_ARESETn {true} \
    CONFIG.Has_TREADY {false} \
    CONFIG.Output_Frequency1 {0.1953125} \
    CONFIG.Output_Frequency2 {0.1953125} \
    CONFIG.Phase_Offset_Angles1 {0} \
    CONFIG.Phase_Offset_Angles2 {0.25} \
] [get_ips singen]

generate_target all [get_ips {video_mem singen}]
set_property top top [get_filesets sources_1]
set_property top tb [get_filesets sim_1]
set_property used_in_synthesis false [get_files */sim_1/new/tb.vhd]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
