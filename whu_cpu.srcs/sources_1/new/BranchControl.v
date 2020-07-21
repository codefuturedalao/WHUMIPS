`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 07:56:14 PM
// Design Name: 
// Module Name: BranchControl
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


module BranchControl(
	input wire i_jump,
	input wire i_jump_src,
	input wire i_branch,
	input wire [`INST_ADDR_WIDTH] i_pc,
	input wire [25:0] i_imm26,
	input wire [`REG_WIDTH] i_reg1_ndata,
	input wire [`REG_WIDTH] i_reg2_ndata,
	input wire [`ALUOP_WIDTH] i_aluop, 
	output wire o_jump_branch,
	output reg [`INST_ADDR_WIDTH] o_jump_branch_pc,
	output reg o_next_in_dslot
    );
	reg branch_flag;
	assign o_jump_branch = (branch_flag & i_branch) | i_jump;
	always
		@(i_jump, i_jump_src, i_branch, i_pc, i_imm26, i_reg1_ndata, i_reg2_ndata, i_aluop, branch_flag) begin
			if(i_jump == `IS_JUMP) begin
				if(i_jump_src == `JUMP_FROM_REG) begin
					o_jump_branch_pc <= i_reg1_ndata;
				end	
				else begin
					o_jump_branch_pc <= {i_pc[31:28], i_imm26, 2'b00};
				end
			end 
			else if(i_branch == `IS_BRANCH && branch_flag == 1'b1) begin 
				o_jump_branch_pc <= i_pc + {{14{i_imm26[15]}}, i_imm26[15:0], 2'b00} + 4;
			end
			else begin
				o_jump_branch_pc <= `ZERO_WORD;
			end
		end

	always
		@(*) begin
			branch_flag <= 1'b0;
			case(i_aluop)
				`BEQ_ALU_OPCODE: begin
					if(i_reg1_ndata == i_reg2_ndata) begin
							branch_flag <= 1'b1;
					end
					else begin
							branch_flag <= 1'b0;
					end
				end	
				`BNE_ALU_OPCODE: begin
					if(i_reg1_ndata != i_reg2_ndata) begin
							branch_flag <= 1'b1;
					end
					else begin
							branch_flag <= 1'b0;
					end
				end	
				`BGEZ_ALU_OPCODE: begin
					branch_flag <= ~(i_reg1_ndata[31]);
				end	
				`BGTZ_ALU_OPCODE: begin
					branch_flag <= (~i_reg1_ndata[31] & i_reg1_ndata != 32'b0);
				end	
				`BLEZ_ALU_OPCODE: begin
					branch_flag <= (i_reg1_ndata[31] | i_reg1_ndata == 32'b0);
				end	
				`BLTZ_ALU_OPCODE: begin
					branch_flag <= i_reg1_ndata[31];
				end	
				`BGEZAL_ALU_OPCODE: begin
					branch_flag <= ~(i_reg1_ndata[31]);
				end	
				`BLTZAL_ALU_OPCODE: begin
					branch_flag <= i_reg1_ndata[31];
				end	
				default: begin
						//do nothing
				end
			endcase
		end

	always
		@(*) begin
				if((i_branch | i_jump) == 1'b1) begin
						o_next_in_dslot <= `IN_DSLOT;
				end	
				else begin
						o_next_in_dslot <= `NOT_IN_DSLOT;
				end
		end
endmodule
