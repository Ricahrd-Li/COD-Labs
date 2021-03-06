`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 22:26:23
// Design Name: 
// Module Name: PC
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
module PC(
    input clk,
    input we,rst,
    input [31:0]pc_in,
    output reg [31:0]pc  
    );
    always @(posedge clk,posedge rst)begin
        if(rst) pc<=0;
        else if(we) pc<=pc_in;
    end
    
endmodule
