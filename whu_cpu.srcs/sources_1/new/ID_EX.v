`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 09:08:31 PM
// Design Name: 
// Module Name: ID_EX
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


module ID_EX(
	input wire i_clk,
	input wire i_rst,
	input wire [`STALL_WIDTH] i_stall,
	input wire i_flush,
	input wire [`REG_ADDR_WIDTH] i_id_reg1_addr,
	input wire [`REG_ADDR_WIDTH] i_id_reg2_addr,
	input wire i_id_reg1_read,
	input wire i_id_reg2_read, 
	input wire [`REG_WIDTH] i_id_reg1_data,
	input wire [`REG_WIDTH] i_id_reg2_data,
	input wire [`REG_ADDR_WIDTH] i_id_reg3_addr,
	input wire [25:0] i_id_imm26,
	input wire [`ALUOP_WIDTH] i_id_aluop,
	input wire i_id_jump,
	input wire i_id_jump_src,
	input wire i_id_branch,
	input wire i_id_mem_write,
	input wire i_id_mem_read,
	input wire i_id_result_or_mem,
	input wire i_id_reg3_write,
	input wire [`INST_ADDR_WIDTH] i_id_pc,

	output reg [`REG_ADDR_WIDTH] o_ex_reg1_addr,
	output reg [`REG_ADDR_WIDTH] o_ex_reg2_addr,
	output reg o_ex_reg1_read,
	output reg o_ex_reg2_read, 
	output reg [`REG_WIDTH] o_ex_reg1_data,
	output reg [`REG_WIDTH] o_ex_reg2_data,
	output reg [`REG_ADDR_WIDTH] o_ex_reg3_addr,
	output reg [25:0] o_ex_imm26,
	output reg [`ALUOP_WIDTH] o_ex_aluop,
	output reg o_ex_jump,
	output reg o_ex_jump_src,
	output reg o_ex_branch,
	output reg o_ex_mem_write,
	output reg o_ex_mem_read,
	output reg o_ex_result_or_mem,
	output reg o_ex_reg3_write,
	output reg [`INST_ADDR_WIDTH] o_ex_pc
    );
	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
				o_ex_reg1_read <= `REG_NO_READ;
				o_ex_reg2_read <= `REG_NO_READ;
				o_ex_reg1_data <= `ZERO_WORD;
				o_ex_reg2_data <= `ZERO_WORD;
				o_ex_reg3_addr <= 5'b00000;
				o_ex_imm26 <= 26'b0;
				o_ex_aluop <= `NOP_ALU_OPCODE;
				o_ex_jump <= `NO_JUMP;
				o_ex_jump_src <= `JUMP_FROM_IMM;
				o_ex_branch <= `NO_BRANCH;
				o_ex_mem_write <= `MEM_NO_WRITE;
				o_ex_mem_read <= `MEM_NO_READ;
				o_ex_result_or_mem <= `REG3_FROM_MEM;
				o_ex_reg3_write <= `REG3_NO_WRITE;
				o_ex_pc <= `ZERO_WORD;
			end
			else if(i_flush == `IS_FLUSH || (i_stall[2] == 1'b1 && i_stall[3] == 1'b0)) begin
				o_ex_reg1_read <= `REG_NO_READ;
				o_ex_reg2_read <= `REG_NO_READ;
				o_ex_reg1_data <= `ZERO_WORD;
				o_ex_reg2_data <= `ZERO_WORD;
				o_ex_reg3_addr <= 5'b00000;
				o_ex_imm26 <= 26'b0;
				o_ex_aluop <= `NOP_ALU_OPCODE;
				o_ex_jump <= `NO_JUMP;
				o_ex_jump_src <= `JUMP_FROM_IMM;
				o_ex_branch <= `NO_BRANCH;
				o_ex_mem_write <= `MEM_NO_WRITE;
				o_ex_mem_read <= `MEM_NO_READ;
				o_ex_result_or_mem <= `REG3_FROM_MEM;
				o_ex_reg3_write <= `REG3_NO_WRITE;
				o_ex_pc <= `ZERO_WORD;
			end 
			else if(i_stall[2] == 1'b1 && i_stall[3] == 1'b1) begin
				//keep the original value
			end
			else begin
				o_ex_reg1_read <= i_id_reg1_read;
				o_ex_reg2_read <= i_id_reg2_read;
				o_ex_reg1_data <= i_id_reg1_data;
				o_ex_reg2_data <= i_id_reg2_data;
				o_ex_reg3_addr <= i_id_reg3_addr;
				o_ex_imm26 <= i_id_imm26;
				o_ex_aluop <= i_id_aluop;
				o_ex_jump <= i_id_jump;
				o_ex_jump_src <= i_id_jump_src;
				o_ex_branch <= i_id_branch;
				o_ex_mem_write <= i_id_mem_write;
				o_ex_mem_read <= i_id_mem_read;
				o_ex_result_or_mem <= i_id_result_or_mem;
				o_ex_reg3_write <= i_id_reg3_write;
				o_ex_pc <= i_id_pc;
			end
		end
endmodule