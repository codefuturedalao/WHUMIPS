`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2020 09:17:37 PM
// Design Name: 
// Module Name: MUX4
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


module MUX4(
		input wire [`REG_WIDTH] i_mem_hi,
		input wire [`REG_WIDTH] i_mem_lo,
		input wire i_mem_hilo_wen,
		input wire [`REG_WIDTH] i_wb_hi,
		input wire [`REG_WIDTH] i_wb_lo,
		input wire i_wb_hilo_wen,
		input wire [`REG_WIDTH] i_ex_hi,
		input wire [`REG_WIDTH] i_ex_lo,

		output reg [`REG_WIDTH] o_ex_nhi,
		output reg [`REG_WIDTH] o_ex_nlo
    );

	always
		@(*) begin
			o_ex_nhi <= i_ex_hi;
			o_ex_nlo <= i_ex_lo;
			if(i_mem_hilo_wen == `HILO_WRITE) begin
				o_ex_nhi <= i_mem_hi;
				o_ex_nlo <= i_mem_lo;
			end
			if(i_wb_hilo_wen == `HILO_WRITE) begin
				o_ex_nhi <= i_wb_hi;
				o_ex_nlo <= i_wb_lo;
			end
		end



endmodule
