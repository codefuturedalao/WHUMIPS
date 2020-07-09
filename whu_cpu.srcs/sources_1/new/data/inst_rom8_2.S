.org 0x0
.set noreorder
.set nomacro
.set noat
.global _start
_start:
	ori $3,$0,0x8000
	sll $3,16
	ori $1,$0,0x0001
	j s1
	ori $1,$0,0x0002
1:
	ori $1,$0,0x1111
	ori $1,$0,0x1100
.org 0x20
s1:
	ori $1,$0,0x0003
	jal s2
	add $0,$1,$1		#check if zero reg can be written into
	ori $1,$0,0x1100
	ori $1,$0,0x1111
	bne $1,$0,s3
	nop
	ori $1,$0,0x1100
	ori $1,$0,0x1111
.org 0x50
s2:
	ori $1,$0,0x0004
	beq $3,$3,s3
	or $1,$31,$0
	ori $1,$0,0x1111
	ori $1,$0,0x1100
2:
	ori $1,$0,0x0007
	ori $1,$0,0x0008
	bgtz $1,s4
	ori $1,$0,0x0009
	ori $1,$0,0x1111
	ori $1,$0,0x1100

.org 0x80
s3:
	ori $1,$0,0x0005
	bgez $1,2b
	ori $1,$0,0x0006
	ori $1,$0,0x1111
	ori $1,$0,0x1100
.org 0x100
s4:
	ori $1,$0,0x000a
	bgezal $3,s3
	or $1,$0,$31
	ori $1,$0,0x000b
	ori $1,$0,0x000c
	ori $1,$0,0x000d
	ori $1,$0,0x000e
	bltz $3,s5
	ori $1,$0,0x000f
	ori $1,$0,0x1100

.org 0x130
s5:
	ori $1,$0,0x0010
	blez $1,2b
	ori $1,$0,0x0011
	ori $1,$0,0x0012
	ori $1,$0,0x0013
	bltzal $3,s6
	or $1,$0,$31
	ori $1,$0,0x1100

.org 0x160
s6:
	ori $1,$0,0x0014 
	nop

_loop:
	j _loop
	nop
