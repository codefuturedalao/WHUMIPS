onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+unsign_multiplier -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.unsign_multiplier xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {unsign_multiplier.udo}

run -all

endsim

quit -force
