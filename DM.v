`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/15 20:07:33
// Design Name: 
// Module Name: DM
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

`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100
module DM(
input					clk,  //100MHZ CLK
input 					DMWr, 
input rstn, //write signal
input [15:0]     sw_i,
input [10:0]			addr,
input [31:0]			din,
input [2:0]			DMType, 
output reg [31:0]		dout 
    );
//先处理读信号

reg[7:0] dmem[255:0];
integer i1;
always@(*)begin
    case(DMType)
    `dm_word:begin
        dout[7:0]<=dmem[addr];
            dout[15:8]<=dmem[addr+1];
            dout[23:16]<=dmem[addr+2];
            dout[31:24]<=dmem[addr+3];
    end
    `dm_halfword:begin
        dout[15:0]<={dmem[addr+1],dmem[addr]};
                dout[31:16]<={16{dmem[addr+1][7]}};
    end 
    `dm_halfword_unsigned:
    begin
        dout[15:0]<={dmem[addr+1],dmem[addr]};
                dout[31:16]<=16'b0;
    end
    `dm_byte:begin
        dout[7:0]<=dmem[addr];
            dout[31:8]<={24{dmem[addr][7]}};
    end
    `dm_byte_unsigned:
    begin dout[7:0]<=dmem[addr];
            dout[31:8]<=24'b0;
    end
endcase
end
integer i;
always@(posedge clk or negedge rstn)begin 
    if(!rstn)begin
        dmem[0]<=16;
dmem[1]<=0;
dmem[2]<=8'hFF;
dmem[3]<=8'hFF;
dmem[4]<=8'hFF;
dmem[5]<=8'hFF;
dmem[6]<=6;
dmem[7]<=7;
dmem[8]<=8;
dmem[9]<=9;
dmem[10]<=10;
dmem[11]<=11;
dmem[12]<=12;
dmem[13]<=13;
dmem[14]<=14;
dmem[15]<=15;
dmem[16]<=16;
dmem[17]<=17;
dmem[18]<=18;
dmem[19]<=19;
dmem[20]<=20;
dmem[21]<=21;
dmem[22]<=22;
dmem[23]<=23;
dmem[24]<=24;
dmem[25]<=25;
dmem[26]<=26;
dmem[27]<=27;
dmem[28]<=28;
dmem[29]<=29;
dmem[30]<=30;
dmem[31]<=31;
dmem[32]<=32;
dmem[33]<=33;
dmem[34]<=34;
dmem[35]<=35;
dmem[36]<=36;
dmem[37]<=37;
dmem[38]<=38;
dmem[39]<=39;
dmem[40]<=40;
dmem[41]<=41;
dmem[42]<=42;
dmem[43]<=43;
dmem[44]<=44;
dmem[45]<=45;
dmem[46]<=46;
dmem[47]<=47;
dmem[48]<=48;
dmem[49]<=49;
dmem[50]<=50;
dmem[51]<=51;
dmem[52]<=52;
dmem[53]<=53;
dmem[54]<=54;
dmem[55]<=55;
dmem[56]<=56;
dmem[57]<=57;
dmem[58]<=58;
dmem[59]<=59;
dmem[60]<=60;
dmem[61]<=61;
dmem[62]<=62;
dmem[63]<=63;
for(i=64;i<256;i=i+1)begin
    dmem[i]<=8'hfc;
end
    end
    else begin
    if(DMWr&!sw_i[1])begin
        case(DMType)
        `dm_word:
        begin dmem[addr]<=din[7:0];
        dmem[addr+1]<=din[15:8];
        dmem[addr+2]<=din[23:16];
        dmem[addr+3]<=din[31:24];
end
        `dm_halfword:
        begin
            dmem[addr]<=din[7:0];
            dmem[addr+1]=din[15:8];
        end
        `dm_byte:
        dmem[addr]<=din[7:0];
        endcase
    end//maybe there need an else
    end
end
endmodule
