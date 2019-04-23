`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/14 15:56:06
// Design Name: 
// Module Name: draw
// Project Name: 
// Target Devices: 
// Tool  Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module DCU(
    input clk25MHz,
    input [11:0] vdata,
    input [7:0] pen_x,
    input [7:0] pen_y,
    output reg [15:0] vaddr,
    output reg [3:0] VGA_R,VGA_G,VGA_B,
    output reg VGA_HS,VGA_VS
    );
    reg [9:0] HScount=0;reg [9:0] VScount=0;  // Horizontal  & Vertical
    initial begin VGA_HS=0;VGA_VS=0;end
    always @(posedge clk25MHz) begin   //Horizontal scanning 
        HScount=HScount+1;
        if (HScount>800) HScount=1;
        if (HScount==656) VGA_HS=1;   //
        if (HScount==752) VGA_HS=0;
    end
    always @(posedge VGA_HS) begin
        VScount=VScount+1;
        if (VScount>525) VScount=1;   //
        if (VScount==490) VGA_VS=1;
        if (VScount==492) VGA_VS=0;
    end
    always @ (HScount,VScount) begin
    	vaddr[7:0]=HScount-193;
    	vaddr[15:8]=VScount-113;
    end
    always @ (vdata,pen_x,pen_y,vaddr,HScount,VScount) begin
    	if (HScount<193||VScount<113||HScount>448||VScount>368)     //outside area is black!
    		{VGA_R,VGA_G,VGA_B}=0;
    	else if (pen_y==vaddr[15:8]&&pen_x==vaddr[7:0]||     
    			 pen_y==vaddr[15:8]&&|pen_x&&pen_x-8'b00000001==vaddr[7:0]||    
    			 pen_y==vaddr[15:8]&&(pen_x>=8'b0000_0010)&&pen_x-8'b00000010==vaddr[7:0]||    
    			 pen_y==vaddr[15:8]&&(pen_x>=8'b0000_0011)&&pen_x-8'b00000011==vaddr[7:0]||  
    			 pen_y==vaddr[15:8]&&!(&pen_x)&&pen_x+8'b00000001==vaddr[7:0]||
    			 pen_y==vaddr[15:8]&&(pen_x<=8'b1111_1101)&&pen_x+8'b00000010==vaddr[7:0]||
    			 pen_y==vaddr[15:8]&&(pen_x<=8'b1111_1100)&&pen_x+8'b00000011==vaddr[7:0]||
    			 |pen_y&&pen_y-8'b00000001==vaddr[15:8]&&pen_x==vaddr[7:0]||
    			 (pen_y>=8'b0000_0010)&&pen_y-8'b00000010==vaddr[15:8]&&pen_x==vaddr[7:0]||
    			 (pen_y>=8'b0000_0011)&&pen_y-8'b00000011==vaddr[15:8]&&pen_x==vaddr[7:0]||
    			 !(&pen_y)&&pen_y+8'b00000001==vaddr[15:8]&&pen_x==vaddr[7:0]||
    			 (pen_y<=8'b1111_1101)&&pen_y+8'b00000010==vaddr[15:8]&&pen_x==vaddr[7:0]||
    			 (pen_y<=8'b1111_1100)&&pen_y+8'b00000011==vaddr[15:8]&&pen_x==vaddr[7:0])begin
    		{VGA_R,VGA_G,VGA_B}=0;   //cross-shaped cursor                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    	end else begin
    		{VGA_R,VGA_G,VGA_B}=vdata;
    	end
    end
endmodule

module Debouncer(
    input clk,   //20MHz   
    input [3:0] in_signal,
    output [3:0] out_signal
    );
    reg [3:0]out;
    reg [22:0]counter;
    reg [24:0]counter2;
    assign out_signal=out;                                                                                     
    
    always @(posedge clk)begin
        if(~in_signal)begin 
            counter<=0;
            counter2<=0;
            out<=0;
        end
        if(in_signal)begin
            counter<=counter+1;
            counter2<=counter2+1;
            if(&counter2) begin 
                out<=in_signal;   
                counter2<=25'b1111_1111_1111_1111_11111_1101;   //continuously move
            end
            else if((counter2<24'b1111_1111_1111_1111_1111_1111)&&(&counter)) out<=in_signal;   //When count for 0.3s, produce a signal pulse.  0.3*25*10^6=7500000
            else out<=0;
        end
    end    
endmodule

module PCU(
    input clk,rst, draw, 
    input [11:0]rgb,
    input [3:0]dir,         //dir : {up, down ,left ,right}
    output reg [15:0]paddr,
    output reg [11:0]pdata,
    output reg we,
    output reg [7:0]x,y
    );
    initial begin
        x=128;y=128;we=0;paddr=0;pdata=0;
    end
    wire clk20MHz;
    clk_wiz_1 wiz1(clk20MHz,clk);
    
    wire [3:0]dir_signal;
    Debouncer deb(clk20MHz,dir,dir_signal);
    
    always @(posedge clk, posedge rst) begin
            we=draw;   // YOU need to enable the we to draw colors! 
            paddr={y,x};
            pdata=rgb;
            
            if(rst) begin
                x<=8'd128;
                y<=8'd128;
            end
            else begin
                case (dir_signal)
                    4'b0001: if(y<8'd255)y<=y+1;  //right
                    4'b0010: if(y>8'd0)y<=y-1;  //left
                    4'b1000: if(x>8'd0)x<=x-1;  //up  //btnr
                    4'b0100: if(x<8'd255)x<=x+1;   //down
                    4'b1010: begin if(x>8'd0)x<=x-1;  if(y>8'd0)y<=y-1;  end //up and left 
                    4'b1001: begin if(x>8'd0)x<=x-1;  if(y<8'd255)y<=y+1; end //up and right
                    4'b0110: begin if(x<8'd255)x<=x+1;  if(y>8'd0)y<=y-1;  end //down and left
                    4'b0101: begin if(x<8'd255)x<=x+1; if(y<8'd255)y<=y+1; end  //down and right
                    default: ;  //do nothing
                endcase
            end
        end
        
endmodule

module Draw(
    input clk100MHz,rst, draw, 
    input [11:0]rgb, 
    input [3:0]dir,  //dir : {up, down ,left ,right}
    output [3:0] VGA_R,VGA_G,VGA_B,
    output VGA_HS,VGA_VS
    //output [7:0] led_x,led_y   //For debugging. 
    );
    wire [15:0]paddr;
    wire [11:0]pdata;
    wire we;
    wire [7:0]x,y;
    
    wire [11:0] vdata;
    wire [15:0] vaddr;
    wire clk;
    
    clk_wiz_0 wiz(clk,clk100MHz);   //clk :25MHz

    dist_mem_gen_0 VRAM(.clk(clk),.we(we),.a(paddr),.d(pdata),.dpra(vaddr),.dpo(vdata));
    
    DCU dcu(clk,vdata,x,y,vaddr,VGA_R,VGA_G,VGA_B,VGA_HS,VGA_VS);
    
    PCU pcu(clk,rst,draw,rgb,dir,paddr,pdata,we,x,y);
    
endmodule
