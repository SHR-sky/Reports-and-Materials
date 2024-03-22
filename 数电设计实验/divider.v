`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:07:46
// Design Name: 
// Module Name: divider
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


module divider(
    input CP,
    input CLR_n,
    output one_HZ,
    output five_hundred_HZ
);


//分频模块
reg [17:0] cnt_500;
reg [15:0] cnt_1;
reg CP_out_500;
reg CP_out_1;

always @(posedge CP, posedge CLR_n) begin
    if (CLR_n) CP_out_500 <=0;
    else if(cnt_500 == 18'd50000 - 18'd1)    //0.1MHZ分频，得到1000HZ信号
        begin
            CP_out_500 <= ~CP_out_500;
            cnt_500 <= 0;
        end
     else begin
            cnt_500 <= cnt_500 + 1;
            CP_out_500 <= CP_out_500;
     end
 end


always @(posedge CP_out_500, posedge CLR_n) begin
    if (CLR_n) CP_out_1<=0;
    else if(cnt_1 == 16'd500 - 16'd1)    //1000HZ分频，得到1HZ信号
        begin
            CP_out_1 <= ~CP_out_1;
            cnt_1 <= 0;
        end
        else
        begin
            cnt_1 <= cnt_1 + 1;
            CP_out_1 <= CP_out_1;
        end
    end


assign one_HZ = CP_out_1;
assign five_hundred_HZ = CP_out_500;

endmodule
