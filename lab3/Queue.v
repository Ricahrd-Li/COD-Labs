`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
    input [3:0]y,
    output reg[6:0]x
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

module RegFile #(parameter W=32,N=3) ( //W=Width, N=num
    input clk,rst,we,
    input [N-1:0]ra0,ra1,wa,
    input [W-1:0]wd,
    output [W-1:0]rd0,rd1
);
    reg [W-1:0]Reg[N-1:0];
    integer k;
    
    assign rd0=Reg[ra0];
    assign rd1=Reg[ra1];

    always @(posedge clk,posedge rst)begin
        if(rst) begin 
            for(k=0;k<N;k=k+1)begin
                Reg[k]=0;
            end                      
        end
        else if(we) Reg[wa]=wd;    
    end

endmodule

module Counter #(parameter W=4)(
    input clk,rst,ce,pe,
    input [W-1:0]d,
    output [W-1:0]q
);
    reg [W-1:0]count;
    always @(posedge clk, posedge rst)begin
        if(rst) count=0;
        else if(pe) count=d;
        else if(ce) count=count+1;
    end

    assign q=count;
endmodule

module Queue #(parameter QL=2, QW=4, S_initial=3'b000, S_in=3'b001,S_out=3'b010,S_check=3'b100)(  //QL: queue length, QW: queue word width 
    input clk100,rst,en_out,en_in,
    input [QW-1:0]in,
    output [QW-1:0]out,
    output [2:0]empty,full, //led light 
    output reg[7:0]AN,
    output DP,
    output reg[6:0]d  //display
);
    reg state,next_state;
    reg ce_head,ce_tail,we;
    reg [QL-1:0]wa,ra0,ra1;

    wire rst_signal;
     //2 Counter
    wire ce_head_signal,ce_tail_signal;
    wire [QL-1:0]head_pointer,tail_pointer;
    Counter head_counter(clk100,rst_signal,ce_head_signal,,,head_pointer);
    Counter tail_counter(clk100,rst_signal,ce_tail_signal,,,tail_pointer);
    
    //1 RegFile
    wire we_signal;
    wire [QW-1:0]rd0_signal,rd1_signal,wd_signal;
    wire [QL-1:0]ra0_signal,ra1_signal,wa_signal; 
    RegFile RF(.clk(clk100),.rst(rst_signal),.we(we_signal),.wd(wd_signal),
            .ra0(ra0_signal),.rd0(out),.ra1(ra1_signal),.rd1(rd1_signal));

    assign ce_head_signal=ce_head; //#
    assign ce_tail_signal=ce_tail;
    //write
    assign we_signal=we;
    assign wa_signal=wa;
    assign wd_signal=in;

    assign rst_signal=rst; //!
    //read
    assign ra0_signal=ra0;
    
    assign empty=(tail_pointer==head_pointer)?3'b010:3'b000;
    assign full=((tail_pointer+1)%8==head_pointer)?3'b100:3'b000;
   
    always @(posedge clk100,posedge rst)begin
        if(rst) state=S_check;  
        else state=next_state;
    end

    always @(posedge clk100) begin  //Here we need to use posedge clk, cause we want the enable signal just works when posedge clk!
        if(en_in) next_state=S_in;
        if(en_out) next_state=S_out;
        else next_state=S_check;
       
        case(state)
        S_in: begin
            if(~en_in) begin  //A way to fix viberation 
                //write into RF
                we=1;
                wa=head_pointer; //先入队，再让head_pointer+1！
                ce_head=1; //#
            end
        end

        S_out: begin
            if(~en_out)begin    
                ce_tail=1;
                //read
                ra0=tail_pointer;
            end
        end
        
        default:begin
        end    
    endcase
    end

    // Display 
    wire Clk5;   //5MHz
    clk_wiz_0(Clk5,,,clk100);
    reg [12:0]cnt_show;
    Display display (ra1_signal,d);

    always @(posedge Clk5)begin
        if(cnt_show >= 13'd7999)
            cnt_show    <= 13'h0;
        else
            cnt_show    <= cnt_show + 13'h1;
    end

    assign DP=(ra1_signal==head_pointer)?1:0;

    always @ * begin
        if(cnt_show<13'd999) begin
            ra1=3'b000;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b0111_1111:8'b1111_1111;
        end
        else if(cnt_show<13'd1999) begin
            ra1=3'b001;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b1011_1111:8'b1111_1111;
        end
        else if(cnt_show<13'd2999) begin
            ra1=3'b010;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b1101_1111:8'b1111_1111;
        end
        else if(cnt_show<13'd3999) begin
            ra1=3'b011;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b1110_1111:8'b1111_1111;
        end
        else if(cnt_show<13'd4999) begin
            ra1=3'b100;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b1111_0111:8'b1111_1111;
        end
        else if(cnt_show<13'd5999) begin
            ra1=3'b101;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b1111_1011:8'b1111_1111;
        end
        else if(cnt_show<13'd6999) begin
            ra1=3'b110;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b1111_1101:8'b1111_1111;
        end
        else begin
            ra1=3'b111;
            AN=(ra1_signal<tail_pointer||ra1_signal>=head_pointer)?8'b1111_1110:8'b1111_1111;
        end
    end
 
 endmodule
