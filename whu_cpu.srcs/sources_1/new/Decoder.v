`timescale 1ns / 1ps
`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2020 12:33:19 AM
// Design Name: 
// Module Name: Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Decoder(
    input wire [`INST_WIDTH] i_inst,  
	input wire [31:0] i_exp_type,

    output reg o_reg1_read,
	output reg o_reg2_read,
	output wire [`REG_ADDR_WIDTH] o_reg1_addr,
	output wire [`REG_ADDR_WIDTH] o_reg2_addr,
	output wire [`REG_ADDR_WIDTH] o_rd_addr,
	output reg [`REG_ADDR_WIDTH] o_reg3_addr,
	output reg [`ALUOP_WIDTH] o_aluop,
	output wire [25:0] o_imm26,
	output reg o_jump,
	output reg o_jump_src,
	output reg o_branch,
	output reg o_mem_en,   
	output reg [3:0] o_mem_wen,	//write enable 
	output reg [2:0] o_mem_byte_se,
	output reg o_result_or_mem,
	output reg o_reg3_write,
	output reg o_cp0_write,
	output wire [31:0] o_exp_type,
	output reg o_hilo_write
    );
	
	reg syscall;
	reg eret;
	reg break;
	reg inst_valid;

	assign o_reg1_addr = i_inst[25:21];
	assign o_reg2_addr = i_inst[20:16];
	assign o_rd_addr = i_inst[15:11];
	assign o_imm26 = i_inst[25:0];
	assign o_exp_type = {i_exp_type[31:12], syscall, eret, break, inst_valid, i_exp_type[7:0]};
	wire [5:0] opcode = i_inst[31:26];	
	wire [5:0] imm5_0 = i_inst[5:0];
	wire [4:0] imm20_16 = i_inst[20:16]; //the same as reg2_addr

/*arth and logical*/
	always
		@(*) begin
			syscall <= `NO_EXCEPTION;
			break <=  `NO_EXCEPTION;
			inst_valid <= `INST_NO_VALID;
            o_reg1_read <= `REG_READ;
            o_reg2_read <= `REG_READ;
            o_reg3_addr <= i_inst[15:11];
            o_aluop <= `NOP_ALU_OPCODE;
            o_reg3_write <= `REG3_WRITE;
			o_hilo_write <= `HILO_NO_WRITE;

			o_mem_en <= `MEM_DISABLE;
			o_mem_wen <= 4'b0000;  //may be it represent read, i am not sure 07/05
			o_mem_byte_se <= `MEM_SE_BYTE;
			o_result_or_mem <= `REG3_FROM_RESULT; //it doesn't matter bec reg3 no write

			o_jump <= `NO_JUMP;
			o_jump_src <= `JUMP_FROM_REG;
			o_branch <= `NO_BRANCH;

			o_cp0_write <= `CP0_NO_WRITE;
			eret <= `NO_EXCEPTION; 
			case(opcode)
				`ADDI_OPCODE: begin
					o_aluop <= `ADDI_ALU_OPCODE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
				`ADDIU_OPCODE: begin
					o_aluop <= `ADDIU_ALU_OPCODE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
				`SLTI_OPCODE: begin
					o_aluop <= `SLTI_ALU_OPCODE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
				`SLTIU_OPCODE: begin
					o_aluop <= `SLTIU_ALU_OPCODE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
				`ANDI_OPCODE: begin
					o_aluop <= `ANDI_ALU_OPCODE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
				`LUI_OPCODE: begin
					o_aluop <= `LUI_ALU_OPCODE;
					o_reg1_read <= `REG_NO_READ;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
				`ORI_OPCODE: begin
					o_aluop <= `ORI_ALU_OPCODE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
				`XORI_OPCODE: begin
					o_aluop <= `XORI_ALU_OPCODE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];
					inst_valid <= `INST_VALID;
				end
/* load and store */
				`LB_OPCODE: begin
					o_aluop <= `LB_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_byte_se <= `MEM_SE_BYTE;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];			
					o_result_or_mem <= `REG3_FROM_MEM;
					inst_valid <= `INST_VALID;
				end	
				`LBU_OPCODE: begin
					o_aluop <= `LBU_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_byte_se <= `MEM_SE_BYTE_U;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];			
					o_result_or_mem <= `REG3_FROM_MEM;
					inst_valid <= `INST_VALID;
				end	
				`LH_OPCODE: begin
					o_aluop <= `LH_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_byte_se <= `MEM_SE_HALF;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];			
					o_result_or_mem <= `REG3_FROM_MEM;
					inst_valid <= `INST_VALID;
				end	
				`LHU_OPCODE: begin
					o_aluop <= `LHU_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_byte_se <= `MEM_SE_HALF_U;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];			
					o_result_or_mem <= `REG3_FROM_MEM;
					inst_valid <= `INST_VALID;
				end	
				`LW_OPCODE: begin
					o_aluop <= `LW_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_byte_se <= `MEM_SE_WORD;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= i_inst[20:16];			
					o_result_or_mem <= `REG3_FROM_MEM;
					inst_valid <= `INST_VALID;
				end	
				`SB_OPCODE: begin
					o_aluop <= `SB_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_wen <= 4'b0001;
					//o_mem_byte_se <= `MEM_SE_BYTE;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end	
				`SH_OPCODE: begin
					o_aluop <= `SH_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_wen <= 4'b0011;
					//o_mem_byte_se <= `MEM_SE_BYTE;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end	
				`SW_OPCODE: begin
					o_aluop <= `SW_ALU_OPCODE;
					o_mem_en <= `MEM_ENABLE;
					o_mem_wen <= 4'b1111;
					//o_mem_byte_se <= `MEM_SE_BYTE;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end
				`SPECIAL_OPCODE: begin
					case(imm5_0)
						`ADD_OPCODE: begin
							o_aluop <= `ADD_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end
						`ADDU_OPCODE: begin
							o_aluop <= `ADDU_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end	
						`SUB_OPCODE: begin
							o_aluop <= `SUB_ALU_OPCODE;	
							inst_valid <= `INST_VALID;
						end
						`SUBU_OPCODE: begin	
							o_aluop <= `SUBU_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end
						`SLT_OPCODE: begin
							o_aluop <= `SLT_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end
						`SLTU_OPCODE: begin
							o_aluop <= `SLTU_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end
						`DIV_OPCODE: begin
							o_aluop <= `DIV_ALU_OPCODE;
							inst_valid <= `INST_VALID;
							o_hilo_write <= `HILO_WRITE;
							o_reg3_write <= `REG3_NO_WRITE;
						end	 
						`DIVU_OPCODE: begin
							o_aluop <= `DIVU_ALU_OPCODE;
							inst_valid <= `INST_VALID;
							o_hilo_write <= `HILO_WRITE;
							o_reg3_write <= `REG3_NO_WRITE;
						end	 
						`MULT_OPCODE: begin
							o_aluop <= `MULT_ALU_OPCODE;
							inst_valid <= `INST_VALID;
							o_hilo_write <= `HILO_WRITE;
							o_reg3_write <= `REG3_NO_WRITE;
						end	 
						`MULTU_OPCODE: begin
							o_aluop <= `MULTU_ALU_OPCODE;
							inst_valid <= `INST_VALID;
							o_hilo_write <= `HILO_WRITE;
							o_reg3_write <= `REG3_NO_WRITE;
						end	 
						`AND_OPCODE: begin
							o_aluop <= `AND_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end	 
						`NOR_OPCODE: begin
							o_aluop <= `NOR_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end	 
						`OR_OPCODE: begin
							o_aluop <= `OR_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end	 
						`XOR_OPCODE: begin
							o_aluop <= `XOR_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end	 
						`SLLV_OPCODE: begin
							o_aluop <= `SLLV_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end
						`SLL_OPCODE: begin
							o_aluop <= `SLL_ALU_OPCODE;
							o_reg1_read <= `REG_NO_READ;
							inst_valid <= `INST_VALID;
						end
						`SRAV_OPCODE: begin
							o_aluop <= `SRAV_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end
						`SRA_OPCODE: begin
							o_aluop <= `SRA_ALU_OPCODE;
							o_reg1_read <= `REG_NO_READ;
							inst_valid <= `INST_VALID;
						end
						`SRLV_OPCODE: begin
							o_aluop <= `SRLV_ALU_OPCODE;
							inst_valid <= `INST_VALID;
						end
						`SRL_OPCODE: begin
							o_aluop <= `SRL_ALU_OPCODE;
							o_reg1_read <= `REG_NO_READ;
							inst_valid <= `INST_VALID;
						end
						`MFHI_OPCODE: begin
							o_aluop <= `MFHI_ALU_OPCODE;
							o_reg1_read <= `REG_NO_READ;
							o_reg2_read <= `REG_NO_READ;
							inst_valid <= `INST_VALID;
						end
						`MFLO_OPCODE: begin
							o_aluop <= `MFLO_ALU_OPCODE;
							o_reg1_read <= `REG_NO_READ;
							o_reg2_read <= `REG_NO_READ;
							inst_valid <= `INST_VALID;
						end
						`MTHI_OPCODE: begin
							o_aluop <= `MTHI_ALU_OPCODE;
							o_reg2_read <= `REG_NO_READ;
							o_reg3_write <= `REG3_NO_WRITE;
							inst_valid <= `INST_VALID;
							o_hilo_write <= `HILO_WRITE;
						end
						`MTLO_OPCODE: begin
							o_aluop <= `MTLO_ALU_OPCODE;
							o_reg2_read <= `REG_NO_READ;
							o_reg3_write <= `REG3_NO_WRITE;
							inst_valid <= `INST_VALID;
							o_hilo_write <= `HILO_WRITE;
						end
						/*trap inst*/
						`BREAK_OPCODE: begin
							o_aluop <= `BREAK_ALU_OPCODE;
							inst_valid <= `INST_VALID;
							break <= `IS_EXCEPTION;
						end
						`SYS_OPCODE: begin
							o_aluop <= `SYS_ALU_OPCODE;
							inst_valid <= `INST_VALID;
							syscall <= `IS_EXCEPTION;
						end
						/* branch and jump */
						`JR_OPCODE: begin
							o_aluop <= `JR_ALU_OPCODE;
							o_jump <= `IS_JUMP;
							o_reg2_read <= `REG_NO_READ;
							o_reg3_addr <= 5'b11111;
							o_reg3_write <= `REG3_NO_WRITE;
							inst_valid <= `INST_VALID;
						end	
						`JALR_OPCODE: begin
							o_aluop <= `JALR_ALU_OPCODE;
							o_jump <= `IS_JUMP;
							o_reg2_read <= `REG_NO_READ;
							inst_valid <= `INST_VALID;
						end	
						default: begin
							//nothing
						end
					endcase
				end
				`SPECIAL2_OPCODE: begin
				    case(imm5_0)
				        `MUL_OPCODE: begin
				            o_aluop <= `MUL_ALU_OPCODE;
							inst_valid <= `INST_VALID;
							//o_hilo_write <= `HILO_WRITE;
							//o_reg3_write <= `REG3_NO_WRITE;
				        end
				        default: begin
				            //nothing
				        end
				    endcase
				end
/* branch and jump */
				`BEQ_OPCODE: begin
					o_aluop <= `BEQ_ALU_OPCODE;
					o_branch <= `IS_BRANCH;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end	
				`BNE_OPCODE: begin
					o_aluop <= `BNE_ALU_OPCODE;
					o_branch <= `IS_BRANCH;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end	
				`BGTZ_OPCODE: begin
					o_aluop <= `BGTZ_ALU_OPCODE;
					o_branch <= `IS_BRANCH;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end	
				`BLEZ_OPCODE: begin
					o_aluop <= `BLEZ_ALU_OPCODE;
					o_branch <= `IS_BRANCH;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end	
				`J_OPCODE: begin
					o_aluop <= `J_ALU_OPCODE;
					o_jump <= `IS_JUMP;
					o_jump_src <= `JUMP_FROM_IMM;
					o_reg1_read <= `REG_NO_READ;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_write <= `REG3_NO_WRITE;
					inst_valid <= `INST_VALID;
				end
				`JAL_OPCODE: begin
					o_aluop <= `JAL_ALU_OPCODE;
					o_jump <= `IS_JUMP;
					o_jump_src <= `JUMP_FROM_IMM;
					o_reg1_read <= `REG_NO_READ;
					o_reg2_read <= `REG_NO_READ;
					o_reg3_addr <= 5'b11111;
					inst_valid <= `INST_VALID;
				end
				`BGELTZ_OPCODE: begin
					case(imm20_16)
						`BGEZ_OPCODE: begin
							o_aluop <= `BGEZ_ALU_OPCODE;
							o_reg2_read <= `REG_NO_READ;
							o_branch <= `IS_BRANCH;
							o_reg3_write <= `REG3_NO_WRITE;
							inst_valid <= `INST_VALID;
						end
						`BLTZ_OPCODE: begin
							o_aluop <= `BLTZ_ALU_OPCODE;
							o_reg2_read <= `REG_NO_READ;
							o_branch <= `IS_BRANCH;
							o_reg3_write <= `REG3_NO_WRITE;
							inst_valid <= `INST_VALID;
						end
						`BGEZAL_OPCODE: begin
							o_aluop <= `BGEZAL_ALU_OPCODE;
							o_reg2_read <= `REG_NO_READ;
							o_reg3_addr <= 5'b11111;
							o_branch <= `IS_BRANCH;
							inst_valid <= `INST_VALID;
						end
						`BLTZAL_OPCODE: begin
							o_aluop <= `BLTZAL_ALU_OPCODE;
							o_reg2_read <= `REG_NO_READ;
							o_reg3_addr <= 5'b11111;
							o_branch <= `IS_BRANCH;
							inst_valid <= `INST_VALID;
						end
						default: begin
						    o_aluop <= `NOP_ALU_OPCODE;
						    o_reg1_read <= `REG_NO_READ;
							o_reg2_read <= `REG_NO_READ;
							o_reg3_write <= `REG3_NO_WRITE;
						end
					endcase
				end
				`PRIV_OPCODE: begin
						case(o_reg1_addr) 
								`ERET_OPCODE: begin
										o_cp0_write <= `CP0_NO_WRITE; // emmmm
										o_aluop <= `ERET_ALU_OPCODE;
										o_reg3_write <= `REG3_NO_WRITE;	
										o_reg1_read <= `REG_NO_READ;
										o_reg2_read <= `REG_NO_READ;
										inst_valid <= `INST_VALID;
										eret <= `IS_EXCEPTION;
								end
								`MFC0_OPCODE: begin
										o_cp0_write <= `CP0_NO_WRITE;
										o_aluop <= `MFC0_ALU_OPCODE;
										o_reg3_write <= `REG3_WRITE;	
										o_reg1_read <= `REG_NO_READ;
										o_reg3_addr <= i_inst[20:16];
										inst_valid <= `INST_VALID;
								end
								`MTC0_OPCODE: begin
										o_cp0_write <= `CP0_WRITE;
										o_aluop <= `MTC0_ALU_OPCODE;
										o_reg3_write <= `REG3_NO_WRITE;	
										o_reg1_read <= `REG_NO_READ;
										o_cp0_write <= `CP0_WRITE;
										inst_valid <= `INST_VALID;
								end
								default: begin
										//do nothing
								end
						endcase
				end
				default: begin
					//nothing
				end
			endcase 
		end


endmodule
