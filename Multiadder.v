
module multiadder(
  input [5:0]a,
  input clk,  //clk of register
  input en,
  input rst,
  output reg[5:0]out
);
  reg[5:0] sum;

  always @(posedge clk,posedge rst) begin
    if(rst) begin
      sum<=6'b000_000;
    end
    else if(en) begin
      sum=sum+a;
      out=sum;
    end 
    else begin
      out=sum;
    end 
  end

endmodule
