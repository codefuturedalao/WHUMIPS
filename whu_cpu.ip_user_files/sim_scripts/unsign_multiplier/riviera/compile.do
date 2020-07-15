vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"d:/225/2020MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/i/unsign_multiplier/unsign_multiplier_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

