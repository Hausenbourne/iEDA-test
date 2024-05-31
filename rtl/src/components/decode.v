module decode#(
    IN_WIDTH = 2
)(in, out);
    localparam OUT_WIDTH = 1 << IN_WIDTH;
    input     [ IN_WIDTH - 1: 0] in ;
    output    [OUT_WIDTH - 1: 0] out;
    assign out = 1 << in;

endmodule