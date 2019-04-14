`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Zhehao Li
// 
// Create Date: 2019/04/12 16:10:28
// Design Name: 
// Module Name: Queue
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
    input enable,
    input [3:0]y,
    output reg[6:0]x
);
    always @ * begin
        if(enable) begin
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
        else x=7'b111_1111;
      end
      
endmodule

module RegFile #(parameter W=4,N=3) ( //W=Width, N=num
    input clk,rst,we,
    input [N-1:0]ra0,ra1,wa, //address 是3位的： 0--8 [2:0]
    input [W-1:0]wd,    //data 是4位的：0-15 [3:0]
    output [W-1:0]rd0,rd1
);
    reg [W-1:0]Reg[7:0];  //the reg[3:0] is not right !!! should be reg[7:0]!!!
    
    assign rd0=Reg[ra0];
    assign rd1=Reg[ra1];

    always @(posedge clk,posedge rst)begin
        if(rst) begin 
            Reg[3'b000]<=0; 
            Reg[3'b001]<=0; 
            Reg[3'b010]<=0; 
            Reg[3'b011]<=0; 
            Reg[3'b100]<=0; 
            Reg[3'b101]<=0; 
            Reg[3'b110]<=0; 
            Reg[3'b111]<=0;           
        end
        else if(we) Reg[wa]<=wd;    
    end

endmodule

module Counter #(parameter W=3)(
    input clk,rst,ce,pe,
    input [W-1:0]d,
    output [W-1:0]q
);
    reg [W-1:0]count;
    always @(posedge clk, posedge rst)begin
        if(rst) count<=0;
        else if(pe) count<=d;
        else if(ce) count<=count+1;
    end

    assign q=count;
endmodule

module Queue #(parameter QL=3, QW=4)(  //QL: queue length, QW: queue word width 
    input clk100,rst,en_out,en_in,
    input [QW-1:0]in,
    output [QW-1:0]out,
    output [2:0]empty,full, //led light 
    output reg[7:0]AN,
    output DP,
    output [6:0]d  //display
);
    reg ce_head,ce_tail,we;
    reg [QL-1:0]wa,ra0,ra1;

     //2 Counter
    wire ce_head_signal,ce_tail_signal;
    wire [QL-1:0]head_pointer,tail_pointer;
    Counter head_counter(clk100,rst,ce_head_signal,,,head_pointer);
    Counter tail_counter(clk100,rst,ce_tail_signal,,,tail_pointer);
    
    assign ce_head_signal=ce_head; 
    assign ce_tail_signal=ce_tail;
    
    //1 RegFile
    wire we_signal;
    wire [QW-1:0]rd0_signal,rd1_signal;
    wire [QL-1:0]ra0_signal,ra1_signal,wa_signal; 
    
    RegFile RF(.clk(clk100),.rst(rst),.we(we_signal),.wd(in),.wa(wa_signal),
            .ra0(ra0_signal),.rd0(out),.ra1(ra1_signal),.rd1(rd1_signal));

    //write
    assign we_signal=we;
    assign wa_signal=wa;
    //read
    assign ra0_signal=ra0;
    assign ra1_signal=ra1;  // Is assign simultaneously executed?
    
    assign empty=(tail_pointer==head_pointer)?3'b010:3'b000;
    assign full=((tail_pointer+1)%8==head_pointer)?3'b100:3'b000;
   
    reg in_flag,out_flag;  // use flag to handle viboration
    
    always @(posedge clk100,posedge rst)begin  //No '=' in sequential logic always, why? 
        if(rst) begin
            //ra1<=0;
            //AN<=8'b0111_1111;     ----> not right, this is sequential logic, and it may lead to ra1 always=0, and AN always =0111_1111;
            
            in_flag<=0;
            out_flag<=0;
            we<=0; 
            ce_tail<=0;
            ce_head<=0;
        end
        
        else begin
            we<=0; 
            ce_tail<=0;
            ce_head<=0;
            
            if(en_in&&!full) in_flag<=1;
            if(~en_in && in_flag) begin
                we<=1;     
                wa<=tail_pointer; 
                ce_tail<=1; //tail_pointer +=1
                in_flag<=0;
            end
            
            if(en_out&&!empty) out_flag<=1;
            if(~en_out && out_flag) begin
                ra0<=head_pointer; //read first, then head_pointer++
                ce_head<=1;  
                out_flag<=0;
            end  
        end
    end

    // Display 
    wire Clk5;   //5MHz
    clk_wiz_0 wiz(Clk5,,,clk100);
    reg [12:0]cnt_show;
    
    wire display_enable;
    
    assign DP=(ra1_signal==head_pointer)?0:1;  //Why this didn't work?
    assign display_enable=~(empty&&~DP);  // if empty&&~DP : display_enable=0; else =1
    
    Display display (display_enable, rd1_signal,d);

    always @(posedge Clk5)begin
        if(cnt_show >= 13'd7999)
            cnt_show    <= 13'h0;
        else
            cnt_show    <= cnt_show + 13'h1;
    end

    always @ * begin
        if(cnt_show<13'd999) begin
            ra1=3'b000;
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b0111_1111:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b0111_1111;
            
        end
        else if(cnt_show<13'd1999) begin
            ra1=3'b001;  
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b1011_1111:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b1011_1111;


        end
        else if(cnt_show<13'd2999) begin
            ra1=3'b010;
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b1101_1111:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b1101_1111;

        end
        else if(cnt_show<13'd3999) begin
            ra1=3'b011;
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b1110_1111:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b1110_1111;

        end
        else if(cnt_show<13'd4999) begin
            ra1=3'b100;
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b1111_0111:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b1111_0111;

        end
        else if(cnt_show<13'd5999) begin
            ra1=3'b101;
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b1111_1011:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b1111_1011;

        end
        else if(cnt_show<13'd6999) begin
            ra1=3'b110;
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b1111_1101:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b1111_1101;

        end
        else begin
            ra1=3'b111;
            if(head_pointer<=tail_pointer)  AN=(~DP||(ra1_signal>=head_pointer&&ra1_signal<tail_pointer))?8'b1111_1110:8'b1111_1111;
            else AN=(ra1_signal>=tail_pointer&&ra1_signal<head_pointer)?8'b1111_1111:8'b1111_1110;

        end
    end
 
 endmodule
