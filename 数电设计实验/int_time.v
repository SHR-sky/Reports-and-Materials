`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/21 21:31:50
// Design Name: 
// Module Name: int_time
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


module int_time(
    input one_HZ,
    input CLR_n,

    input [3:0] second_six,
    input [3:0] second_ten,
    input [3:0] minute_six,
    input [3:0] minute_ten,
    input [3:0] hour_one,
    input [3:0] hour_ten,

    output reg led_int

);


reg [3:0] real_time;


always @(posedge one_HZ, posedge CLR_n) begin
    if(CLR_n) begin led_int <= 0; real_time <= 0; end
    else if (real_time == 0 && second_six == 0 && second_ten == 0 && minute_six == 0 && minute_ten == 0) begin
        real_time <= (hour_one + hour_ten * 10) * 2 - 1;
    end
    else if(real_time) begin
        led_int = ~led_int;
        real_time <= real_time - 1;
    end
    else if (real_time == 0) begin
        led_int <= 0;
    end
end

endmodule
