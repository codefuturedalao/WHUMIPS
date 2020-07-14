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
	input wire [5:0] i_int, 
	input wire [`REG_WIDTH] i_dmem_data,
	input wire [`REG_WIDTH] i_imem_data,
	output wire [`INST_ADDR_WIDTH] o_imem_addr,
	output wire [`REG_WIDTH] o_imem_data,
	output wire [3:0] o_imem_wen,
	output wire o_imem_en,
	output wire [`REG_WIDTH] o_dmem_addr,
	output wire [`REG_WIDTH] o_dmem_data,
	output wire [3:0] o_dmem_wen,
	output wire o_dmem_en,
	output wire o_timer_int
    );
	wire [`STALL_WIDTH] stall;
	wire [`INST_ADDR_WIDTH] branch_pc;
	wire is_branch;
	wire flush;
	wire [`INST_ADDR_WIDTH] if_pc;
	wire imem_ce;
	wire [`INST_ADDR_WIDTH] exp_pc;
	wire stall_req_from_if;
	PC my_pc(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_branch_pc(branch_pc), 
			.i_isbranch(is_branch), .i_flush(flush), .i_new_pc(exp_pc),

			.o_pc(if_pc), .o_ce(imem_ce)
	);


	wire [`INST_WIDTH] if_inst; 
	wire if_sram_stall;
	wire mem_sram_stall; 
	Sram_Controller my_imem_controller(
		.i_clk(i_clk), .i_rst(i_rst), .i_en(imem_ce), .i_din(`ZERO_WORD),
		.i_addr(if_pc), .i_wen(4'b0000), .i_dout(i_imem_data), .i_stall(if_sram_stall), 
		
		.o_en(o_imem_en), .o_wen(o_imem_wen), .o_din(o_imem_data), .o_stall_req(stall_req_from_if),
		.o_data(if_inst), .o_addr(o_imem_addr)
	);

    assign o_imem_addr = if_pc;
	wire [`INST_ADDR_WIDTH] id_pc;
	wire [`INST_WIDTH] id_inst;
	IF_ID my_if_id(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_flush(flush), 
			.i_if_inst(if_inst), .i_if_pc(if_pc), 
			
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
	wire [31:0] id_exp_type;
	Decoder my_decoder(
			.i_inst(id_inst), 

			.o_reg1_read(id_reg1_read), .o_reg2_read(id_reg2_read), .o_reg1_addr(id_reg1_addr), .o_reg2_addr(id_reg2_addr), 
			.o_reg3_addr(id_reg3_addr), .o_aluop(id_aluop), .o_imm26(id_imm26), .o_jump(id_jump), 
			.o_jump_src(id_jump_src), .o_branch(id_branch), .o_mem_en(id_mem_en), .o_mem_wen(id_mem_wen), 
			.o_mem_byte_se(id_mem_byte_se), .o_result_or_mem(id_result_or_mem), .o_reg3_write(id_reg3_write),
			.o_cp0_write(id_cp0_write), .o_rd_addr(id_rd_addr), .o_exp_type(id_exp_type)
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

	wire ex_next_in_dslot;
	wire id_next_in_dslot;
	wire id_curr_in_dslot;
	BranchControl my_branch_control(
			.i_jump(id_jump), .i_jump_src(id_jump_src), .i_branch(id_branch), .i_pc(id_pc), .i_imm26(id_imm26),
			.i_reg1_ndata(id_reg1_ndata), .i_reg2_ndata(id_reg2_ndata), .i_aluop(id_aluop), .i_curr_in_dslot(ex_next_in_dslot),

			.o_jump_branch(is_branch), .o_jump_branch_pc(branch_pc), .o_curr_in_dslot(id_curr_in_dslot), .o_next_in_dslot(id_next_in_dslot)
	);	

	wire [`REG_ADDR_WIDTH] ex_reg3_addr;
	wire ex_reg3_write;
	wire ex_result_or_mem;
	wire [`REG_ADDR_WIDTH] mem_reg3_addr;
	wire mem_reg3_write;
	wire stall_req_from_mem;
	Ctrl my_ctrl(
			.i_id_reg1_addr(id_reg1_addr), .i_id_reg2_addr(id_reg2_addr), .i_id_reg1_read(id_reg1_read), .i_id_reg2_read(id_reg2_read),
			.i_ex_reg3_addr(ex_reg3_addr), .i_ex_reg3_write(ex_reg3_write), .i_ex_result_or_mem(ex_result_or_mem), 
			.i_mem_reg3_addr(mem_reg3_addr), .i_mem_reg3_write(mem_reg3_write), .i_stall_req_from_if(stall_req_from_if), .i_stall_req_from_mem(stall_req_from_mem),

			.o_stall(stall), .o_if_sram_stall(if_sram_stall), .o_mem_sram_stall(mem_sram_stall), .o_forwardA(forwardA), .o_forwardB(forwardB)
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
	wire [31:0] ex_exp_type;
	wire ex_curr_in_dslot;
	ID_EX my_id_ex(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_flush(flush),


			.i_id_reg1_data(id_reg1_ndata), .i_id_reg2_data(id_reg2_ndata),
			.i_id_reg3_addr(id_reg3_addr), .i_id_imm16(id_imm26[15:0]),.i_id_aluop(id_aluop),
			.i_id_result_or_mem(id_result_or_mem),
			.i_id_mem_wen(id_mem_wen), .i_id_mem_en(id_mem_en),
			.i_id_mem_byte_se(id_mem_byte_se), .i_id_reg3_write(id_reg3_write), .i_id_pc(id_pc),
			.i_id_rd_addr(id_rd_addr), .i_id_cp0_write(id_cp0_write), .i_id_exp_type(id_exp_type), 
			.i_id_next_in_dslot(id_next_in_dslot), .i_id_curr_in_dslot(id_curr_in_dslot),


			.o_ex_reg1_data(ex_reg1_data), .o_ex_reg2_data(ex_reg2_data),
			.o_ex_reg3_addr(ex_reg3_addr), .o_ex_imm16(ex_imm16), .o_ex_aluop(ex_aluop),
			.o_ex_mem_wen(ex_mem_wen),
			.o_ex_mem_en(ex_mem_en), .o_ex_mem_byte_se(ex_mem_byte_se), .o_ex_result_or_mem(ex_result_or_mem),
			.o_ex_reg3_write(ex_reg3_write), .o_ex_pc(ex_pc),
			.o_ex_rd_addr(ex_rd_addr), .o_ex_cp0_write(ex_cp0_write), .o_ex_exp_type(ex_exp_type),
			.o_ex_next_in_dslot(ex_next_in_dslot), .o_ex_curr_in_dslot(ex_curr_in_dslot)
	);	

	wire [`REG_WIDTH] ex_cp0_data;
	wire [2:0] wb_cp0_sel;
	wire [`REG_WIDTH] wb_cp0_data;
	assign wb_cp0_data = wb_reg3_data;
	wire [`REG_ADDR_WIDTH] wb_rd_addr;
	assign wb_rd_addr = wb_reg3_addr;
	wire wb_cp0_write;
	wire [`INST_ADDR_WIDTH] mem_pc;
	wire mem_curr_in_dslot;
	wire [31:0] mem_exp_ntype;
	wire [`REG_WIDTH] mem_cp0_status;
	wire [`REG_WIDTH] mem_cp0_cause;
	wire [`REG_WIDTH] mem_cp0_epc;
	CP0 my_cp0(
		.i_clk(i_clk), .i_rst(i_rst), .i_int(i_int), .i_ex_rd_addr(ex_rd_addr), .i_ex_cp0_sel(ex_imm16[2:0]), 
		.i_wb_cp0_sel(wb_cp0_sel), .i_wb_cp0_data(wb_cp0_data), .i_wb_rd_addr(wb_rd_addr), .i_wb_cp0_write(wb_cp0_write),
		.i_exp_type(mem_exp_ntype), .i_curr_in_dslot(mem_curr_in_dslot), .i_pc(mem_pc),

		.o_ex_cp0_data(ex_cp0_data), .o_timer_int(o_timer_int),
		.o_status(mem_cp0_status), .o_cause(mem_cp0_cause), .o_epc(mem_cp0_epc)

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
	wire [31:0] ex_exp_ntype;
	ALU my_alu(
			.i_pc(ex_pc), .i_reg1_ndata(ex_reg1_data), .i_reg2_ndata(ex_reg2_data), .i_imm16(ex_imm16),
			.i_aluop(ex_aluop), .i_cp0_ndata(ex_cp0_ndata), .i_exp_type(ex_exp_type), 

			.o_alu_result(ex_alu_result), .o_exp_type(ex_exp_ntype)
	);

	wire [2:0] mem_mem_byte_se;
	wire mem_result_or_mem;
	wire [31:0] mem_exp_type;
	wire [3:0] mem_mem_wen;
	wire mem_mem_en;
	wire [`REG_WIDTH] mem_mem_data;
	EX_ME my_ex_me(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_ex_alu_result(ex_alu_result), .i_ex_reg2_ndata(ex_reg2_data),
			.i_ex_reg3_addr(ex_reg3_addr), .i_ex_mem_wen(ex_mem_wen), .i_ex_mem_en(ex_mem_en), .i_ex_mem_byte_se(ex_mem_byte_se),
			.i_ex_result_or_mem(ex_result_or_mem), .i_ex_reg3_write(ex_reg3_write),
			.i_ex_cp0_write(ex_cp0_write) ,.i_ex_cp0_sel(ex_imm16[2:0]),
			.i_ex_pc(ex_pc), .i_ex_exp_type(ex_exp_ntype), .i_ex_curr_in_dslot(ex_curr_in_dslot),
			.i_flush(flush),

			.o_mem_alu_result(mem_alu_result), .o_mem_reg2_ndata(mem_mem_data), .o_mem_reg3_addr(mem_reg3_addr), .o_mem_mem_wen(mem_mem_wen),
			.o_mem_mem_en(mem_mem_en), .o_mem_mem_byte_se(mem_mem_byte_se), .o_mem_result_or_mem(mem_result_or_mem), .o_mem_reg3_write(mem_reg3_write),
			.o_mem_cp0_write(mem_cp0_write), .o_mem_cp0_sel(mem_cp0_sel),
			.o_mem_pc(mem_pc), .o_mem_exp_type(mem_exp_type), .o_mem_curr_in_dslot(mem_curr_in_dslot)
	);

	wire exp_mem_en;
	wire [`REG_WIDTH] dmem_data;
	Sram_Controller my_dmem_controller(
		.i_clk(i_clk), .i_rst(i_rst), .i_en(exp_mem_en), .i_din(mem_mem_data), .i_addr(mem_alu_result),
		.i_wen(mem_mem_wen), .i_dout(i_dmem_data),
		.i_stall(mem_sram_stall),
		.o_en(o_dmem_en), .o_wen(o_dmem_wen), .o_din(o_dmem_data), .o_stall_req(stall_req_from_mem),
		.o_data(dmem_data), .o_addr(o_dmem_addr)
		
	);


	Exp_Handler my_exp_handler(
			.i_exp_type(mem_exp_type), .i_pc(mem_pc), .i_cp0_status(mem_cp0_status), .i_cp0_cause(mem_cp0_cause), .i_cp0_epc(mem_cp0_epc),
			.i_wb_cp0_sel(wb_cp0_sel), .i_wb_cp0_data(wb_cp0_data), .i_wb_rd_addr(wb_reg3_addr), .i_wb_cp0_write(wb_cp0_write), .i_mem_en(mem_mem_en),

			.o_mem_en(exp_mem_en), .o_exp_type(mem_exp_ntype), .o_exp_pc(exp_pc), .o_flush(flush)
	);


	MUX2 my_mux2(
			.i_result_or_mem(mem_result_or_mem), .i_alu_result(mem_alu_result), .i_mem_data(dmem_data), .i_mem_byte_se(mem_mem_byte_se), 

			.o_reg3_data(mem_reg3_data)
	);
	
	ME_WB my_me_wb(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_mem_reg3_data(mem_reg3_data), .i_mem_reg3_addr(mem_reg3_addr),
			.i_mem_reg3_write(mem_reg3_write), .i_mem_cp0_write(mem_cp0_write), .i_mem_cp0_sel(mem_cp0_sel), 
			.i_flush(flush),

			.o_wb_reg3_data(wb_reg3_data), .o_wb_reg3_addr(wb_reg3_addr), .o_wb_reg3_write(wb_reg3_write),
			.o_wb_cp0_write(wb_cp0_write), .o_wb_cp0_sel(wb_cp0_sel)
	);

endmodule
