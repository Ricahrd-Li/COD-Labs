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
    input RegWrite,
    input [7:0] DCU_Read_addr,
    input [4:0] ReadReg1_addr, ReadReg2_addr, WriteReg_addr, //32 regs
    input [31:0]Writedata,
    output [31:0] DCU_Read_data, Readdata1,Readdata2 
);
      reg [31:0]Reg[31:0];
      assign DCU_Read_data=Reg[DCU_Read_addr];
      assign Readdata1=Reg[ReadReg1_addr];
      assign Readdata2=Reg[ReadReg2_addr];
  
     always @(posedge clk)begin
          Reg[0]<=0;
          if(RegWrite) Reg[WriteReg_addr]<=Writedata;    
      end
      
endmodule
