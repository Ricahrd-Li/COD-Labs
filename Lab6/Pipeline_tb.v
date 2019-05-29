`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/28 20:40:01
// Design Name: 
// Module Name: Pipeline_tb
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


module Pipeline_tb(

    );
     reg [7:0]addr;   //DCU addr
     wire [7:0]pc_out;
     wire [31:0]mem_data,reg_data,ins_data;
        
      reg  clk;
       reg rst;
        //control signals
        wire [1:0] ALUOp,Immi_func;
        wire ALUSrc, RegWrite, RegDst, MemRead, MemWrite, MemtoReg, Immi_enable, Branch, Jump;
        wire [5:0]Op;
             
           
        // PC
        wire [31:0] pc_in, pc32;
        wire [7:0] pc8;
        PC Pc(clk, rst, pc_in,pc32);
        assign pc_out=pc8;
        assign pc8=pc32[9:2];
        wire [31:0] incremented_pc;    
        PC_Adder pc_adder(clk, pc32, incremented_pc);
       
        wire [31:0] add_result_mux_in;
        
        wire PCSrc;
        Mux pc_mux(PCSrc, incremented_pc, add_result_mux_in, pc_in);
        
        // Instruction Reg
    
         wire [31:0] ins32_in;
         InsMem Ins_Mem (.clk(clk), .a(pc8), .dpra(addr),.dpo(ins_data), .spo(ins32_in));
    
         // ID/EX registers and control signals
         wire [31:0] id_npc;
         Reg  IF_ID_NPC(clk, ,incremented_pc, id_npc);
         wire [31:0] ins32;
         Reg  IF_ID_IR(clk, ,ins32_in, ins32);
         
         wire [5:0]ins31_26;
         wire [4:0]ins25_21,ins20_16;
         wire [15:0]ins15_0;
         wire [4:0]ins15_11;
         wire [5:0]ins5_0;
         wire [25:0]ins25_0;
         
         assign ins31_26=ins32[31:26];
         assign ins15_0=ins32[15:0];
         assign ins20_16=ins32[20:16];
         assign ins15_11=ins15_0[15:11];
         assign ins5_0=ins15_0[5:0];
         assign ins25_21=ins32[25:21];
         assign ins25_0={ins25_21,ins20_16,ins15_0};
         assign Op=ins32[31:26];
         //RF
         wire [4:0]Reg_Writeaddr;
         wire [31:0]Reg_Writedata,ReadData1,ReadData2;
         wire Reg_write_en;
         RegFile RF(clk, Reg_write_en, addr, ins25_21, ins20_16,Reg_Writeaddr, Reg_Writedata, reg_data,ReadData1,ReadData2);
        //SEXT
        wire [31:0]SEXT;  
                   
        assign SEXT={{16{ins15_0[15]}}, ins15_0};
        
        //Control 
        Control control(Op,ALUOp,ALUSrc, RegWrite, RegDst, MemRead, MemWrite, MemtoReg, Immi_enable, Branch, Jump,Immi_func);
        
        wire [1:0] ex_ALUOp;
        wire  ex_ALUSrc;
        wire ex_RegDst;
        wire Bne=Op[0];  
       
        //EX signals
        Reg #(1) ID_EX_ALUSrc(clk, rst,ALUSrc, ex_ALUSrc);
        Reg #(2) ID_EX_ALUOp(clk,rst,ALUOp, ex_ALUOp);
        Reg #(1) ID_EX_RegDst(clk, rst,RegDst, ex_RegDst);
        
        //MEM signals
        wire ex_Branch, ex_Jump, ex_Bne, ex_MemWrite;
        Reg #(1) ID_EX_Branch(clk, rst,Branch, ex_Branch);
        Reg #(1) ID_EX_Jump(clk, rst,Jump, ex_Jump);
        Reg #(1) ID_EX_Bne(clk,rst, Bne, ex_Bne);
        Reg #(1) ID_EX_MemWrite(clk, rst,MemWrite, ex_MemWrite);
        
        //WB signals
        wire ex_RegWrite, ex_MemtoReg;
        Reg #(1) ID_EX_RegWrite(clk, rst,RegWrite, ex_RegWrite);
        Reg #(1) ID_EX_MemtoReg(clk,rst, MemtoReg, ex_MemtoReg);
        
        //
        wire [31:0] ALUa, ALUb;
        Reg ID_EX_RegA(clk,, ReadData1 ,ALUa);
        Reg ID_EX_RegB(clk,, ReadData2 ,ALUb);
        
        wire [31:0] sext;
        Reg ID_EX_sext(clk,,SEXT, sext);
        wire [4:0] ex_ins20_16, ex_ins15_11;
        Reg #(5) ID_EX_ins20_16(clk,, ins20_16, ex_ins20_16);
        Reg #(5) ID_EX_ins15_11(clk,, ins15_11, ex_ins15_11);
        
        wire [31:0] ex_npc;
        Reg ID_EX_NPC(clk,, id_npc, ex_npc);
        
        //EX
        wire [31:0]SEXT_sft2;
        assign SEXT_sft2=SEXT<<2;
        
        wire [31:0] Add_result;
        Shift_Adder sft_adder(ex_npc, SEXT_sft2,Add_result);
        
        wire [31:0] ALUb_mux,ALUresult;
        Mux ALUSrcB(ALUSrc, ALUb, sext, ALUb_mux);
        wire [3:0]ALUctrl;
        wire cf,zf,of;
        ALUcontrol alu_control(clk,ALUOp,ins5_0, Immi_enable,Immi_func,ALUctrl);
        ALU alu(clk, ALUctrl,ALUa,ALUb_mux,cf, of,zf, ALUresult);
        
        wire [4:0] ins_mux;
        Mux #(5) ex_ins_mux(RegDst, ex_ins20_16, ex_ins15_11, ins_mux);
        
        //EX/ MEM
        //MEM signals
        wire mem_Branch, mem_Jump, mem_Bne, mem_MemWrite;
        Reg #(1) EX_MEM_Branch(clk, rst,ex_Branch, mem_Branch);
        Reg #(1) EX_MEM_ump(clk, rst,ex_Jump, mem_Jump);
        Reg #(1) EX_MEM_Bne(clk, rst,ex_Bne, mem_Bne);
        Reg #(1) EX_MEM_MemWrite(clk,rst, ex_MemWrite, mem_MemWrite);
        
        //WB signals
        wire mem_RegWrite, mem_MemtoReg;
        Reg #(1) EX_MEM_RegWrite(clk, rst,ex_RegWrite, mem_RegWrite);
        Reg #(1) EX_MEM_MemtoReg(clk,rst, ex_MemtoReg, mem_MemtoReg);
        
        wire [31:0] mem_ALUresult;
        wire [7:0] DataMem_addr;
        assign DataMem_addr = mem_ALUresult[9:2];
        
        wire [31:0]mem_ALUb;
        Reg EX_MEM_ALUresult(clk, ,ALUresult, mem_ALUresult);
        Reg EX_MEM_ALUb(clk,, ALUb, mem_ALUb);
        wire [4:0] mem_ins5;
        Reg #(5) EX_MEM_ins5(clk,, ins_mux, mem_ins5);
        wire mem_zf;
        Reg #(1) EX_MEM_zf(clk,,zf,mem_zf);
        wire mem_Add_result;
        Reg EX_MEM_Add_result(clk,,Add_result,mem_Add_result);
        
        //MEM
        
        assign PCSrc=((mem_Bne ^ mem_zf ) & mem_Branch) | mem_Jump; 
        
        wire [31:0] ReadData;
        
        DataMem data_mem(.clk(clk),.we(MemWrite), .a(DataMem_addr), .d(mem_ALUb),.dpra(addr),.dpo(mem_data), .spo(ReadData));
        
        assign  add_result_mux_in=mem_Add_result;
        
        wire[31:0] wb_ALUresult, wb_ReadData;
        Reg MEM_WB_ALUb (clk,, mem_ALUresult, wb_ALUresult);
        Reg MEM_WB_ReadData (clk,, ReadData, wb_ReadData);
        wire [4:0] wb_ins5;
        Reg #(5) MEM_WB_ins5(clk,, mem_ins5, wb_ins5);
        
        //
        //WB signals
        wire wb_RegWrite, wb_MemtoReg;
        Reg #(1) MEM_WB_RegWrite(clk, rst,mem_RegWrite, wb_RegWrite);
        Reg #(1) MEM_WB_MemtoReg(clk, rst,mem_MemtoReg, wb_MemtoReg);
        
        Mux wb_mux(wb_MemtoReg,wb_ALUresult, wb_ReadData, Reg_Writedata);
        
        assign Reg_Writeaddr=wb_ins5;
            
        assign Reg_write_en=wb_RegWrite;

    integer k;
   initial begin
        clk=0; rst=0; addr=7'b0000;
        for(k=0;k<1000;k=k+1) begin
            #5 clk=~clk;
            if(k==1) rst=1;
            else if(k==3) rst=0;
        end
   end
endmodule
