`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/03/29 09:14:00
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
    output reg cf, //cf: non-signed carry/borrow; of:signed overflow; zf: zero
    output reg of,
    output reg zf,
    output reg[5:0]y //result
);
//s: 000--add, 001--sub, 010--and, 011--or, 100--not, 101--xor,
//   110--leftshift,111--rightshift

always @(posedge clk) begin
    case (s)  
    //add
      3'b000: begin
        {cf,y}={1'b0,a}+{1'b0,b};
        of=(~a[5]&~b[5]&y[5]|a[5]&b[5]&~y[5]);
      end
    //sub
      3'b001: begin
        {cf,y}=a-b;
        of=(~a[5]&b[5]&~y[5]|a[5]&~b[5]&~y[5]);
      end
    //and  
      3'b010: y=a&b;
    //or 
      3'b011: y=a|b;
    //not 
      3'b100: y=~a;
    //xor 
      3'b101: y=a^b;
    //leftshift
      3'b110: begin
        y={a[4:0],1'b0};
      end 
    //rightshift
      default:begin
        y={1'b0,a[5:1]};
      end
    endcase

    zf=~|y;

end

endmodule 

