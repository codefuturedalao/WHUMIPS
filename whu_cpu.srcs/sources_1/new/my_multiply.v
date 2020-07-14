`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/14 21:37:01
// Design Name: 
// Module Name: my_multiply
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


module my_multiply(
    input         clk,        // ʱ��
    input         mult_begin, // �˷���ʼ�ź�
    input  [31:0] mult_op1,   // �˷�Դ������1
    input  [31:0] mult_op2,   // �˷�Դ������2
    output [63:0] product,    // �˻�
    output        mult_end   // �˷������ź�
    );
    //�˷����������źźͽ����ź�
    reg mult_valid;
    assign mult_end = mult_valid & ~(|multiplier); //�˷������źţ�����ȫ0
    always @(posedge clk)   //��
    begin
        if (!mult_begin || mult_end)    //���û�п�ʼ�����Ѿ�������
        begin
            mult_valid <= 1'b0;     //mult_valid ��ֵ��0��˵������û�н�����Ч�ĳ˷�����
        end
        else
        begin
            mult_valid <= 1'b1;
       //     test <= 1'b1;
        end
    end

    //����Դ����ȡ����ֵ�������ľ���ֵΪ�䱾�������ľ���ֵΪȡ����1
    wire        op1_sign;      //������1�ķ���λ
    wire        op2_sign;      //������2�ķ���λ
    wire [31:0] op1_absolute;  //������1�ľ���ֵ
    wire [31:0] op2_absolute;  //������2�ľ���ֵ
    assign op1_sign = mult_op1[31];
    assign op2_sign = mult_op2[31];
    assign op1_absolute = op1_sign ? (~mult_op1+1) : mult_op1;
    assign op2_absolute = op2_sign ? (~mult_op2+1) : mult_op2;
    //���ر�����������ʱÿ������һλ
    reg  [63:0] multiplicand;
    always @ (posedge clk)  //��
    begin
        if (mult_valid)
        begin    // ������ڽ��г˷����򱻳���ÿʱ������һλ
            multiplicand <= {multiplicand[62:0],1'b0};  //������xÿ������һλ��
        end
        else if (mult_begin) 
        begin   // �˷���ʼ�����ر�������Ϊ����1�ľ���ֵ
            multiplicand <= {32'd0,op1_absolute};
        end
    end

    //���س���������ʱÿ������һλ���൱��y
    reg  [31:0] multiplier;
    
    always @ (posedge clk)  //��
    begin
    if(mult_valid)
    begin       //������ڽ��г˷��������ÿʱ������һλ
         multiplier <= {1'b0,multiplier[31:1]}; //�൱�ڳ���y����һλ
    end
    else if(mult_begin)
    begin   //�˷���ʼ�����س�����Ϊ����2�ľ���ֵ
        multiplier <= op2_absolute;
        end
    end
    // ���ֻ�������ĩλΪ1���ɱ��������Ƶõ�������ĩλΪ0�����ֻ�Ϊ0
    wire [63:0] partial_product;
    assign partial_product = multiplier[0] ? multiplicand:64'd0;        //����ʱy�����λΪ1�����x��ֵ�����ֻ�partial_product�������0��ֵ��partial_product
    
    //�ۼ���
    reg [63:0] product_temp;		//��ʱ���
    always @ (posedge clk)  //��//clk�źŴ�0��Ϊ1ʱ�������˶�����ִ�У�������ִ����Ҫʱ��
    begin
        if (mult_valid)
        begin
            product_temp <= product_temp + partial_product;
        end      
        else if (mult_begin)
        begin
        product_temp <= 64'd0;
        end
     end
     
    //�˷�����ķ���λ�ͳ˷����
    reg product_sign;	//�˻�����ķ���
    always @ (posedge clk)  // �˻���
    begin
        if (mult_valid)
        begin
              product_sign <= op1_sign ^ op2_sign;
        end
    end 
    //���˷����Ϊ����������Ҫ�Խ��ȡ��+1
    
    assign product = product_sign ? (~product_temp+1) : product_temp;
endmodule

