`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/20 08:34:22
// Design Name: 
// Module Name: ALU
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

//This is an ALU
module ALU(
    input clk, 
    input [2:0]s,
    input [5:0]a,
    input [5:0]b,
    output reg[1:0]f,
    output reg[5:0]result
);
//s: 000--add, 001--sub, 010--and, 011--or, 100--not, 101--xor
//N-Normal,O-Overflow/Carry,B=Borrow, Z=Zero
parameter N=2'b00; 
parameter OC=2'b01;
parameter B=2'b10;
parameter Z=2'b11;

reg[6:0]tmpr; //temp_result

always @(posedge clk) begin
    case (s)  
    //add
      3'b000: begin
        tmpr={1'b0,a}+{1'b0,b};
        //deal with f
        if(tmpr[6]==1'b1) f<=OC;
        else if(tmpr==7'b000_0000) f=Z;
        else f=N;
        result=tmpr[5:0];
      end
    //sub
      3'b001: begin
        tmpr={1'b1,a};
        tmpr=tmpr-{1'b0,b};
        //deal with f
        if(tmpr[6]==1'b0) f= B;
        else if(tmpr==7'b000_0000) f=Z;
        else f=N;
        result=tmpr[5:0];
      end
    //and  
       3'b010: begin
        result=a&b;
        if(result==6'b000_0000) f=Z;
        else f=N;
       end
    //or 
       3'b011: begin
        result=a|b;
        if(result==6'b000_0000) f=Z;
        else f=N;
       end
    //not 
       3'b100: begin
        result=~a;
        if(result==6'b000_0000) f=Z;
        else f=N;
       end
    //xor 
      default: begin
        result=a^b;
        if(result==6'b000_0000) f=Z;
        else f=N;
       end
    endcase
end

endmodule 

module Fib(
  input clk,
  input rst,
  input [5:0]f0,
  input [5:0]f1,
  output reg[5:0]fn
);
  reg[5:0] r0,r1,tmpr;
  wire[5:0]sum;
  wire[2:0]s;
  
  assign s=3'b000;
  
  initial begin   //initial 没有执行？？？
    r0=f0;
    r1=f1;
  end  
  
  ALU add(clk,s,r0,r1,,sum);
  
  always @(posedge clk,posedge rst) begin
    if(rst) begin
      r0=f0;
      r1=f1;
    end
    else begin
      tmpr=sum; // OK了
      r0=r1;
      r1=tmpr;
      fn=tmpr;
    end
  end

endmodule


