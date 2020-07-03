`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 04:13:01 PM
// Design Name: 
// Module Name: IF_ID
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


module IF_ID(
	input wire i_clk,
	input wire i_rst,
	input wire [`STALL_WIDTH] i_stall,
	input wire i_flush,
	input wire [`INST_WIDTH] i_if_inst,
	input wire [`INST_ADDR_WIDTH] i_if_pc,
	
	output reg [`INST_WIDTH] o_id_inst,
	output reg [`INST_ADDR_WIDTH] o_id_pc	
    );
	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
					o_id_inst <= `ZERO_WORD;	
					o_id_pc <= `ZERO_WORD;
			end
			else if(i_flush == `IS_FLUSH || (i_stall[1] == 1'b1 && i_stall[2] == 1'b0)) begin
					o_id_inst <= `ZERO_WORD;
					o_id_pc <= `ZERO_WORD;
			end
			else if(i_stall[1] == 1'b1 && i_stall[2] == 1'b0) begin
					//keep the original value
			end
			else begin
					o_id_inst <= i_if_inst;
					o_id_pc <= i_if_pc;
			end

		end
endmodule