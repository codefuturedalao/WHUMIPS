# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7k70tfbv676-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.cache/wt [current_project]
set_property parent.project_path D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/ALU.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/BranchControl.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/CP0.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/Ctrl.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/DMEM.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/Decoder.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/EX_ME.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/ID_EX.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/IF_ID.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/IMEM.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/ME_WB.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/MUX1.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/MUX2.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/MUX3.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/PC.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/RG.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/WHUCPU.v
  D:/225/2020����MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/new/WHUCPU_soc.v
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top WHUCPU_soc -part xc7k70tfbv676-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef WHUCPU_soc.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file WHUCPU_soc_utilization_synth.rpt -pb WHUCPU_soc_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]