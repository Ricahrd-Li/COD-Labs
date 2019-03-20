`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/20 08:41:11
// Design Name: 
// Module Name: ALU_tb
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

module ALU_tb(
    );
    reg clk,rst;
    reg [5:0] r0,r1;
    wire[5:0]result;
    integer k;
    
    Fib test(clk,rst,r0,r1,result);
    //ADD test(clk,a,b,result);
    
    initial 
    begin
      clk=0;
      r0=6'b000_000;
      r1=6'b000_001;
      rst=0;
      
      for(k=0;k<200;k = k+1) begin
        #5 clk=~clk;
        if(k==50)rst=1'b1;
        else rst=1'b0;
      end
    end
endmodule
