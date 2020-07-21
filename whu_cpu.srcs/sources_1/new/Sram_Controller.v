`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2020 09:22:37 AM
// Design Name: 
// Module Name: Sram_Controller
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


module Sram_Controller(
		input wire i_clk,
		input wire i_rst,
		//
		input wire i_en,
		input wire [`INST_WIDTH] i_din,
		input wire [`INST_ADDR_WIDTH] i_addr,
		input wire [`WEN_ADDR] i_wen,
		//
		input wire [`INST_WIDTH] i_dout,
		input wire i_stall,
		input wire i_flush,
		//
		output reg o_en,
		output reg [`WEN_ADDR] o_wen,
		output reg [`INST_ADDR_WIDTH] o_din,
		output reg o_stall_req,
		output reg [`INST_WIDTH] o_data,
		output reg [`INST_ADDR_WIDTH] o_addr,
		output reg o_status
    );
   
   
    //address mapping
    always
        @(*) begin
            if(i_addr >= `KSEG0_START && i_addr < `KSEG1_START) begin
                  o_addr <= i_addr & 32'h7fff_ffff;
            end
            else if(i_addr < `KSEG2_START && i_addr >= `KSEG1_START) begin
                    o_addr <= i_addr & 32'h5fff_ffff;
            end
            else begin
                    o_addr <= i_addr;
            end
        end
    
	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
			end
			else if(i_stall == 1'b1) begin
				o_status <= 1'b1; 		//1 means ready
			end
			else if(i_stall == 1'b0) begin
				o_status <= 1'b0;
			end
		end

	always
		@(*) begin
			o_data <= `ZERO_WORD;
			if(i_rst == `RST_ENABLE || i_flush == `IS_FLUSH) begin
			    o_en <= `CHIP_DISABLE;
			    o_status <= 1'b0;
				o_data <= `ZERO_WORD;
				o_stall_req <= `NO_STALL;
				o_wen <= 4'b0000;
			end
			else if(i_en == `CHIP_ENABLE && o_status == 1'b0) begin
				o_en <= i_en;
				if((|i_wen) == 1'b1) begin //write
						o_stall_req <= `NO_STALL;
						o_wen <= i_wen;
						o_din <= i_din;
					//	o_addr <= i_addr;
				end
				else begin
						o_stall_req <= `IS_STALL;
					//	o_addr <= i_addr;
						o_wen <= i_wen;
				end
			end
			else begin   //1 means ready,that we can get our data
				o_stall_req <= `NO_STALL;
				o_en <= `CHIP_DISABLE;
				o_wen <= 4'b0000;
				o_data <= i_dout;
			end
		end


endmodule
