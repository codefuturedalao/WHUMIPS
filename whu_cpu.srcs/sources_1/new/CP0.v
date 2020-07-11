`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2020 05:17:07 PM
// Design Name: 
// Module Name: CP0
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


module CP0(
	input wire i_clk,
	input wire i_rst,
	input wire [5:0] i_int,
	input wire [`REG_ADDR_WIDTH] i_ex_rd_addr,
   	input wire [2:0] i_ex_cp0_sel,
	input wire [2:0] i_wb_cp0_sel,
	input wire [`REG_WIDTH] i_wb_cp0_data,
	input wire [`REG_ADDR_WIDTH] i_wb_rd_addr,
	input wire i_wb_cp0_write,

	output reg [`REG_WIDTH] o_ex_cp0_data,
	output reg o_timer_int
    );

	
	reg [`REG_WIDTH] count;
	reg [`REG_WIDTH] compare;
	reg [`REG_WIDTH] status;
	reg [`REG_WIDTH] cause;
	reg [`REG_WIDTH] epc;
	reg [`REG_WIDTH] prid;
	reg [`REG_WIDTH] conf;


	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
				count <= `ZERO_WORD;
				compare <= `ZERO_WORD;
				status <= 32'b0001_0000_0000_0000_0000_0000_0000_0000;
				cause <= `ZERO_WORD;
				epc <= `ZERO_WORD;
				conf <= 32'b0000_0000_0000_0000_10000_0000_0000_0000; //little endian
				prid <= 32'b0000_0000_0100_1100_0000_0001_0000_0010;
				o_timer_int <= `INT_NO_ASSERTION;
			end
			else begin
				count <= count + 1;
				cause[15:0] <= i_int;
				if ( compare != `ZERO_WORD && count == compare) begin
						o_timer_int <= `INT_ASSERTION;
				end

				if(i_wb_cp0_write == `CP0_WRITE) begin
						case(i_wb_rd_addr) 
							`CP0_REG_COUNT: begin
								count <= i_wb_cp0_data;
							end
							`CP0_REG_COMPARE: begin
								compare <= i_wb_cp0_data;
								o_timer_int <= `INT_NO_ASSERTION;
							end
							`CP0_REG_STATUS: begin
								status <= i_wb_cp0_data;	
							end
							`CP0_REG_EPC: begin
								epc <= i_wb_cp0_data;
							end
							`CP0_REG_CAUSE: begin
								cause[9:8] <= i_wb_cp0_data[9:8];
								cause[23] <= i_wb_cp0_data[23];
								cause[22] <= i_wb_cp0_data[22];
							end
						endcase
				end
			end

		end

		always
			@(*) begin
					if(i_rst == `RST_ENABLE) begin
							o_ex_cp0_data <= `ZERO_WORD;
					end
					else begin
							case(i_ex_rd_addr)
								`CP0_REG_COUNT: begin
									o_ex_cp0_data <= count;
								end
								`CP0_REG_COMPARE: begin
									o_ex_cp0_data <= compare;
								end
								`CP0_REG_STATUS: begin
									o_ex_cp0_data <= status;
								end
								`CP0_REG_CAUSE: begin
									o_ex_cp0_data <= cause;
								end
								`CP0_REG_EPC: begin
									o_ex_cp0_data <= epc;
								end
								`CP0_REG_PRID: begin
									o_ex_cp0_data <= prid;
								end
								`CP0_REG_CONFIG: begin
									o_ex_cp0_data <= conf;
								end
								default: begin
									o_ex_cp0_data <= `ZERO_WORD;
								end
							endcase
					end
			end
endmodule
