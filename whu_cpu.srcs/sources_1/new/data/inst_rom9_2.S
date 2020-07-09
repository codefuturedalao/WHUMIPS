.org 0x0
.set noreorder
.set nomacro
.set noat
.global _start
_start:
	ori $1,$0,0x1234
	sw $1,0x0($0)
	ori $2,$0,0x1234
	ori $1,$0,0x0
	lw $1,0x0($0)
	beq $1,$2,Label
	nop
	ori $1,$0,0x4567
	nop
	sb $1,0x1($0)
	sh $1,0x2($0)     
	lh $2,0x2($0)
	add $1,$2,40       	#data hazard need to stall
	lb $1,0x1($0)
	add $1,$1,$1		#data hazard need to stall
	lw $1,0x0($0)
	sw $1,0x1($0)		#data hazard need to stall
Label:
	ori $1,$0,0x89ab
	nop

_loop:
	j _loop
	nop
