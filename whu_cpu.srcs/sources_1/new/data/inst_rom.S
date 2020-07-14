.org 0x0
.set noreorder
.set nomacro
.set noat
.global _start
_start:
	ori $3,$0,0xeeff
	sb $3,0x3($0)
	srl $3,$3,8
	sb $3,0x2($0)
	ori $3,$0,0xccdd
	sb $3,0x1($0)
	srl $3,$3,8
	sb $3,0x0($0)
	lb $1,0x3($0)
	lbu $1,0x2($0)
	
	ori $3,$0,0xaabb
	sh $3,0x4($0)
	lhu $1,0x4($0)
	lh $1,0x4($0)
	ori $3,$0,0x8899
	sh $3,0x6($0)
	lh $1,0x6($0)
	lhu $1,0x6($0)
	
	ori $3,$0,0x4455
	sll $3,$3,0x10
	ori $3,$3,0x6677
	sw $3,0x8($0)
	lw $1,0x8($0)
	nop

_loop:
	j _loop
	nop
