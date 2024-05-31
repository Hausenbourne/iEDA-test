module counter(
    input                    i_clk,
    input                    i_set,
    input                    i_ena,
    input      [ 7: 0] i_count_num,
    output reg              o_done
);

    reg [ 7: 0] count_num;

    /*
    always@(posedge i_clk)begin
        if(i_set) begin 
            count_num <= i_count_num;
            o_done    <= 1'b0;
        end

        else if(i_ena)begin
            if(count_num == 8'b1) begin 
                o_done <= 1'b1;
            end

            else begin
                count_num <= count_num - 1;
            end
        end

        else begin
            count_num <= i_count_num;
            o_done    <= 1'b0;
        end
    end
    */

    parameter IDLE  = 1'b0;
    parameter COUNT = 1'b1;
    reg state, next_state;

    always @(posedge i_clk) begin
        if(~i_rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE   : next_state = i_ena ? COUNT: IDLE ;
            COUNT  : next_state = o_done? IDLE : COUNT; 
            default: next_state = IDLE                ; 
        endcase
    end

    always @(posedge i_clk) begin

        if(i_set) begin 
            count_num <= i_count_num;
            o_done    <= 1'b0;
        end

        else if(state == COUNT) begin
            count_num <= count_num - 1;
        end

        else if(count_num == 8'b1) begin
            o_done    <= 1'b1;
        end

        else begin
            
        end

    
    end

endmodule