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
    input cont,step,mem,inc,dec,
    output [15:0]led,
    output [7:0]AN,
    output [6:0]seg,
    output dp
    );
    
    
endmodule


module Control(   
    input clk,
    input [5:0]Op,
    output reg [1:0] PCSource, ALUOp, ALUSrcB, 
    output  reg ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite
    );
    parameter S0=4'b0000, S1=4'b0001,S2=4'b0010,S3=4'b0011, S4=4'b0100,S5=4'b0101,S6=4'b0110, S7=4'b0111,S8=4'b1000,S9=4'b1001;
    reg [4:0]state,nextstate;
    always @(posedge clk)begin
        state<=nextstate;
    end
    
    always @* begin
        case(state)
            S0: nextstate=S1;
            S1: begin
                case(Op)
                    //# First implement lw, sw, R-type, beq,  j
                    6'b000000: nextstate=S6; //R-type: and, sub, and, or, xor, nor, slt 
                    6'b100011: nextstate=S2;  //lw  
                    6'b101011: nextstate=S2;  //sw
                    6'b000100: nextstate=S8;
                    6'b000010: nextstate=S9;
                endcase 
            end
            S2: begin 
                if(Op==6'b100011) nextstate=S3;
                if(Op==6'b101011) nextstate=S5;
           end
           S3: nextstate=S4;
           S6: nextstate=S7;
           default: nextstate=S0;
        endcase    
    end
    
    always @(posedge clk) begin
        case(state)
            S0: begin
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite}<=
                {2'b00,       2'b00,  2'b01,     1'b0,       1'b0,        1'b0,     1'b0,             1'b1,      1'b0, 1'b1,        1'b0,          1'b0,         1'b1    };              
              // IR=mem[PC], PC+=4;       
            end  
            S1: begin
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite}<=
                {2'b00,       2'b00,  2'b11,     1'b0,       1'b0,        1'b0,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0    };                
            end                       
            S6: begin
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite}<=
                {2'b00,       2'b10,  2'b00,     1'b1,       1'b0,        1'b0,     1'b0,             1'b1,      1'b0, 1'b1,        1'b0,          1'b0,         1'b1    };                
            end

        endcase 
    end
    
endmodule

module CPU(
    input clk,rst,
    input run,
    input [7:0]addr,
    output [7:0]pc_out,
    output [31:0]mem_data,reg_data
);
    
    wire [31:0]regA,regB,ALUOut,ALUresult;
    wire [31:0]ReadData1,ReadData2;
    Reg A(clk,ReadData1,regA);
    Reg B(clk, ReadData2, regB);
    Reg alu_out(clk, ALUresult, ALUOut);
    
    
    //Memory 
    wire [31:0]Writedata, MemData;
    wire [7:0]mem_addr;
    wire [31:0]MemDataReg;
    Reg mem_data_reg(clk,MemData,MemDataReg);
    
    // Instruction Reg
    wire [5:0]ins31_26;
    wire [4:0]ins25_21,ins20_16;
    wire [15:0]ins15_0;
    wire [4:0]ins15_11;
    wire [5:0]ins5_0;
    
    assign ins15_11=ins15_0[15:11];
    assign ins5_0=ins15_0[5:0];
    
    //Control 
    wire [1:0] PCSource, ALUOp, ALUSrcB;
    wire ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite;
    wire [5:0]Op;
    
    control ctrl(clk,Op,PCSource, ALUOp, ALUSrcB,
     ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite);
   
    Memory memory(clk,MemWrite, MemRead, mem_addr, Writedata, MemData);
    
    Instruction_Reg InsReg(clk,rst,IRWrite, MemData, ins31_26, ins25_21, ins20_16, ins15_0);
    
    wire zf,cf,of;
    
    //PC 
    wire pc_we;
    assign pc_we=(zf&PCWriteCond)|PCWrite;
    wire [7:0]pc_in;
    wire [7:0]pc;
    PC p_c (clk,pc_we,pc_in,pc);

    Mux1 m_pc (lorD,pc,ALUOut,mem_addr);
    
    //RegFile
    wire [4:0]Reg_addr;
    wire [31:0]Reg_Writedata;
    
    Mux1 m_RF_WriteData(MemtoReg, ALUOut, MemDataReg,Reg_Writedata);
    
    Mux1 m_RF(RegDst, ins20_16, ins15_11,Reg_addr);
    
    RegFile RF(clk, ins25_21, ins20_16,Reg_addr, regA,regB);
    
    wire [31:0]SEXT;
    
    assign SEXT={{16{ins15_0[15]}}, ins15_0};
    
    wire [31:0]SEXT_sft2;
    assign SEXT_sft2=SEXT<<2;
    
    //ALU & ALUcontrol
    wire [31:0] aluA, aluB;
    
    Mux1 m1_ALU(ALUSrcA, pc, regA, aluA);
    Mux2 m2_ALU(ALUSrcB, regB, SEXT,SEXT_sft2,aluB);
    
    wire [3:0]ALUctrl;
    ALUcontrol alu_control(clk,ALUOp,ins5_0, ALUctrl);
    ALU alu(clk, ALUctrl,aluA,aluB,cf, of,zf, ALUresult);

endmodule
