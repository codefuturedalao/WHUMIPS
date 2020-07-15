vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 \
"d:/225/2020MIPS/addr/WHUMIPS/whu_cpu.srcs/sources_1/i/sign_multiplier/sign_multiplier_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

