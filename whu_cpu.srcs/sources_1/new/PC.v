`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 08:47:00 PM
// Design Name: 
// Module Name: PC
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


module PC(
	input wire i_clk,
	input wire i_rst,
	input wire [`STALL_WIDTH] i_stall,
	input wire [`INST_ADDR_WIDTH] i_branch_pc,
	input wire i_isbranch,
	output reg [`INST_ADDR_WIDTH] o_pc
    );
	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
					o_pc <= `DEFAULT_PC;
			end
			else if(i_stall[0] == 1'b1 && i_stall[1] == 1'b0) begin
					o_pc <= `DEFAULT_PC;
			end
			else if(i_stall[1] == 1'b1 && i_stall[1] == 1'b1) begin
					//do nothing, just keep the original value
			end
			else if(i_isbranch == 1'b1) begin
					o_pc <= i_branch_pc;
			end
			else begin
					o_pc <= o_pc + 4;
			end
		end
endmodule