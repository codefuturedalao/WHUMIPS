`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 08:47:00 PM
// Design Name: 
// Module Name: IMEM
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


module IMEM(
	input wire i_clk,
	input wire i_mem_en,
	input wire [`INST_ADDR_WIDTH] i_pc,
	input wire [3:0] i_mem_wen,
	input wire [`REG_WIDTH] i_data,
   	output reg [`INST_WIDTH] o_inst	
    );

	reg [31:0] imem [512:0];

	initial $readmemh("/home/jacksonsang/vivadoProject/whu_cpu/whu_cpu.srcs/sources_1/new/data/inst_rom.data", imem);

	always
		@(posedge i_clk) begin
				if(i_mem_en == `CHIP_ENABLE) begin
					o_inst <= imem[i_pc[15:2]];
				end
				else begin
					o_inst <= `ZERO_WORD;
				end
		end

endmodule
