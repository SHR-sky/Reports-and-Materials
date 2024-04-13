module Dram(
    input clk,
    input wb,
    input [4:0] addr,
    input [1:0] lb,
    input [31:0] WriteData,
    input MemWr,

    output reg [31:0] ReadData

);
    //数据存储器输出
    reg [31:0] regs[0:31];  //32个32位的寄存器
    always @(addr)begin
       if(wb)begin
            case (lb[1:0])
                2'b00:
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][7:0]}; // LB 3:0
                    else if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][7:0]}; // LB 3:0
                end
                2'b01: 
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][15:8]}; // LB 7:4
                    else if (regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][15:8]}; // LB 7:4
                end
                2'b10: 
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][23:16]}; // LB 11:8
                    else if (regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][23:16]}; // LB 11:8
                end
                2'b11: 
                begin
                    if(regs[addr[6:2]][7] == 1)
                        ReadData <= {24'hffffff, regs[addr[6:2]][31:24]}; // LB 15:12
                    else if (regs[addr[6:2]][7] == 1)
                        ReadData <= {24'b0, regs[addr[6:2]][31:24]}; // LB 15:12
                end
            endcase
       end
       else begin
            ReadData = regs[addr];
       end
    end

    //数据存储器写入
    always @(negedge clk) begin
        if(MemWr) regs[addr] = WriteData;
    end

    //数据存储器初始化
    integer i;
    initial begin
        for(i=0;i<32;i=i+1) begin
            regs[i] = i*4;
        end
    end
endmodule