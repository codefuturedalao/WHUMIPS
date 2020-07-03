`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 08:47:00 PM
// Design Name: 
// Module Name: DMEM
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


module DMEM(
	input wire i_clk,
	input wire [`REG_WIDTH] i_addr,
	input wire [`REG_WIDTH] i_data,
	input wire i_mem_read,
	input wire i_mem_write,

	output reg [`REG_WIDTH] o_data
    );
	reg [31:0] dmem [127:0];	
	//read
	always
		@(*) begin
				if(i_mem_read == `MEM_READ) begin
					o_data <= dmem[i_addr];
				end
				else begin
					o_dat <= `ZERO_WORD;
				end
		end
	always
			@(posedge i_clk) begin
				if(i_mem_write == `MEM_WRITE) begin
					dmem[i_addr] <= i_data;
				end	
			end
endmodule
