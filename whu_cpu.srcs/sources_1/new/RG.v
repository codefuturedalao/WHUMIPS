`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 07:56:14 PM
// Design Name: 
// Module Name: RG
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


module RG(
	input wire i_clk,
	input wire i_rst,
	input wire [`REG_ADDR_WIDTH] i_reg1_addr,
	input wire [`REG_ADDR_WIDTH] i_reg2_addr,
	input wire i_reg1_read,
	input wire i_reg2_read,
	input wire [`REG_ADDR_WIDTH] i_reg3_addr,
	input wire [`REG_WIDTH] i_reg3_data,
	input wire i_reg3_write,
	output reg [`REG_WIDTH] o_reg1_data,
	output reg [`REG_WIDTH] o_reg2_data
    );
	reg [`REG_WIDTH] rg [`REG_NUM];
	/* write data */
	always
		@(posedge i_clk) begin
			/* don't use i_rst to control write data */
			if(i_reg3_write == `REG3_WRITE) begin
				rg[i_reg3_addr] <= i_reg3_data;
			end
		end
	/* read data */
	always
		@(*) begin
			if(i_rst == `RST_ENABLE) begin
				o_reg1_data <= `ZERO_WORD;
				o_reg2_data <= `ZERO_WORD;
			end	
			else begin
				/* reg1 */
				if(i_reg1_read == `REG_READ) begin
					if(i_reg3_addr == i_reg1_addr && i_reg3_write == `REG3_WRITE && i_reg3_addr != 5'b00000) begin //solve data hazard
						o_reg1_data <= i_reg3_data;	
					end
					else begin
						o_reg1_data <= rg[i_reg1_addr]; //normal read	
					end 
				end
				else begin
					o_reg1_data <= `ZERO_WORD;
				end
				/* reg2 */
				if(i_reg2_read == `REG_READ) begin
					if(i_reg3_addr == i_reg2_addr && i_reg3_write == `REG3_WRITE && i_reg3_addr != 5'b00000) begin //solve data hazard
						o_reg2_data <= i_reg3_data;	
					end
					else begin
						o_reg2_data <= rg[i_reg2_addr];	//normal read	
					end 
				end
				else begin
					o_reg2_data <= `ZERO_WORD;
				end
			end	
		end
endmodule
