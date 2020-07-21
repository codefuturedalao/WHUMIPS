`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2020 09:17:37 PM
// Design Name: 
// Module Name: HILO
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


module HILO(
		input wire i_clk,
		input wire i_rst,
		
		input wire i_wen,
		input wire [`REG_WIDTH] i_hi,
		input wire [`REG_WIDTH] i_lo,

		output reg [`REG_WIDTH] o_hi,
		output reg [`REG_WIDTH] o_lo

    );

	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
					o_hi <= `ZERO_WORD;
					o_lo <= `ZERO_WORD;
			end
			else if(i_wen == `HILO_WRITE) begin
					o_hi <= i_hi;
					o_lo <= i_lo;
			end
		end
endmodule
