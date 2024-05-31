module encode #(
    OUT_WIDTH = 2
)(in, out);
    localparam IN_WIDTH = 1 << OUT_WIDTH;
    input      [ IN_WIDTH - 1: 0] in;
    output reg [OUT_WIDTH - 1: 0] out;

    integer i;
    always@(*)begin
        out = 0;
        for(i = IN_WIDTH - 1; i >= 0; i = i - 1) begin
            if(in[i]) begin
                out = i[OUT_WIDTH - 1:0];
                //break;
            end
        end
    end    
endmodule