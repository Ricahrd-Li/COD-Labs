`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/29 08:16:48
// Design Name: 
// Module Name: Div
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

module Div(
    input clk,
    input rst,
    input [3:0]x, //dividend
    input [3:0]y, //dividor
    output reg[3:0]q,
    output reg[3:0]r,
    output reg [2:0]error,
    output reg [2:0]done 
);

reg [6:0]dividend,dividor; // 7位 dividend :000$$$$ 
                                //     dividor  :$$$$000
reg [3:0]tmpq;
reg [2:0]state,nextstate; 
parameter S0=3'b000,S1=3'b001,S2=3'b010,S3=3'b011,S4=3'b100,S5=3'b101; 

always @ (posedge clk,posedge rst) begin
  if(rst) state=S0;
  else state=nextstate;
end

always @ * begin
    case (state) 
        S0: nextstate=S1;
        S1: nextstate=S2;
        S2: nextstate=S3;
        S3: nextstate=S4;
        default: nextstate=S5;
    endcase
end

always @(posedge clk) begin
    case(state) 
        S0:begin
            done=3'b000;
            tmpq=4'b0000;

            dividor={y[3:0],3'b000};
            if(dividor==7'b0000_000) error=3'b001; //red
            else error=3'b000;

            dividend={3'b000,x[3:0]};
        end

        S1:begin
            if(dividend>=dividor) begin 
                dividend=dividend-dividor;
                tmpq[3]=1'b1;
            end
            dividor={1'b0,dividor[6:1]};
        end

        S2: begin
            if(dividend>=dividor) begin 
                dividend=dividend-dividor;
                tmpq[2]=1'b1;
            end
            dividor={1'b0,dividor[6:1]};
        end

        S3: begin
            if(dividend>=dividor) begin 
                dividend=dividend-dividor;
                tmpq[1]=1'b1;
            end
            dividor={1'b0,dividor[6:1]};
        end

        S4: begin
            if(dividend>=dividor) begin 
                dividend=dividend-dividor;
                tmpq[0]=1'b1;
            end

        end

        default: begin 
            q=tmpq;
            done=3'b010;
            r=dividend;
        end
    endcase
    
end

endmodule
