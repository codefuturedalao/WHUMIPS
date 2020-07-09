`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 04:13:01 PM
// Design Name: 
// Module Name: ME_WB
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


module ME_WB(
	input wire i_clk,
	input wire i_rst,
	input wire [`STALL_WIDTH] i_stall,
	input wire [`REG_WIDTH] i_mem_reg3_data,
	input wire [`REG_ADDR_WIDTH] i_mem_reg3_addr,
	input wire i_mem_reg3_write,

	output reg [`REG_WIDTH] o_wb_reg3_data,
	output reg [`REG_ADDR_WIDTH] o_wb_reg3_addr,
	output reg o_wb_reg3_write
    );
	always
		@(posedge i_clk) begin
				if(i_rst == `RST_ENABLE) begin
						o_wb_reg3_data <= `ZERO_WORD;
						o_wb_reg3_addr <= 5'b00000;
						o_wb_reg3_write <= `REG3_NO_WRITE;
				end
				else if(i_stall[4] == 1'b1 && i_stall[5] == 1'b0) begin
						o_wb_reg3_data <= `ZERO_WORD;
						o_wb_reg3_addr <= 5'b00000;
						o_wb_reg3_write <= `REG3_NO_WRITE;
				end
				else if(i_stall[4] == 1'b1 && i_stall[5] == 1'b1) begin
						//do nothing, keep the original value
				end
				else begin
						o_wb_reg3_data <= i_mem_reg3_data;
						o_wb_reg3_addr <= i_mem_reg3_addr;
						o_wb_reg3_write <= i_mem_reg3_write;
				end
		end
endmodule
