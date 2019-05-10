`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 19:41:44
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
module ALUcontrol(
    input clk,
    input [1:0]ALUOp,
    input [5:0]func,
    input Immi_enable,
    input [1:0]Immi_func,
    output reg [3:0]ALUctrl
    );
    always @ * begin
        case(ALUOp)
             2'b00: ALUctrl<=4'b0010; //add
             2'b01: ALUctrl<=4'b0110; //subtract 
             2'b10: begin
                 if(~Immi_enable)begin
                    case(func)
                        6'b100000: ALUctrl<=4'b0010;  //add
                        6'b100010: ALUctrl<=4'b0110;  //subtract
                        6'b100100: ALUctrl<=4'b0000;   //and 
                        6'b100101: ALUctrl<=4'b0001;  //or
                        6'b101010: ALUctrl<=4'b0111;  //set on less than
                        6'b100110: ALUctrl<=4'b1000; //xor
                        6'b100111: ALUctrl<=4'b1001; //nor
                        default:;
                    endcase
                 end
                 
                 else begin
                    case(Immi_func)
                        2'b00: ALUctrl<=4'b0010;  //add
                        2'b01: ALUctrl<=4'b0000;  //and
                        2'b10: ALUctrl<=4'b0001;  //or
                        default:; 
                    endcase
                 end
             end
             default: ;
        endcase
    end
endmodule


module ALU(
    input clk, 
    input [3:0]ALUctrl,
    input [31:0]a,
    input [31:0]b,
    output reg cf, //cf: non-signed carry/borrow; of:signed overflow; zf: zero
    output reg of,
    output reg zf,
    output reg[31:0]y //result
);
//ALUOp: 000--add, 001--sub, 010--and, 011--or, 100--not, 101--xor,
//   110--leftshift,111--rightshift

always @ *  begin
    case (ALUctrl)  
        //add
        4'b0010: begin
            {cf,y}={1'b0,a}+{1'b0,b};
            of=(~a[5]&~b[5]&y[5]|a[5]&b[5]&~y[5]);
        end
        //and
        4'b0000:  y=a&b;
        //sub
        4'b0110: begin
            {cf,y}=a-b;
            of=(~a[5]&b[5]&~y[5]|a[5]&~b[5]&~y[5]);
        end
        //or
        4'b0001: y=a|b;
        //Set on less than
        4'b0111: y=(a<b)?1:0;
        //xor
        4'b1000: y=a^b;
        //nor
        4'b1001: y=~(a|b);
        default: ;
        endcase
        zf=~|y;
end

endmodule 

