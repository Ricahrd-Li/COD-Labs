`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 09:53:35
// Design Name: 
// Module Name: DDU
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
module DDU(
    input clk100MHz,
    input cont,step,mem,inc,dec,rst,
    output [15:0]led,
    output reg [7:0]AN,
    output [6:0]seg,
    output [2:0]RGB_led
//    output dp
    );
    wire run;
    reg [7:0]addr;
    wire [31:0] mem_data,reg_data;
    wire clk5MHz;
    wire [7:0]pc_out;
    
    CPU cpu(clk5MHz,run,step,rst,addr,pc_out, mem_data,reg_data);
    
    assign run=cont;
    reg dec_flag,inc_flag;
     
    always @(posedge clk5MHz, posedge rst)begin
        if(rst) begin addr<=0;  dec_flag<=0; inc_flag<=0; end
        else begin
            if(dec) dec_flag<=1;
            else if(inc)  inc_flag<=1;
            else if(dec_flag) begin dec_flag<=0; addr<=addr-1; end 
            else if(inc_flag) begin inc_flag<=0; addr<=addr+1; end 
        end
    end
   
    clk_wiz_5MHz clk5(.clk_in1(clk100MHz), .clk_out1(clk5MHz)); 
    
    
    reg [12:0]cnt_show;
    always @(posedge clk5MHz)begin
        if(cnt_show >= 13'd7999)
            cnt_show    <= 13'h0;
        else
            cnt_show    <= cnt_show + 13'h1;
    end
    
    reg [3:0] display_num;
    wire [31:0]show;
    //reg display_enable;
    assign show= mem? mem_data: reg_data;
    assign RGB_led=mem? 3'b110 : 3'b001 ;
    assign led[7:0]=addr;
    assign led[15:8]=pc_out;
    
    always @ * begin
        if(cnt_show<13'd999)begin
            display_num=show[31:28];
            AN=8'b0111_1111;
        end
        else if(cnt_show<13'd1999)begin
            display_num=show[27:24];
            AN=8'b1011_1111;
        end
        else if(cnt_show<13'd2999)begin
            display_num=show[23:20];
            AN=8'b1101_1111;
        end
        else if(cnt_show<13'd3999)begin
            display_num=show[19:16];
            AN=8'b1110_1111;
        end
        else if(cnt_show<13'd4999)begin
            display_num=show[15:12];
            AN=8'b1111_0111;
        end
        else if(cnt_show<13'd5999)begin
            display_num=show[11:8];
            AN=8'b1111_1011;
        end
        else if(cnt_show<13'd6999)begin
            display_num=show[7:4];
            AN=8'b1111_1101;
        end
        else if(cnt_show<13'd7999)begin
            display_num=show[3:0];
            AN=8'b1111_1110;
        end
        
    end
    Display display(display_num,seg);
    
    
endmodule



