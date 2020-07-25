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
(*mark_debug = "true"*)	input wire aclk,
(*mark_debug = "true"*)	input wire aresetn,
	input wire [5:0] ext_int, 
	output wire [3:0] arid, 	//0 : fetch inst  1 : fetch data
	output wire [31:0] araddr,
	output wire [3:0] arlen,
	output wire [2:0] arsize,
	output wire [1:0] arburst,
	output wire [1:0] arlock,
	output wire [3:0] arcache,
	output wire [2:0] arprot,
	output wire arvalid,
	input wire arready,

	input wire [3:0] rid,
	input wire [31:0] rdata,
    input wire [1:0] rresp,
	input wire rlast,
	input wire rvalid,
	output wire rready,

	output wire [3:0] awid,
	output wire [31:0] awaddr,
	output wire [3:0] awlen,
	output wire [2:0] awsize,
	output wire [1:0] awburst,
	output wire [1:0] awlock,
	output wire [3:0] awcache,
	output wire [2:0] awprot,
	output wire awvalid,
	input wire awready,

	output wire [3:0] wid,
	output wire [31:0] wdata,
	output wire [3:0] wstrb,
	output wire wlast,
	output wire wvalid,
	input wire wready,

	input wire [3:0] bid,
	input wire [1:0] bresp,
	input wire bvalid,
	output wire bready,

	output wire o_timer_int,
//for debug
(*mark_debug = "true"*)	output wire [`INST_ADDR_WIDTH] debug_wb_pc,
(*mark_debug = "true"*)	output wire [3:0] debug_wb_rf_wen,
(*mark_debug = "true"*)	output wire [`REG_ADDR_WIDTH] debug_wb_rf_wnum,
(*mark_debug = "true"*) output wire [`REG_WIDTH] debug_wb_rf_wdata

    );
	wire i_rst; 
	assign i_rst = aresetn;
	wire i_clk;
	assign i_clk = aclk;
	wire [`STALL_WIDTH] stall;
	wire [`INST_ADDR_WIDTH] branch_pc;
	wire is_branch;
	wire flush;
	(*mark_debug = "true"*) wire [`INST_ADDR_WIDTH] if_pc;
	wire imem_ce;
	wire [`INST_ADDR_WIDTH] exp_pc;
	wire stall_req_from_if;
	wire [31:0] if_exp_type;
	wire [`INST_ADDR_WIDTH] if_bad_pc;
	wire id_next_in_dslot;
	wire if_curr_in_dslot;
	PC my_pc(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_branch_pc(branch_pc), 
			.i_isbranch(is_branch), .i_flush(flush), .i_new_pc(exp_pc),
			.i_curr_in_dslot(id_next_in_dslot),

			.o_pc(if_pc), .o_ce(imem_ce), .o_exp_type(if_exp_type), .o_bad_pc(if_bad_pc),
			.o_curr_in_dslot(if_curr_in_dslot)
	);


	(*mark_debug = "true"*) wire [`REG_WIDTH] if_inst;
	wire exp_mem_en;
	wire [`REG_WIDTH] mem_alu_result;
	wire [3:0] mem_mem_wen;
	wire [`REG_WIDTH] mem_mem_data;
	wire [`REG_WIDTH] dmem_data;
	wire stall_req_from_mem;
	wire if_read_result_flag;
	wire if_axi_stall;
	wire [`WEN_ADDR] mem_n_wen;
	wire [`REG_WIDTH] mem_n_mem_data;
	Axi_Controller my_axi_controller(
		.i_aclk(i_clk), .i_aresetn(i_rst), .i_flush(flush), .i_if_addr(if_pc), .i_if_en(1'b1), .i_if_data(`ZERO_WORD), .i_if_axi_stall(if_axi_stall), .i_ce(imem_ce),
		.o_if_data(if_inst), .i_mem_addr(mem_alu_result), .i_mem_en(exp_mem_en), .i_mem_wen(mem_n_wen), 
		.i_mem_data(mem_n_mem_data), .o_mem_data(dmem_data), 
		.o_arid(arid), .o_araddr(araddr), .o_arlen(arlen), .o_arsize(arsize), .o_arburst(arburst), .o_arlock(arlock), 
		.o_arcache(arcache), .o_arprot(arprot), .o_arvalid(arvalid), .i_arready(arready),
		.i_rid(rid), .i_rdata(rdata), .i_rresp(rresp), .i_rlast(rlast), .i_rvalid(rvalid), .o_rready(rready),
		.o_awid(awid), .o_awaddr(awaddr), .o_awlen(awlen), .o_awsize(awsize), .o_awburst(awburst), .o_awlock(awlock) ,.o_awcache(awcache), .o_awprot(awprot), .o_awvalid(awvalid), .i_awready(awready),
		.o_wid(wid), .o_wdata(wdata), .o_wstrb(wstrb), .o_wlast(wlast), .o_wvalid(wvalid), .i_wready(wready),
		.i_bid(bid), .i_bresp(bresp), .i_bvalid(bvalid), .o_bready(bready),
		.o_stall_req_from_if(stall_req_from_if), .o_stall_req_from_mem(stall_req_from_mem), .o_if_read_result_flag(if_read_result_flag), .o_me_read_result_flag()
	);

	(*mark_debug = "true"*) wire [`INST_ADDR_WIDTH] id_pc;
	(*mark_debug = "true"*) wire [`INST_WIDTH] id_inst;
	wire [31:0] id_exp_type;
	wire [`INST_ADDR_WIDTH] id_bad_pc;
	wire id_curr_in_dslot;
	IF_ID my_if_id(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_flush(flush), 
			.i_if_inst(if_inst), .i_if_pc(if_pc), .i_if_exp_type(if_exp_type), .i_if_bad_pc(if_bad_pc), 
			.i_if_curr_in_dslot(if_curr_in_dslot),
			
			.o_id_inst(id_inst), .o_id_pc(id_pc), .o_id_exp_type(id_exp_type), .o_id_bad_pc(id_bad_pc),
			.o_id_curr_in_dslot(id_curr_in_dslot)
	);

	wire id_reg1_read;
	wire id_reg2_read;
	wire [`REG_ADDR_WIDTH] id_reg1_addr;
	wire [`REG_ADDR_WIDTH] id_reg2_addr;
	wire [`REG_ADDR_WIDTH] id_rd_addr;
	wire [`REG_ADDR_WIDTH] id_reg3_addr;
(*mark_debug = "true"*)	wire [`ALUOP_WIDTH] id_aluop;
	wire [25:0] id_imm26;
	wire id_jump;
	wire id_jump_src;
	wire id_branch;
	wire id_mem_en;
	wire [3:0] id_mem_wen;
	wire [2:0] id_mem_byte_se;
	wire id_result_or_mem;
(*mark_debug = "true"*)	wire id_reg3_write;
	wire id_cp0_write;
	wire [31:0] id_n_exp_type;
	wire id_hilo_wen;
	Decoder my_decoder(
			.i_inst(id_inst), .i_exp_type(id_exp_type),

			.o_reg1_read(id_reg1_read), .o_reg2_read(id_reg2_read), .o_reg1_addr(id_reg1_addr), .o_reg2_addr(id_reg2_addr), 
			.o_reg3_addr(id_reg3_addr), .o_aluop(id_aluop), .o_imm26(id_imm26), .o_jump(id_jump), 
			.o_jump_src(id_jump_src), .o_branch(id_branch), .o_mem_en(id_mem_en), .o_mem_wen(id_mem_wen), 
			.o_mem_byte_se(id_mem_byte_se), .o_result_or_mem(id_result_or_mem), .o_reg3_write(id_reg3_write),
			.o_cp0_write(id_cp0_write), .o_rd_addr(id_rd_addr), .o_exp_type(id_n_exp_type), .o_hilo_write(id_hilo_wen)
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
	BranchControl my_branch_control(
			.i_jump(id_jump), .i_jump_src(id_jump_src), .i_branch(id_branch), .i_pc(id_pc), .i_imm26(id_imm26),
			.i_reg1_ndata(id_reg1_ndata), .i_reg2_ndata(id_reg2_ndata), .i_aluop(id_aluop), 

			.o_jump_branch(is_branch), .o_jump_branch_pc(branch_pc), .o_next_in_dslot(id_next_in_dslot)
	);	

	wire [`REG_ADDR_WIDTH] ex_reg3_addr;
	wire ex_reg3_write;
	wire ex_result_or_mem;
	wire [`REG_ADDR_WIDTH] mem_reg3_addr;
	wire mem_reg3_write;
	wire stall_req_from_ex;
	Ctrl my_ctrl(
			.i_id_reg1_addr(id_reg1_addr), .i_id_reg2_addr(id_reg2_addr), .i_id_reg1_read(id_reg1_read), .i_id_reg2_read(id_reg2_read),
			.i_ex_reg3_addr(ex_reg3_addr), .i_ex_reg3_write(ex_reg3_write), .i_ex_result_or_mem(ex_result_or_mem), 
			.i_mem_reg3_addr(mem_reg3_addr), .i_mem_reg3_write(mem_reg3_write), .i_stall_req_from_if(stall_req_from_if), .i_stall_req_from_ex(stall_req_from_ex), .i_stall_req_from_mem(stall_req_from_mem),
			.i_jump(id_jump), .i_branch(id_branch), .i_if_read_result_flag(if_read_result_flag),

			.o_stall(stall), .o_forwardA(forwardA), .o_forwardB(forwardB), .o_if_axi_stall(if_axi_stall)
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
	wire ex_hilo_wen;
	wire [`INST_ADDR_WIDTH] ex_bad_pc;
	ID_EX my_id_ex(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_flush(flush),


			.i_id_reg1_data(id_reg1_ndata), .i_id_reg2_data(id_reg2_ndata),
			.i_id_reg3_addr(id_reg3_addr), .i_id_imm16(id_imm26[15:0]),.i_id_aluop(id_aluop),
			.i_id_result_or_mem(id_result_or_mem), .i_id_bad_pc(id_bad_pc), 
			.i_id_mem_wen(id_mem_wen), .i_id_mem_en(id_mem_en),
			.i_id_mem_byte_se(id_mem_byte_se), .i_id_reg3_write(id_reg3_write), .i_id_pc(id_pc),
			.i_id_rd_addr(id_rd_addr), .i_id_cp0_write(id_cp0_write), .i_id_exp_type(id_n_exp_type), 
			.i_id_next_in_dslot(id_next_in_dslot), .i_id_curr_in_dslot(id_curr_in_dslot), .i_id_hilo_wen(id_hilo_wen),


			.o_ex_reg1_data(ex_reg1_data), .o_ex_reg2_data(ex_reg2_data),
			.o_ex_reg3_addr(ex_reg3_addr), .o_ex_imm16(ex_imm16), .o_ex_aluop(ex_aluop),
			.o_ex_mem_wen(ex_mem_wen), .o_ex_bad_pc(ex_bad_pc),
			.o_ex_mem_en(ex_mem_en), .o_ex_mem_byte_se(ex_mem_byte_se), .o_ex_result_or_mem(ex_result_or_mem),
			.o_ex_reg3_write(ex_reg3_write), .o_ex_pc(ex_pc),
			.o_ex_rd_addr(ex_rd_addr), .o_ex_cp0_write(ex_cp0_write), .o_ex_exp_type(ex_exp_type),
			.o_ex_next_in_dslot(ex_next_in_dslot), .o_ex_curr_in_dslot(ex_curr_in_dslot), .o_ex_hilo_wen(ex_hilo_wen)
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
	wire [`REG_WIDTH] bad_addr;
	CP0 my_cp0(
		.i_clk(i_clk), .i_rst(i_rst), .i_int(ext_int), .i_ex_rd_addr(ex_rd_addr), .i_ex_cp0_sel(ex_imm16[2:0]), 
		.i_wb_cp0_sel(wb_cp0_sel), .i_wb_cp0_data(wb_cp0_data), .i_wb_rd_addr(wb_rd_addr), .i_wb_cp0_write(wb_cp0_write),
		.i_exp_type(mem_exp_ntype), .i_curr_in_dslot(mem_curr_in_dslot), .i_pc(mem_pc), .i_bad_addr(bad_addr),

		.o_ex_cp0_data(ex_cp0_data), .o_timer_int(o_timer_int),
		.o_status(mem_cp0_status), .o_cause(mem_cp0_cause), .o_epc(mem_cp0_epc)

	);

	wire [2:0] mem_cp0_sel;
	wire mem_cp0_write;
	wire [`REG_WIDTH] ex_cp0_ndata;
	MUX3 my_mux3(
			.i_ex_cp0_sel(ex_imm16[2:0]), .i_mem_alu_result(mem_alu_result), .i_mem_reg3_addr(mem_reg3_addr), .i_mem_cp0_sel(mem_cp0_sel),
			.i_mem_cp0_write(mem_cp0_write), .i_wb_cp0_data(wb_cp0_data), .i_wb_reg3_addr(wb_reg3_addr), 
			.i_wb_cp0_sel(wb_cp0_sel), .i_wb_cp0_write(wb_cp0_write), .i_ex_rd_addr(ex_rd_addr), .i_ex_cp0_data(ex_cp0_data),

			.o_ex_cp0_ndata(ex_cp0_ndata)
	);

	wire [`REG_WIDTH] ex_hi;
	wire [`REG_WIDTH] ex_lo;
	wire [`REG_WIDTH] wb_hi;
	wire [`REG_WIDTH] wb_lo;
	wire wb_hilo_wen;
	HILO my_hilo(
		.i_clk(i_clk), .i_rst(i_rst), .i_wen(wb_hilo_wen), 
		.i_hi(wb_hi), .i_lo(wb_lo),

		.o_hi(ex_hi), .o_lo(ex_lo)
	);

	wire [`REG_WIDTH] mem_hi;
	wire [`REG_WIDTH] mem_lo;
	wire mem_hilo_wen;
	wire [`REG_WIDTH] ex_nhi;
	wire [`REG_WIDTH] ex_nlo;

	MUX4 my_mux4(	
		.i_mem_hi(mem_hi), .i_mem_lo(mem_lo), .i_mem_hilo_wen(mem_hilo_wen),
		.i_wb_hi(wb_hi), .i_wb_lo(wb_lo), .i_wb_hilo_wen(wb_hilo_wen),
		.i_ex_hi(ex_hi), .i_ex_lo(ex_lo),

		.o_ex_nhi(ex_nhi), .o_ex_nlo(ex_nlo)
	);
	
	wire exception_flag;
	wire [31:0] ex_exp_ntype;
	wire [`REG_WIDTH] alu_hi;
	wire [`REG_WIDTH] alu_lo;
	ALU my_alu(
			.i_clk(i_clk), .i_rst(i_rst),
			.i_pc(ex_pc), .i_reg1_ndata(ex_reg1_data), .i_reg2_ndata(ex_reg2_data), .i_imm16(ex_imm16),
			.i_aluop(ex_aluop), .i_cp0_ndata(ex_cp0_ndata), .i_exp_type(ex_exp_type), 
			.i_nhi(ex_nhi), .i_nlo(ex_nlo),

			.o_alu_result(ex_alu_result), .o_exp_type(ex_exp_ntype), .o_hi(alu_hi), .o_lo(alu_lo),
			.o_stall(stall_req_from_ex)
	);

	wire [2:0] mem_mem_byte_se;
	wire mem_result_or_mem;
	wire [31:0] mem_exp_type;
	wire mem_mem_en;
	wire [`INST_ADDR_WIDTH] mem_bad_pc;
	EX_ME my_ex_me(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_ex_alu_result(ex_alu_result), .i_ex_reg2_ndata(ex_reg2_data),
			.i_ex_reg3_addr(ex_reg3_addr), .i_ex_mem_wen(ex_mem_wen), .i_ex_mem_en(ex_mem_en), .i_ex_mem_byte_se(ex_mem_byte_se),
			.i_ex_result_or_mem(ex_result_or_mem), .i_ex_reg3_write(ex_reg3_write),
			.i_ex_cp0_write(ex_cp0_write) ,.i_ex_cp0_sel(ex_imm16[2:0]),
			.i_ex_pc(ex_pc), .i_ex_exp_type(ex_exp_ntype), .i_ex_curr_in_dslot(ex_curr_in_dslot),
			.i_flush(flush),
			.i_ex_hilo_wen(ex_hilo_wen), .i_ex_hi(alu_hi), .i_ex_lo(alu_lo), .i_ex_bad_pc(ex_bad_pc),

			.o_mem_alu_result(mem_alu_result), .o_mem_reg2_ndata(mem_mem_data), .o_mem_reg3_addr(mem_reg3_addr), .o_mem_mem_wen(mem_mem_wen),
			.o_mem_mem_en(mem_mem_en), .o_mem_mem_byte_se(mem_mem_byte_se), .o_mem_result_or_mem(mem_result_or_mem), .o_mem_reg3_write(mem_reg3_write),
			.o_mem_cp0_write(mem_cp0_write), .o_mem_cp0_sel(mem_cp0_sel),
			.o_mem_pc(mem_pc), .o_mem_exp_type(mem_exp_type), .o_mem_curr_in_dslot(mem_curr_in_dslot),
			.o_mem_hilo_wen(mem_hilo_wen), .o_mem_hi(mem_hi), .o_mem_lo(mem_lo), .o_mem_bad_pc(mem_bad_pc)
	);

	Memwen_Transform my_mem_wen_tran(
		.i_alu_result(mem_alu_result), .i_mem_wen(mem_mem_wen), .i_reg2_data(mem_mem_data),

		.o_mem_wen(mem_n_wen), .o_reg2_data(mem_n_mem_data)
	);


	Exp_Handler my_exp_handler(
			.i_exp_type(mem_exp_type), .i_pc(mem_pc), .i_cp0_status(mem_cp0_status), .i_cp0_cause(mem_cp0_cause), .i_cp0_epc(mem_cp0_epc),
			.i_alu_result(mem_alu_result), .i_bad_pc(mem_bad_pc),
			.i_wb_cp0_sel(wb_cp0_sel), .i_wb_cp0_data(wb_cp0_data), .i_wb_rd_addr(wb_reg3_addr), .i_wb_cp0_write(wb_cp0_write), .i_mem_en(mem_mem_en), .i_mem_wen(mem_mem_wen),//use mem_mem_wen or mem_n_wen is same

			.o_mem_en(exp_mem_en), .o_exp_type(mem_exp_ntype), .o_exp_pc(exp_pc), .o_flush(flush),
			.o_bad_addr(bad_addr)
	);


	MUX2 my_mux2(
			.i_result_or_mem(mem_result_or_mem), .i_alu_result(mem_alu_result), .i_mem_data(dmem_data), .i_mem_byte_se(mem_mem_byte_se), 

			.o_reg3_data(mem_reg3_data)
	);
	
	assign debug_wb_rf_wen = {4{wb_reg3_write}};
	assign debug_wb_rf_wnum = wb_reg3_addr;
	assign debug_wb_rf_wdata = wb_reg3_data;
	
	ME_WB my_me_wb(
			.i_clk(i_clk), .i_rst(i_rst), .i_stall(stall), .i_mem_reg3_data(mem_reg3_data), .i_mem_reg3_addr(mem_reg3_addr),
			.i_mem_reg3_write(mem_reg3_write), .i_mem_cp0_write(mem_cp0_write), .i_mem_cp0_sel(mem_cp0_sel), 
			.i_flush(flush), .i_mem_pc(mem_pc),
			.i_mem_hilo_wen(mem_hilo_wen), .i_mem_hi(mem_hi), .i_mem_lo(mem_lo),

			.o_wb_reg3_data(wb_reg3_data), .o_wb_reg3_addr(wb_reg3_addr), .o_wb_reg3_write(wb_reg3_write),
			.o_wb_cp0_write(wb_cp0_write), .o_wb_cp0_sel(wb_cp0_sel), .o_wb_pc(debug_wb_pc),
			.o_wb_hilo_wen(wb_hilo_wen), .o_wb_hi(wb_hi), .o_wb_lo(wb_lo)
	);

endmodule
