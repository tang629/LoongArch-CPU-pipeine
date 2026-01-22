`timescale 1ns / 1ps
module NPC(
input clk,
input rstn,
input stall,
input is_jump,
input [5:0]bOp,
input Zero,
input [31:0]alu_result,
input [2:0]NPCOp,
input [31:0]imm,
input [31:0]PC,
output is_jump_out,
output reg [31:0]NPC_out
);
 wire is_branch;
    assign is_branch=is_jump|(bOp[0]&Zero)|(bOp[1]&(~Zero))|(bOp[2]&alu_result[0])|(bOp[3]&(~alu_result[0]))|(bOp[4]&(alu_result[0]))|(bOp[5]&~alu_result[0]);
    wire[2:0] true_NPCOp=NPCOp&{3{is_branch}};
    assign is_jump_out=is_branch; 
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        NPC_out <= 32'h64;
    end else if (stall&~is_branch) begin
        NPC_out <= NPC_out;
    end
    else begin
    case (true_NPCOp)   
        3'b000: NPC_out <= NPC_out + 4;                     //PC+4
        3'b001: NPC_out <= PC+imm;                  //branch target address
        3'b010: NPC_out <= alu_result; 
        3'b011: NPC_out <= NPC_out;                  //jump target address       //jal target address
        default: NPC_out <= NPC_out + 4;
    endcase
    end
//00的话，PC+4
end
endmodule