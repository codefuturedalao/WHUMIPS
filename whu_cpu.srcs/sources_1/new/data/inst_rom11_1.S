.org 0x0
.set noreorder
.set nomacro
.set noat
.global _start
_start:
	ori $1,$0,0x100
	jr $1
nop

	.org 0x40
	ori $1,$0,0x8000
	ori $1,$0,0x9000
	mfc0 $1,$14,0x0
	addi $1,$1,0x4
	mtc0 $1,$14,0x0
	eret
	nop

	.org 0x100
	ori $1,$0,0x1000
	sw $1,0x0000($0)
	syscall

	ori $1,$0,0x2000
	break

	ori $1,$0,0x3000
	lw $1,0x0001($0)  #no align

	ori $1,$0,0x4000
	#inst not valid	
	
	ori $1,$0,0xffff
	sll $1,$1,16
	ori $2,$0,0x8000
	sll $2,$2,16
	add $3,$1,$2  #overflow
	addu $3,$1,$2


	lw $1,0x0000($0)

_loop:
	j _loop
	nop	

