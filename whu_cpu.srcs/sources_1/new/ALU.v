`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 07:56:14 PM
// Design Name: 
// Module Name: ALU // Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//		LOHI,BREAK.C0 to do 
// Dependencies: 
//		 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
	input wire i_clk,
	input wire i_rst,
	input wire [`INST_ADDR_WIDTH] i_pc,
	input wire [`REG_WIDTH] i_reg1_ndata,
	input wire [`REG_WIDTH] i_reg2_ndata,
	input wire [`REG_WIDTH] i_cp0_ndata,
	input wire [15:0] i_imm16,
	input wire [`ALUOP_WIDTH] i_aluop,
	input wire [`REG_WIDTH] i_nhi,
	input wire [`REG_WIDTH] i_nlo,
	output reg [`REG_WIDTH] o_hi,
	output reg [`REG_WIDTH] o_lo,
	input wire [31:0] i_exp_type,
	output reg [`REG_WIDTH] o_alu_result,
	output wire [31:0] o_exp_type,
	output reg o_stall
    );
	wire [32:0] add_result_reg; //the most significant bit can be used for judge overflow
	wire [32:0] sub_result_reg; //
	wire [32:0] add_result_imm; //the most significant bit can be used for judge overflow
	wire [32:0] sub_result_imm; //
	wire [31:0] imm32_sign;                //could be replace by imm33_sign    do it later
	wire [31:0] imm32_unsign;              //could be replace by imm33_unsign
	wire [32:0] imm33_sign; 
	wire [32:0] imm33_unsign; 
	reg overflow;
	reg no_align;
	assign o_exp_type = {i_exp_type[31:14], overflow, no_align, i_exp_type[11:0]};

	assign imm32_sign = {{16{i_imm16[15]}},i_imm16[15:0]};
	assign imm32_unsign = {16'b0,i_imm16[15:0]};
	assign imm33_sign = {{17{i_imm16[15]}},i_imm16[15:0]};
	assign imm33_unsign = {17'b0,i_imm16[15:0]};
	assign add_result_reg = {i_reg1_ndata[31],i_reg1_ndata[31:0]} + {i_reg2_ndata[31],i_reg2_ndata[31:0]}; //usr for add,addu
	assign add_result_imm = {i_reg1_ndata[31],i_reg1_ndata[31:0]} + imm33_sign; //use for addi,addiu
	assign sub_result_reg = {i_reg1_ndata[31],i_reg1_ndata[31:0]} - {i_reg2_ndata[31],i_reg2_ndata[31:0]}; //use for sub,subu,slt
	assign sub_result_imm = {i_reg1_ndata[31],i_reg1_ndata[31:0]} - imm33_sign; //use for slti



	reg mul_ce;
	reg mul_sclr;
	reg [32:0] mul_operand1;
	reg [32:0] mul_operand2;
	wire [65:0] mul_result;
	reg [2:0] mul_status;
	//reg mul_signal;
	reg mul_done;
	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin 		//initialize
				//mul_signal <= 1'b0;
				//mul_ce <= 1'b0;
				//mul_sclr <= 1'b0;
				mul_status <= 3'b0;
				mul_done <= 1'b0;
			end
			else if((i_aluop == `MULT_ALU_OPCODE || i_aluop == `MULTU_ALU_OPCODE) && mul_status != 3'b101) begin
				mul_status <= mul_status + 1'b1;
				mul_done <= 1'b0;
			end
			else if((i_aluop == `MULT_ALU_OPCODE || i_aluop == `MULTU_ALU_OPCODE) && mul_status == 3'b101) begin
				mul_status <= 3'b000;
				mul_done <= 1'b1;
			end
			else begin
				mul_status <= 3'b000;
				mul_done <= 1'b0;
			end
		end

	mult_gen_0 my_mult(
			.CLK(i_clk),    // input wire CLK
			.A(mul_operand1),        // input wire [32 : 0] A
			.B(mul_operand2),        // input wire [32 : 0] B
			.CE(mul_ce),      // input wire CE
			.SCLR(mul_sclr),  // input wire SCLR
			.P(mul_result)        // output wire [65 : 0] P
	);
	reg s_axis_divisor_tvalid;
	wire s_axis_divisor_tready;
	reg [39:0] s_axis_divisor_tdata;
	reg s_axis_dividend_tvalid;
	wire s_axis_dividend_tready;
	reg [39:0] s_axis_dividend_tdata;
	wire m_axis_dout_tvalid;
	wire [79:0] m_axis_dout_tdata;
	reg [2:0] div_status;
	//reg div_signal;
	reg div_done;
	always
		@(posedge i_clk) begin
			if(i_rst == `RST_ENABLE) begin
		//		s_axis_divisor_tvalid <= 1'b0;
				//s_axis_divisor_tdata <= `ZERO_WORD;
		//		s_axis_dividend_tvalid <= 1'b0;
				//s_axis_dividend_tdata <= `ZERO_WORD;
			end
			else if((i_aluop == `DIV_ALU_OPCODE || i_aluop == `DIVU_ALU_OPCODE) && div_status != 3'b101) begin
				div_status <= div_status + 1'b1;
				div_done <= 1'b0;
			end
			else if((i_aluop == `DIV_ALU_OPCODE || i_aluop == `DIVU_ALU_OPCODE) && div_status == 3'b101) begin
				div_status <= 3'b000; 
				div_done <= 1'b1;
			end
			else begin
				div_status <= 3'b000; 
				div_done <= 1'b0;
			end
		end

	div_gen_1 my_div(
			.aclk(i_clk),                                      // input wire aclk
			.s_axis_divisor_tvalid(s_axis_divisor_tvalid),    // input wire s_axis_divisor_tvalid
			//.s_axis_divisor_tready(s_axis_divisor_tready),    // output wire s_axis_divisor_tready
			.s_axis_divisor_tdata(s_axis_divisor_tdata),      // input wire [39 : 0] s_axis_divisor_tdata
			.s_axis_dividend_tvalid(s_axis_dividend_tvalid),  // input wire s_axis_dividend_tvalid
		//	.s_axis_dividend_tready(s_axis_dividend_tready),  // output wire s_axis_dividend_tready
			.s_axis_dividend_tdata(s_axis_dividend_tdata),    // input wire [39 : 0] s_axis_dividend_tdata
			.m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
			.m_axis_dout_tdata(m_axis_dout_tdata)            // output wire [71 : 0] m_axis_dout_tdata
	);

	always
		@(*) begin
			overflow <= `NO_EXCEPTION;
			no_align <= `NO_EXCEPTION;
			o_hi <= i_nhi;
			o_lo <= i_nlo;
			o_stall <= `NO_STALL;
			mul_ce <= 1'b0;
			mul_sclr <= 1'b1;
			s_axis_divisor_tvalid <= 1'b0; 
			s_axis_dividend_tvalid <= 1'b0;
			mul_operand1 <= `ZERO_WORD;		
			mul_operand2 <= `ZERO_WORD; 
			s_axis_divisor_tdata <= `ZERO_WORD;
			s_axis_dividend_tdata <= `ZERO_WORD;
			case(i_aluop)
				`MULT_ALU_OPCODE: begin
					mul_operand1 <= {{8{i_reg1_ndata[31]}},i_reg1_ndata[31:0]};		
					mul_operand2 <= {{8{i_reg2_ndata[31]}},i_reg2_ndata[31:0]};		
					if(mul_done != 1'b1) begin
						mul_sclr <= 1'b0;
						mul_ce <= 1'b1;
						o_stall <= `IS_STALL;
					end
					else if(mul_done == 1'b1) begin
						o_stall <= `NO_STALL;
						mul_sclr <= 1'b1;
						mul_ce <= 1'b0;
						o_hi <= mul_result[63:32];
						o_lo <= mul_result[31:0];
					end
				end
				`MULTU_ALU_OPCODE: begin
					mul_operand1 <= {8'b0, i_reg1_ndata[31:0]};		
					mul_operand2 <= {8'b0, i_reg2_ndata[31:0]};		
					if(mul_done != 1'b1) begin
						mul_sclr <= 1'b0;
						mul_ce <= 1'b1;
						o_stall <= `IS_STALL;
					end
					else begin
						o_stall <= `NO_STALL;
						mul_sclr <= 1'b1;
						mul_ce <= 1'b0;
						o_hi <= mul_result[63:32];
						o_lo <= mul_result[31:0];
					end
				end
				`DIV_ALU_OPCODE: begin
						s_axis_divisor_tdata <= {{8{i_reg2_ndata[31]}},i_reg2_ndata[31:0]};
						s_axis_dividend_tdata <= {{8{i_reg1_ndata[31]}},i_reg1_ndata[31:0]};
						//s_axis_divisor_tdata <= i_reg2_ndata[31:0];
						//s_axis_dividend_tdata <= i_reg1_ndata[31:0];
						if(div_done != 1'b1) begin
							//div_signal <= 1'b1;
							o_stall <= `IS_STALL;
							if(div_status == 3'b000) begin
									s_axis_divisor_tvalid <= 1'b1; 
									s_axis_dividend_tvalid <= 1'b1;
							end
							else begin
									s_axis_divisor_tvalid <= 1'b0; 
									s_axis_dividend_tvalid <= 1'b0;
							end
						end
						else begin
							//div_signal <= 1'b0;
							o_stall <= `NO_STALL;
							o_hi <= m_axis_dout_tdata[31:0];
							o_lo <= m_axis_dout_tdata[71:40];
							s_axis_divisor_tvalid <= 1'b0; 
							s_axis_dividend_tvalid <= 1'b0;
						end
				end
				`DIVU_ALU_OPCODE: begin
						s_axis_divisor_tdata <= {8'b0 ,i_reg2_ndata[31:0]};
						s_axis_dividend_tdata <= {8'b0 ,i_reg1_ndata[31:0]};
						if(div_done != 1'b1) begin
							//div_signal <= 1'b1;
							o_stall <= `IS_STALL;
							s_axis_divisor_tvalid <= 1'b1; 
							s_axis_dividend_tvalid <= 1'b1;
						end
						else begin
							//div_signal <= 1'b0;
							o_stall <= `NO_STALL;
							o_hi <= m_axis_dout_tdata[31:0];
							o_lo <= m_axis_dout_tdata[71:40];
							s_axis_divisor_tvalid <= 1'b0; 
							s_axis_dividend_tvalid <= 1'b0;
						end
				end
				`ADD_ALU_OPCODE: begin
					if(add_result_reg[32] ^ add_result_reg[31] == 1'b1) begin //overflow
						overflow <= `IS_EXCEPTION;
						o_alu_result <= `ZERO_WORD;
					end 
					else begin	
						o_alu_result <= add_result_reg[31:0];
					end
				end	
				`ADDI_ALU_OPCODE: begin 
					if(add_result_imm[32] ^ add_result_imm[31] == 1'b1) begin //overflow
						overflow <= `IS_EXCEPTION;
						o_alu_result <= `ZERO_WORD;
					end else begin	
						o_alu_result <= add_result_imm[31:0];
					end
				end
				`ADDU_ALU_OPCODE: begin
					o_alu_result <= add_result_reg[31:0];
				end	
				`ADDIU_ALU_OPCODE: begin
					o_alu_result <= add_result_imm[31:0];
				end	
				`SUB_ALU_OPCODE: begin
					if(sub_result_reg[32] ^ sub_result_reg[31] == 1'b1) begin //overflow
						overflow <= `IS_EXCEPTION;
						o_alu_result <= `ZERO_WORD;
					end else begin	
						o_alu_result <= sub_result_reg[31:0];
					end
				end	
				`SUBU_ALU_OPCODE: begin
					o_alu_result <= sub_result_reg[31:0];
				end	
				`SLT_ALU_OPCODE: begin
//					if(sub_result_reg[32] == 1'b1)
//						o_alu_result <= 32'b1;
                    if(sub_result_reg[32] ^ sub_result_reg[31] != 1'b1) begin
					    o_alu_result <= sub_result_reg[31];
					end
					else begin
					   o_alu_result <= {{31'b0},~(sub_result_reg[31])};
					end
				end
				`SLTI_ALU_OPCODE: begin
				    if(sub_result_imm[32] ^ sub_result_imm[31] != 1'b1) begin
					   o_alu_result <= sub_result_imm[31];
					end
					else begin
					   o_alu_result <= {{31'b0},~(sub_result_imm[31])};
					end
				end
				`SLTU_ALU_OPCODE: begin
					o_alu_result <= (i_reg1_ndata < i_reg2_ndata) ? 32'b1 : 32'b0;
				end
				`SLTIU_ALU_OPCODE: begin
					o_alu_result <= (i_reg1_ndata < imm32_sign) ? 32'b1 : 32'b0;

				end
				`AND_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata & i_reg2_ndata;
				end
				`ANDI_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata & imm32_unsign;

				end
				`LUI_ALU_OPCODE: begin
					o_alu_result <= {i_imm16,16'b0};
				end
				`NOR_ALU_OPCODE: begin
					o_alu_result <= ~ (i_reg1_ndata | i_reg2_ndata);
				end
				`OR_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata | i_reg2_ndata;
				end
				`ORI_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata | imm32_unsign; 
				end
				`XOR_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata ^ i_reg2_ndata; 
				end
				`XORI_ALU_OPCODE: begin
					o_alu_result <= i_reg1_ndata ^ imm32_unsign;
				end
				`SLLV_ALU_OPCODE: begin
					o_alu_result <= i_reg2_ndata << i_reg1_ndata[4:0]; 
				end
				`SLL_ALU_OPCODE: begin
					o_alu_result <= i_reg2_ndata << i_imm16[10:6]; 
				end
				`SRAV_ALU_OPCODE: begin
					o_alu_result <= (i_reg2_ndata >> i_reg1_ndata[4:0]) | ((i_reg2_ndata[31]) ? ~({32{1'b1}} >> i_reg1_ndata[4:0]) : 32'b0); 
				end
				`SRA_ALU_OPCODE: begin
					o_alu_result <= (i_reg2_ndata >> i_imm16[10:6]) | ((i_reg2_ndata[31]) ? ~({32{1'b1}} >> i_imm16[10:6]) : 32'b0); 
				end
				`SRLV_ALU_OPCODE: begin
					o_alu_result <= i_reg2_ndata >> i_reg1_ndata[4:0]; 
				end
				`SRL_ALU_OPCODE: begin
					o_alu_result <= i_reg2_ndata >> i_imm16[10:6]; 
				end
				`MFHI_ALU_OPCODE: begin
					o_alu_result <= i_nhi;		//write to the rd
				end
				`MFLO_ALU_OPCODE: begin
					o_alu_result <= i_nlo;		//write to the rd
				end
				`MTHI_ALU_OPCODE: begin
					o_alu_result <= `ZERO_WORD;		//write to the rd
					o_hi <= i_reg1_ndata;
				end
				`MTLO_ALU_OPCODE: begin
					o_alu_result <= i_nlo;		//write to the rd
					o_lo <= i_reg1_ndata;
				end
/*branch and jump */
				`BEQ_ALU_OPCODE: begin
					o_alu_result <= `ZERO_WORD;
				end	
				`BNE_ALU_OPCODE: begin
					o_alu_result <= `ZERO_WORD;
				end	
				`BGEZ_ALU_OPCODE: begin
					o_alu_result <= `ZERO_WORD;
				end	
				`BGTZ_ALU_OPCODE: begin
					o_alu_result <= `ZERO_WORD;
				end	
				`BLEZ_ALU_OPCODE: begin
					o_alu_result <= `ZERO_WORD;
				end	
				`BLTZ_ALU_OPCODE: begin
					o_alu_result <= `ZERO_WORD;
				end	
				`BGEZAL_ALU_OPCODE: begin
					o_alu_result <= i_pc + 8;
				end	
				`BLTZAL_ALU_OPCODE: begin
					o_alu_result <= i_pc + 8;
				end	
				`J_ALU_OPCODE: begin
					//nothing
					o_alu_result <= `ZERO_WORD;
				end
				`JAL_ALU_OPCODE: begin
					o_alu_result <= i_pc + 8;	
				end
				//`JR_ALU_OPCODE: begin
					//nothing
				//	o_alu_result <= `ZERO_WORD;
				//end
				`JALR_ALU_OPCODE: begin
					o_alu_result <= i_pc + 8;	
				end
/* priviliged instruction */
				`MFC0_ALU_OPCODE: begin
						o_alu_result <= i_cp0_ndata;
				end
				`MTC0_ALU_OPCODE: begin
						o_alu_result <= i_reg2_ndata;
				end
/* access memory */
				`LH_ALU_OPCODE: begin
					o_alu_result <= add_result_imm;
					no_align <= add_result_imm[0];
				end
				//lhu is the same as lh
				`LW_ALU_OPCODE: begin
					o_alu_result <= add_result_imm;
					no_align <= add_result_imm[1] | add_result_imm[0];
				end
				default: begin
					o_alu_result <= `ZERO_WORD;
				end
			endcase
		end

endmodule
