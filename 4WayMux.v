`timescale 1ns / 1ps
module FourWayMux(
    input is_rs,
    input forwardEX,
    input forwardMEM,
    input [31:0] rs_data,   
    input [31:0] other_data,//when rs1,that is PC,and when rs2,that is imm
    input [31:0] EX_alu_result,
    input [31:0] MEM_dm_data,
    output[31:0]true_rs,
    output [31:0]   mux_out
);
wire [31:0]true_rs_wire=forwardEX ? EX_alu_result : (forwardMEM ? MEM_dm_data : rs_data);
assign true_rs=true_rs_wire;
assign mux_out = is_rs?true_rs_wire:other_data;
endmodule
//rs1,and rs2 data need to be true!!