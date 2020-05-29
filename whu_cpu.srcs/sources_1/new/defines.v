`define INST_WIDTH 31:0
`define REG_ADDR_WIDTH 4:0
`define ALUOP_WIDTH 5:0

/*opcode defines*/
//arith and logic
`define SPECIAL_OPCODE 6'b000000
`define ADD_OPCODE 6'b100000		//inst[5:0]
`define ADDU_OPCODE 6'b100001
`define SUB_OPCODE 6'b100010
`define SUBU_OPCODE 6'b100011

`define ADDI_OPCODE 6'b001000
`define ADDIU_OPCODE 6'b001001
`define SLTI_OPCODE 6'b001010
`define SLTIU_OPCODE 6'b001011
`define ANDI_OPCODE 6'b001100
`define LUI_OPCODE 6'b001111
`define ORI_OPCODE 6'b001101
`define XORI_OPCODE 6'b001110
//branch
`define BEQ_OPCODE 6'b000100
`define BNE_OPCODE 6'b000101
`define BGEZ_OPCODE 6'b000001
`define BGTZ_OPCODE 6'b000111
`define BLEZ_OPCODE 6'b000110
`define BLTZ_OPCODE 6'b000001  //the same as BGEZ, the diff is 20:15 field
`define BGEZAL_OPCODE 6'b000001 //the same as BGEZ, the diff is 20:15 field
`define
`define BLTZAL_OPCODE 6'b000001 //the same
`define J_OPCODE 6'b000010
`define JAL_OPCODE 6'b000011
//load & store
`define LB_OPCODE 6'b100000
`define LBU_OPCODE 6'b100100
`define LH_OPCODE 6'b100001
`define LHU_OPCODE 6'b100101
`define LW_OPCODE 6'b100011
`define SB_OPCODE 6'b101000
`define SH_OPCODE 6'b101001
`define SW_OPCODE 6'b101011
`define ERET_OPCODE 6'b010000
`define MFC0_OPCODE 6'b010000 //the same as ERET,
`define MTC0_OPCODE 6'b010000 //the same as ERET,
 

/*control signal*/
`define REG_READ 1'b1
`define REG_NO_READ 1'b0
`define IS_JUMP 1'b1
`define NO_JUMP 1'b0
`define JUMP_FROM_REG 1'b1
`define JUMP_FROM_IMM 1'b0
`define IS_BRANCH 1'b1
`define NO_BRANCH 1'b0
`define MEM_WRITE 1'b1
`define MEM_NO_WRITE 1'b0
`define MEM_READ 1'b1
`define MEM_NO_READ 1'b0
`define REG3_FROM_RESULT 1'b1
`define REG3_FROM_MEM 1'b0
`define REG3_WRITE 1'b1
`define REG3_NO_WRITE 1'b0

/*ALU OPCODE*/
`define ADD_ALU_OPCODE 6'b000000
`define ADDU_ALU_OPCODE 6'b000001
`define SUB_ALU_OPCODE 6'b000010
`define SUBU_ALU_OPCODE 6'b000011
