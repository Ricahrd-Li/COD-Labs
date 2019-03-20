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
    
    reg  clk;
    reg[5:0] a;
    reg[5:0]b;
    reg[2:0] s;
    wire [5:0]result;
    wire [1:0]f;
    integer k;
    
    ALU test(clk,s,a,b,f,result);
    //ADD test(clk,a,b,result);
    
    initial 
    begin
      clk=0;
      a=6'b000_000;
      b=6'b000_000;
      s=3'b000;
      
      for(k=0;k<200;k = k+1) begin
        #5 clk=~clk;
        if(clk==1'b0)begin
            a=a+6'b000_010;
            b=b-6'b000_001;
        end
        if(k==70)s=3'b001;
        else if(k==100)s=3'b010;
        else if(k==130)s=3'b011;
        else if(k==150)s=3'b100;
        else if(k==170)s=3'b101;
      end
    end
endmodule
