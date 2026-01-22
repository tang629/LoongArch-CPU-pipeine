`timescale 1ns / 1ps


    // ��ʼ���Ĵ�������
   

    // ʱ���߼�
`define OPCODE_JIRL   6'b010011  // JIRL跳转指令
`define OPCODE_B      6'b010100  // B无条件分支指令
`define OPCODE_BL     6'b010101  // BL带链接无条件分支指令
`define OPCODE_BEQ    6'b010110  // BEQ条件分支指令
`define OPCODE_BNE    6'b010111  // BNE条件分支指令
`define OPCODE_BLT    6'b011000  // BLT条件分支指令
`define OPCODE_BGE    6'b011001  // BGE条件分支指令
`define OPCODE_BLTU   6'b011010  // BLTU条件分支指令
`define OPCODE_BGEU   6'b011011  // BGEU条件分支指令
`define OPCODE_LUI  7'b0001010
`define OPCODE_PCADDU12I  7'b0001110
`define ADDW  5'b00000
`define SUBW  5'b00010
`define SLT   5'b00100
`define SLTU  5'b00101
`define NOR   5'b01000
`define AND   5'b01001
`define OR    5'b01010
`define XOR   5'b01011
`define SLL_W 5'b01110
`define SRL_W 5'b01111
`define SRA_W 5'b10000

module Ctrl( 
input  [31:0] instr,
output RegWrite, // control signal for register write
output MemWrite, 
output MemRead, // control signal for memory write
output	[5:0]EXTOp,    // control signal to signed extension
output [11:0] ALUOp,    // ALU opertion
output [2:0] NPCOp,//output [2:0] NPCOp,    // next pc operation
output ALUSrc,  // ALU source for b
output [2:0] DMType, //dm r/w type
output[2:0] WDSel,  // (register) write data selection  (MemtoReg)
output is_auipc,
output is_jump,
output[5:0]bOp,
output[5:0]rs1,rs2,rd
); 

//no processing Zero ,if you want beq,that is important

wire itype=(instr[31:25]==7'b0000001);
wire slti=(instr[24:22]==3'b000)&itype;
wire sltui=(instr[24:22]==3'b001)&itype;
wire addi=(instr[24:22]==3'b010)&itype;
wire ori=(instr[24:22]==3'b110)&itype;
wire andi=(instr[24:22]==3'b101)&itype;
wire xori=(instr[24:22]==3'b111)&itype;


wire ltype=(instr[31:26]==6'b001010)&(~instr[24]);
wire lbu=(instr[25:22]==4'b1000)&ltype;
wire lhu=(instr[25:22]==4'b1001)&ltype;
wire lb=(instr[25:22]==4'b0000)&ltype;  
wire lh=(instr[25:22]==4'b0001)&ltype;
wire lw=(instr[25:22]==4'b0010)&ltype;

wire stype=(instr[31:26]==6'b001010)&(instr[24]);
wire sb=(instr[24:22]==3'b100)&stype;
wire sh=(instr[24:22]==3'b101)&stype;
wire sw=(instr[24:22]==3'b110)&stype;


wire shifttype=(instr[31:25]==0)&instr[22];
wire slli=shifttype & (instr[19:18]==2'b00);
wire srli=shifttype & (instr[19:18]==2'b01);
wire srai=shifttype & (instr[19:18]==2'b10);


wire jirl  = (instr[31:26] == `OPCODE_JIRL);
wire b     = (instr[31:26] == `OPCODE_B);
wire bl    = (instr[31:26] == `OPCODE_BL);
wire beq   = (instr[31:26] == `OPCODE_BEQ);
wire bne   = (instr[31:26] == `OPCODE_BNE);
wire blt   = (instr[31:26] == `OPCODE_BLT);
wire bge   = (instr[31:26] == `OPCODE_BGE);
wire bltu  = (instr[31:26] == `OPCODE_BLTU);
wire bgeu  = (instr[31:26] == `OPCODE_BGEU);

assign bOp[0]=beq;
assign bOp[1]=bne;
assign bOp[2]=blt;
assign bOp[3]=bge;
assign bOp[4]=bltu;
assign bOp[5]=bgeu;

wire lui=instr[31:25]==`OPCODE_LUI;
wire pcaddu=instr[31:25]==`OPCODE_PCADDU12I;

wire rtype=(instr[31:25]==0)&~instr[22];
wire addr=(instr[19:15]==5'b00000)&rtype;
wire subr=(instr[19:15]==5'b00010)&rtype;
wire sltr=(instr[19:15]==5'b00100)&rtype;
wire sltur=(instr[19:15]==5'b00101)&rtype;
wire norr=(instr[19:15]==5'b01000)&rtype;
wire orr=(instr[19:15]==5'b01010)&rtype;
wire andr=(instr[19:15]==5'b01001)&rtype;
wire xorr=(instr[19:15]==5'b01011)&rtype;
wire sllr=(instr[19:15]==5'b01110)&rtype;
wire srlr=(instr[19:15]==5'b01111)&rtype;
wire srar=(instr[19:15]==5'b10000)&rtype;

wire btype=beq|bne|blt|bge|bltu|bgeu;
wire i5type=shifttype;
wire i12type=itype&ltype&stype;
wire i26type=b|bl;
wire i16type=btype|jirl;
wire i20type=lui|pcaddu;
  assign MemRead= ltype;              // memory read
  assign RegWrite   = rtype | itype|ltype|shifttype|bl|jirl|lui|pcaddu ; // register write
  assign MemWrite   = stype;              // memory 
  assign ALUSrc     = itype | stype | ltype|jirl|pcaddu|lui|shifttype|b|bl;//pcaddu no alu!!
   // ALU B is from instruction immediate
//mem2reg=wdsel ,WDSel_FromALU 2'b00  WDSel_FromMEM 2'b01
  assign WDSel[0] = ltype;   
  assign WDSel[1] = jirl|bl;    
  assign WDSel[2]=0;
  //defalut register!??

//ALUOp_nop 5'b00000
//ALUOp_lui 5'b00001
//ALUOp_auipc 5'b00010
//ALUOp_add 5'b00011
//ALUOp_sub 5'b00100
`define ALUOp_sll 5'b01010
`define ALUOp_srl 5'b01011
`define ALUOp_sra 5'b01100


// assign op_add = alu_op[0];
// assign op_sub = alu_op[1];
// assign op_slt = alu_op[2]; 
// assign op_sltu = alu_op[3];
// assign op_and = alu_op[4];
// assign op_nor = alu_op[5];
// assign op_or  = alu_op[6];
// assign op_xor = alu_op[7];
// assign op_sll = alu_op[8];
// assign op_srl = alu_op[9];
// assign op_sra = alu_op[10];
// assign op_lui = alu_op[11];
  assign ALUOp[0]= addi|addr|ltype|stype|jirl|pcaddu;
  assign ALUOp[1]= subr|beq|bne;//add addtional Zero bit
  assign ALUOp[2]= slti|sltr|blt|bge;
  assign ALUOp[3]= sltui|sltur|bltu|bgeu;
  assign ALUOp[4]= andi|andr;
  assign ALUOp[5]= norr;
  assign ALUOp[6]= ori|orr;
  assign ALUOp[7]= xori|xorr;
  assign ALUOp[8]= slli|sllr;
  assign ALUOp[9]= srli|srlr;
  assign ALUOp[10]= srai|srar;
  assign ALUOp[11]= lui;
// `define Z12To32 6b'000001
// `define S12To32 6b'000010
// `define S16To32 6b'000100
// `define S26To32 6b'001000
// `define F20To32 6b'010000
// `define Z5To32 6b'100000
assign EXTOp[0] =  andi|ori|xori;
assign EXTOp[1] =  slti|sltui|addi|lbu|lhu|lb|lh|lw|sb|sh|sw; 
assign EXTOp[2]=i16type;
assign EXTOp[3]=i26type;
assign EXTOp[4]=lui|pcaddu;
assign EXTOp[5]=i5type;
// dm_word 3'b000
//dm_halfword 3'b001
//dm_halfword_unsigned 3'b010
//dm_byte 3'b011
//dm_byte_unsigned 3'b100
assign DMType[2]=lbu;
assign DMType[1]=lb | sb | lhu;
assign DMType[0]=lh | sh | lb | sb;

assign is_auipc=pcaddu|lui|b|bl;//there the is_auipc is for judge whether rs1 is valid,so lui use nothing

assign is_jump=jirl|i26type;
// wire is_jump=(beq&Zero)|(bne&(~Zero))|(blt&alu_result)|(bge&(~alu_result))|(bltu&(alu_result))|(bgeu&~alu_result);
//00的话，PC+4
//01的话，PC+IG<<1
//10的话，选取ALU的结果
assign NPCOp[0]=btype|i26type;
assign NPCOp[1]=jirl;
assign NPCOp[2]=0;
assign rs1=instr[9:5];
assign rd=bl?5'b00001:instr[4:0];
assign rs2=instr[30]|stype?instr[4:0]:instr[14:10];
endmodule