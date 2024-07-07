`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/06 20:41:41
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
    input clk,
    input rst
);




    wire [31:0] TempPC,RsData,RtData,ALUIn,ALUResult,MemReadData,instr,WriteData,JumpPC,SequencePC,BranchPC;
    wire [31:0] Imm32,ImmL2,MuxPC;
    wire [27:0] PsudeoPC;
    wire [4:0] WriteAddr;
    wire [1:0] ALUOp;
    wire [3:0] ALUCtrl;

    wire zero,MemWr,RegWr,RegDst,ALUSrc,jump,branch,Mem2Reg,BranchZ;
    
    wire wb;
    
    reg [31:0] PC;

    assign PsudeoPC = {instr[25:0],2'b00};  //jָ�����26λ��00
    assign JumpPC = {SequencePC[31:28],PsudeoPC};   //��PCָ��ǰ��λ��ȫ
    assign SequencePC = PC + 4; //��4,��֤�����������PC��ָ����һ��ָ�
    assign BranchPC = ImmL2 + SequencePC;   //�õ�ƫ�ƺ�ĵ�ַ
    assign MuxPC = BranchZ ? BranchPC : SequencePC; //��֧����ѡָ�루sw/lw ���� +4��
    assign TempPC = jump ? JumpPC : MuxPC;  //��һ��PC�Ƿ�֧��ת����jָ��

    assign BranchZ = branch & zero; //���Ʒ�֧
    assign ImmL2 = {Imm32[29:0],2'b00}; //��4���ֽڵ�ַ
    assign Imm32 = {instr[15] ? 16'hffff : 16'h0 , instr[15:0]};    //������չ����ƫ������Ϊƫ�Ƶ�ַ
    assign ALUIn = ALUSrc ? Imm32 : RtData; //ѡ��Դ�Ĵ���������������������
    assign WriteAddr = jump ? 5'b1_1111:RegDst ? instr[15:11] : instr[20:16];   //�������jָ���ô���Ĵ����ĵ�ַ
    assign WriteData = jump ? PC + 4 : Mem2Reg ? MemReadData : ALUResult;   //�����jָ���ô��PC��4,ִ����һ��ָ��;��jָ������£������Ǵ�rom�ж�ȡ����ALU����õ�
    
    //ָ��洢��
    irom U1(clk,PC[6:2],instr);

    //����
    Decoder U2(.Op(instr[31:26]),.ALUOp(ALUOp),.RegDst(RegDst),.RegWr(RegWr),.ALUSrc(ALUSrc),.MemWr(MemWr),.jump(jump),.branch(branch),.Mem2Reg(Mem2Reg),.wb(wb));
    ALUCtrler U3(.ALUOp(ALUOp),.func((ALUSrc && instr[31:26] == 6'b00_1101)?6'bxx_0101:instr[5:0]),.ALUCtrl(ALUCtrl));
    
    //�Ĵ����ļ�
    regfile U4(.clk(clk),.rst(rst),.RegWr(RegWr),.WriteData(WriteData),.RsAddr(instr[25:21]),.RtAddr(instr[20:16]),.WriteAddr(WriteAddr),.RsData(RsData),.RtData(RtData));
    
    //ALU����
    ALU U5(.inputA(RsData),.inputB(ALUIn),.ALUCtrl(ALUCtrl),.ALUResult(ALUResult),.zero(zero));
    
    //���ݴ洢��
    Dram U6(.clk(clk),.wb(wb),.addr(ALUResult[6:2]),.lb(ALUResult[1:0]),.WriteData(RtData),.MemWr(MemWr),.ReadData(MemReadData));
    
    always @(negedge clk or negedge rst) begin
        // ��ʼ��ָ��
        if (!rst) PC <= 0;
        // clk�½��ظı�PCָ��
        else if (instr[25:21] == 5'b1_1111) PC <= RsData;
        else PC <= TempPC;
    end

endmodule