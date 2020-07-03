`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 07:56:14 PM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		LOHI,BREAK.C0 to do 
// Dependencies: 
//		 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
	input wire [`INST_ADDR_WIDTH] i_pc,
	input wire [`REG_WIDTH] i_reg1_ndata,
	input wire [`REG_WIDTH] i_reg2_ndata,
	input wire [15:0] i_imm16,
	input wire [`ALUOP_WIDTH] i_aluop,
	output reg o_branch_flag,
	output reg o_exception_flag,
	output reg [`REG_WIDTH] o_alu_result
    );
	wire [32:0] add_result_reg; //the most significant bit can be used for judge overflow
	wire [32:0] sub_result_reg; //
	wire [32:0] add_result_imm; //the most significant bit can be used for judge overflow
	wire [32:0] sub_result_imm; //
	wire [31:0] imm32_sign; 
	wire [31:0] imm32_unsign; 

	assign imm32_sign = {{16{i_imm16[15]}},i_imm16[15:0]};
	assign imm32_unsign = {16'b0,i_imm16[15:0]};
	assign add_result_reg = {i_reg1_ndata[31],i_reg1_ndata[31:0]} + {i_reg2_ndata[31],i_reg2_ndata[31:0]}; //usr for add,addu
	assign add_result_imm = {i_reg1_ndata[31],i_reg1_ndata[31:0]} + imm32_sign; //use for addi,addiu
	assign sub_result_reg = {i_reg1_ndata[31],i_reg1_ndata[31:0]} - {i_reg2_ndata[31],i_reg2_ndata[31:0]}; //use for sub,subu,slt
	assign sub_result_imm = {i_reg1_ndata[31],i_reg1_ndata[31:0]} - imm32_unsign; //use for slti

	always
		@(i_aluop) begin
			o_exception_flag <= `NO_EXCEPTION;
			case(i_aluop)
				`ADD_ALU_OPCODE: begin
					if(add_result_reg[32] ^ add_result_reg[31] == 1'b1) begin //overflow
						o_exception_flag <= `IS_EXCEPTION;
						o_alu_result <= `ZERO_WORD;
					end else begin	
						o_alu_result <= add_result_reg[31:0];
					end
				end	
				`ADDI_ALU_OPCODE: begin
					if(add_result_imm[32] ^ add_result_imm[31] == 1'b1) begin //overflow
						o_exception_flag <= `IS_EXCEPTION;
						o_alu_result <= `ZERO_WORD;
					end else begin	
						o_alu_result <= add_result_imm[31:0];
					end
				end
				`ADDU_ALU_OPCODE: begin
					o_alu_result <= add_result_reg[31:0];
				end	
				`ADDIU_ALU_OPCODE: begin
					o_alu_result <= add_result_imm[31:0];
				end	
				`SUB_ALU_OPCODE: begin
					if(sub_result_reg[32] ^ sub_result_reg[31] == 1'b1) begin //overflow
						o_exception_flag <= `IS_EXCEPTION;
						o_alu_result <= `ZERO_WORD;
					end else begin	
						o_alu_result <= sub_result_reg[31:0];
					end
				end	
				`SUBU_ALU_OPCODE: begin
					o_alu_result <= sub_result_reg[31:0];
				end	
				`SLT_ALU_OPCODE: begin
//					if(sub_result_reg[32] == 1'b1)
//						o_alu_result <= 32'b1;
					o_alu_result <= sub_result_reg[32];
				end
				`SLTI_ALU_OPCODE: begin
					o_alu_result <= sub_result_imm[32];
				end
				`SLTU_ALU_OPCODE: begin
					o_alu_result <= (i_reg1_ndata < i_reg2_ndata) ? 32'b1 : 32'b0;
				end
				`SLTIU_ALU_OPCODE: begin
					o_alu_result <= (i_reg1_ndata < imm32_sign) ? 32'b1 : 32'b0;

				end
				`AND_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata & i_reg2_ndata;
				end
				`ANDI_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata & imm32_unsign;

				end
				`LUI_ALU_OPCODE: begin
					o_alu_result <= {i_imm16,16'b0};
				end
				`NOR_ALU_OPCODE: begin
					o_alu_result <= ~ (i_reg1_ndata | i_reg2_ndata);
				end
				`OR_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata | i_reg2_ndata;
				end
				`ORI_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata | imm32_unsign; 
				end
				`XOR_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata ^ i_reg2_ndata; 
				end
				`XORI_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata ^ imm32_unsign;
				end
				`SLLV_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata << i_reg2_ndata[4:0]; 
				end
				`SLL_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata << i_imm16[10:6]; 
				end
				`SRAV_ALU_OPCODE: begin
					o_alu_result <= (i_reg1_ndata >> i_reg2_ndata[4:0]) | (i_reg1_ndata[31]) ? ~({32{1'b1}} >> i_reg2_ndata[4:0]) : 32'b0; 
				end
				`SRA_ALU_OPCODE: begin
					o_alu_result <= (i_reg1_ndata >> i_imm16[10:6]) | (i_reg1_ndata[31]) ? ~({32{1'b1}} >> i_imm16[10:6]) : 32'b0; 
				end
				`SRLV_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata >> i_reg2_ndata[4:0]; 
				end
				`SRL_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata >> i_imm16[10:6]; 
				end
				default: begin
				    //todo
				end
			endcase
		end

/*branch and jump */
	always
		@(i_aluop) begin
			o_branch_flag <= 1'b0;
			o_alu_result <= `ZERO_WORD;
			case(i_aluop)
				`BEQ_ALU_OPCODE: begin
					o_branch_flag <= ~(| sub_result_reg[31:0]);
				end	
				`BNE_ALU_OPCODE: begin
					o_branch_flag <= | sub_result_reg[31:0];
				end	
				`BGEZ_ALU_OPCODE: begin
					o_branch_flag <= ~(i_reg1_ndata[31]);
				end	
				`BGTZ_ALU_OPCODE: begin
					o_branch_flag <= (~i_reg1_ndata[31] & i_reg1_ndata != 32'b0);
				end	
				`BLEZ_ALU_OPCODE: begin
					o_branch_flag <= (~i_reg1_ndata[31] | i_reg1_ndata == 32'b0);
				end	
				`BLTZ_ALU_OPCODE: begin
					o_branch_flag <= i_reg1_ndata[31];
				end	
				`BGEZAL_ALU_OPCODE: begin
					o_branch_flag <= ~(i_reg1_ndata[31]);
					o_alu_result <= i_pc + 8;
				end	
				`BLTZAL_ALU_OPCODE: begin
					o_branch_flag <= i_reg1_ndata[31];
					o_alu_result <= i_pc + 8;
				end	
				`J_ALU_OPCODE: begin
					//nothing
				end
				`JAL_ALU_OPCODE: begin
					o_alu_result <= i_pc + 8;	
				end
				`JR_ALU_OPCODE: begin
					//nothing
				end
				`JALR_ALU_OPCODE: begin
					o_alu_result <= i_pc + 8;	
				end
			endcase
		end
/* access memory */
	always
		@(i_aluop) begin
			case(i_aluop)
				//lb and lbu is the same as addiu
				`LH_ALU_OPCODE: begin
					o_alu_result <= add_result_imm;
					o_exception_flag <= add_result_imm[0];
				end
				//lhu is the same as lh
				`LW_ALU_OPCODE: begin
					o_alu_result <= add_result_imm;
					o_exception_flag <= add_result_imm[1] | add_result_imm[0];
				end
				//sb is the same as addiu
				//sh is the same as lh
				//sw is the same as lw
			endcase	
		end
endmodule