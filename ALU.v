`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/06 21:26:13
// Design Name: 
// Module Name: decode
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


module ALU(
    input wire[11:0]alu_op,
    input wire[31:0]alu_src1,
    input wire[31:0]alu_src2,
    output wire[31:0]alu_result,
    output wire Zero
);
wire op_add;
wire op_sub;
wire op_slt;
wire op_sltu;
wire op_and;
wire op_nor;
wire op_or;
wire op_xor;
wire op_sll;
wire op_srl;
wire op_sra;
wire op_lui;

assign op_add = alu_op[0];
assign op_sub = alu_op[1];
assign op_slt = alu_op[2]; 
assign op_sltu = alu_op[3];
assign op_and = alu_op[4];
assign op_nor = alu_op[5];
assign op_or  = alu_op[6];
assign op_xor = alu_op[7];
assign op_sll = alu_op[8];
assign op_srl = alu_op[9];
assign op_sra = alu_op[10];
assign op_lui = alu_op[11];

wire [31:0]add_sub_res;
wire [31:0]slt_res;
wire [31:0]sltu_res;
wire [31:0]and_res;
wire [31:0]or_res;
wire [31:0]nor_res; 
wire [31:0]xor_res;
wire [31:0]sll_res;
wire [31:0]srl_res;
wire [31:0]sra_res;
wire [31:0]lui_res;
wire cin;
wire cout;
wire [31:0]adder_a;
wire [31:0]adder_b;
assign adder_a=alu_src1;
assign cin=(op_sub|op_slt|op_sltu)?1:0;
assign adder_b=(op_sub|op_slt|op_sltu)?~alu_src2:alu_src2;
assign {cout,add_sub_res}=adder_a+adder_b+cin;
assign slt_res={31'b0,alu_src1[31]^alu_src2[31]?alu_src1[31]:add_sub_res[31]};
assign sltu_res={31'b0,~cout};
assign sll_res=alu_src1<<alu_src2[4:0];
assign srl_res=alu_src1>>alu_src2[4:0];
assign sra_res=($signed(alu_src1))>>>alu_src2[4:0];
assign and_res=alu_src1&alu_src2;
assign or_res=alu_src1|alu_src2;
assign nor_res=~or_res;
assign xor_res=alu_src1^alu_src2;
assign lui_res=alu_src2;
assign Zero=(add_sub_res==32'b0)?1'b1:1'b0;
assign alu_result=({32{op_add}}&add_sub_res)|
                  ({32{op_sub}}&add_sub_res)|
                  ({32{op_slt}}&slt_res)|
                  ({32{op_sltu}}&sltu_res)|
                  ({32{op_and}}&and_res)|
                  ({32{op_nor}}&nor_res)|
                  ({32{op_or}}&or_res)|
                  ({32{op_xor}}&xor_res)|
                  ({32{op_sll}}&sll_res)|
                  ({32{op_srl}}&srl_res)|
                  ({32{op_sra}}&sra_res)|
                  ({32{op_lui}}&lui_res);
endmodule
