`timescale 1ns / 1ps
module WBReg(
input clk,
input rstn,
input is_flush,
input [31:0]instr_in,
input [31:0]PC_in,
input [31:0]alu_result_in,
input [31:0]dm_data_in,
input [4:0] rd_in,
input RegWrite_in,
input[2:0] WDSel_in,
output reg [31:0]instr_out,
output reg [31:0]PC_out,
output reg [31:0]alu_result_out,
output reg [31:0]dm_data_out,
output reg [4:0] rd_out,
output reg RegWrite_out,
output reg [2:0] WDSel_out
);
always@(posedge clk or negedge rstn)begin
    if(!rstn)begin
        instr_out<=32'b0;
        PC_out<=32'b0;
        alu_result_out<=32'b0;
        dm_data_out<=32'b0;
        rd_out<=5'b0;
        RegWrite_out<=1'b0;
        WDSel_out<=3'b0;
    end else if (is_flush) begin
        instr_out<=32'b0;
        PC_out<=32'b0;
        alu_result_out<=32'b0;
        dm_data_out<=32'b0;
        rd_out<=5'b0;
        RegWrite_out<=1'b0;
        WDSel_out<=3'b0;
    end else begin
        instr_out<=instr_in;
        PC_out<=PC_in;
        alu_result_out<=alu_result_in;
        dm_data_out<=dm_data_in;
        rd_out<=rd_in;
        RegWrite_out<=RegWrite_in;
        WDSel_out<=WDSel_in;
    end
end
endmodule