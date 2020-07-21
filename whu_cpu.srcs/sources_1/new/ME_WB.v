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
	input wire i_flush,
	input wire [`REG_WIDTH] i_mem_reg3_data,
	input wire [`REG_ADDR_WIDTH] i_mem_reg3_addr,
	input wire i_mem_reg3_write,
	input wire i_mem_cp0_write,
	input wire [2:0] i_mem_cp0_sel,
	input wire [`INST_ADDR_WIDTH] i_mem_pc,
	input wire i_mem_hilo_wen,
	input wire [`REG_WIDTH] i_mem_hi,
	input wire [`REG_WIDTH] i_mem_lo,

	output reg [`REG_WIDTH] o_wb_reg3_data,
	output reg [`REG_ADDR_WIDTH] o_wb_reg3_addr,
	output reg o_wb_reg3_write,
	output reg o_wb_cp0_write,
	output reg [2:0] o_wb_cp0_sel,
	output reg [`INST_ADDR_WIDTH] o_wb_pc,
	output reg o_wb_hilo_wen,
	output reg [`REG_WIDTH] o_wb_hi,
	output reg [`REG_WIDTH] o_wb_lo

    );
	always
		@(posedge i_clk) begin
				if(i_rst == `RST_ENABLE) begin
						o_wb_reg3_data <= `ZERO_WORD;
						o_wb_reg3_addr <= 5'b00000;
						o_wb_reg3_write <= `REG3_NO_WRITE;
						o_wb_cp0_write <= `CP0_NO_WRITE;
						o_wb_cp0_sel <= 3'b000;
						o_wb_pc <= `ZERO_WORD;
						o_wb_hilo_wen <= `HILO_NO_WRITE;
						o_wb_hi <= `ZERO_WORD;
						o_wb_lo <= `ZERO_WORD;
				end
				else if(i_flush == `IS_FLUSH) begin
						o_wb_reg3_data <= `ZERO_WORD;
						o_wb_reg3_addr <= 5'b00000;
						o_wb_reg3_write <= `REG3_NO_WRITE;
						o_wb_cp0_write <= `CP0_NO_WRITE;
						o_wb_cp0_sel <= 3'b000;
						o_wb_pc <= `ZERO_WORD;
						o_wb_hilo_wen <= `HILO_NO_WRITE;
						o_wb_hi <= `ZERO_WORD;
						o_wb_lo <= `ZERO_WORD;
				end
				else if(i_stall[1] == 1'b1 && i_stall[0] == 1'b0) begin
						o_wb_reg3_data <= `ZERO_WORD;
						o_wb_reg3_addr <= 5'b00000;
						o_wb_reg3_write <= `REG3_NO_WRITE;
						o_wb_cp0_write <= `CP0_NO_WRITE;
						o_wb_cp0_sel <= 3'b000;
						o_wb_pc <= `ZERO_WORD;
						o_wb_hilo_wen <= `HILO_NO_WRITE;
						o_wb_hi <= `ZERO_WORD;
						o_wb_lo <= `ZERO_WORD;
				end
				else if(i_stall[1] == 1'b1 && i_stall[0] == 1'b1) begin
						//do nothing, keep the original value
				end
				else begin
						o_wb_reg3_data <= i_mem_reg3_data;
						o_wb_reg3_addr <= i_mem_reg3_addr;
						o_wb_reg3_write <= i_mem_reg3_write;
						o_wb_cp0_write <= i_mem_cp0_write; 
						o_wb_cp0_sel <= i_mem_cp0_sel; 
						o_wb_pc <= i_mem_pc;
						o_wb_hilo_wen <= i_mem_hilo_wen; 
						o_wb_hi <= i_mem_hi;
						o_wb_lo <= i_mem_lo; 
				end
		end
endmodule
