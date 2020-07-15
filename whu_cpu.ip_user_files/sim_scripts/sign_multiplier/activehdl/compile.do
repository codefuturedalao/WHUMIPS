vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"d:/225/2020MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/i/sign_multiplier/sign_multiplier_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

