`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 07:56:14 PM
// Design Name: 
// Module Name: Ctrl
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


module Ctrl(
	input wire [`REG_ADDR_WIDTH] i_id_reg1_addr,
	input wire [`REG_ADDR_WIDTH] i_id_reg2_addr,
	input wire i_id_reg1_read,
	input wire i_id_reg2_read,
	input wire [`REG_ADDR_WIDTH] i_ex_reg3_addr,
	input wire i_ex_reg3_write,
	input wire i_ex_result_or_mem,  //represent load instruction
	input wire [`REG_ADDR_WIDTH] i_mem_reg3_addr,
	input wire i_mem_reg3_write,
	input wire i_stall_req_from_if,
	input wire i_stall_req_from_mem,
	input wire i_jump_branch,
	input wire i_if_read_result_flag,
	
	output reg [`STALL_WIDTH] o_stall,
	output reg o_if_axi_stall,
	output reg [1:0] o_forwardA,
	output reg [1:0] o_forwardB
    );
	/*data hazard*/
	//forward 
	always
		@(*) begin
				if(i_ex_reg3_addr == i_id_reg1_addr && i_ex_reg3_addr != 5'b00000 && i_ex_reg3_write == `REG3_WRITE && i_id_reg1_read == `REG_READ) begin
					o_forwardA <= 2'b01;	
				end	
				else if(i_mem_reg3_addr == i_id_reg1_addr && i_mem_reg3_addr != 5'b00000 && i_mem_reg3_write == `REG3_WRITE && i_id_reg1_read == `REG_READ) begin
					o_forwardA <= 2'b10;
				end
				else begin
					o_forwardA <= 2'b00;
				end
		end	

	always
		@(*) begin
				if(i_ex_reg3_addr == i_id_reg2_addr && i_ex_reg3_addr != 5'b00000 && i_ex_reg3_write == `REG3_WRITE && i_id_reg2_read == `REG_READ) begin
					o_forwardB <= 2'b01;	
				end	
				else if(i_mem_reg3_addr == i_id_reg2_addr && i_mem_reg3_addr != 5'b00000 && i_mem_reg3_write == `REG3_WRITE && i_id_reg2_read == `REG_READ) begin
					o_forwardB <= 2'b10;
				end
				else begin
					o_forwardB <= 2'b00;
				end
		end	
	//stall
	always
		@(*) begin
				o_stall <= 6'b000000;
				o_if_axi_stall <= `NO_STALL;
				if(i_stall_req_from_mem == `IS_STALL) begin
						o_stall <= 6'b111110;
						o_if_axi_stall <= `IS_STALL;
				end
				else if(i_ex_result_or_mem == `REG3_FROM_MEM && i_ex_reg3_write == `REG3_WRITE && (i_id_reg1_addr == i_ex_reg3_addr && i_id_reg1_read == `REG_READ || i_id_reg2_addr == i_ex_reg3_addr && i_id_reg2_read == `REG_READ)) begin//load inst
						o_stall <= 6'b111000;
						o_if_axi_stall <= `IS_STALL;
				end
				else if(i_jump_branch == 1'b1 && i_if_read_result_flag == 1'b0) begin
						o_stall <= 6'b111000;
						o_if_axi_stall <= `IS_STALL;
				end
				else if(i_stall_req_from_if == `IS_STALL) begin
						o_stall <= 6'b110000;
						o_if_axi_stall <= `IS_STALL;
				end
		end	
endmodule
