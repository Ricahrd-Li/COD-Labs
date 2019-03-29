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
module Display(  
    input [3:0]y,
    output reg [6:0]x
);
    always @ * begin
        case(y[3:0])
            4'b0000: x = 7'b100_0000; //0
            4'b0001: x = 7'b111_1001;//1001_111;
            4'b0010: x = 7'b010_0100;//0010_010;
            4'b0011: x = 7'b011_0000;//0000_110;//
            4'b0100: x = 7'b001_1001;//1001_100;
            4'b0101: x = 7'b001_0010;//0100_100;
            4'b0110: x = 7'b000_0010;//0100_000;
            4'b0111: x = 7'b111_1000;//0001_111;
            4'b1000: x = 7'b000_0000;//0000_000;
            4'b1001: x = 7'b001_0000;//0000_100;
            4'b1010: x= 7'b000_1000; //A 000_1000        
            4'b1011: x= 7'b000_0011; //b 110_0000
            4'b1100: x= 7'b010_0111; //c 111_0010
            4'b1101: x= 7'b010_0001; //d 100_0010
            4'b1110: x= 7'b000_0110;//E  011_0000
            default: x= 7'b000_1110;//F 011_1000
        endcase
    end
endmodule

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
    output reg [2:0]done,   //用RGB灯

    input Clk100,
    output [6:0]d, //seven segments digital light
    output reg[7:0]AN  
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
    end

    always @(posedge clk)begin
        case(state)
            S0: begin
                done=3'b000;
                count=3'b000;
                r0=x0;
                r1=x1;
                r2=x2;
                r3=x3;
            end

            S1:begin
                if(r0<r1) begin   //xx$$ ,$ represent the item to be swaped.
                    tmp=r0;
                    r0=r1;
                    r1=tmp;
                end
            end
            

            S2:begin
                if (count==3'b001) count=count+1; //count: 1->2
                if(r1<r2) begin   //x$$x
                    tmp=r1;
                    r1=r2;
                    r2=tmp;    
                end
            end

            S3:begin
                count=count+1; //count: 0->1
                if(r2<r3) begin   //$$xx, the highest bit is the smallest.
                    tmp=r2;
                    r2=r3;
                    r3=tmp;    
                end
            end

            default: done=3'b010; 
        endcase

        //to show-process-in-time 
        s0=r0;
        s1=r1;
        s2=r2;
        s3=r3;
    end

    always @ * begin
        case(state)
            S0: nextstate=S1;  //声明是reg但因为是组合逻辑，不一定产生reg

            S1: begin          
                if(count==3'b010) nextstate=S4; //When count==3'b010, sorting is done. 
                else nextstate=S2;     
            end

            S2: begin
                if (count==3'b001) nextstate=S1;
                else nextstate=S3;
            end

            S3: nextstate=S1;

            default: nextstate=S4; 
        endcase
    end

    //digital display
    wire Clk5;
    clk_wiz_0(Clk5,,,Clk100);

    reg [12:0]cnt_show=13'h0;
    reg [3:0]show; //number to show

    Display display (show,d);

    always @(posedge Clk5)begin
        if(cnt_show >= 13'd3999)
            cnt_show    = 13'h0;
        else
            cnt_show    = cnt_show + 13'h1;
    end

    always @* begin
        if(cnt_show<13'd999) begin
            show=r0;
            AN=8'b1111_1110;
        end
        else if(cnt_show<13'd1999) begin
            show=r1;
            AN=8'b1111_1101;
        end
        else if(cnt_show<13'd2999) begin
            show=r2;
            AN=8'b1111_1011;
        end
        else begin
            show=r3;
            AN=8'b1111_0111;
        end
    end

endmodule
