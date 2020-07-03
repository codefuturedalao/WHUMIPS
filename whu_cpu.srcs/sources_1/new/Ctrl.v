`timescale 1ns / 1ps
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
	input wire [`REG_ADDR_WIDTH] i_ex_reg1_addr,
	input wire [`REG_ADDR_WIDTH] i_ex_reg2_addr,
	input wire i_ex_reg1_read,
	input wire i_ex_reg2_read,
	input wire [`REG_ADDR_WIDTH] i_mem_reg3_addr,
	input wire i_mem_reg3_write,
	input wire i_mem_mem_read,
	input wire [`REG_ADDR_WIDTH] i_wb_reg3_addr,
	input wire [`REG_ADDR_WIDTH] i_wb_reg3_addr,
	input wire i_wb_reg3_write,
	input wire i_jump_branch,
	
	output reg [`STALL_WIDTH] o_stall,
	output reg o_flush,
	output reg [1:0] o_forwardA,
	output reg [1:0] o_forwardB
    );
	/*control hazard*/
	assign o_flush = i_jump_branch;
	/*data hazard*/
	//forward 
	always
		@(*) begin
				if(i_mem_reg3_addr == i_ex_reg1_addr && i_mem_reg3_write == `REG3_WRITE && i_ex_reg1_read == `REG_READ) begin
					o_forwardA <= 2'b01;	
				end	
				else if(i_wb_reg3_addr == i_ex_reg1_addr && i_wb_reg3_write == `REG3_WRITE && i_ex_reg1_read == `REG_READ) begin
					o_forwardA <= 2'b10;
				end
				else begin
					o_forwardA <= 2'b00;
				end
		end	

	always
		@(*) begin
				if(i_mem_reg3_addr == i_ex_reg2_addr && i_mem_reg3_write == `REG3_WRITE && i_ex_reg2_read == `REG_READ) begin
					o_forwardB <= 2'b01;	
				end	
				else if(i_wb_reg3_addr == i_ex_reg2_addr && i_wb_reg3_write == `REG3_WRITE && i_ex_reg2_read == `REG_READ) begin
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
				if(i_mem_mem_read == `MEM_READ) begin//load inst
						if(i_ex_reg1_addr == i_mem_reg3_addr && i_ex_reg1_read == `REG_READ || i_ex_reg2_addr == i_mem_reg3_addr && i_ex_reg1_read == `REG_READ) begin
							o_stall <= 6'b111100;
						end
				end
		end	
endmodule