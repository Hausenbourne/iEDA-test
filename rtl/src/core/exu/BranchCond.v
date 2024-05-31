module BranchCond(
    input [2:0]Branch,
    input      Zero,
    input      Less,
    output     PCAsrc,
    output     PCBsrc
);
    assign PCAsrc = 
          (~Branch[2] &  Branch[0]) 
        | (~Branch[1] &  Branch[0] & ~Zero) 
        | (~Branch[2] &  Branch[1]) 
        | ( Branch[1] & ~Branch[0] &  Less) 
        | ( Branch[1] &  Branch[0] & ~Less) 
        | ( Branch[2] & ~Branch[1] & ~Branch[0] &  Zero);
        
    assign PCBsrc = ~Branch[2] & Branch[1];

endmodule

//参考：https://nju-projectn.github.io/dlco-lecture-note/exp/11.html#tab-extop
//逻辑表达式由logisim生成