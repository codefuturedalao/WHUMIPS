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
// 		lack of ce signal 
// 		may cause some unpredicatable problem
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
	input wire i_flush,
	input wire [`INST_ADDR_WIDTH] i_new_pc,
	input wire [`INST_ADDR_WIDTH] i_branch_pc,
	input wire i_isbranch,
	output reg [`INST_ADDR_WIDTH] o_pc,
	output reg o_ce
    );

	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
				o_ce <= `CHIP_DISABLE;
			end
			else begin
				o_ce <= `CHIP_ENABLE;
			end
		end
	always
		@(posedge i_clk) begin
			if(o_ce == `CHIP_DISABLE) begin
					o_pc <= `DEFAULT_PC;
			end
			else if(i_flush == `IS_FLUSH) begin
					o_pc <= i_new_pc;
			end
			else if(i_stall[5] == 1'b1 && i_stall[4] == 1'b0) begin //this will not happen 
					o_pc <= `DEFAULT_PC;  
			end
			else if(i_stall[5] == 1'b1 && i_stall[4] == 1'b1) begin
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
