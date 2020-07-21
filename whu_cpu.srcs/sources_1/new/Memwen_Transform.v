`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2020 09:28:50 AM
// Design Name: 
// Module Name: Memwen_Transform
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


module Memwen_Transform(
		input wire [`REG_WIDTH] i_alu_result,
		input wire [`WEN_ADDR] i_mem_wen,
		input wire [`REG_WIDTH] i_reg2_data,

		output reg [`WEN_ADDR] o_mem_wen,
		output reg [`REG_WIDTH] o_reg2_data
    );
	always
		@(*) begin
			if(|i_mem_wen != 1'b0) begin		//write valid
					case(i_alu_result[1:0])
						2'b00: begin
							o_mem_wen <= i_mem_wen;
							o_reg2_data <= i_reg2_data;
						end
						2'b01: begin
							o_mem_wen <= i_mem_wen << 1;
							o_reg2_data <= i_reg2_data << 8;
						end
						2'b10: begin
							o_mem_wen <= i_mem_wen << 2;
							o_reg2_data <= i_reg2_data << 16;
						end
						2'b11: begin
							o_mem_wen <= i_mem_wen << 3;
							o_reg2_data <= i_reg2_data << 24;
						end
					endcase
			end
			else begin
					o_mem_wen <= i_mem_wen;
					o_reg2_data <= i_reg2_data;
			end
		end
endmodule

