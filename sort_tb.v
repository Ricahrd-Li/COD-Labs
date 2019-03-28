`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/28 08:29:44
// Design Name: 
// Module Name: sort_tb
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


module sort_tb(
    );
    reg clk,rst;
    reg[3:0]x0,x1,x2,x3;
    integer k;
    wire [3:0]s0,s1,s2,s3;
    wire [2:0]done;
    
    Sort s(clk,rst,x0,x1,x2,x3,s0,s1,s2,s3,done);
    
    initial begin
        k=0;
        clk=0;
        rst=0;
        x3=4'b1000;
        x2=4'b0100;
        x1=4'b0010;
        x0=4'b0001;
   
    
        for(k=0;k<=20;k=k+1) begin
            #5 clk=~clk;
            if(k==2) rst=1;
            else rst=0;
        end
    end
endmodule
