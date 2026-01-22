`timescale 1ns / 1ps
`include "NPC.v"
`include "3WayMux.v"
`include "4WayMux.v"
`include "HazardDetection.v"
`include "EXReg.v"
`include "MEMReg.v"
`include "WBReg.v"
`include "IDReg.v"
`include "led.v"
`include "ForwardUnit.v"
`include"ALU.v"
`include "rf.v"
`include"IG.v"
`include"DM.v"
`include"Ctrl.v"
`define WDSel_FromALU 3'b000  
`define WDSel_FromMEM 3'b001
`define WDSel_FromPC 3'b010
module sccomp(clk,rstn,sw_i,disp_seg_o,disp_an_o
    );
input clk;
input rstn;
input[15:0]sw_i;
output[7:0]disp_seg_o;
output[7:0]disp_an_o;

reg[31:0]clkdiv;

wire Clk_CPU;
always@(posedge clk or negedge rstn)begin
    if(!rstn)
        clkdiv<=32'd0;
    else
        clkdiv<=clkdiv+1'b1;
end

assign Clk_CPU=clkdiv<=(sw_i[15])?clkdiv[25]:clkdiv[25];//这里有改动
reg[63:0]LED_DATA[18:0];
reg[63:0]display_data;
parameter LED_DATA_NUM=19;
reg[5:0]led_data_addr;
reg[63:0]led_disp_data;


// 关键信号声明,这就是一些中间信号，关键是下面的实例化连接部分
wire npc_is_jump_out;
wire [31:0] npc_NPC_out;
wire [31:0] instr;
wire [31:0] idreg_instr_out;
wire [31:0] idreg_PC_out;
wire [31:0] rfs_RD1, rfs_RD2;
wire [31:0] ext_immout;
wire [31:0] exreg_instr_out, exreg_PC_out, exreg_rs1_out, exreg_rs2_out, exreg_imm_out;
wire [31:0] muxA_mux_out, muxB_mux_out;
wire [31:0] alu_alu_result;
wire [31:0] memreg_instr_out, memreg_PC_out, memreg_rs1_out, memreg_rs2_out, memreg_imm_out, memreg_alu_result_out;
wire [31:0] dm_dout;
wire [31:0] regwd_mux_out;
wire [31:0] wbreg_instr_out, wbreg_PC_out, wbreg_alu_result_out, wbreg_dm_data_out;


wire RegWrite, MemRead, MemWrite;
wire [5:0] EXTOp;
wire [11:0] ALUOp;
wire[2:0]NPCOp;
wire  ALUSrc;
wire [2:0]DMType;
wire [2:0] WDSel;
wire is_auipc, is_jump;
wire [5:0]bOp;
wire alu_Zero;
wire exreg_RegWrite_out, exreg_MemRead_out, exreg_MemWrite_out, exreg_is_auipc_out, exreg_is_jump_out;
wire [5:0]exreg_bOp_out;
wire memreg_MemRead_out, memreg_MemWrite_out, memreg_RegWrite_out, memreg_is_auipc_out, memreg_is_jump_out, memreg_Zero_out;
wire [5:0]memreg_bOp_out;
wire [2:0] memreg_WDSel_out, memreg_DMType_out, memreg_NPCOp_out;
wire wbreg_RegWrite_out;  // 保持1位
wire [2:0] wbreg_WDSel_out;
wire [2:0] exreg_WDSel_out, exreg_DMType_out, exreg_NPCOp_out;
wire exreg_ALUSrc_out;    // 保持1位
wire [31:0]muxA_rs1_out,muxB_rs2_out;

//some wire or reg for debug or display


wire [11:0]exreg_alu_op_out;
wire [4:0] ctrl_rs1, ctrl_rs2, ctrl_rd;
wire ctrl_RegWrite, ctrl_MemRead, ctrl_MemWrite;
wire [5:0] ctrl_EXTOp;
wire [11:0] ctrl_ALUOp;
wire [2:0] ctrl_NPCOp,  ctrl_DMType, ctrl_WDSel;
wire ctrl_ALUSrc;
wire ctrl_is_auipc, ctrl_is_jump;
wire [5:0] ctrl_bOp;
wire [3:0] flush;
// 寄存器声明
wire [4:0] rs1, rs2, rd;
wire [4:0] exreg_rd_out;
wire [4:0] memreg_rd_out;
wire [4:0] wbreg_rd_out;
//some wire for display and debug
wire [2:0]memreg_NPCOp_out_true=sw_i[1]?3'b011:memreg_NPCOp_out;
wire memreg_is_jump_out_true=sw_i[1]?1'b1:memreg_is_jump_out;
wire [4:0]ctrl_rs1_true=sw_i[1]?sw_i[10:6]:ctrl_rs1;
wire memreg_MemWrite_out_true=sw_i[1]?1'b0:memreg_MemWrite_out;
wire [31:0]memreg_alu_result_out_true=sw_i[1]?{3'b000,sw_i[10:3]}:memreg_alu_result_out;
//now the CPU is a stop state,but it can't continue by sw_i[1]==0,because some instruction without run,and 
//memreg's aluresult is changed

//for forward
wire   ForwardA1,ForwardA2,FowardB1,FowardB2;
wire [4:0]exreg_rs2_index_out;


wire stall;

HarzardDetection hazardDetection(.is_jump(npc_is_jump_out),
.ctrl_rs1(ctrl_rs1),.ctrl_rs2(ctrl_rs2),.exreg_rd(exreg_rd_out),
.exreg_MemRead(exreg_MemRead_out),.ctrl_is_auipc(ctrl_is_auipc),
.ctrl_MemWrite(ctrl_MemWrite),.ctrl_ALUSrc(ctrl_ALUSrc),
.stall(stall),.flush(flush)
);


//there need the jiekou
ForwardUnit forward_unit(.EX_rs1(exreg_instr_out[9:5]),.EX_rs2(exreg_rs2_index_out),
.EX_is_auipc(exreg_is_auipc_out),.EX_ALUSrc(exreg_ALUSrc_out),
.EX_MemWrite(exreg_MemWrite_out),.MEM_rd(memreg_rd_out),
.MEM_RegWr(memreg_RegWrite_out),.WB_rd(wbreg_rd_out),
.WB_RegWr(wbreg_RegWrite_out),.ForwardA1(ForwardA1),
.ForwardA2(ForwardA2),.ForwardB1(ForwardB1),.ForwardB2(ForwardB2)
);

dist_mem_gen_0 rom(.a(npc_NPC_out>>2),.spo(instr));

IDReg idreg(.clk(Clk_CPU),.rstn(rstn),.is_flush(flush[3]),.stall(stall),.instr_in(instr),
.PC_in(npc_NPC_out),.instr_out(idreg_instr_out),.PC_out(idreg_PC_out));

Ctrl ctrl(.instr(idreg_instr_out),.RegWrite(ctrl_RegWrite),.MemRead(ctrl_MemRead),.MemWrite(ctrl_MemWrite),.EXTOp(ctrl_EXTOp),.ALUOp(ctrl_ALUOp),
.NPCOp(ctrl_NPCOp),.ALUSrc(ctrl_ALUSrc),.DMType(ctrl_DMType),.WDSel(ctrl_WDSel),.is_auipc(ctrl_is_auipc),.is_jump(ctrl_is_jump),.rs1(ctrl_rs1),.rs2(ctrl_rs2),.rd(ctrl_rd),.bOp(ctrl_bOp));

RF rfs(.clk(Clk_CPU),.rstn(rstn),.RFWr(wbreg_RegWrite_out),.sw_i(sw_i),.A1(ctrl_rs1_true),.A2(ctrl_rs2),
.A3(wbreg_rd_out),.WD(regwd_mux_out),.RD1(rfs_RD1),.RD2(rfs_RD2));

EXT ext(.EXTOp(ctrl_EXTOp),.instr(idreg_instr_out),.immout(ext_immout));

EXReg exreg(.clk(Clk_CPU),.rstn(rstn),.is_flush( flush[2]) ,.instr_in(idreg_instr_out),
.PC_in(idreg_PC_out),.rs1_in(rfs_RD1),.rs2_in(rfs_RD2),.imm_in(ext_immout),.alu_op_in(ctrl_ALUOp),.rd_in(ctrl_rd),
.RegWrite_in(ctrl_RegWrite),.WDSel_in(ctrl_WDSel),.MemRead_in(ctrl_MemRead),.MemWrite_in(ctrl_MemWrite),
.DMType_in(ctrl_DMType),.is_auipc_in(ctrl_is_auipc),.ALUSrc_in(ctrl_ALUSrc),.NPCOp_in(ctrl_NPCOp),
.is_jump(ctrl_is_jump),.bOp_in(ctrl_bOp),.rs2_index_in(ctrl_rs2),.rs1_out(exreg_rs1_out),.rs2_out(exreg_rs2_out),.imm_out(exreg_imm_out),
.instr_out(exreg_instr_out),.PC_out(exreg_PC_out),.alu_op_out(exreg_alu_op_out),.rd_out(exreg_rd_out),.RegWrite_out(exreg_RegWrite_out),
.WDSel_out(exreg_WDSel_out),.MemRead_out(exreg_MemRead_out),.MemWrite_out(exreg_MemWrite_out),.DMType_out(exreg_DMType_out),
.is_auipc_out(exreg_is_auipc_out),.ALUSrc_out(exreg_ALUSrc_out),.NPCOp_out(exreg_NPCOp_out),
.is_jump_out(exreg_is_jump_out),.bOp_out(exreg_bOp_out),.rs2_index_out(exreg_rs2_index_out)
);

FourWayMux muxA(.is_rs(!exreg_is_auipc_out),.forwardEX(ForwardA1),.forwardMEM(ForwardA2),.rs_data(exreg_rs1_out),
.other_data(exreg_PC_out),.EX_alu_result(memreg_alu_result_out),.MEM_dm_data(regwd_mux_out),.mux_out(muxA_mux_out),.true_rs(muxA_rs1_out)
);
FourWayMux muxB(.is_rs(!exreg_ALUSrc_out),.forwardEX(ForwardB1),.forwardMEM(ForwardB2),.rs_data(exreg_rs2_out),
.other_data(exreg_imm_out),.EX_alu_result(memreg_alu_result_out),.MEM_dm_data(regwd_mux_out),.mux_out(muxB_mux_out),.true_rs(muxB_rs2_out)
);

ALU alu(.alu_src1(muxA_mux_out),.alu_src2(muxB_mux_out),.alu_op(exreg_alu_op_out),.alu_result(alu_alu_result),.Zero(alu_Zero));

MEMReg memreg(.clk(Clk_CPU),.rstn(rstn),.is_flush(flush[1]),.instr_in(exreg_instr_out),
.MemRead_in(exreg_MemRead_out),.MemWrite_in(exreg_MemWrite_out),.DMType_in(exreg_DMType_out),
.NPCOp_in(exreg_NPCOp_out),.is_jump(exreg_is_jump_out),.bOp_in(exreg_bOp_out),.Zero_in(alu_Zero),
.PC_in(exreg_PC_out),.rs1_in(muxA_rs1_out),.rs2_in(muxB_rs2_out),.imm_in(exreg_imm_out),.RegWrite_in(exreg_RegWrite_out),
.WDSel_in(exreg_WDSel_out),.rd_in(exreg_rd_out),.alu_result_in(alu_alu_result),.rd_out(memreg_rd_out),.RegWrite_out(memreg_RegWrite_out),
.rs1_out(memreg_rs1_out),.rs2_out(memreg_rs2_out),.imm_out(memreg_imm_out),.instr_out(memreg_instr_out),.PC_out(memreg_PC_out),
.MemRead_out(memreg_MemRead_out),.MemWrite_out(memreg_MemWrite_out),.DMType_out(memreg_DMType_out),.WDSel_out(memreg_WDSel_out),.NPCOp_out(memreg_NPCOp_out),
.is_jump_out(memreg_is_jump_out),.bOp_out(memreg_bOp_out),.Zero_out(memreg_Zero_out),.alu_result_out(memreg_alu_result_out)
);

NPC npc(.clk(Clk_CPU),.rstn(rstn),.stall(stall),.is_jump(memreg_is_jump_out_true),.bOp(memreg_bOp_out),
.Zero(memreg_Zero_out),.alu_result(memreg_alu_result_out),.NPCOp(memreg_NPCOp_out_true),.imm(memreg_imm_out),
.PC(memreg_PC_out),.is_jump_out(npc_is_jump_out),.NPC_out(npc_NPC_out));

DM dm(.clk(Clk_CPU),.DMWr(memreg_MemWrite_out_true),.rstn(rstn),.sw_i(sw_i),.addr(memreg_alu_result_out_true),.din(memreg_rs2_out),.DMType(memreg_DMType_out),.dout(dm_dout));

seg7_x16 u_seg7x16(.clk(clk),.rstn(rstn),.i_data(display_data),.disp_mode(sw_i[0]),.o_seg(disp_seg_o),.o_sel(disp_an_o));

ThreeWayMux regwd(.WDSel(wbreg_WDSel_out),.alu_data(wbreg_alu_result_out),.dm_data(wbreg_dm_data_out),.pc_data(wbreg_PC_out),.mux_out(regwd_mux_out));

WBReg wbreg(.clk(Clk_CPU),.rstn(rstn),.is_flush(flush[0]),.instr_in(memreg_instr_out),
.PC_in(memreg_PC_out),.alu_result_in(memreg_alu_result_out),.dm_data_in(dm_dout),.rd_in(memreg_rd_out),
.RegWrite_in(memreg_RegWrite_out),.WDSel_in(memreg_WDSel_out),
.instr_out(wbreg_instr_out),.PC_out(wbreg_PC_out),
.alu_result_out(wbreg_alu_result_out),.dm_data_out(wbreg_dm_data_out),
.rd_out(wbreg_rd_out),.RegWrite_out(wbreg_RegWrite_out),.WDSel_out(wbreg_WDSel_out)
);



initial begin
    clkdiv=0;
    LED_DATA[0]=64'hC6F6F6F0C6F6F6F0;
    LED_DATA[1]=64'hF9F6F6CFF9F6F6CF;
    LED_DATA[2]=64'hFFC6F0FFFFC6F0FF;
    LED_DATA[3]=64'hFFC0FFFFFFC0FFFF;
    LED_DATA[4]=	64'hFFA3FFFFFFA3FFFF;	
	LED_DATA[5]=	64'hFFFFA3FFFFFFA3FF;	
	LED_DATA[6]=	64'hFFFF9CFFFFFF9CFF;	
	LED_DATA[7]=	64'hFF9EBCFFFF9EBCFF;	
    LED_DATA[8]=	64'hFF9CFFFFFF9CFFFF;	
	LED_DATA[9]=	64'hFFC0FFFFFFC0FFFF;	
	LED_DATA[10]=	64'hFFA3FFFFFFA3FFFF;	
	LED_DATA[11]=	64'hFFA7B3FFFFA7B3FF;	
	LED_DATA[12]=	64'hFFC6F0FFFFC6F0FF;	
	LED_DATA[13]=	64'hF9F6F6CFF9F6F6CF;	
	LED_DATA[14]=	64'h9EBEBEBC9EBEBEBC;	
	LED_DATA[15]=	64'h2737373327373733;	
	LED_DATA[16]=	64'h505454EC505454EC;	
	LED_DATA[17]=	64'h744454F8744454F8;
    LED_DATA[18]=	64'h0062080000620800;
end
always@(posedge Clk_CPU or negedge rstn)begin
    if(!rstn)begin
        led_data_addr<=0;
        led_disp_data<=64'b1;
    end
    else if(sw_i[0]==1'b1)begin
        if(led_data_addr==LED_DATA_NUM)
        begin led_data_addr<=6'd0;
        led_disp_data<=64'b1;
        end 
        led_disp_data<=LED_DATA[led_data_addr];
        led_data_addr<=led_data_addr+1'b1;
    end
end
       


always@(sw_i)begin
    if(sw_i[0]==0)
    begin
    case(sw_i[14:11])
    4'b1000:display_data=instr;
    4'b0100:display_data=rfs_RD1;
    4'b0010:display_data=alu_alu_result;
    4'b0001:display_data=dm_dout;
    default:display_data=0;
    endcase end
    else begin display_data=led_disp_data;
    end
end


endmodule
