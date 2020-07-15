onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+sign_div -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.sign_div xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {sign_div.udo}

run -all

endsim

quit -force
