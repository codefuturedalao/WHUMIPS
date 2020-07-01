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
	input wire [`REG_WIDTH] i_jump_reg_data,
	input wire i_branch_flag,
	output wire o_jump_branch,
	output reg [`INST_ADDR_WIDTH] o_jump_branch_pc
    );
	assign o_jump_branch = i_jump & i_branch & i_branch_flag;	
	always
		@(i_jump, i_jump_src, i_branch, i_pc, i_imm26, i_jump_reg_data) begin
			if(i_jump == `IS_JUMP) begin
				if(i_jump_src == `JUMP_FROM_REG) begin
					o_jump_branch_pc <= i_jump_reg_data;
				end	
				else begin
					o_jump_branch_pc <= {i_pc[31:28], i_imm26, 2'b00};
				end
			end 
			else begin 
				o_jump_branch_pc <= i_pc + {{14{i_imm26[15]}}, i_imm26, 2'b00};
			end
		end
endmodule
