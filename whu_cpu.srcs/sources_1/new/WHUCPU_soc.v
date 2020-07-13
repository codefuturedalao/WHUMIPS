`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2020 09:57:31 PM
// Design Name: 
// Module Name: WHUCPU_soc
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


module WHUCPU_soc(
	input wire i_sys_clk,
	input wire i_sys_rst
    );

	wire [`REG_WIDTH] dmem_idata;
	wire [`REG_WIDTH] imem_data;
	wire [`INST_ADDR_WIDTH] imem_addr;
	wire [`REG_WIDTH] dmem_addr;
	wire [`REG_WIDTH] dmem_odata;
	wire [3:0] dmem_wen;
	wire timer_int;
	wire [5:0] int;
	assign int = {5'b00000, timer_int};
	wire dmem_en;
	WHUCPU my_whucpu(
			.i_clk(i_sys_clk), .i_rst(i_sys_rst), .i_dmem_data(dmem_odata), .i_imem_data(imem_data),
			.i_int(int),

			.o_imem_addr(imem_addr), .o_dmem_addr(dmem_addr), .o_dmem_data(dmem_idata), .o_dmem_wen(dmem_wen), .o_dmem_en(dmem_en),
			.o_timer_int(timer_int)
	);
	IMEM my_imem(
			.i_en(~i_sys_rst),.i_pc(imem_addr), .o_inst(imem_data)
	);

	DMEM my_dmem(
			.i_clk(i_sys_clk), .i_addr(dmem_addr), .i_data(dmem_idata), .i_mem_en(dmem_en), .i_mem_wen(dmem_wen),

			.o_data(dmem_odata)
	);
endmodule
