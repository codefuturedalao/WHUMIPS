`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2020 06:49:03 PM
// Design Name: 
// Module Name: Exp_Handler
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


module Exp_Handler(
		input wire [31:0] i_exp_type,
		input wire [`INST_ADDR_WIDTH] i_pc,
		input wire [`REG_WIDTH] i_cp0_status,
		input wire [`REG_WIDTH] i_cp0_cause,
		input wire [`REG_WIDTH] i_cp0_epc,
		input wire [2:0] i_wb_cp0_sel,
		input wire [`REG_WIDTH] i_wb_cp0_data,
		input wire [`REG_ADDR_WIDTH] i_wb_rd_addr,
		input wire i_wb_cp0_write,
		input wire [3:0] i_mem_wen,

		output reg [3:0] o_mem_wen,
		output reg [31:0] o_exp_type,
		output reg [`INST_ADDR_WIDTH] o_exp_pc,
		output reg o_flush
    );

	reg [`REG_WIDTH] cp0_status;
	reg [`REG_WIDTH] cp0_cause;
	reg [`REG_WIDTH] cp0_epc;

	/* get the newset cp0 data */
	always
		@(*) begin
				if(i_wb_cp0_write == `CP0_WRITE && i_wb_rd_addr == `CP0_REG_STATUS && i_wb_cp0_sel == 3'b000) begin
						cp0_status <= i_wb_cp0_data;
				end
				else begin
						cp0_status <= i_cp0_status;
				end
				if(i_wb_cp0_write == `CP0_WRITE && i_wb_rd_addr == `CP0_REG_CAUSE && i_wb_cp0_sel == 3'b000) begin
						cp0_cause[9:8] <= i_wb_cp0_data[9:8];
						cp0_cause[22] <= i_wb_cp0_data[22];
						cp0_cause[23] <= i_wb_cp0_data[23];
				end
				else begin
						cp0_cause <= i_cp0_cause;
				end
				if(i_wb_cp0_write == `CP0_WRITE && i_wb_rd_addr == `CP0_REG_EPC && i_wb_cp0_sel == 3'b000) begin
						cp0_epc <= i_wb_cp0_data;
				end
				else begin
						cp0_epc <= i_cp0_epc;
				end
		end


		always
			@(*) begin
					o_exp_type <= `NO_EXP_TYPE;
					o_exp_pc <= `EXP_DEFAULT_PC;
					if(i_pc != `ZERO_WORD) begin
						if(((cp0_cause[`CAUSE_IP] & cp0_status[`STATUS_IM])) != 8'h00 && cp0_status[`STATUS_IE] == 1'b1 && cp0_status[`STATUS_EXL] == 1'b0) begin
								o_exp_type <= `INT_EXP_TYPE; 
								o_exp_pc <= 32'h0000_0020;  //for test
						end
						else if(i_exp_type[8] == 1'b1) begin //inst_valid
								o_exp_type <= `INST_VALID_EXP_TYPE; 
								o_exp_pc <= 32'h0000_0040;  //for test
						end
						else if(i_exp_type[11] == 1'b1) begin //syscall
								o_exp_type <=  `SYS_EXP_TYPE;
								o_exp_pc <= 32'h0000_0040;  //for test
						end
						else if(i_exp_type[10] == 1'b1) begin //eret
								o_exp_type <= `ERET_EXP_TYPE;
								o_exp_pc <= cp0_epc;  
						end
						else if(i_exp_type[9] == 1'b1) begin //break
								o_exp_type <= `BREAK_EXP_TYPE;
								o_exp_pc <= 32'h0000_0040;  //for test
						end
						else if(i_exp_type[13] == 1'b1) begin //overflow
								o_exp_type <=  `OV_EXP_TYPE;
								o_exp_pc <= 32'h0000_0040;  //for test
						end
						else if(i_exp_type[12] == 1'b1) begin //no_align
								o_exp_type <=  `ALIGN_EXP_TYPE;
								o_exp_pc <= 32'h0000_0040;  //for test
						end
					end
			end

		always
			@(*) begin
				if(~(|o_exp_type) == 1'b0) begin //exception occur
						o_mem_wen <= 4'b0000;
						o_flush <= `IS_FLUSH;
				end
				else begin
						o_mem_wen <= i_mem_wen;
						o_flush <= `NO_FLUSH;
				end
			end

endmodule