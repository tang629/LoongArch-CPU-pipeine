`timescale 1ns / 1ps
`define Z12To32 6b'000001
`define S12To32 6b'000010
`define S16To32 6b'000100
`define S26To32 6b'001000
`define F20To32 6b'010000
`define Z5To32 6b'100000
module EXT( 
input [5:0]	 EXTOp,
input[31:0]instr,
output [31:0] 	immout
);
wire[31:0] Z12To32Result;
wire[31:0] S12To32Result;
wire[31:0] S16To32Result;
wire[31:0] S26To32Result;
wire[31:0] F20To32Result;
wire[31:0] Z5To32Result;
assign Z12To32Result = {20'b0,instr[21:10]};
assign S12To32Result = {{20{instr[21]}},instr[21:10]};
assign S16To32Result = {{14{instr[15]}},instr[25:10],2'b00};
assign S26To32Result = {{4{instr[25]}},instr[9:0],instr[25:10],2'b00};
assign F20To32Result=	{instr[24:5],12'b0};
assign Z5To32Result={27'b0,instr[14:10]};
assign immout=({32{EXTOp[0]}}&Z12To32Result)|
			   ({32{EXTOp[1]}}&S12To32Result)|
			   ({32{EXTOp[2]}}&S16To32Result)|
			   ({32{EXTOp[3]}}&S26To32Result)|
			   ({32{EXTOp[4]}}&F20To32Result)|
			   ({32{EXTOp[5]}}&Z5To32Result);
endmodule