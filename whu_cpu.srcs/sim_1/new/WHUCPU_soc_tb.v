`timescale 1ns / 1ps
`include "../../sources_1/new/defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/05/2020 10:24:39 PM
// Design Name: 
// Module Name: WHUCPU_soc_tb
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


module WHUCPU_soc_tb(

    );

	reg CLOCK_50;
	reg rst; 

	initial begin
			CLOCK_50 = 1'b0;
			forever #10 CLOCK_50 = ~CLOCK_50;
	end

	initial begin
			rst = `RST_ENABLE;
			#195 rst = `RST_DISABLE;
			#1000 $stop;
	end

	WHUCPU_soc my_whu_cpu_soc(
			.i_sys_clk(CLOCK_50),
			.i_sys_rst(rst)
	);

endmodule
