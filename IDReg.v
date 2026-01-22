`timescale 1ns / 1ps
module IDReg(
input clk,
input rstn,
input stall,
input is_flush,
input [31:0] instr_in,
input [31:0]PC_in,
output reg [31:0] instr_out,
output reg [31:0] PC_out
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        instr_out <= 32'b0;
        PC_out <= 32'b0;
    end else if (is_flush) begin
        instr_out <= 32'b0;
        PC_out <= 32'b0;
    end else if (stall) begin
        instr_out <= instr_out;
        PC_out <= PC_out;
    end else begin
        instr_out <= instr_in;
        PC_out <= PC_in;
    end
end
endmodule