onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+unsign_div -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.unsign_div xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {unsign_div.udo}

run -all

endsim

quit -force
