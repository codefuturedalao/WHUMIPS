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
	input wire i_clk,
	input wire [`REG_WIDTH] i_reg1_ndata,
	input wire [`REG_WIDTH] i_reg2_ndata,
	input wire [`ALUOP_WIDTH] i_aluop,
	output reg [`REG_WIDTH] o_hi_result,
	output reg [`REG_WIDTH] o_lo_result
    );
    wire [63:0] multu_result;
    wire [63:0] divu_result;
    wire [63:0] mult_result;
    wire [63:0] div_result;
    reg CE;
    reg SCLR;
    reg divisor_tvalid;
    reg dividend_tvalid;
    reg dout_tvalid;
    
     initial
    begin     
        CE = 0;
        SCLR = 1;     
        divisor_tvalid=1;
        dividend_tvalid=1;
        dout_tvalid=1;
    end
    
    sign_multiplier s_mult(
    .CLK(i_clk),
    .A(i_reg1_ndata),
    .B(i_reg2_ndata),
    .CE(CE),
    .SCLR(SCLR),
    .P(mult_result)
    );
    
    unsign_multiplier u_mult(
    .CLK(i_clk),
    .A(i_reg1_ndata),
    .B(i_reg2_ndata),
    .P(multu_result)
    );
    
    sign_div s_div(
    .aclk(i_clk),
    .s_axis_divisor_tvalid(divisor_tvalid),
    .s_axis_divisor_tdata(i_reg1_ndata),
    .s_axis_dividend_tvalid(dividend_tvalid),
    .s_axis_dividend_tdata(i_reg2_ndata),
    .m_axis_dout_tvalid(dout_tvalid),
    .m_axis_dout_tdata(div_result)
  );

  
endmodule
