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
	input wire [`REG_WIDTH] i_ex_alu_result,
	input wire [`REG_WIDTH] i_ex_reg2_ndata,
	input wire [`REG_ADDR_WIDTH] i_ex_reg3_addr,
	input wire i_ex_mem_write,
	input wire i_ex_mem_read,
	input wire i_ex_result_or_mem,
	input wire i_ex_reg3_write,
	
	output reg [`REG_WIDTH] o_mem_alu_result,
	output reg [`REG_WIDTH] o_mem_reg2_ndata,
	output reg [`REG_ADDR_WIDTH] o_mem_reg3_addr,
	output reg o_mem_mem_write,
	output reg o_mem_mem_read,
	output reg o_mem_result_or_mem,
	output reg o_mem_reg3_write
    );
	always
		@(posedge i_clk) begin
				if(i_rst == `RST_ENABLE) begin
						o_mem_alu_result <= `ZERO_WORD;
						o_mem_reg2_ndata <= `ZERO_WORD;
						o_mem_reg3_addr <= 5'b00000;
						o_mem_mem_write <= `MEM_NO_WRITE;
						o_mem_mem_read <= `MEM_NO_READ; 
						o_mem_result_or_mem <= `REG3_FROM_MEM; 
						o_mem_reg3_write <= `REG3_NO_WRITE;
				end
				else if(i_stall[3] == 1'b1 && i_stall[4] == 0) begin
						o_mem_alu_result <= `ZERO_WORD;
						o_mem_reg2_ndata <= `ZERO_WORD;
						o_mem_reg3_addr <= 5'b00000;
						o_mem_mem_write <= `MEM_NO_WRITE;
						o_mem_mem_read <= `MEM_NO_READ; 
						o_mem_result_or_mem <= `REG3_FROM_MEM; 
						o_mem_reg3_write <= `REG3_NO_WRITE;
				end
				else if(i_stall[3] == 1'b1 && i_stall[4] == 1) begin
						//do nothing, just keep the original value
				end
				else begin
						o_mem_alu_result <= i_ex_alu_result;
						o_mem_reg2_ndata <= i_ex_reg2_ndata;
						o_mem_reg3_addr <= i_ex_reg3_addr;
						o_mem_mem_write <= i_ex_mem_write;
						o_mem_mem_read <= i_ex_mem_read;
						o_mem_result_or_mem <= i_ex_result_or_mem;
						o_mem_reg3_write <= i_ex_reg3_write;
				end
		end
endmodule