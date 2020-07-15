vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"d:/225/2020MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/i/unsign_div/unsign_div_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

