`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/14 22:12:04
// Design Name: 
// Module Name: my_hilo
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


module my_hilo(
	input wire i_clk,
	input wire i_rst,
	input wire i_hi_read,
	input wire i_lo_read,
    
	input wire i_hi_write,
	input wire i_lo_write,
	input wire [`REG_WIDTH] i_hi_data,
	input wire [`REG_WIDTH] i_lo_data,
	output reg [`REG_WIDTH] o_hi_data,
	output reg [`REG_WIDTH] o_lo_data
    );
    reg [`REG_WIDTH] hi;
    reg [`REG_WIDTH] lo;
    	/* write data */
	always
		@(posedge i_clk) begin
			/* don't use i_rst to control write data */
			if(i_hi_write == `HI_WRITE) begin
				hi <= i_hi_data;
			end
			if(i_lo_write == `LO_WRITE) begin
				lo <= i_lo_data;
			end
		end
		
	/* read data */
	always
		@(*) begin
			if(i_rst == `RST_ENABLE) begin
			    hi <= `ZERO_WORD;
				lo <= `ZERO_WORD;
				o_hi_data <= `ZERO_WORD;
				o_lo_data <= `ZERO_WORD;
			end	
			else begin
				/* hi */
				if(i_hi_read == `HI_READ) begin
					o_hi_data <= hi; 		
				end
				else begin
					o_hi_data <= `ZERO_WORD;
				end
				
				/* lo */
				if(i_lo_read == `LO_READ) begin
					o_lo_data <= lo; 					
				end
				else begin
					o_lo_data <= `ZERO_WORD;
				end
			end
		end
endmodule