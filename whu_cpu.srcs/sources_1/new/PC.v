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
	input wire i_curr_in_dslot,
	output reg [`INST_ADDR_WIDTH] o_pc,
	output reg [`INST_ADDR_WIDTH] o_bad_pc,
	output reg [31:0] o_exp_type,
	output reg o_ce,
	output wire o_curr_in_dslot
    );
	assign o_curr_in_dslot = i_curr_in_dslot;
	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
				o_ce <= `CHIP_DISABLE;
				o_exp_type <= `ZERO_WORD;
				o_bad_pc <= `ZERO_WORD;
			end
			else begin
				o_ce <= `CHIP_ENABLE;
			end
		end
	always
		@(posedge i_clk) begin
			if(o_ce == `CHIP_DISABLE) begin
					o_pc <= `DEFAULT_PC;
					o_exp_type <= `ZERO_WORD;
			end
			else if(i_flush == `IS_FLUSH) begin
					if(i_new_pc[1:0] == 2'b0) begin
							o_pc <= i_new_pc;
							o_exp_type <= `ZERO_WORD;
					end
					else begin
							o_pc <= `EXP_DEFAULT_PC;
							o_bad_pc <= i_new_pc;
//							o_pc <= `ZERO_WORD;
							o_exp_type[14] <= 1'b1;
					end
			end
			else if(i_stall[5] == 1'b1 && i_stall[4] == 1'b0) begin //this will not happen 
					o_pc <= `DEFAULT_PC;  
					o_exp_type <= `ZERO_WORD;
			end
			else if(i_stall[5] == 1'b1 && i_stall[4] == 1'b1) begin
					//do nothing, just keep the original value
			end
			else if(i_isbranch == 1'b1) begin
					if(i_branch_pc[1:0] == 2'b0) begin
							o_pc <= i_branch_pc;
							o_exp_type <= `ZERO_WORD;
					end
					else begin
							o_pc <= `EXP_DEFAULT_PC;
							o_bad_pc <= i_branch_pc;
//							o_pc <= `ZERO_WORD;
							o_exp_type[14] <= 1'b1;
					end
			end
			else begin
					o_pc <= o_pc + 4;
					o_exp_type <= `ZERO_WORD;
			end
		end

/*
	always
		@(*) begin
				if(i_rst == `RST_ENABLE) begin
					o_curr_in_dslot <= `NOT_IN_DSLOT;
				end
				else if(i_flush == `IS_FLUSH || (i_stall[5] == 1'b1 && i_stall[4] == 1'b0)) begin
					o_curr_in_dslot <= `NOT_IN_DSLOT;
				end
				else if(i_stall[5] == 1'b1 && i_stall[4] == 1'b1) begin
					//keep the original value
					//o_curr_in_dslot <= i_curr_in_dslot;
				end
				else begin
					o_curr_in_dslot <= i_curr_in_dslot;
				end
		end
		*/
endmodule
