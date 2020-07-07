ifndef NUM
NUM = 10
endif
ifndef CROSS_COMPILE
CROSS_COMPILE = mipsel-linux-
endif
CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o

export CROSS_COMPILE

all: inst_rom.data

%.o: %.S
	$(CC) -mips32 $< -o $@

inst_rom.om: ram.ld $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@

inst_rom.bin: inst_rom.om
	$(OBJCOPY) -O binary $< $@

inst_rom.data: inst_rom.bin
	./bi2txt $(NUM)  $<  $@

clean:
	rm -f *.o *.om *.bin *.data
