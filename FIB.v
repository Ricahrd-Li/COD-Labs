module Fib(
  input clk,
  input rst,
  input [5:0]f0,
  input [5:0]f1,
  output reg[5:0]fn
);
  reg[5:0] r0,r1,tmpr;
  
  initial begin   //initial Ã»ÓÐÖ´ÐÐ£¿£¿£¿
    r0=f0;
    r1=f1;
  end  
  
  always @(posedge clk,posedge rst) begin
    if(rst) begin
      r0<=f0;
      r1<=f1;
    end
    else begin
      tmpr=r0+r1;
      r0=r1;
      r1=tmpr;
      fn=tmpr;
    end
  end

endmodule