`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 22:10:53
// Design Name: 
// Module Name: RegFile
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
module RegFile(
    input clk,
    input [4:0] ReadReg1_addr, ReadReg2_addr, WriteReg_addr, //32 regs
    input [31:0]Writedata,
    output [31:0] Readdata1,Readdata2 
);
endmodule
