`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/06 11:50:13
// Design Name: 
// Module Name: Control
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

module Control(   
    input clk,rst,
    input [5:0]Op,
    output reg [1:0] PCSource, ALUOp, ALUSrcB, 
    output  reg ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite, Immi_enable,
    output reg [1:0]Immi_func
    );
    parameter Sinitial=4'b1111,S0=4'b0000, S1=4'b0001,S2=4'b0010,S3=4'b0011, S4=4'b0100,S5=4'b0101,S6=4'b0110, S7=4'b0111,S8=4'b1000,S9=4'b1001,S10=4'b1010,S11=4'b1011,S12=4'b1100;
    reg [4:0]state,nextstate;
    always @(posedge clk,posedge rst)begin
        if(rst) state<=Sinitial;
        else state<=nextstate;
    end
    
    always @* begin
        case(state)
            Sinitial: nextstate=S0;
            S0: nextstate=S1;
            S1: begin
                case(Op)
                    //# First implement lw, sw, R-type, beq,  j
                    6'b000000: nextstate=S6; //R-type: and, sub, and, or, xor, nor, slt 
                    6'b100011: nextstate=S2;  //lw  
                    6'b101011: nextstate=S2;  //sw
                    6'b000100: nextstate=S8;  //beq
                    6'b000010: nextstate=S9;  //j 
                    6'b000101: nextstate=S10; //bnq
                     //I-type//immidiata: addi, andi, ori
                    6'b001000: begin nextstate=S11; Immi_func=2'b00; end //addi
                    6'b001100: begin nextstate=S11; Immi_func=2'b01; end //andi
                    default: begin nextstate=S11; Immi_func=2'b10; end //ori
                endcase 
            end
            S2: begin 
                if(Op==6'b100011) nextstate=S3;
                if(Op==6'b101011) nextstate=S5;
           end
           S3: nextstate=S4;
           S6: nextstate=S7;
           S11: nextstate=S12;
           default: nextstate=S0; 
        endcase    
    end
    
    always @ * begin
        case(nextstate)
            S0: begin    // IR=mem[PC], PC+=4; 
                //PC+=4: PCSource =00, PCWrite=1, ALUSrcB=1, ALUSrcA=0, ALUOp=00 (PC will increase at the next clk poesedge)  
                //IR=mem[PC]: IRWrite=1;
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite, Immi_enable}<=
                {2'b00,       2'b00,  2'b01,     1'b0,       1'b0,        1'b0,     1'b0,             1'b1,      1'b0, 1'b1,        1'b0,          1'b0,         1'b1    , 1'b0};              
            end  
            
            S1: begin   //Decode: RegA=RF[IR[25-21]], RegB=RF[IR[20-16]], ALUOut=PC+(SE(IR[15-0])<<2)
                //ALUOut=PC+(SE(IR[15-0])<<2):   ALUSrcA=0, ALUSrcB=11, ALUOp=00, 
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b00,  2'b11,     1'b0,       1'b0,        1'b0,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
            end    
            
            S2: begin //Opcode=LW or SW:  Memory Address Computation: ALUOut= A + SE(IR[15-0]) 
                 // ALUOut= A + SE(IR[15-0]) : ALUSrcA=1, ALUSrcB=10, ALUOp=00
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b00,  2'b10,     1'b1,       1'b0,        1'b0,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
            end

            S3: begin //Memory Access: MDR=Mem[ALUOut],
                 // lorD=1, MemRead=1
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b00,  2'b10,     1'b1,       1'b0,        1'b0,     1'b0,             1'b0,      1'b1, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
            end
            
            S4: begin // Write Back: RF[IR[20-16]] =MDR
                // RegWrite=1, RegDst=0, MemroReg=1
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b00,  2'b10,     1'b1,       1'b1,        1'b0,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b1,         1'b0   , 1'b0  };                
            end 
                                                 
             S5: begin  //Memory Access: Mem[ALUOut] = B
                 // MemWrite=1, lorD=1 
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b00,  2'b10,     1'b1,       1'b0,        1'b0,     1'b0,             1'b0,      1'b1, 1'b1,        1'b1,          1'b0,         1'b0   , 1'b0  };                
            end    
                  
            S6: begin  // R-type Execution ALUOut = A Op B
                  // ALUSrcA=1, ALUSrcB=00, ALUOp = 10 
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b10,  2'b00,     1'b1,       1'b0,        1'b0,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0    , 1'b0 };                
            end
            
            S7: begin  // R-type WriteBack to RF
                 //RegWrite=1, RegDst=1, MemtoReg=0
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b10,  2'b00,     1'b1,       1'b1,        1'b1,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
            end
            
            S8: begin  //Op="BEQ"  if(A== B) PC=ALUOut
                 //if(A==B) need to calculate A-B: ALUSrcA=1, ALUSrcB=0, ALUOp=01
                 // PC=ALUOut: PCWrite=0, PCWriteCond=1, PCSource=01
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b01,       2'b01,  2'b00,     1'b1,       1'b0,        1'b0,     1'b1,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
            end
            
            S9: begin  //Jump: 
                    // PCWrite=1, PCSource=10
                    {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                    {2'b10,       2'b00,  2'b00,     1'b1,       1'b0,        1'b0,     1'b0,             1'b1,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
            end
            
            S10: begin  // Op="bnq" if(A!=B) PC=ALUOut
                 //if(A!=B) need to calculate A-B: ALUSrcA=1, ALUSrcB=00, ALUOp=01
                 // PC=ALUOut: PCWrite=0, PCWriteCond=1, PCSource=01
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b01,       2'b01,  2'b00,     1'b1,       1'b0,        1'b0,     1'b1,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
        end
            S11: begin  //Op= addi / ori  : ALUOut = A + SE(IR[15-0]) : 
                 // ALUSrcA=1, ALUSrcB=10, ALUOp=10  
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b10,  2'b10,     1'b1,       1'b0,        1'b0,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b1};                
        end                        
            default:begin
                {PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCWriteCond, PCWrite, lorD, MemRead, MemWrite, MemtoReg, IRWrite,Immi_enable}<=
                {2'b00,       2'b10,  2'b00,     1'b1,       1'b1,        1'b0,     1'b0,             1'b0,      1'b0, 1'b1,        1'b0,          1'b0,         1'b0     , 1'b0};                
        end
        endcase 
    end
    
endmodule
