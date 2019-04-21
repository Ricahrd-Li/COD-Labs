# COD-Labs
## Here I save my code lab codes in the process of development. 
# ***Please don't copy my codes without declaration.***
---
### A small summary
**实验中90%的错误来源于对verilog语法逻辑理解的不足，往往是用写C的思维在写verilog。**

一些需要注意的点：
1. 分清**组合逻辑**与**时序逻辑**的不同
   + 组合逻辑里面不能有反馈，如count=count+1，否则会出现无限循环
   + 组合逻辑里面写if必须要对应写else（否则会出现锁存器，导致组合与时序掺杂，下载后出现问题），时序逻辑则不是
2. 声明一个变量为reg不代表implement的时候就是一个reg，有可能为wire，看是什么逻辑
3. **锁存器**与**触发器**的区别？
   + 在verilog中触发器对应的always块应该@posedge clk,这样生成触发器
