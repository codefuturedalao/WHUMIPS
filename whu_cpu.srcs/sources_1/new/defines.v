`define INST_WIDTH 31:0
`define INST_ADDR_WIDTH 31:0
`define REG_ADDR_WIDTH 4:0
`define REG_WIDTH 31:0
`define REG_NUM 31:0
`define ALUOP_WIDTH 5:0
`define STALL_WIDTH 5:0
`define DEFAULT_PC 32'hbfc0_0000
`define EXP_DEFAULT_PC 32'hBFC0_0380
`define WEN_ADDR 3:0

`define KUSEG_START 32'h0000_0000
`define KSEG0_START 32'h8000_0000
`define KSEG1_START 32'hA000_0000
`define KSEG2_START 32'hC000_0000
`define KSEG3_START 32'hE000_0000

/*control signal*/
`define RST_ENABLE 1'b0     //low valid
`define RST_DISABLE 1'b1
`define IS_FLUSH 1'b1
`define NO_FLUSH 1'b0
`define REG_READ 1'b1
`define REG_NO_READ 1'b0
`define IS_JUMP 1'b1
`define NO_JUMP 1'b0
`define JUMP_FROM_REG 1'b1
`define JUMP_FROM_IMM 1'b0
`define IS_BRANCH 1'b1
`define NO_BRANCH 1'b0
`define IS_EXCEPTION 1'b1
`define NO_EXCEPTION 1'b0
`define MEM_ENABLE 1'b1
`define MEM_DISABLE 1'b0
`define MEM_SE_BYTE 3'b100
`define MEM_SE_HALF 3'b101
`define MEM_SE_WORD 3'b110
`define MEM_SE_BYTE_U 3'b000
`define MEM_SE_HALF_U 3'b001
`define REG3_FROM_RESULT 1'b1
`define REG3_FROM_MEM 1'b0
`define REG3_WRITE 1'b1
`define REG3_NO_WRITE 1'b0
`define CP0_WRITE 1'b1
`define CP0_NO_WRITE 1'b0
`define INT_ASSERTION 1'b1
`define INT_NO_ASSERTION 1'b0
`define CHIP_ENABLE 1'b1
`define CHIP_DISABLE 1'b0
`define IS_STALL 1'b1
`define NO_STALL 1'b0
//make no valid is 1
`define INST_VALID 1'b0
`define INST_NO_VALID 1'b1
`define IN_DSLOT 1'b1
`define NOT_IN_DSLOT 1'b0

/* CP0 Register */
`define CP0_REG_COUNT 5'b01001
`define CP0_REG_COMPARE 5'b01011
`define CP0_REG_STATUS 5'b01100
`define CP0_REG_CAUSE 5'b01101
`define CP0_REG_EPC 5'b01110
`define CP0_REG_PRID 5'b01111
`define CP0_REG_CONFIG 5'b10000

`define STATUS_EXL 1
`define STATUS_IE 0
`define STATUS_IM 15:8
`define CAUSE_IP 15:8
`define CAUSE_BD 31 
`define CAUSE_EXCCODE 6:2

/* EXCCODE */
`define INT_EXC 5'b00000
`define ADEL_EXC 5'b00100
`define ADES_EXC 5'b00101
`define OV_EXC 5'b01100
`define SYS_EXC 5'b01000
`define BP_EXC 5'b01001
`define RI_EXC 5'b01010

/* EXP TYPE*/
`define NO_EXP_TYPE 32'h0000_0000
`define INT_EXP_TYPE 32'h0000_0001
`define INST_VALID_EXP_TYPE 32'h0000_0002
`define SYS_EXP_TYPE 32'h0000_0003
`define ERET_EXP_TYPE 32'h0000_0004
`define BREAK_EXP_TYPE 32'h0000_0005
`define OV_EXP_TYPE 32'h0000_0006
`define ALIGN_EXP_TYPE 32'h0000_0007

//
`define ZERO_WORD 32'b0000_0000_0000_0000_0000_0000_0000_0000

/*    --------------- ID stage ----------------    */
/*opcode defines*/
/*special op*/
//arith and logic
`define SPECIAL_OPCODE 6'b000000
`define ADD_OPCODE 6'b100000		//inst[5:0]
`define ADDU_OPCODE 6'b100001
`define SUB_OPCODE 6'b100010
`define SUBU_OPCODE 6'b100011
`define SLT_OPCODE 6'b101010
`define SLTU_OPCODE 6'b101011
`define DIV_OPCODE 6'b011010
`define DIVU_OPCODE 6'b011011
`define MULT_OPCODE 6'b011000
`define MULTU_OPCODE 6'b011001
`define AND_OPCODE 6'b100100
`define NOR_OPCODE 6'b100111
`define OR_OPCODE 6'b100101
`define XOR_OPCODE 6'b100110
`define SLLV_OPCODE 6'b000100
`define SLL_OPCODE 6'b000000
`define SRAV_OPCODE 6'b000111
`define SRA_OPCODE 6'b000011
`define SRLV_OPCODE 6'b000110
`define SRL_OPCODE 6'b000010
//jump
`define JR_OPCODE 6'b001000
`define JALR_OPCODE 6'b001001
//memory
`define MFHI_OPCODE 6'b010000
`define MFLO_OPCODE 6'b010010
`define MTHI_OPCODE 6'b010001
`define MTLO_OPCODE 6'b010011
/*I type op*/
`define ADDI_OPCODE 6'b001000
`define ADDIU_OPCODE 6'b001001
`define SLTI_OPCODE 6'b001010
`define SLTIU_OPCODE 6'b001011
`define ANDI_OPCODE 6'b001100
`define LUI_OPCODE 6'b001111
`define ORI_OPCODE 6'b001101
`define XORI_OPCODE 6'b001110
//load & store
`define LB_OPCODE 6'b100000
`define LBU_OPCODE 6'b100100
`define LH_OPCODE 6'b100001
`define LHU_OPCODE 6'b100101
`define LW_OPCODE 6'b100011
`define SB_OPCODE 6'b101000
`define SH_OPCODE 6'b101001
`define SW_OPCODE 6'b101011
/*J type op*/
`define BEQ_OPCODE 6'b000100
`define BNE_OPCODE 6'b000101
/*BGELTZ op*/
`define BGELTZ_OPCODE 6'b000001
`define BGEZ_OPCODE 5'b00001
`define BLTZ_OPCODE 5'b00000
`define BGEZAL_OPCODE 5'b10001
`define BLTZAL_OPCODE 5'b10000

`define BGTZ_OPCODE 6'b000111
`define BLEZ_OPCODE 6'b000110
`define J_OPCODE 6'b000010
`define JAL_OPCODE 6'b000011
//trap
`define BREAK_OPCODE 6'b001101
`define SYS_OPCODE 6'b001100
/*privileged op*/
`define PRIV_OPCODE 6'b010000
`define ERET_OPCODE 5'b10000
`define MFC0_OPCODE 5'b00000 
`define MTC0_OPCODE 5'b00100
 

/*    --------------- EX stage ----------------    */
/*ALU OPCODE*/
// R type op
`define NOP_ALU_OPCODE 6'b000000
`define ADD_ALU_OPCODE 6'b000001
`define ADDU_ALU_OPCODE 6'b000010
`define SUB_ALU_OPCODE 6'b000011
`define SUBU_ALU_OPCODE 6'b000100
`define SLT_ALU_OPCODE 6'b000101
`define SLTU_ALU_OPCODE 6'b000110
`define DIV_ALU_OPCODE 6'b000111
`define DIVU_ALU_OPCODE 6'b001000
`define MULT_ALU_OPCODE 6'b001001
`define MULTU_ALU_OPCODE 6'b001010
`define AND_ALU_OPCODE 6'b001011
`define NOR_ALU_OPCODE 6'b001100
`define OR_ALU_OPCODE 6'b001101
`define XOR_ALU_OPCODE 6'b001110
`define SLLV_ALU_OPCODE 6'b001111
`define SLL_ALU_OPCODE 6'b010000
`define SRAV_ALU_OPCODE 6'b010001
`define SRA_ALU_OPCODE 6'b010010
`define SRLV_ALU_OPCODE 6'b010011
`define SRL_ALU_OPCODE 6'b010100
// I type op
`define ADDI_ALU_OPCODE 6'b010101
`define ADDIU_ALU_OPCODE 6'b010110
`define SLTI_ALU_OPCODE 6'b010111
`define SLTIU_ALU_OPCODE 6'b011000
`define ANDI_ALU_OPCODE 6'b011001
`define LUI_ALU_OPCODE 6'b011010
`define ORI_ALU_OPCODE 6'b011011
`define XORI_ALU_OPCODE 6'b011100
// J type op
`define BEQ_ALU_OPCODE 6'b011101
`define BNE_ALU_OPCODE 6'b011110
`define BGEZ_ALU_OPCODE 6'b011111
`define BGTZ_ALU_OPCODE 6'b100000
`define BLEZ_ALU_OPCODE 6'b100001
`define BLTZ_ALU_OPCODE 6'b100010
`define BGEZAL_ALU_OPCODE 6'b100011
`define BLTZAL_ALU_OPCODE 6'b100100
`define J_ALU_OPCODE 6'b000000 //the same as nop alu opcode
`define JAL_ALU_OPCODE 6'b100101
`define JR_ALU_OPCODE 6'b000000
`define JALR_ALU_OPCODE 6'b100110
//load & store
`define LB_ALU_OPCODE 6'b010110  //the same as addiu
`define LBU_ALU_OPCODE 6'b010110 //the same as addiu 
`define LH_ALU_OPCODE 6'b100111
`define LHU_ALU_OPCODE 6'b100111 //the same as LH
`define LW_ALU_OPCODE 6'b101000 

`define SB_ALU_OPCODE 6'b010110  //the same as addiu
`define SH_ALU_OPCODE 6'b100111 //the same as LH
`define SW_ALU_OPCODE 6'b101000 //the same as LW

// HI/LO op
`define MFHI_ALU_OPCODE 6'b000000
`define MFLO_ALU_OPCODE 6'b000000
`define MTHI_ALU_OPCODE 6'b000000
`define MTLO_ALU_OPCODE 6'b000000
// trap
`define BREAK_ALU_OPCODE 6'b000000   //the same as nop
`define SYS_ALU_OPCODE 6'b000000     //the same as nop
//privileged op
`define ERET_ALU_OPCODE 6'b101001
`define MFC0_ALU_OPCODE 6'b101010
`define MTC0_ALU_OPCODE 6'b101011
