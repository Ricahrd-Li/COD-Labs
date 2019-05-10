`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/06 11:48:50
// Design Name: 
// Module Name: CPU
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

module CPU(
    input clk5MHz,
    input run,
    input step,
    input rst,
    input [7:0]addr,
    output [7:0]pc_out,
    output [31:0]mem_data,reg_data
);
    //******************************* CPU part ************************
    wire clk;
    
 //Regs
          wire [31:0]regA,regB,ALUOut,ALUresult;
          wire [31:0]ReadData1,ReadData2;
          Reg A(clk,ReadData1,regA);
          Reg B(clk, ReadData2, regB);
          Reg alu_out(clk, ALUresult, ALUOut);
          
          //Memory 
          wire [31:0]Writedata, MemData;
          wire [7:0]mem_addr;
          wire [31:0]MemDataReg;  //from mem_data_reg to mux 
          Reg mem_data_reg(clk,MemData,MemDataReg);
          
          assign Writedata=regB;
          // Instruction Reg
          wire [5:0]ins31_26;
          wire [4:0]ins25_21,ins20_16;
          wire [15:0]ins15_0;
          wire [4:0]ins15_11;
          wire [5:0]ins5_0;
          wire [25:0]ins25_0;
          
          assign ins15_11=ins15_0[15:11];
          assign ins5_0=ins15_0[5:0];
          assign ins25_0={ins25_21,ins20_16,ins15_0};
          
          //Control 
          wire [1:0] PCSource, ALUOp, ALUSrcB, Immi_func;
          wire ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable;
          wire [5:0]Op;
          
          assign Op=ins31_26;
          Control ctrl(clk,rst,Op,PCSource, ALUOp, ALUSrcB,
           ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable,Immi_func);
         
          dist_mem_gen_0 memory(.clk(clk),.we(MemWrite), .a(mem_addr), .d(Writedata),.dpra(addr),.dpo(mem_data), .spo(MemData));
          
          Instruction_Reg InsReg(clk,IRWrite, MemData, ins31_26, ins25_21, ins20_16, ins15_0);
          
          wire zf,cf,of;
        
          //PC 
          wire pc_we;
          wire condition;
          assign condition=Op[0]^zf;//(~Op[0]&zf) | (Op[0]&~zf); 
          assign pc_we=(condition&PCWriteCond)|PCWrite;
          
          wire [31:0]pc_in;  //The input of PC is 32 bits wide, and the output of PC is 32 bits wide. 
          wire [31:0]pc;
          assign pc_out=pc[9:2];
          PC p_c (clk,pc_we,rst,pc_in,pc);
          
          Mux_PC_to_Mem pc_to_mem (lorD,pc,ALUOut,mem_addr); 
          
          //RegFile
          wire [4:0]Reg_addr;
          wire [31:0]Reg_Writedata;
          
          Mux1 m_RF_WriteData(MemtoReg, ALUOut, MemDataReg,Reg_Writedata);
          
          Mux_RF_Write_addr m_RF(RegDst, ins20_16, ins15_11,Reg_addr);
          
          RegFile RF(clk, RegWrite, addr, ins25_21, ins20_16,Reg_addr, Reg_Writedata, reg_data,ReadData1,ReadData2);
          
          wire [31:0]SEXT;  
          
          assign SEXT={{16{ins15_0[15]}}, ins15_0};
          
          wire [31:0]SEXT_sft2;
          assign SEXT_sft2=SEXT<<2;
          
          //ALU & ALUcontrol
          wire [31:0] aluA, aluB;
          
          Mux1 m1_ALU(ALUSrcA, pc, regA, aluA);
          Mux2 m2_ALU(ALUSrcB, regB, SEXT,SEXT_sft2,aluB);
          
          wire [3:0]ALUctrl;
          ALUcontrol alu_control(clk,ALUOp,ins5_0, Immi_enable,Immi_func,ALUctrl);
          ALU alu(clk, ALUctrl,aluA,aluB,cf, of,zf, ALUresult);
          
          wire [31:0] jaddr;
          assign jaddr={pc[31:28],ins15_0,2'b00};    //the aim address of jump 
              
          Mux_ALU_to_PC mux_alu_to_pc(PCSource,ALUresult,ALUOut,jaddr,pc_in);
   //************************************ Interact with DCU Part ************************
   assign clk=( run )? clk5MHz: step;
  
endmodule