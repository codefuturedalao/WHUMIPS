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
	input wire i_mem_en,
	input wire i_mem_wen,

	output reg [`REG_WIDTH] o_data
    );
	reg [31:0] dmem [127:0];	
	//read
	always
		@(*) begin
				if(i_mem_en == `MEM_ENABLE && i_mem_wen == 4'b0000) begin
					o_data <= dmem[i_addr];
				end
				else begin
					o_dat <= `ZERO_WORD;
				end
		end
	always
			@(posedge i_clk) begin
				if(i_mem_en == `MEM_ENABLE) begin
					if(i_mem_wen[0] == 1'b1) begin
							dmem[i_addr][7:0] <= i_data[7:0];
					end
					if(i_mem_wen[1] == 1'b1) begin
							dmem[i_addr][15:7] <= i_data[15:8];
					end
					if(i_mem_wen[2] == 1'b1) begin
							dmem[i_addr][23:16] <= i_data[15:8];
					end
					if(i_mem_wen[3] == 1'b1) begin
							dmem[i_addr][31:24] <= i_data[15:8];
					end
				end	
			end
endmodule
