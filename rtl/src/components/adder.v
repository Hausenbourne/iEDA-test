/*加减法器组件*/
module Adder #(DATA_LEN = 32)(
    input [DATA_LEN-1:0]A,
    input [DATA_LEN-1:0]B,
    input Cin,
    output Carry,
    output Zero,
    output Overflow,
    output [DATA_LEN-1:0]Result
);
    wire [DATA_LEN-1:0] t_no_Cin;
    assign t_no_Cin           = B ^ {DATA_LEN{Cin}};
    assign {Carry, Result}    = A + t_no_Cin + {{31{1'b0}},Cin};
    assign Overflow           = (A[DATA_LEN-1] == t_no_Cin[DATA_LEN-1]) && (Result [DATA_LEN-1] != A[DATA_LEN-1]);
    assign Zero               = ~(|Result);

endmodule


//参考：https://nju-projectn.github.io/dlco-lecture-note/exp/03.html