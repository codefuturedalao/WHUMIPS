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
	wire [5:0] opcode = i_inst[31:26];	
	wire [5:0] imm5_0 = i_inst[5:0];
	always
		@(*) begin
			case(opcode)
				o_reg1_read <= `REG_READ;
				o_reg2_read <= `REG_READ;
				o_reg3_addr <= i_inst[15:11];
				o_aluop <= 6'b000_000;
				o_jump <= `NO_JUMP;
				o_jump_src <= `JUMP_FROM_REG;
				o_branch <= `NO_BRANCH;
				o_mem_write <= `MEM_NO_WRITE;
				o_mem_read <= `MEM_NO_READ;
				o_result_or_mem <= `REG3_FROM_RESULT;
				o_reg3_write <= `REG3_WRITE;
				`SPECIAL_OPCODE: begin
					case(imm5_0)
						`ADD_OPCODE: begin
							o_aluop <= ADD_ALU_OPCODE;
						end
						`ADDU_OPCODE: begin
							o_aluop <= ADDU_ALU_OPCODE;
						end	
						`SUB_OPCODE: begin
							o_aluop <= SUB_ALU_OPCODE;	
						end
						`SUBU_OPCODE: begin	
							o_aluop <= SUBU_ALU_OPCODE;
						end
					endcase
				end
			endcase 
		end

endmodule
