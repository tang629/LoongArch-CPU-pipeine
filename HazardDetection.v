`timescale 1ns / 1ps
module HarzardDetection(
input is_jump,
input [4:0] ctrl_rs1,
input [4:0] ctrl_rs2,
input [4:0]exreg_rd,
input exreg_MemRead,
input ctrl_is_auipc,
input ctrl_MemWrite,
input ctrl_ALUSrc,
output stall,
output [3:0] flush
);
wire isReadRs1=(ctrl_rs1!=5'b0)&(~ctrl_is_auipc);
wire isReadRs2=(ctrl_rs2!=5'b0)&(~ctrl_ALUSrc|ctrl_MemWrite);
wire is_stall=exreg_MemRead&((isReadRs1&(ctrl_rs1==exreg_rd))|(isReadRs2&(ctrl_rs2==exreg_rd)));
assign stall=is_stall;
assign flush=is_jump?4'b1110:{1'b0,is_stall,2'b00};
endmodule
//there is a stange logic ,when is_jump is 1 ,the stall will be 0!
//the ex stage instruction will be flushed when ld make the hazard