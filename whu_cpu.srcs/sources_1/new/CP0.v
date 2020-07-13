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
//  	the int_i connect here may cost long time to handle the interrupt, may
//  	be we can connect i_int to the Exp_Handler.v
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
	input wire [31:0] i_exp_type,
	input wire i_curr_in_dslot,
	input wire [`INST_ADDR_WIDTH] i_pc,

	output reg [`REG_WIDTH] o_ex_cp0_data,
	output reg o_timer_int,
	output reg [`REG_WIDTH] o_status,
	output reg [`REG_WIDTH] o_cause,
	output reg [`REG_WIDTH] o_epc
    );

	
	reg [`REG_WIDTH] count;
	reg [`REG_WIDTH] compare;
//	reg [`REG_WIDTH] status;
//	reg [`REG_WIDTH] cause;
//	reg [`REG_WIDTH] epc;
	reg [`REG_WIDTH] prid;
	reg [`REG_WIDTH] conf;


	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
				count <= `ZERO_WORD;
				compare <= `ZERO_WORD;
				o_status <= 32'b0001_0000_0000_0000_0000_0000_0000_0000;
				o_cause <= `ZERO_WORD;
				o_epc <= `ZERO_WORD;
				conf <= 32'b0000_0000_0000_0000_10000_0000_0000_0000; //little endian
				prid <= 32'b0000_0000_0100_1100_0000_0001_0000_0010;
				o_timer_int <= `INT_NO_ASSERTION;
			end
			else begin
				count <= count + 1;
				o_cause[15:10] <= i_int;
				if (compare != `ZERO_WORD && count == compare) begin
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
								o_status <= i_wb_cp0_data;	
							end
							`CP0_REG_EPC: begin
								o_epc <= i_wb_cp0_data;
							end
							`CP0_REG_CAUSE: begin
								o_cause[9:8] <= i_wb_cp0_data[9:8];
								o_cause[23] <= i_wb_cp0_data[23];
								o_cause[22] <= i_wb_cp0_data[22];
							end
						endcase
				end
				/*when exception occur*/
				case(i_exp_type)
						`INT_EXP_TYPE: begin  //have detect EXL in EXP_Handler
							if(i_curr_in_dslot == `IN_DSLOT) begin
									o_epc <= i_pc - 4;
									o_cause[`CAUSE_BD] <= 1'b1;
							end
							else begin
									o_epc <= i_pc;
									o_cause[`CAUSE_BD] <= 1'b0;
							end
							o_status[`STATUS_EXL] <= 1'b1;
							o_cause[`CAUSE_EXCCODE] <= `INT_EXC;
						end
						`INST_VALID_EXP_TYPE: begin
								if(o_status[`STATUS_EXL] == 1'b0) begin
										if(i_curr_in_dslot == `IN_DSLOT) begin
												o_epc <= i_pc - 4;
												o_cause[`CAUSE_BD] <= 1'b1;
										end
										else begin
												o_epc <= i_pc;
												o_cause[`CAUSE_BD] <= 1'b0;
										end
								end
								o_status[`STATUS_EXL] <= 1'b1;
								o_cause[`CAUSE_EXCCODE] <= `RI_EXC;
						end
						`SYS_EXP_TYPE: begin
								if(o_status[`STATUS_EXL] == 1'b0) begin
										if(i_curr_in_dslot == `IN_DSLOT) begin
												o_epc <= i_pc - 4;
												o_cause[`CAUSE_BD] <= 1'b1;
										end
										else begin
												o_epc <= i_pc;
												o_cause[`CAUSE_BD] <= 1'b0;
										end
								end
								o_status[`STATUS_EXL] <= 1'b1;
								o_cause[`CAUSE_EXCCODE] <= `SYS_EXC;
						end
						`ERET_EXP_TYPE: begin
							o_status[`STATUS_EXL] <= 1'b0;
						end
						`BREAK_EXP_TYPE: begin
								if(o_status[`STATUS_EXL] == 1'b0) begin
										if(i_curr_in_dslot == `IN_DSLOT) begin
												o_epc <= i_pc - 4;
												o_cause[`CAUSE_BD] <= 1'b1;
										end
										else begin
												o_epc <= i_pc;
												o_cause[`CAUSE_BD] <= 1'b0;
										end
								end
								o_status[`STATUS_EXL] <= 1'b1;
								o_cause[`CAUSE_EXCCODE] <= `BP_EXC;
						end
						`OV_EXP_TYPE: begin
								if(o_status[`STATUS_EXL] == 1'b0) begin
										if(i_curr_in_dslot == `IN_DSLOT) begin
												o_epc <= i_pc - 4;
												o_cause[`CAUSE_BD] <= 1'b1;
										end
										else begin
												o_epc <= i_pc;
												o_cause[`CAUSE_BD] <= 1'b0;
										end
								end
								o_status[`STATUS_EXL] <= 1'b1;
								o_cause[`CAUSE_EXCCODE] <= `OV_EXC;
						end
						`ALIGN_EXP_TYPE: begin
								if(o_status[`STATUS_EXL] == 1'b0) begin
										if(i_curr_in_dslot == `IN_DSLOT) begin
												o_epc <= i_pc - 4;
												o_cause[`CAUSE_BD] <= 1'b1;
										end
										else begin
												o_epc <= i_pc;
												o_cause[`CAUSE_BD] <= 1'b0;
										end
								end
								o_status[`STATUS_EXL] <= 1'b1;
								o_cause[`CAUSE_EXCCODE] <= `ADES_EXC;
						end
				endcase
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
									o_ex_cp0_data <= o_status;
								end
								`CP0_REG_CAUSE: begin
									o_ex_cp0_data <= o_cause;
								end
								`CP0_REG_EPC: begin
									o_ex_cp0_data <= o_epc;
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
