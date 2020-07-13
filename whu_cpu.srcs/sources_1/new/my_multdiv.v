`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/13 21:55:25
// Design Name: 
// Module Name: my_multdiv
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


module my_multdiv(
	input wire [`REG_WIDTH] i_reg1_ndata,
	input wire [`REG_WIDTH] i_reg2_ndata,
	input wire [`ALUOP_WIDTH] i_aluop,
	output reg [`REG_WIDTH] o_hi_result,
	output reg [`REG_WIDTH] o_lo_result
    );
    wire [63:0] multu_result;
    wire [31:0] divu_result_hi;
    wire [31:0] divu_result_lo;
    wire [63:0] mult_result;
    wire [31:0] div_result_hi;
    wire [31:0] div_result_lo;

  
endmodule
