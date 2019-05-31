`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/30 05:18:51
// Design Name: 
// Module Name: ForwardingUnit
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

module ForwardingUnit(
    input Branch, // Branch
    input mem_RegWrite, wb_RegWrite,
    input [4:0] RegSrcA,  // ex_ins[25-21]
    input [4:0] RegSrcB, // ex_ins[20- 16]
    input [4:0] PRegA,PRegB, //ins25_21, ins20_16 Predict 
    input [4:0] ex_RegWriteaddr,
    input [4:0] mem_RegWriteaddr, wb_RegWriteaddr, 
    output reg Forward1A, Forward1B, Forward2A, Forward2B,
    output reg PForward1A, PForward1B, PForward2A, PForward2B //Predict Forward signal
    );
    always @ * begin
        Forward1A=0;
        Forward2A=0;
        Forward1B=0;
        Forward2B=0;
        PForward1A =0;
        PForward1B =0;
        PForward2A =0;
        PForward2B =0;
         if(Branch)  begin
           //C1
            if(ex_RegWrite & ex_RegWriteaddr !=0 ) begin
                if(PRegA ==ex_RegWriteaddr ) PForward1A=1;
                else PForward1A = 0;
                if(PRegB ==ex_RegWriteaddr ) PForward1B=1;
                else PForward1B = 0;
            end
            else ;
            //C2
            if(mem_RegWrite & mem_RegWriteaddr !=0 ) begin
                if(PRegA ==mem_RegWriteaddr ) PForward2A=1;
                else PForward2A = 0;
                if(PRegB ==mem_RegWriteaddr ) PForward2B=1;
                else PForward2B = 0;
            end        
        end
            else ;
        // C1
        if (mem_RegWrite &  mem_RegWriteaddr !=0 ) begin
            if( RegSrcA == mem_RegWriteaddr) Forward1A=1;
            else Forward1A = 0;
            if (RegSrcB== mem_RegWriteaddr)  Forward1B=1;
            else Forward1B = 0;
        end
        else ;
        //C2
        if(wb_RegWrite & wb_RegWriteaddr!=0) begin
            if(mem_RegWrite) begin
                if(mem_RegWriteaddr != RegSrcA & wb_RegWriteaddr == RegSrcA ) Forward2A=1;
                else Forward2A=0;
                if(mem_RegWriteaddr != RegSrcB & wb_RegWriteaddr == RegSrcB ) Forward2B=1;
                else Forward2B=0;
            end
            else begin
                if(wb_RegWriteaddr == RegSrcA ) Forward2A=1;
                else Forward2A=0;
                if(wb_RegWriteaddr == RegSrcB ) Forward2B=1;
                else Forward2B=0;
            end
        end
        else ;
    end
endmodule


module ForwardMux(
    input Forward1, Forward2,
    input [31:0] Readdata, C1data,C2data,
    output reg[31:0] out
    );
    always @ * begin
        if(Forward1 & Forward2) out = C2data;
        else if(Forward1) out=C1data;
        else if(Forward2) out = C2data;  
        else out = Readdata;
    end
endmodule
