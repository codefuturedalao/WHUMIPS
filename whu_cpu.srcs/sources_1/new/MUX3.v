`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2020 10:05:45 PM
// Design Name: 
// Module Name: MUX3
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


module MUX3(
	input wire [2:0] i_ex_cp0_sel,
	input wire [`REG_WIDTH] i_mem_alu_result,
	input wire [`REG_ADDR_WIDTH] i_mem_reg3_addr,
	input wire [2:0] i_mem_cp0_sel,
	input wire i_mem_cp0_write,
	input wire [`REG_WIDTH] i_wb_cp0_data,
	input wire [`REG_ADDR_WIDTH] i_wb_reg3_addr,
	input wire [2:0] i_wb_cp0_sel,
	input wire i_wb_cp0_write,
	input wire [`REG_ADDR_WIDTH] i_ex_rd_addr,
	input wire [`REG_WIDTH] i_ex_cp0_data,
	
	output reg [`REG_WIDTH] o_ex_cp0_ndata
    );

	always
		@(*) begin
				if(i_mem_cp0_write == `CP0_WRITE && i_mem_reg3_addr == i_ex_rd_addr && i_mem_cp0_sel == i_ex_cp0_sel) begin
						o_ex_cp0_ndata <= i_mem_alu_result;
				end
				else if(i_wb_cp0_write == `CP0_WRITE && i_wb_reg3_addr == i_ex_rd_addr && i_wb_cp0_sel == i_ex_cp0_sel) begin
						o_ex_cp0_ndata <= i_wb_cp0_data;
				end
				else begin
						o_ex_cp0_ndata <= i_ex_cp0_data;
				end
		end
endmodule
