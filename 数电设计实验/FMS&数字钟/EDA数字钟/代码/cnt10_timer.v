`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/20 19:08:49
// Design Name: 
// Module Name: cnt10_timer
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


module cnt10_timer (
    input one_HZ,
    input CLR_n,
    input isSetting,
    output reg [3:0] second_ten,
    output reg bit10
);


always @(posedge one_HZ or posedge CLR_n or posedge isSetting) begin
    if (CLR_n) begin 
        bit10 <= 0; 
        second_ten <= 0; 
    end
    else if (isSetting) begin 
        second_ten <= 0;
        bit10 <= 0; 
    end
    else if (second_ten == 4'd9) begin
        second_ten <= 0;
        bit10 <= 1;
    end
    else begin
        second_ten <= second_ten + 1;
        bit10 <= 0; 
    end
end

endmodule
