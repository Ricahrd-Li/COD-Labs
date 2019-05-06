`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 22:14:50
// Design Name: 
// Module Name: Memory
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
module Memory(
    input clk,
    input MemWrite,  //write signal
    input MemRead, //Read_signal
    input [7:0]addr,
    input Writedata,   
    output reg [31:0]MemData
);
    reg [31:0]mem[255:0];
    
    always @(posedge clk)begin
        if(MemRead) MemData<=mem[addr];
        if(MemWrite) mem[addr]<=Writedata;
    end
endmodule
