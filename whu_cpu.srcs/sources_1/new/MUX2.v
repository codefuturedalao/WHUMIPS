`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 08:47:00 PM
// Design Name: 
// Module Name: MUX2
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


module MUX2(
	input wire i_result_or_mem,
	input wire [`REG_WIDTH] i_alu_result,
	input wire [`REG_WIDTH] i_mem_data,
	input wire [2:0] i_mem_byte_se,
	output reg [`REG_WIDTH] o_reg3_data
    );
	always
		@(i_result_or_mem, i_alu_result, i_mem_data) begin
				if(i_result_or_mem == `REG3_FROM_RESULT) begin
					o_reg3_data <= i_alu_result;
				end
				else begin
					case(i_mem_byte_se)
							`MEM_SE_BYTE: begin
									o_reg3_data <= {{24{i_mem_data[7]}},i_mem_data[7:0]};
							end
							`MEM_SE_BYTE_U: begin
									o_reg3_data <= {{24'b0},i_mem_data[7:0]};
							end
							`MEM_SE_HALF: begin
									o_reg3_data <= {{16{i_mem_data[15]}},i_mem_data[15:0]};
							end
							`MEM_SE_HALF_U: begin
									o_reg3_data <= {{16{i_mem_data[15]}},i_mem_data[15:0]};
							end
							`MEM_SE_WORD: begin
									o_reg3_data <= i_mem_data;
							end
					endcase
				end
		end
endmodule
