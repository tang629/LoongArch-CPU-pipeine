`timescale 1ns / 1ps

module RF(
    input clk,
    input rstn,
    input RFWr,
    input [15:0] sw_i,
    input [4:0] A1, A2, A3,	
    input [31:0] WD,
    output reg [31:0] RD1,
    output reg [31:0] RD2
);
    reg [31:0] rf[31:0];

 
    // ��ʼ���Ĵ�������
   

    // ʱ���߼�
    always@(negedge clk or negedge rstn)begin
        if(!rstn)begin
            rf[0]<=0;
            rf[1]<=8'h88;
            rf[2]<=55;
            rf[3]<=255;
            rf[4]<=0;
            rf[5]<=1;
            rf[6]<=8'hFF;
            rf[7]<=7;
            rf[8]<=8;
            rf[9]<=9;
            rf[10]<=4;
            rf[11]<=11;
            rf[12]<=12;
            rf[13]<=13;
            rf[14]<=14;
            rf[15]<=15;
            rf[16]<=16;
            rf[17]<=17;
            rf[18]<=18;
            rf[19]<=19;
            rf[20]<=20;
            rf[21]<=21;
            rf[22]<=22;
            rf[23]<=23;
            rf[24]<=24;
            rf[25]<=25;
            rf[26]<=26;
            rf[27]<=27;
            rf[28]<=28;
            rf[29]<=29;
            rf[30]<=30;
            rf[31]<=31;
        end else
        if(RFWr&&!sw_i[1])begin
            rf[A3]=WD;
        end
    end
    always @(*) begin
            RD1 <= (A1==0?0:rf[A1]);
            RD2 <= (A2==0?0:rf[A2]);

    end
endmodule