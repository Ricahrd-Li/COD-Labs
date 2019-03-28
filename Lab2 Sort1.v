`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/28 08:28:07
// Design Name: 
// Module Name: sort
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
module Sort(
    input clk,
    input rst,
    input [3:0]x0,
    input [3:0]x1,
    input [3:0]x2,
    input [3:0]x3,
    output reg [3:0]s0, 
    output reg [3:0]s1, 
    output reg [3:0]s2, 
    output reg [3:0]s3,
    output reg [2:0]done   //用RGB灯
);
    reg [3:0]r0,r1,r2,r3,tmp; 
    reg [2:0]state,nextstate; 
    reg [2:0]count; //this is a flag used to control the process of state swaping.
    parameter S0=3'b000,S1=3'b001,S2=3'b010,S3=3'b011,S4=3'b100,S5=3'b101;
    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state =S0;
        end
        else 
            state=nextstate;
            //to show-process-in-time 
            s0=r0;
            s1=r1;
            s2=r2;
            s3=r3;
    end

    always @(state) begin
        case(state)
            S0:begin
                done=3'b000;
                count=3'b000;
                r0=x0;
                r1=x1;
                r2=x2;
                r3=x3;
                nextstate=S1;
            end
            
            S1: begin    
                if(r0<r1) begin   //xx$$ ,$ represent the item to be swaped.
                    tmp=r0;
                    r0=r1;
                    r1=tmp;
                end
                else begin end 

                if(count==3'b010) nextstate=S4; //When count==3'b010, sorting is done. 
                else nextstate=S2;
                
            end

            S2: begin
                if(r1<r2) begin   //x$$x
                    tmp=r1;
                    r1=r2;
                    r2=tmp;    
                end
                else begin end

                if (count==3'b001) begin 
                    count=count+1; //count: 1->2
                    nextstate=S1;
                end
                else nextstate=S3;
            end

            S3: begin
                if(r2<r3) begin   //$$xx, the highest bit is the smallest.
                    tmp=r2;
                    r2=r3;
                    r3=tmp;    
                end
                else begin end 

                count=count+1; //count: 0->1

                nextstate=S1;
            end


            default: begin
                done=3'b010; 
            end
        endcase
    end

    endmodule
