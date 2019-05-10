`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 22:13:51
// Design Name: 
// Module Name: IR_Reg
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
module Instruction_Reg(  
    input clk,
    input IRWrite,  //signal
    input [31:0]MemData,
    output [5:0]ins31_26, // opcode
    output [4:0]ins25_21, //
    output [4:0]ins20_16,
    output [15:0]ins15_0
    );
    reg [31:0]ins;  //instruction;
    assign ins31_26=ins[31:26];
    assign ins25_21=ins[25:21];
    assign ins20_16=ins[20:16];
    assign ins15_0=ins[15:0];
    
    always @(posedge clk) begin
        if(IRWrite) ins<=MemData;
    end
    
endmodule
