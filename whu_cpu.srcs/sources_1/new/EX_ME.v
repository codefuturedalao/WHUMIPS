`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 04:13:01 PM
// Design Name: 
// Module Name: EX_ME
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


module EX_ME(
	input wire i_clk,
	input wire i_rst,
	input wire [`STALL_WIDTH] i_stall,
	input wire i_flush,
	input wire [`REG_WIDTH] i_ex_alu_result,
	input wire [`REG_WIDTH] i_ex_reg2_ndata,
	input wire [`REG_ADDR_WIDTH] i_ex_reg3_addr,
	input wire [3:0] i_ex_mem_wen,
	input wire i_ex_mem_en,
	input wire [2:0] i_ex_mem_byte_se,
	input wire i_ex_result_or_mem,
	input wire i_ex_reg3_write,
	input wire i_ex_cp0_write,
	input wire [2:0] i_ex_cp0_sel,
	input wire i_ex_curr_in_dslot,
	input wire [31:0] i_ex_exp_type,
	input wire [`INST_ADDR_WIDTH] i_ex_pc,
	
	output reg [`REG_WIDTH] o_mem_alu_result,
	output reg [`REG_WIDTH] o_mem_reg2_ndata,
	output reg [`REG_ADDR_WIDTH] o_mem_reg3_addr,
	output reg [3:0] o_mem_mem_wen,
	output reg o_mem_mem_en,
	output reg [2:0] o_mem_mem_byte_se,
	output reg o_mem_result_or_mem,
	output reg o_mem_reg3_write,
	output reg o_mem_cp0_write,
	output reg [2:0] o_mem_cp0_sel,
	output reg [31:0] o_mem_exp_type,
	output reg [`INST_ADDR_WIDTH] o_mem_pc,
	output reg o_mem_curr_in_dslot
    );
	always
		@(posedge i_clk) begin
				if(i_rst == `RST_ENABLE) begin
						o_mem_alu_result <= `ZERO_WORD;
						o_mem_reg2_ndata <= `ZERO_WORD;
						o_mem_reg3_addr <= 5'b00000;
						o_mem_mem_wen <= 4'b0000;
						o_mem_mem_en <= `MEM_DISABLE; 
						o_mem_mem_byte_se <= `MEM_SE_BYTE_U;
						o_mem_result_or_mem <= `REG3_FROM_MEM; 
						o_mem_reg3_write <= `REG3_NO_WRITE;
						o_mem_cp0_write <= `CP0_NO_WRITE;
						o_mem_cp0_sel <= 3'b000;
						o_mem_pc <= `ZERO_WORD;
						o_mem_exp_type <= `ZERO_WORD;
						o_mem_curr_in_dslot <= `NOT_IN_DSLOT;
				end
				else if(i_flush == `IS_FLUSH || i_stall[2] == 1'b1 && i_stall[1] == 0) begin
						o_mem_alu_result <= `ZERO_WORD;
						o_mem_reg2_ndata <= `ZERO_WORD;
						o_mem_reg3_addr <= 5'b00000;
						o_mem_mem_wen <= 4'b0000;
						o_mem_mem_en <= `MEM_DISABLE; 
						o_mem_mem_byte_se <= `MEM_SE_BYTE_U;
						o_mem_result_or_mem <= `REG3_FROM_MEM; 
						o_mem_reg3_write <= `REG3_NO_WRITE;
						o_mem_cp0_write <= `CP0_NO_WRITE;
						o_mem_cp0_sel <= 3'b000;
						o_mem_pc <= `ZERO_WORD;
						o_mem_exp_type <= `ZERO_WORD;
						o_mem_curr_in_dslot <= `NOT_IN_DSLOT;
				end
				else if(i_stall[2] == 1'b1 && i_stall[1] == 1) begin
						//do nothing, just keep the original value
				end
				else begin
						o_mem_alu_result <= i_ex_alu_result;
						o_mem_reg2_ndata <= i_ex_reg2_ndata;
						o_mem_reg3_addr <= i_ex_reg3_addr;
						o_mem_mem_wen <= i_ex_mem_wen;
						o_mem_mem_en <= i_ex_mem_en;
						o_mem_mem_byte_se <= i_ex_mem_byte_se;
						o_mem_result_or_mem <= i_ex_result_or_mem;
						o_mem_reg3_write <= i_ex_reg3_write;
						o_mem_cp0_write <= i_ex_cp0_write; 
						o_mem_cp0_sel <= i_ex_cp0_sel; 
						o_mem_pc <= i_ex_pc; 
						o_mem_exp_type <= i_ex_exp_type; 
						o_mem_curr_in_dslot <= i_ex_curr_in_dslot;
				end
		end
endmodule
