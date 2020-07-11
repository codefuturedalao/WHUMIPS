`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2020 12:08:55 PM
// Design Name: 
// Module Name: WHUCPU
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


module WHUCPU(
	input wire i_clk,
	input wire i_rst,
	input wire [`REG_WIDTH] i_dmem_data,
	input wire [`REG_WIDTH] i_imem_data,
	output wire [`INST_ADDR_WIDTH] o_imem_addr,
	output wire [`REG_WIDTH] o_dmem_addr,
	output wire [`REG_WIDTH] o_dmem_data,
	output wire [3:0] o_dmem_wen,
	output wire o_dmem_en
    );
	wire [`STALL_WIDTH] stall;
	wire [`INST_ADDR_WIDTH] branch_pc;
	wire is_branch;
	wire flush;
	wire [`INST_ADDR_WIDTH] if_pc;
	PC my_pc(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_branch_pc(branch_pc), 
			.i_isbranch(is_branch), 

			.o_pc(if_pc)
	);
    assign o_imem_addr = if_pc;
	wire [`INST_ADDR_WIDTH] id_pc;
	wire [`INST_WIDTH] id_inst;
	IF_ID my_if_id(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_flush(flush), 
			.i_if_inst(i_imem_data), .i_if_pc(if_pc), 
			
			.o_id_inst(id_inst), .o_id_pc(id_pc)
	);

	wire id_reg1_read;
	wire id_reg2_read;
	wire [`REG_ADDR_WIDTH] id_reg1_addr;
	wire [`REG_ADDR_WIDTH] id_reg2_addr;
	wire [`REG_ADDR_WIDTH] id_rd_addr;
	wire [`REG_ADDR_WIDTH] id_reg3_addr;
	wire [`ALUOP_WIDTH] id_aluop;
	wire [25:0] id_imm26;
	wire id_jump;
	wire id_jump_src;
	wire id_branch;
	wire id_mem_en;
	wire [3:0] id_mem_wen;
	wire [2:0] id_mem_byte_se;
	wire id_result_or_mem;
	wire id_reg3_write;
	wire id_cp0_write;
	Decoder my_decoder(
			.i_inst(id_inst), 

			.o_reg1_read(id_reg1_read), .o_reg2_read(id_reg2_read), .o_reg1_addr(id_reg1_addr), .o_reg2_addr(id_reg2_addr), 
			.o_reg3_addr(id_reg3_addr), .o_aluop(id_aluop), .o_imm26(id_imm26), .o_jump(id_jump), 
			.o_jump_src(id_jump_src), .o_branch(id_branch), .o_mem_en(id_mem_en), .o_mem_wen(id_mem_wen), 
			.o_mem_byte_se(id_mem_byte_se), .o_result_or_mem(id_result_or_mem), .o_reg3_write(id_reg3_write),
			.o_cp0_write(id_cp0_write), .o_rd_addr(id_rd_addr)
	);

	wire wb_reg3_write;
	wire [`REG_ADDR_WIDTH] wb_reg3_addr;
	wire [`REG_WIDTH] wb_reg3_data;
	wire [`REG_WIDTH] id_reg1_data;
	wire [`REG_WIDTH] id_reg2_data;
	RG my_rg(
			.i_clk(i_clk), .i_rst(i_rst), .i_reg1_addr(id_reg1_addr), .i_reg2_addr(id_reg2_addr),
			.i_reg1_read(id_reg1_read), .i_reg2_read(id_reg2_read), .i_reg3_addr(wb_reg3_addr), 
			.i_reg3_data(wb_reg3_data), .i_reg3_write(wb_reg3_write), 

			.o_reg1_data(id_reg1_data), .o_reg2_data(id_reg2_data)
	);

	wire [1:0] forwardA;
	wire [1:0] forwardB;
	wire [`REG_WIDTH] ex_alu_result;
	wire [`REG_WIDTH] id_reg1_ndata;
	wire [`REG_WIDTH] id_reg2_ndata;
	wire [`REG_WIDTH] mem_reg3_data;
	MUX1 my_mux1(
			.i_forwardA(forwardA), .i_forwardB(forwardB), .i_ex_alu_result(ex_alu_result), .i_mem_reg3_data(mem_reg3_data),
			.i_reg1_data(id_reg1_data), .i_reg2_data(id_reg2_data),

			.o_reg1_data(id_reg1_ndata), .o_reg2_data(id_reg2_ndata)
	);

	BranchControl my_branch_control(
			.i_jump(id_jump), .i_jump_src(id_jump_src), .i_branch(id_branch), .i_pc(id_pc), .i_imm26(id_imm26),
			.i_reg1_ndata(id_reg1_ndata), .i_reg2_ndata(id_reg2_ndata), .i_aluop(id_aluop), 

			.o_jump_branch(is_branch), .o_jump_branch_pc(branch_pc)
	);	

	wire [`REG_ADDR_WIDTH] ex_reg3_addr;
	wire ex_reg3_write;
	wire ex_result_or_mem;
	wire [`REG_ADDR_WIDTH] mem_reg3_addr;
	wire mem_reg3_write;
	Ctrl my_ctrl(
			.i_id_reg1_addr(id_reg1_addr), .i_id_reg2_addr(id_reg2_addr), .i_id_reg1_read(id_reg1_read), .i_id_reg2_read(id_reg2_read),
			.i_ex_reg3_addr(ex_reg3_addr), .i_ex_reg3_write(ex_reg3_write), .i_ex_result_or_mem(ex_result_or_mem), 
			.i_mem_reg3_addr(mem_reg3_addr), .i_mem_reg3_write(mem_reg3_write), 

			.o_stall(stall), .o_flush(flush), .o_forwardA(forwardA), .o_forwardB(forwardB)
	);	
	

	wire [`REG_WIDTH] ex_reg1_data;
	wire [`REG_WIDTH] ex_reg2_data;
	wire [15:0] ex_imm16;
	wire [`ALUOP_WIDTH] ex_aluop;
	wire [3:0] ex_mem_wen;
	wire ex_mem_en;
	wire [2:0] ex_mem_byte_se;
	wire [`INST_ADDR_WIDTH] ex_pc;
	wire [`REG_ADDR_WIDTH] ex_rd_addr;
	wire ex_cp0_write;
	ID_EX my_id_ex(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_flush(flush),


			.i_id_reg1_data(id_reg1_ndata), .i_id_reg2_data(id_reg2_ndata),
			.i_id_reg3_addr(id_reg3_addr), .i_id_imm16(id_imm26[15:0]),.i_id_aluop(id_aluop),
			.i_id_result_or_mem(id_result_or_mem),
			.i_id_mem_wen(id_mem_wen), .i_id_mem_en(id_mem_en),
			.i_id_mem_byte_se(id_mem_byte_se), .i_id_reg3_write(id_reg3_write), .i_id_pc(id_pc),
			.i_id_rd_addr(id_rd_addr), .i_id_cp0_write(id_cp0_write),


			.o_ex_reg1_data(ex_reg1_data), .o_ex_reg2_data(ex_reg2_data),
			.o_ex_reg3_addr(ex_reg3_addr), .o_ex_imm16(ex_imm16), .o_ex_aluop(ex_aluop),
			.o_ex_mem_wen(ex_mem_wen),
			.o_ex_mem_en(ex_mem_en), .o_ex_mem_byte_se(ex_mem_byte_se), .o_ex_result_or_mem(ex_result_or_mem),
			.o_ex_reg3_write(ex_reg3_write), .o_ex_pc(ex_pc),
			.o_ex_rd_addr(ex_rd_addr), .o_ex_cp0_write(ex_cp0_write)
	);	

	wire [5:0] int = 5'b00000;
	wire [`REG_WIDTH] ex_cp0_data;
	wire [2:0] wb_cp0_sel;
	wire [`REG_WIDTH] wb_cp0_data;
	assign wb_cp0_data = wb_reg3_data;
	wire [`REG_ADDR_WIDTH] wb_rd_addr;
	assign wb_rd_addr = wb_reg3_addr;
	wire wb_cp0_write;
	CP0 my_cp0(
		.i_clk(i_clk), .i_rst(i_rst), .i_int(int), .i_ex_rd_addr(ex_rd_addr), .i_ex_cp0_sel(ex_imm16[2:0]), 
		.i_wb_cp0_sel(wb_cp0_sel), .i_wb_cp0_data(wb_cp0_data), .i_wb_rd_addr(wb_rd_addr), .i_wb_cp0_write(wb_cp0_write),

		.o_ex_cp0_data(ex_cp0_data), .o_timer_int()

	);

	wire [2:0] mem_cp0_sel;
	wire mem_cp0_write;
	wire [`REG_WIDTH] ex_cp0_ndata;
	wire [`REG_WIDTH] mem_alu_result;
	MUX3 my_mux3(
			.i_ex_cp0_sel(ex_imm16[2:0]), .i_mem_alu_result(mem_alu_result), .i_mem_reg3_addr(mem_reg3_addr), .i_mem_cp0_sel(mem_cp0_sel),
			.i_mem_cp0_write(mem_cp0_write), .i_wb_cp0_data(wb_cp0_data), .i_wb_reg3_addr(wb_reg3_addr), 
			.i_wb_cp0_sel(wb_cp0_sel), .i_wb_cp0_write(wb_cp0_write), .i_ex_rd_addr(ex_rd_addr), .i_ex_cp0_data(ex_cp0_data),

			.o_ex_cp0_ndata(ex_cp0_ndata)
	);

	
	wire exception_flag;
	ALU my_alu(
			.i_pc(ex_pc), .i_reg1_ndata(ex_reg1_data), .i_reg2_ndata(ex_reg2_data), .i_imm16(ex_imm16),
			.i_aluop(ex_aluop), .i_cp0_ndata(ex_cp0_ndata),

			.o_exception_flag(exception_flag), .o_alu_result(ex_alu_result)
	);

	wire [2:0] mem_mem_byte_se;
	wire mem_result_or_mem;
	assign o_dmem_addr = mem_alu_result;
	EX_ME my_ex_me(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_ex_alu_result(ex_alu_result), .i_ex_reg2_ndata(ex_reg2_data),
			.i_ex_reg3_addr(ex_reg3_addr), .i_ex_mem_wen(ex_mem_wen), .i_ex_mem_en(ex_mem_en), .i_ex_mem_byte_se(ex_mem_byte_se),
			.i_ex_result_or_mem(ex_result_or_mem), .i_ex_reg3_write(ex_reg3_write),
			.i_ex_cp0_write(ex_cp0_write) ,.i_ex_cp0_sel(ex_imm16[2:0]),

			.o_mem_alu_result(mem_alu_result), .o_mem_reg2_ndata(o_dmem_data), .o_mem_reg3_addr(mem_reg3_addr), .o_mem_mem_wen(o_dmem_wen),
			.o_mem_mem_en(o_dmem_en), .o_mem_mem_byte_se(mem_mem_byte_se), .o_mem_result_or_mem(mem_result_or_mem), .o_mem_reg3_write(mem_reg3_write),
			.o_mem_cp0_write(mem_cp0_write), .o_mem_cp0_sel(mem_cp0_sel)
	);

	MUX2 my_mux2(
			.i_result_or_mem(mem_result_or_mem), .i_alu_result(mem_alu_result), .i_mem_data(i_dmem_data), .i_mem_byte_se(mem_mem_byte_se), 

			.o_reg3_data(mem_reg3_data)
	);
	
	ME_WB my_me_wb(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_mem_reg3_data(mem_reg3_data), .i_mem_reg3_addr(mem_reg3_addr),
			.i_mem_reg3_write(mem_reg3_write), .i_mem_cp0_write(mem_cp0_write), .i_mem_cp0_sel(mem_cp0_sel),

			.o_wb_reg3_data(wb_reg3_data), .o_wb_reg3_addr(wb_reg3_addr), .o_wb_reg3_write(wb_reg3_write),
			.o_wb_cp0_write(wb_cp0_write), .o_wb_cp0_sel(wb_cp0_sel)
	);

endmodule
