`timescale 1ns / 1ps
`include "defines.v"

`define READ_START 3'b000
`define IF_WA 3'b001				//if stage wait for address
`define IF_WD 3'b010				//if stage wait for data
`define IF_WD_ME_WA 3'b011			//if stage wait for data and mem stage wait for address
`define IF_WD_ME_WD 3'b100			//if stage and mem stage both wait for data
`define ME_WD 3'b101 				//mem stage wait for data
`define ME_WA 3'b110				//mem stage wait for address
`define IF_WA_ME_WD	3'b111			//if stage wait for address and mem stage wait for data

`define WRITE_START 2'b00			
`define WAIT_ADDR 2'b01				//wait address ack
`define WRITE_DATA 2'b10			//send data and wait for ack
`define WAIT_RESPONSE 2'b11			//wait response
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2020 04:43:06 PM
// Design Name: 
// Module Name: Axi_Controller
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


module Axi_Controller(
	input wire i_aclk,
	input wire i_aresetn,
	input wire i_flush,
	input wire i_if_axi_stall,
	input wire i_ce,
	
	input wire [`INST_ADDR_WIDTH] i_if_addr,
	input wire i_if_en,
	//input wire i_if_wen,
	input wire [`INST_WIDTH] i_if_data,
	output reg [`INST_WIDTH] o_if_data,

	input wire [`REG_WIDTH] i_mem_addr,
	input wire i_mem_en,
	input wire [3:0] i_mem_wen,
	input wire [`REG_WIDTH] i_mem_data,
	output reg [`REG_WIDTH] o_mem_data,

	output reg [3:0] o_arid, 	//0 : fetch inst  1 : fetch data
	output reg [31:0] o_araddr,
	output reg [3:0] o_arlen,
	output reg [2:0] o_arsize,
	output reg [1:0] o_arburst,
	output reg [1:0] o_arlock,
	output reg [3:0] o_arcache,
	output reg [2:0] o_arprot,
	output reg o_arvalid,
	input wire i_arready,

	input wire [3:0] i_rid,
	input wire [31:0] i_rdata,
    input wire [1:0] i_rresp,
	input wire i_rlast,
	input wire i_rvalid,
	output reg o_rready,

	output reg [3:0] o_awid,
	output reg [31:0] o_awaddr,
	output reg [3:0] o_awlen,
	output reg [2:0] o_awsize,
	output reg [1:0] o_awburst,
	output reg [1:0] o_awlock,
	output reg [3:0] o_awcache,
	output reg [2:0] o_awprot,
	output reg o_awvalid,
	input wire i_awready,

	output reg [3:0] o_wid,
	output reg [31:0] o_wdata,
	output reg [3:0] o_wstrb,
	output reg o_wlast,
	output reg o_wvalid,
	input wire i_wready,

	input wire [3:0] i_bid,
	input wire [1:0] i_bresp,
	input wire i_bvalid,
	output reg o_bready,

	output reg o_stall_req_from_if,
	output reg o_stall_req_from_mem,
	output reg o_if_read_result_flag,
	output reg o_me_read_result_flag
    );

	reg [3:0] r_status;
	//reg o_if_read_result_flag;		//0 : getting, 1: got
	reg [2:0] w_status;

	reg [31:0] if_addr;
	reg [31:0] mem_addr;
    //address mapping
    always
        @(*) begin
            if(i_if_addr >= `KSEG0_START && i_if_addr < `KSEG1_START) begin
                  if_addr <= i_if_addr & 32'h7fff_ffff;
            end
            else if(i_if_addr < `KSEG2_START && i_if_addr >= `KSEG1_START) begin
                    if_addr <= i_if_addr & 32'h5fff_ffff;
            end
            else begin
                    if_addr <= i_if_addr;
            end
        end

    always
        @(*) begin
            if(i_mem_addr >= `KSEG0_START && i_mem_addr < `KSEG1_START) begin
                  mem_addr <= i_mem_addr & 32'h7fff_ffff;
            end
            else if(i_mem_addr < `KSEG2_START && i_mem_addr >= `KSEG1_START) begin
                    mem_addr <= i_mem_addr & 32'h5fff_ffff;
            end
            else begin
                    mem_addr <= i_mem_addr;
            end
        end
  
	


	//if stall control module
	always
		@(*) begin
			if(i_ce == `CHIP_DISABLE || i_flush == `IS_FLUSH) begin 		//initialize
				o_stall_req_from_if <= `NO_STALL;
			end
			else if(o_if_read_result_flag == 1'b0  && i_if_en == `CHIP_ENABLE) begin
				o_stall_req_from_if <= `IS_STALL;
			end
			else begin
				o_stall_req_from_if <= `NO_STALL;
			end
		end
	//mem stall control module
	always
		@(*) begin
			if(i_ce == `CHIP_DISABLE || i_flush == `IS_FLUSH) begin 		//initialize
				o_stall_req_from_mem <= `NO_STALL;
			end
			else if(o_me_read_result_flag == 1'b0  && i_mem_en == `CHIP_ENABLE) begin
				o_stall_req_from_mem <= `IS_STALL;
			end
			else begin
				o_stall_req_from_mem <= `NO_STALL;
			end
		end


	
	always
			@(posedge i_aclk) begin			
				if(i_aresetn == `RST_ENABLE || i_flush == `IS_FLUSH) begin 		//initialize
					o_mem_data <= `ZERO_WORD;
					o_if_data <= `ZERO_WORD;
					r_status <= `READ_START;
					o_if_read_result_flag <= 1'b0;
					o_me_read_result_flag <= 1'b0;
					o_rready <= 1'b0;
					o_arvalid <= 1'b0;
					o_arprot <= 3'b000;
					o_arcache <= 4'b0000;
					o_arlock <= 2'b00;
					o_arburst <= 2'b01;				
					o_arsize <= 4'b0000;
					o_arlen <= 4'b0000;		//transfre data 1 times
					o_araddr <= `ZERO_WORD;
					o_arid <= 4'b0000;
				end
				else begin
					if(o_stall_req_from_mem == `NO_STALL && o_me_read_result_flag == 1'b1) begin
							o_me_read_result_flag <= 1'b0;
					end
					case(r_status)
						`READ_START: begin
								if(i_if_axi_stall == `NO_STALL && o_if_read_result_flag == 1'b1) begin
										o_if_read_result_flag <= 1'b0;
								end
								if(o_if_read_result_flag == 1'b0  && i_if_en == `CHIP_ENABLE && (i_mem_en != `CHIP_ENABLE || (i_mem_en == `CHIP_ENABLE && |i_mem_wen == 1'b0))) begin		//inst read and no memeory read and have not got the result
										o_arid <= 1'b0;		//fetch inst
										o_araddr <= if_addr;
										o_arsize <= 3'b010;		//4 byte in transfer
										o_arvalid <= 1'b1;
										r_status <= `IF_WA;
								end
								else if(o_if_read_result_flag == 1'b0 && i_if_en == `CHIP_ENABLE && i_mem_en == `CHIP_ENABLE) begin		//fetch inst and data simultaneously
										o_arid <= 1'b1;
										o_araddr <= mem_addr;
										o_arsize <= 3'b010;
										o_arvalid <= 1'b1;
										r_status <= `ME_WA;
								end
						end
						`IF_WA: begin
								if(i_mem_en == `CHIP_ENABLE) begin
								end
								if(i_arready == 1'b1 && i_mem_en == `CHIP_DISABLE) begin
									//	o_arid <= 1'b0;
										o_araddr <= `ZERO_WORD;
										o_arvalid <= 1'b0;
									//	o_arsize <= 3'b010;
										o_rready <= 1'b1;
										r_status <= `IF_WD;
								end
								else if(i_arready == 1'b1 && i_mem_en == `CHIP_DISABLE) begin
										o_arid <= 1'b1;			//fetch data
										o_araddr <= mem_addr;
										//o_arsize <= 3'b010;
										//o_arvalid <= 1'b1;
										o_rready <= 1'b1;
										r_status <= `IF_WD_ME_WA;
								end
						end
						`IF_WD: begin
								if(i_rvalid == 1'b1 && i_mem_en == `CHIP_DISABLE) begin
									o_rready <= 1'b0;
									o_if_data <= i_rdata;
									o_if_read_result_flag <= 1'b1;
									r_status <= `READ_START;
								end
								else if(i_rvalid == 1'b1 && i_mem_en == `CHIP_ENABLE) begin
									o_rready <= 1'b0;
									o_if_data <= i_rdata;
									o_if_read_result_flag <= 1'b1;
									o_arid <= 1'b1;			//fetch data
									o_araddr <= mem_addr;
									//o_arsize <= 3'b010;
									o_arvalid <= 1'b1;
									r_status <= `ME_WA;
								end	
								else if(i_rvalid == 1'b0 && i_mem_en == `CHIP_ENABLE) begin
									o_arid <= 1'b1;			//fetch data
									o_araddr <= mem_addr;
									//o_arsize <= 3'b010;
									o_arvalid <= 1'b1;
									//o_rready <= 1'b1;
									r_status <= `IF_WD_ME_WA;
								end
								else begin
										//do nothing
								end
						end
						`IF_WD_ME_WA: begin
								if(i_arready == 1'b1 && i_rvalid == 1'b0) begin
									o_araddr <= `ZERO_WORD;
									o_arvalid <= 1'b0;
									o_arid <= 1'b0;
									r_status <= `IF_WD_ME_WD;
								end
								else if(i_arready == 1'b1 && i_rvalid == 1'b1) begin
									//prepare to fetch data
									o_araddr <= `ZERO_WORD;
									o_arvalid <= 1'b0;
									o_arid <= 1'b0;
									o_rready <= 1'b1;			//original value should be 1'b1
									//fetch data;
									o_if_read_result_flag <= 1'b1;
									o_if_data <= i_rdata;
									r_status <= `ME_WD;
								end
								else if(i_arready == 1'b0 && i_rvalid == 1'b1) begin
									o_rready <= 1'b0;
									o_if_data <= i_rdata;
									o_if_read_result_flag <= 1'b1;
									r_status <= `ME_WA;	
								end
								else begin
										//do nothing
								end
						end
						`IF_WD_ME_WD: begin
								if(i_rvalid == 1'b1 && i_rid == 1'b0) begin	//fetch inst
									o_if_data <= i_rdata;
									o_if_read_result_flag <= 1'b1;
									r_status <= `ME_WD;
								end
								else if(i_rvalid == 1'b1 && i_rid == 1'b1) begin	//fetch data
									o_mem_data <= i_rdata;
									o_me_read_result_flag <= 1'b1;
									r_status <= `IF_WD;
								end
								else begin
										//do nothing
								end
						end
						`ME_WD: begin
								//there should have not if_mem_en == `CHIP_ENABLE
								//and o_if_read_result_flag == 1'b0 situation
								if(i_rvalid == 1'b1) begin
									o_mem_data <= i_rdata;
									o_me_read_result_flag <= 1'b1;
									o_rready <= 1'b0;
									r_status <= `READ_START;
								end
								else begin
										//do nothing
								end
						end
						`ME_WA: begin
								if(i_arready == 1'b1 && i_mem_en == `CHIP_ENABLE && o_if_read_result_flag == 1'b0) begin
										//deliver the inst address
										//o_arvalid <= 1'b0;	
										o_araddr <= if_addr;
										o_arid <= 1'b0;
										//prepare to fetch data
										o_rready <= 1'b1;
										r_status <= `IF_WA_ME_WD;
								end
								else if(i_arready == 1'b1 && !(i_mem_en == `CHIP_ENABLE && o_if_read_result_flag == 1'b0)) begin
										o_arvalid <= 1'b0;	
										o_araddr <= `ZERO_WORD;
										o_arid <= 1'b0;
										//prepare to fetch data
										o_rready <= 1'b1;
										r_status <= `ME_WD;
								end
						end
						`IF_WA_ME_WD: begin
								if(i_arready == 1'b1 && i_rvalid == 1'b1) begin
										o_arvalid <= 1'b0;
										o_araddr <= `ZERO_WORD;
										o_arid <= 1'b0;
										o_mem_data <= i_rdata;
										o_me_read_result_flag <= 1'b1;
										//o_rready == 1'b0;
										r_status <= `IF_WD;
								end
								else if(i_arready == 1'b1 && i_rvalid == 1'b0) begin
										o_arvalid <= 1'b0;
										o_araddr <= `ZERO_WORD;
										o_arid <= 1'b0;
										r_status <= `IF_WD_ME_WD;
								end
								else if(i_arready == 1'b0 && i_rvalid == 1'b1) begin
										o_mem_data <= i_rdata;
										o_me_read_result_flag <= 1'b1;
										o_rready <= 1'b0;
										r_status <= `IF_WA;
								end
								else begin
										//do nothing
								end
						end
					endcase

				end
			end
	
	/* memory write */
	always
			@(posedge i_aclk) begin
				if(i_aresetn == `RST_ENABLE || i_flush == `IS_FLUSH) begin
					w_status <= `WRITE_START;
					o_bready <= 1'b0;
					o_wvalid <= 1'b0;
					o_wlast <= 1'b1;
					o_wstrb <= 4'b0000;
					o_wdata <= `ZERO_WORD;
					o_wid <= 4'b0001; 				//ID number
					o_awvalid <= 1'b0;
					o_awprot <= 3'b000;				//protect attribute
					o_awcache <= 4'b0000;			//cache attribute
					o_awlock <= 2'b00;				//atom lock
					o_awlock <= 2'b01;				//incrementing-address burst
					o_awsize <= 3'b000;
					o_awlen <= 4'b0000;		//transfer data 1 times
					o_awaddr <= `ZERO_WORD;
					o_awid <= 4'b0001;				//ID number
				end
				else begin
					case(w_status)
						`WRITE_START: begin
							if((i_mem_en == `CHIP_ENABLE) && (|i_mem_wen == 1'b1)) begin
								o_awaddr <= mem_addr;
								o_awsize <= 3'b010;			//4 byte in transfer
								o_awvalid <= 1'b1;
								w_status <= `WAIT_ADDR;
							end
							else begin
								//keep the original value
							end
						end
						`WAIT_ADDR: begin
							if(i_awready == 1'b1) begin
								o_awaddr <= `ZERO_WORD;
								o_awsize <= 3'b010;
								o_awvalid <= 1'b0;
								o_wdata <= i_mem_data;
								o_wstrb <= i_mem_wen;
								o_wvalid <= 1'b1;
								o_bready <= 1'b1;
								w_status <= `WRITE_DATA;
							end
							else begin
								//keep the original value
							end
						end
						`WRITE_DATA: begin
							if(i_wready == 1'b1) begin 
								o_wdata <= `ZERO_WORD;
								o_wstrb <= 4'b000;
								o_wvalid <= 1'b0;
								//o_bready <= 1'b1;
								w_status <= `WAIT_RESPONSE;
							end
						end
						`WAIT_RESPONSE: begin
							if(i_bvalid == 1'b1) begin
								o_bready <= 1'b0;
								w_status <= `WRITE_START;
							end
						end
					endcase
				end
			end



endmodule
