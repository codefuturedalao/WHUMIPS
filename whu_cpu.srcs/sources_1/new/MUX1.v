`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 07:56:14 PM
// Design Name: 
// Module Name: MUX1
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


module MUX1(
	input wire [1:0] i_forwardA,
	input wire [1:0] i_forwardB,
	input wire [`REG_WIDTH] i_mem_alu_result,
	input wire [`REG_WIDTH] i_wb_reg3_data,
	input wire [`REG_WIDTH] i_reg1_data,
	input wire [`REG_WIDTH] i_reg2_data,
	output reg [`REG_WIDTH] o_reg1_data,
	output reg [`REG_WIDTH] o_reg2_data
    );
	always
		@(i_forwardA,i_forwardB,i_mem_alu_result,i_wb_reg3_data,i_reg1_data,i_reg2_data) begin
			//reg1_data
			if(i_forwardA == 2'b00) begin
				o_reg1_data <= i_reg1_data;
			end
			else if(i_forwardA == 2'b01) begin
				o_reg1_data <= i_mem_alu_result;
			end
			else if(i_forwardA == 2'b10) begin
				o_reg1_data <= i_wb_reg3_data;
			end
			//reg2_data
			if(i_forwardB == 2'b00) begin
				o_reg2_data <= i_reg2_data;
			end
			else if(i_forwardB == 2'b01) begin
				o_reg2_data <= i_mem_alu_result;
			end
			else if(i_forwardB == 2'b10) begin
				o_reg2_data <= i_wb_reg3_data;
			end
		end

endmodule
