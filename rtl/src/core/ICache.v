module ICache(
    input             i_clk    ,
    input             i_rst    ,
    //axi-lite
    input     [31: 0] i_araddr ,
    input             i_arvalid,
    output            o_arready,
    output    [31: 0] o_rdata  ,
    output    [ 1: 0] o_rresp  ,
    output            o_rvalid ,
    input             i_rready ,
    //axi-full
    output    [31: 0] o_araddr ,
    output    [ 7: 0] o_arlen  ,
    output    [ 2: 0] o_arsize ,
    output    [ 1: 0] o_arburst,
    output            o_arvalid,
    input             i_arready,
    input     [31: 0] i_rdata  ,
    input     [ 1: 0] i_rresp  ,
    input             i_rlast  ,
    input             i_rvalid ,
    output            o_rready 
);
    // ------------------------------------------------------------------------------------------------------
    // # Design parameter definition.
    // ## For cache storage.
    

    //localparam CACHE_SIZE_WIDTH = 12;
    //localparam CACHE_WAY_WIDTH  =  4;
    //localparam BLOCK_SIZE_WIDTH =  7;
    localparam CACHE_SIZE_WIDTH = 6;
    localparam CACHE_WAY_WIDTH  = 1;
    localparam BLOCK_SIZE_WIDTH = 2;


    localparam ADDR_WIDTH       = 32;
    localparam DATA_WIDTH       = 32;

    localparam CACHE_SIZE       = 1 << CACHE_SIZE_WIDTH;
    localparam CACHE_WAY_NUM    = 1 << CACHE_WAY_WIDTH ;
    localparam BLOCK_SIZE       = 1 << BLOCK_SIZE_WIDTH;

    // ## For axi interface.
    localparam ARLEN            = BLOCK_SIZE/4 - 1;
    localparam ARSIZE           = 3'b010          ;
    localparam ARBURST          = 2'b01           ;

    // ## For state machine. [Grey Code]
    localparam WAIT_ARVALID     = 3'b000;
    localparam WAIT_ARREADY     = 3'b001;
    localparam WAIT_RVALID      = 3'b011;
    localparam WAIT_RLAST       = 3'b010;
    localparam UPD_VTAG         = 3'b110;
    localparam WAIT_RREADY      = 3'b100;
    // ------------------------------------------------------------------------------------------------------
    // # ICache control circuit.
    // ## Cache core instantiation. 

    wire [ADDR_WIDTH - 1: 0] cache_addr    ;
    wire                     cache_hit     ;
    wire [DATA_WIDTH - 1: 0] cache_rdata   ;
    
    wire                     cache_vtag_upd;
    wire                     cache_data_upd;
    wire [DATA_WIDTH - 1: 0] cache_wdata   ;

    cache_core 
    #(
        .CACHE_SIZE_WIDTH (CACHE_SIZE_WIDTH),
        .CACHE_WAY_WIDTH  (CACHE_WAY_WIDTH ),
        .BLOCK_SIZE_WIDTH (BLOCK_SIZE_WIDTH),
        .ADDR_WIDTH       (ADDR_WIDTH      ),
        .DATA_WIDTH       (DATA_WIDTH      )
    )cache_core_inst(
        .clk     (i_clk         ),
        .rst     (i_rst         ),
        .addr    (cache_addr    ),
        .hit     (cache_hit     ),
        .rdata   (cache_rdata   ),
        .vtag_upd(cache_vtag_upd),
        .data_upd(cache_data_upd),
        .wdata   (cache_wdata   )
    );
    // ## addr circuit.
    wire [ADDR_WIDTH - 1: 0] raddr           ;
    wire [ADDR_WIDTH - 1: 0] addr            ;

    wire [ADDR_WIDTH - 1: 0] addr_reg_d      ;
    wire [ADDR_WIDTH - 1: 0] addr_reg_q      ;
    wire                     addr_reg_e      ;

    Reg  # (ADDR_WIDTH, 0) addr_reg
    (
        .clk (i_clk           ),
        .rst (i_rst           ),
        .din (addr_reg_d      ),
        .dout(addr_reg_q      ),
        .wen (addr_reg_e      )
    );

    assign addr_reg_d = raddr                        ;
    assign addr       = addr_reg_e? raddr: addr_reg_q;
    // ## ICache addr circuit.
    wire                     cache_addr_sel          ;
    wire                     cache_addr_reg_inpu_sel ;
    wire [ADDR_WIDTH - 1: 0] bank_align_addr         ;
    
    wire [ADDR_WIDTH - 1: 0] cache_addr_reg_d        ;
    wire [ADDR_WIDTH - 1: 0] cache_addr_reg_q        ;
    wire                     cache_addr_reg_e        ;

    Reg  # (ADDR_WIDTH, 0) cache_addr_reg
    (
        .clk (i_clk           ),
        .rst (i_rst           ),
        .din (cache_addr_reg_d),
        .dout(cache_addr_reg_q),
        .wen (cache_addr_reg_e)
    );

    assign bank_align_addr  = addr & ~(BLOCK_SIZE - 1);
    assign cache_addr_reg_d = cache_addr_reg_inpu_sel? bank_align_addr: cache_addr_reg_q + DATA_WIDTH/8;
    assign cache_addr       = cache_addr_sel? cache_addr_reg_q: addr;
    // ------------------------------------------------------------------------------------------------------
    // # interface control.
    // ## resp signal.
    wire [ 1: 0] resp_reg_d;
    wire [ 1: 0] resp_reg_q;
    wire         resp_reg_e;

    Reg # (2, 0) resp_reg
    (
        .clk (i_clk           ),
        .rst (i_rst           ),
        .din (resp_reg_d      ),
        .dout(resp_reg_q      ),
        .wen (resp_reg_e      )
    );
    // ## state machine.
    reg [ 2: 0] state, nstate;
    always@(posedge i_clk) begin
        if(i_rst) begin
            state <= WAIT_ARVALID;
        end
        else begin
            state <= nstate      ;
        end
    end

    always@(*) begin
        case(state)
            WAIT_ARVALID: nstate = i_arvalid? (cache_hit? WAIT_RREADY: WAIT_ARREADY): WAIT_ARVALID;
            WAIT_ARREADY: nstate = i_arready       ? WAIT_RVALID : WAIT_ARREADY;
            WAIT_RVALID : nstate = i_rvalid ? (i_rlast  ? UPD_VTAG   : WAIT_RLAST  ): WAIT_RVALID ;
            WAIT_RLAST  : nstate = i_rlast         ? UPD_VTAG    : WAIT_RLAST  ;
            UPD_VTAG    : nstate = WAIT_RREADY                                 ;
            WAIT_RREADY : nstate = i_rready        ? WAIT_ARVALID: WAIT_RREADY ;  
            default     : nstate = WAIT_ARVALID                                ;
        endcase
    end
    // ------------------------------------------------------------------------------------------------------
    // # signal assign
    // ## with ifu (axi-lite)
    wire receive_addr_ok = i_arvalid & o_arready;
    wire trans_data_ok   = o_rvalid  & i_rready ;
    // ## with mem (axi-full)
    wire trans_addr_ok   = o_arvalid & i_arready;
    wire receive_data_ok = i_rvalid  & o_rready ;

    //wire raddr_ok    = o_arvalid & i_arready;
    //wire rdata_ok    = i_rvalid  & o_rready ;

    assign raddr     = i_araddr             ;
    assign o_arready = state == WAIT_ARVALID;
    assign o_rdata   =          cache_rdata ;
    assign o_rresp   = resp_reg_q           ;
    assign o_rvalid  = state == WAIT_RREADY ;

    assign addr_reg_e              = receive_addr_ok;
    //assign cache_addr_reg_inpu_sel = raddr_ok;
    assign cache_addr_reg_inpu_sel = receive_addr_ok;
    //assign cache_addr_sel          = rdata_ok;
    assign cache_addr_sel          = receive_data_ok;
    //assign cache_addr_reg_e        = raddr_ok | rdata_ok;
    assign cache_addr_reg_e        = receive_addr_ok | receive_data_ok;
    //assign cache_data_upd          = rdata_ok;
    assign cache_data_upd          = receive_data_ok;
    assign cache_vtag_upd          = state == UPD_VTAG;
    //assign resp_reg_e              = rdata_ok & i_rlast;
    assign resp_reg_e              = receive_data_ok & i_rlast;

    assign o_araddr                = cache_addr_reg_q;
    assign o_arlen                 = ARLEN ;
    assign o_arsize                = ARSIZE;
    assign o_arburst               = ARBURST;
    assign cache_wdata             = i_rdata;
    assign o_arvalid               = state == WAIT_ARREADY;
    assign resp_reg_d              = i_rresp;
    assign o_rready                = state == WAIT_RVALID | state == WAIT_RLAST;
    // ------------------------------------------------------------------------------------------------------
    // # Just for debug
    reg [103: 0] dbg_state;
    always@(*) begin
        case(state)
            WAIT_ARVALID: dbg_state = "WAIT_ARVALID";
            WAIT_ARREADY: dbg_state = "WAIT_ARREADY";
            WAIT_RVALID : dbg_state = "WAIT_RVALID" ;
            WAIT_RLAST  : dbg_state = "WAIT_RLAST"  ;
            UPD_VTAG    : dbg_state = "UPD_VTAG"    ;
            WAIT_RREADY : dbg_state = "WAIT_RREADY" ;
            default     : dbg_state = "UNKNOWN";
        endcase
    end
endmodule



module cache_core #(
    CACHE_SIZE_WIDTH = 12              ,
    CACHE_WAY_WIDTH  =  4              ,
    BLOCK_SIZE_WIDTH =  7              ,
    ADDR_WIDTH       = 32              ,
    DATA_WIDTH       = 32              
)(
    clk                                ,
    rst                                ,
    addr                               ,
    hit                                ,
    rdata                              ,
    vtag_upd                           ,
    data_upd                           ,
    wdata   
);
    // ------------------------------------------------------------------------------------------------------------------------
    // # Pin definition 
    input                      clk     ;
    input                      rst     ;
    input  [ADDR_WIDTH - 1: 0] addr    ;
    input                      vtag_upd;
    input                      data_upd;
    input  [DATA_WIDTH - 1: 0] wdata   ;
    output                     hit     ;
    output [DATA_WIDTH - 1: 0] rdata   ;
    // ------------------------------------------------------------------------------------------------------------------------
    // # Local parameter definition 
    localparam CACHE_SIZE    = 1 << CACHE_SIZE_WIDTH;
    localparam CACHE_WAY_NUM = 1 << CACHE_WAY_WIDTH ;
    localparam BLOCK_SIZE    = 1 << BLOCK_SIZE_WIDTH;
    // ------------------------------------------------------------------------------------------------------------------------
    // # Line network definition
    wire [  CACHE_WAY_NUM - 1: 0] cache_way_valid;
    wire [  CACHE_WAY_NUM - 1: 0] cache_way_hit  ;
    wire [     DATA_WIDTH - 1: 0] cache_way_rdata [CACHE_WAY_NUM - 1: 0];
    wire [CACHE_WAY_WIDTH - 1: 0] cache_way_sel  ;
    wire [  CACHE_WAY_NUM - 1: 0] replace_way_sel;
    // ------------------------------------------------------------------------------------------------------------------------
    // # cache way instantiation 
    genvar g;
    generate
        for(g = 0; g < CACHE_WAY_NUM; g=g+1)begin:cache_way_inst
            cache_way #(
                .ADDR_WIDTH  (                                            ADDR_WIDTH),
                .DATA_WIDTH  (                                            DATA_WIDTH),
                .TAG_WIDTH   (ADDR_WIDTH       - CACHE_SIZE_WIDTH + CACHE_WAY_WIDTH ),
                .INDEX_WIDTH (CACHE_SIZE_WIDTH - CACHE_WAY_WIDTH  - BLOCK_SIZE_WIDTH),
                .OFFSET_WIDTH(                                      BLOCK_SIZE_WIDTH)
            )cache_way_inst(
                .clk     (clk                          ),
                .rst     (rst                          ),
                .addr    (addr                         ),
                .vtag_upd(vtag_upd & replace_way_sel[g]),
                .wen     (data_upd & replace_way_sel[g]),
                .wdata   (wdata                        ),
                .valid   (cache_way_valid[g]           ),
                .hit     (cache_way_hit[g]             ),
                .rdata   (cache_way_rdata[g]           )
            );
        end
    endgenerate

    encode #(
        .OUT_WIDTH(CACHE_WAY_WIDTH)
    ) encode_inst(
        .in (cache_way_hit), 
        .out(cache_way_sel)
    );

    assign rdata = cache_way_rdata[cache_way_sel];
    assign hit = |cache_way_hit                  ;
    // ------------------------------------------------------------------------------------------------------------------------
    // # cache way Replacement algorithm

    // ## find unvalid way
    integer i;
    reg [CACHE_WAY_NUM - 1: 0] unvalid_way_sel;
    reg found;
    always @(*) begin
        unvalid_way_sel = 'b1;
        found = 1'b0;
        for (i = 0; i < CACHE_WAY_NUM; i = i + 1) begin
            if (~cache_way_valid[i] && !found) begin
                found = 1'b1;
            end
            if (!found) begin
                unvalid_way_sel = unvalid_way_sel << 1;
            end
        end
    end

    // ## Random replacement algorithm
    wire [ 7: 0] random    ; 
    lfsr lfsr_inst( 
        .clk       (clk   ),  
        .reset     (rst   ),  
        .random_val(random) 
    );

    // ## replace way reg
    wire [CACHE_WAY_NUM - 1: 0] replace_way_reg_d;
    wire [CACHE_WAY_NUM - 1: 0] replace_way_reg_q;
    wire                        replace_way_reg_e;

    Reg # (CACHE_WAY_NUM, 0) replace_way_reg
    (
        .clk (clk              ),
        .rst (rst              ),
        .din (replace_way_reg_d),
        .dout(replace_way_reg_q),
        .wen (replace_way_reg_e)
    );

    assign replace_way_reg_d = (&cache_way_valid)? (1 << random[CACHE_WAY_WIDTH - 1: 0]): unvalid_way_sel;
    assign replace_way_reg_e = data_upd                                                                  ; 
    assign replace_way_sel   = data_upd? replace_way_reg_d: replace_way_reg_q                            ;

endmodule

module cache_way # (
    ADDR_WIDTH  = 32,
    DATA_WIDTH  = 32,
    TAG_WIDTH   = 24,
    INDEX_WIDTH =  1,
    OFFSET_WIDTH=  7
)(
    clk                                ,
    rst                                ,
    addr                               ,
    vtag_upd                           ,
    wen                                ,
    wdata                              ,
    valid                              ,
    hit                                ,
    rdata                              
);
    // ------------------------------------------------------------------------------------------------------------------------
    // # Pin definition
    input                           clk;
    input                           rst;
    input  [ADDR_WIDTH - 1: 0]     addr;
    input                      vtag_upd;
    input                           wen;
    input  [DATA_WIDTH - 1: 0]    wdata;
    output                        valid;
    output                          hit;
    output [DATA_WIDTH - 1: 0]    rdata;
    // ------------------------------------------------------------------------------------------------------------------------
    // # Line network definition
    wire [  TAG_WIDTH - 1: 0]     tag = addr[TAG_WIDTH + INDEX_WIDTH + OFFSET_WIDTH - 1:INDEX_WIDTH + OFFSET_WIDTH];
    wire [INDEX_WIDTH - 1: 0]   index = addr[            INDEX_WIDTH + OFFSET_WIDTH - 1:              OFFSET_WIDTH];
    wire [ OFFSET_WIDTH-1: 0]  offset = addr[                          OFFSET_WIDTH - 1:                         0];
    // ------------------------------------------------------------------------------------------------------------------------
    // # vtag_way and data_way inst

    wire [1+TAG_WIDTH-1: 0] vtag_out;
    vtag_way #(
        .TAG_WIDTH   (   TAG_WIDTH),
        .INDEX_WIDTH ( INDEX_WIDTH),
        .OFFSET_WIDTH(OFFSET_WIDTH)
    )vtag_way_inst(
        .clk  (clk       ),
        .rst  (rst       ),
        .index(index     ),
        .din  ({1'b1,tag}),
        .wen  (vtag_upd  ),
        .dout (vtag_out  )
    );

    data_way #(
        .INDEX_WIDTH ( INDEX_WIDTH),
        .OFFSET_WIDTH(OFFSET_WIDTH),
        .DATA_WIDTH  (  DATA_WIDTH)
    )data_way_inst(
        .clk   (clk       ),
        .index (index     ),
        .offset(offset    ),
        .wen   (wen       ),
        .wdata (wdata     ),
        .rdata (rdata     )
    );

    assign valid = vtag_out[TAG_WIDTH]                     ;
    assign hit   = valid & (vtag_out[TAG_WIDTH - 1 :0] == tag);

endmodule



module data_way #(
    INDEX_WIDTH  =  1,
    OFFSET_WIDTH =  7,
    DATA_WIDTH   = 32
)(
    clk                                 ,
    index                               ,
    offset                              ,
    wen                                 ,
    wdata                               ,
    rdata                               
);
    // ------------------------------------------------------------------------------------------------------------------------
    // Pin definition
    localparam LINE_NUM = 1 << INDEX_WIDTH;

    input                         clk   ;
    input   [ INDEX_WIDTH - 1: 0] index ;
    input   [OFFSET_WIDTH - 1: 0] offset;
    input                         wen   ;
    input   [              31: 0] wdata ;
    output  [               31:0] rdata ;
    // ------------------------------------------------------------------------------------------------------------------------
    // data bank sram inst
    wire  [      LINE_NUM-1: 0] sel = 1 << index;

    wire [31:0] line_data_out [LINE_NUM-1: 0];

    genvar i;
    generate
        for(i = 0; i < LINE_NUM; i=i+1)begin:data_bank_sram_inst
            data_bank_sram #(
                .DATA_WIDTH     (  DATA_WIDTH),
                .BANK_ADDR_WIDTH(OFFSET_WIDTH)
            )
            data_bank_sram_inst(
                .clk (clk             ),
                .addr(offset          ),
                .ena (sel[i]          ),
                .wen (sel[i] & wen    ),
                .din (wdata           ),
                .dout(line_data_out[i])
            );
        end
    endgenerate

    assign rdata = line_data_out[index];

endmodule

module vtag_way #(
    TAG_WIDTH    = 24,
    INDEX_WIDTH  =  1,
    OFFSET_WIDTH =  7
)(
    clk                               ,
    rst                               ,
    index                             ,
    din                               ,
    wen                               ,
    dout                              
);
    // ------------------------------------------------------------------------------------------------------------------------
    // pin definition
    localparam LINE_NUM = 1 << INDEX_WIDTH;

    input                        clk  ;
    input                        rst  ;
    input  [ INDEX_WIDTH - 1: 0] index;
    input  [   1+TAG_WIDTH-1: 0] din  ;
    input                        wen  ;
    output [   1+TAG_WIDTH-1: 0] dout ;
    // ------------------------------------------------------------------------------------------------------------------------
    // valid tag register 
    wire  [      LINE_NUM-1: 0] sel = 1 << index;

    wire [1+TAG_WIDTH-1: 0] line_vtag_out [LINE_NUM-1: 0];

    genvar i;
    generate
        for(i = 0; i < LINE_NUM; i = i+1)begin:vtag_reg_inst
            Reg #(1+TAG_WIDTH, 0) vtag_reg(
                .clk (clk             ),
                .rst (rst             ),
                .din (din             ),
                .dout(line_vtag_out[i]),
                .wen (wen&sel[i]      )
            );
        end
    endgenerate
    
    assign dout = line_vtag_out[index];

endmodule



module data_bank_sram #(
    DATA_WIDTH      = 32,
    BANK_ADDR_WIDTH =  7
)(
    input                           clk  ,
    input  [BANK_ADDR_WIDTH - 1: 0] addr ,
    input                           ena  ,
    input                           wen  ,
    input  [                 31: 0] din  ,
    output [                 31: 0] dout
);
    localparam ADDR_SIZE = 1<<BANK_ADDR_WIDTH;

    reg [             7: 0] data_sram [ADDR_SIZE - 1: 0];

    reg [DATA_WIDTH - 1: 0] output_buffer;
    always@(posedge clk) begin
        if(ena) begin
            if(wen) begin
                data_sram[addr    ] <= din[ 7: 0];  
                data_sram[addr + 1] <= din[15: 8];  
                data_sram[addr + 2] <= din[23:16];  
                data_sram[addr + 3] <= din[31:24];
            end
            else begin
                //output_buffer <= {data_sram[addr], data_sram[addr+1], data_sram[addr+2], data_sram[addr+3]};
                output_buffer <= {data_sram[addr+3], data_sram[addr+2], data_sram[addr+1], data_sram[addr]};
            end
        end
    end
    assign dout = output_buffer;
endmodule


module lfsr
( 
    input           clk         ,
    input           reset       ,
    output  [ 7: 0] random_val  
);

    reg [7:0] r_lfsr;

    always @(posedge clk) begin
        if (reset) begin
            r_lfsr <= 8'b1;
        end
        else begin
            r_lfsr[0] <= r_lfsr[7];
            r_lfsr[1] <= r_lfsr[0];
            r_lfsr[2] <= r_lfsr[1];
            r_lfsr[3] <= r_lfsr[2];
            r_lfsr[4] <= r_lfsr[3] ^ r_lfsr[7];
            r_lfsr[5] <= r_lfsr[4] ^ r_lfsr[7];
            r_lfsr[6] <= r_lfsr[5] ^ r_lfsr[7];
            r_lfsr[7] <= r_lfsr[6];
        end
    end
    assign random_val = r_lfsr;
endmodule
