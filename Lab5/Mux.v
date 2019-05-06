`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/24 22:11:41
// Design Name: 
// Module Name: Mux
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
module Mux1(
    input signal,
    input [31:0]a,b,
    output [31:0]c
    );
    assign c=signal?b:a;
endmodule


module Mux2(
    input [1:0]signal,
    input [31:0]a,b,c,
    output reg[31:0]d
    );
    always @* begin
        case (signal)
            2'b00: d=a;
            2'b01: d=32'd4;
            2'b10: d=b;
            default: d=c;
        endcase
    end
    
endmodule
