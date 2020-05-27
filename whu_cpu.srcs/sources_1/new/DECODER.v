`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/27/2020 12:33:19 AM
// Design Name: 
// Module Name: DECODER
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


module DECODER(
    input [`INST_WIDTH] i_inst,  
    output reg o_reg1_read,
	output reg o_reg2_read,
	output wire [`REG_ADDR_WIDTH] o_reg1_addr,
	output wire [`REG_ADDR_WIDTH] o_reg2_addr,
	output reg [`REG_ADDR_WIDTH} o_reg3_addr,
	output reg [`ALUOP_WIDTH] o_aluop,
	output wire [25:0] o_imm26,
	output reg o_jump,
	output reg o_jump_src,
	output reg o_branch,
	output reg o_mem_write,
	output reg o_mem_read,
	output reg o_result_or_mem,
	output reg o_reg3_write
    );
	assign o_reg1_addr = i_inst[25:21];
	assign o_reg2_addr = i_inst[20:16];
	assign o_imm26 = i_inst[25:0];
	wire opcode = i_inst[31:26];	
	always
		@(*) begin
			case(opcode)
				
		end

endmodule
