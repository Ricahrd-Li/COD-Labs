module Fib(
  input clk,
  input rst,
  input [5:0]f0,
  input [5:0]f1,
  output reg[5:0]fn
);
  reg[5:0] r0,r1,tmpr;
  wire[5:0]sum;
  wire[2:0]s;
  
  assign s=3'b000;
  
  initial begin   //initial 没有执行？？？
    r0=f0;
    r1=f1;
  end  
  
  ALU add(clk,s,r0,r1,,sum);
  
  always @(posedge clk,posedge rst) begin
    if(rst) begin
      r0<=f0;
      r1<=f1;
    end
    else begin
      tmpr=sum; // 这里我不知道怎么解决，应该是对verilog理解不够深入
      r0=r1;
      r1=tmpr;
      fn=tmpr;
    end
  end

endmodule
