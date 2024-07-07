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

    assign PsudeoPC = {instr[25:0],2'b00};  //j指令，将低26位补00
    assign JumpPC = {SequencePC[31:28],PsudeoPC};   //用PC指针前四位补全
    assign SequencePC = PC + 4; //加4,保证程序计数器（PC总指着下一条指令）
    assign BranchPC = ImmL2 + SequencePC;   //得到偏移后的地址
    assign MuxPC = BranchZ ? BranchPC : SequencePC; //分支条件选指针（sw/lw 或者 +4）
    assign TempPC = jump ? JumpPC : MuxPC;  //下一个PC是分支跳转还是j指令

    assign BranchZ = branch & zero; //控制分支
    assign ImmL2 = {Imm32[29:0],2'b00}; //乘4，字节地址
    assign Imm32 = {instr[15] ? 16'hffff : 16'h0 , instr[15:0]};    //符号扩展，将偏移量变为偏移地址
    assign ALUIn = ALUSrc ? Imm32 : RtData; //选择源寄存器还是立即数参与运算
    assign WriteAddr = jump ? 5'b1_1111:RegDst ? instr[15:11] : instr[20:16];   //如果不是j指令，那么赋寄存器的地址
    assign WriteData = jump ? PC + 4 : Mem2Reg ? MemReadData : ALUResult;   //如果是j指令，那么把PC加4,执行下一条指令;非j指令情况下，决定是从rom中读取还是ALU计算得到
    
    //指令存储器
    irom U1(clk,PC[6:2],instr);

    //译码
    Decoder U2(.Op(instr[31:26]),.ALUOp(ALUOp),.RegDst(RegDst),.RegWr(RegWr),.ALUSrc(ALUSrc),.MemWr(MemWr),.jump(jump),.branch(branch),.Mem2Reg(Mem2Reg),.wb(wb));
    ALUCtrler U3(.ALUOp(ALUOp),.func((ALUSrc && instr[31:26] == 6'b00_1101)?6'bxx_0101:instr[5:0]),.ALUCtrl(ALUCtrl));
    
    //寄存器文件
    regfile U4(.clk(clk),.rst(rst),.RegWr(RegWr),.WriteData(WriteData),.RsAddr(instr[25:21]),.RtAddr(instr[20:16]),.WriteAddr(WriteAddr),.RsData(RsData),.RtData(RtData));
    
    //ALU操作
    ALU U5(.inputA(RsData),.inputB(ALUIn),.ALUCtrl(ALUCtrl),.ALUResult(ALUResult),.zero(zero));
    
    //数据存储器
    Dram U6(.clk(clk),.wb(wb),.addr(ALUResult[6:2]),.lb(ALUResult[1:0]),.WriteData(RtData),.MemWr(MemWr),.ReadData(MemReadData));
    
    always @(negedge clk or negedge rst) begin
        // 初始化指针
        if (!rst) PC <= 0;
        // clk下降沿改变PC指针
        else if (instr[25:21] == 5'b1_1111) PC <= RsData;
        else PC <= TempPC;
    end

endmodule