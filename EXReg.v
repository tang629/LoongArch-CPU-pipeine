`timescale 1ns / 1ps
module EXReg(
input clk,
input rstn,        
input is_flush,
input [31:0]instr_in,
input [31:0]PC_in,
input [31:0]rs1_in,
input [31:0]rs2_in,
input [31:0]imm_in, 
input [11:0]alu_op_in,
input [4:0] rd_in,
input RegWrite_in,
input[2:0] WDSel_in,
input MemRead_in,
input MemWrite_in,
input [2:0]DMType_in,
input is_auipc_in,
input ALUSrc_in,
input [2:0]NPCOp_in,
input is_jump,
input [5:0]bOp_in,
input [4:0]rs2_index_in,
output reg [31:0]rs1_out,
output reg [31:0]rs2_out,       
output reg [31:0]imm_out,
output reg [31:0]instr_out,
output reg [31:0]PC_out,
output reg [11:0]alu_op_out,
output reg [4:0] rd_out,
output reg RegWrite_out,
output reg MemRead_out,
output reg MemWrite_out,
output reg [2:0]DMType_out,
output reg is_auipc_out,
output reg [2:0]WDSel_out,
output reg ALUSrc_out,
output reg [2:0]NPCOp_out,
output reg is_jump_out,
output reg [5:0]bOp_out,
output reg [4:0]rs2_index_out
);
always@(posedge clk or negedge rstn)begin
    if(!rstn)begin
        instr_out<=32'b0;
        PC_out<=32'b0;
        rs1_out<=32'b0;
        rs2_out<=32'b0;
        imm_out<=32'b0;
        alu_op_out<=12'b0;
        rd_out<=5'b0;
        RegWrite_out<=1'b0;
        MemRead_out<=1'b0;
        MemWrite_out<=1'b0;
        DMType_out<=3'b0;
        is_auipc_out<=1'b0;
        WDSel_out<=3'b0;
        ALUSrc_out<=1'b0;
        NPCOp_out<=3'b0;
        is_jump_out<=1'b0;
        bOp_out<=6'b0;
        rs2_index_out<=5'b0;
    end
    else if(is_flush)begin
        instr_out<=32'b0;
        PC_out<=32'b0;
        rs1_out<=32'b0;
        rs2_out<=32'b0;
        imm_out<=32'b0;
        alu_op_out<=12'b0;
        rd_out<=5'b0;
        RegWrite_out<=1'b0;
        MemRead_out<=1'b0;
        MemWrite_out<=1'b0;
        DMType_out<=3'b0;
        is_auipc_out<=1'b0;
        WDSel_out<=3'b0;
        ALUSrc_out<=1'b0;
        NPCOp_out<=3'b0;
        is_jump_out<=1'b0;
        bOp_out<=6'b0;
        rs2_index_out<=5'b0;
    end
    else begin
        instr_out<=instr_in;
        PC_out<=PC_in;
        rs1_out<=rs1_in;
        rs2_out<=rs2_in;
        imm_out<=imm_in;
        alu_op_out<=alu_op_in;
        rd_out<=rd_in;
        RegWrite_out<=RegWrite_in;
       
        MemRead_out<=MemRead_in;
        MemWrite_out<=MemWrite_in;
        DMType_out<=DMType_in;
        is_auipc_out<=is_auipc_in;
        WDSel_out<=WDSel_in;
        ALUSrc_out<=ALUSrc_in;
        NPCOp_out<=NPCOp_in;
        is_jump_out<=is_jump;
        bOp_out<=bOp_in;    
        rs2_index_out<=rs2_index_in;
end
end
endmodule