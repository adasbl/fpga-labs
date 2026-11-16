# Vivado 2019.2. Run with -tclargs build to generate the bitstream and XSA.
set lab_dir [file dirname [file normalize [info script]]]
open_project [file join $lab_dir 07-microblaze-processor.xpr]

if {[info exists argv] && $argv eq "build"} {
    set impl_run [get_runs impl_1]
    if {[get_property STATUS $impl_run] ne "write_bitstream Complete!" ||
        [get_property NEEDS_REFRESH $impl_run]} {
        set synth_run [get_runs synth_1]
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
    set build_dir [file join $lab_dir build]
    # Export in a new directory so Vivado can write on synced Windows paths.
    set export_dir [file join $build_dir xsa-[pid]]
    file mkdir $export_dir
    set archive [file join $export_dir mb_system.xsa]
    write_hw_platform -fixed -include_bit -force -file $archive
    file rename -force $archive [file join $build_dir mb_system.xsa]
    file delete $export_dir
}
