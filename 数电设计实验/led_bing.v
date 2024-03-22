`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/21 21:31:03
// Design Name: 
// Module Name: led_bing
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


module led_bing(
    input CLR_n,
    input bing,
    input botton,
    input one_HZ,

    output reg led_alarm

);


reg flag;

always @(posedge one_HZ, posedge bing, posedge botton, posedge CLR_n) begin
    if(CLR_n) begin led_alarm <= 0; flag <= 0; end 
    else if (botton) begin led_alarm <= 0; flag <= 0; end
    else if(bing) begin 
        flag <= 1;
    end
    else if(flag) begin 
        led_alarm <= ~led_alarm;        
    end
end

endmodule
