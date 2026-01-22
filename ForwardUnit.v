`timescale 1ns / 1ps
module ForwardUnit(
    input [4:0] EX_rs1,
    input [4:0] EX_rs2,
    input EX_is_auipc,
    input EX_ALUSrc,
    input EX_MemWrite,
    input [4:0] MEM_rd,
    input MEM_RegWr,
    input [4:0] WB_rd,
    input WB_RegWr,
    output   ForwardA1,
    output   ForwardA2,
    output   ForwardB1,
    output   ForwardB2
    );
wire isReadRs2=(~EX_ALUSrc|EX_MemWrite)&(EX_rs2!=5'b0);
wire isReadRs1=~EX_is_auipc&(EX_rs1!=5'b0);
assign ForwardA1= (isReadRs1 & MEM_RegWr & (EX_rs1==MEM_rd))?1'b1:1'b0;
assign ForwardA2= (isReadRs1 & WB_RegWr & (EX_rs1==WB_rd))?1'b1:1'b0;
assign ForwardB1= (isReadRs2 & MEM_RegWr & (EX_rs2==MEM_rd))?1'b1:1'b0;
assign ForwardB2= (isReadRs2 & WB_RegWr & (EX_rs2==WB_rd))?1'b1:1'b0;
endmodule