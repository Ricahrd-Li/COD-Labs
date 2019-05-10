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

module Mux_RF_Write_addr(
    input RegDst,
    input [5:0]ins20_16,ins15_11,
    output [5:0]reg_write_addr
    );
    assign reg_write_addr=RegDst? ins15_11 : ins20_16;
        
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

module Mux_PC_to_Mem(
    input signal,
    input [31:0]pc,aluout,
    output [7:0]c
    );
    assign c=(~signal)?pc[9:2]:aluout[9:2];
endmodule

module Mux_ALU_to_PC(
    input [1:0]signal,
    input [31:0] pc_increment,aluout,jaddr,
    output reg [31:0] pc_result
);
    always @* begin
        case (signal)
            2'b00: pc_result=pc_increment;
            2'b01: pc_result=aluout;
            default: pc_result=jaddr;
        endcase
    end
endmodule

