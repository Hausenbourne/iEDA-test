module arbiter(
    input          clk_i       ,
    input          rst_n_i     ,
    //master 0
    input  [ 3: 0] m0_arid_i   ,
    input  [31: 0] m0_araddr_i ,
    input  [ 7: 0] m0_arlen_i  ,
    input  [ 2: 0] m0_arsize_i ,
    input  [ 1: 0] m0_arburst_i,
    input          m0_arvalid_i,
    output         m0_arready_o,

    output [ 3: 0] m0_rid_o    ,
    output [31: 0] m0_rdata_o  ,
    output [ 1: 0] m0_rresp_o  ,
    output         m0_rlast_o  ,
    output         m0_rvalid_o ,
    input          m0_rready_i ,

    input  [ 3: 0] m0_awid_i   ,
    input  [31: 0] m0_awaddr_i ,
    input  [ 7: 0] m0_awlen_i  ,
    input  [ 2: 0] m0_awsize_i ,
    input  [ 1: 0] m0_awburst_i,
    input          m0_awvalid_i,
    output         m0_awready_o,

    input  [ 3: 0] m0_wid_i    ,
    input  [31: 0] m0_wdata_i  ,
    input  [ 3: 0] m0_wstrb_i  ,
    input          m0_wlast_i  ,
    input          m0_wvalid_i ,
    output         m0_wready_o ,

    output [ 3: 0] m0_bid_o    ,
    output [ 1: 0] m0_bresp_o  ,
    output         m0_bvalid_o ,
    input          m0_bready_i ,
    //master 1
    input  [ 3: 0] m1_arid_i   ,
    input  [31: 0] m1_araddr_i ,
    input  [ 7: 0] m1_arlen_i  ,
    input  [ 2: 0] m1_arsize_i ,
    input  [ 1: 0] m1_arburst_i,
    input          m1_arvalid_i,
    output         m1_arready_o,

    output [ 3: 0] m1_rid_o    ,
    output [31: 0] m1_rdata_o  ,
    output [ 1: 0] m1_rresp_o  ,
    output         m1_rlast_o  ,
    output         m1_rvalid_o ,
    input          m1_rready_i ,

    input  [ 3: 0] m1_awid_i   ,
    input  [31: 0] m1_awaddr_i ,
    input  [ 7: 0] m1_awlen_i  ,
    input  [ 2: 0] m1_awsize_i ,
    input  [ 1: 0] m1_awburst_i,
    input          m1_awvalid_i,
    output         m1_awready_o,

    input  [ 3: 0] m1_wid_i    ,
    input  [31: 0] m1_wdata_i  ,
    input  [ 3: 0] m1_wstrb_i  ,
    input          m1_wlast_i  ,
    input          m1_wvalid_i ,
    output         m1_wready_o ,

    output [ 3: 0] m1_bid_o    ,
    output [ 1: 0] m1_bresp_o  ,
    output         m1_bvalid_o ,
    input          m1_bready_i ,
    //slaver
    output [ 3: 0] arid_o      ,
    output [31: 0] araddr_o    ,
    output [ 7: 0] arlen_o     ,
    output [ 2: 0] arsize_o    ,
    output [ 1: 0] arburst_o   ,
    output         arvalid_o   ,
    input          arready_i   ,

    input  [ 3: 0] rid_i       ,
    input  [31: 0] rdata_i     ,
    input  [ 1: 0] rresp_i     ,
    input          rlast_i     ,
    input          rvalid_i    ,
    output         rready_o    ,

    output [ 3: 0] awid_o      ,
    output [31: 0] awaddr_o    ,
    output [ 7: 0] awlen_o     ,
    output [ 2: 0] awsize_o    ,
    output [ 1: 0] awburst_o   ,
    output         awvalid_o   ,
    input          awready_i   ,

    output [ 3: 0] wid_o       ,
    output [31: 0] wdata_o     ,
    output [ 3: 0] wstrb_o     ,
    output         wlast_o     ,
    output         wvalid_o    ,
    input          wready_i    ,

    input  [ 3: 0] bid_i       ,
    input  [ 1: 0] bresp_i     ,
    input          bvalid_i    ,
    output         bready_o    

);
    wire rst = ~ rst_n_i                                   ;
    // ===========================================================================
    // read arbiter state machine
    parameter WAIT_ARVALID = 3'b001                        ;
    parameter M0_READ      = 3'b010                        ;
    parameter M1_READ      = 3'b100                        ;

    reg [ 2: 0] read_arbiter_state, next_read_arbiter_state;

    always @(posedge clk_i) begin
        if(rst) 
            read_arbiter_state <= WAIT_ARVALID             ;
        else
            read_arbiter_state <= next_read_arbiter_state  ;
    end

    always @(*) begin
        case(read_arbiter_state)
            WAIT_ARVALID: next_read_arbiter_state =                  m0_arvalid_i? M0_READ     : (m1_arvalid_i? M1_READ: WAIT_ARVALID);
            M0_READ     : next_read_arbiter_state = rlast_i & rvalid_i & rready_o? WAIT_ARVALID:                               M0_READ;
            M1_READ     : next_read_arbiter_state = rlast_i & rvalid_i & rready_o? WAIT_ARVALID:                               M1_READ;
            default     : next_read_arbiter_state = WAIT_ARVALID                                                                      ;
        endcase
    end

    //output
    assign arid_o       = m0_arvalid_i? m0_arid_i   : m1_arvalid_i? m1_arid_i   :  4'b0;
    assign araddr_o     = m0_arvalid_i? m0_araddr_i : m1_arvalid_i? m1_araddr_i : 32'b0;
    assign arlen_o      = m0_arvalid_i? m0_arlen_i  : m1_arvalid_i? m1_arlen_i  :  8'b0;
    assign arsize_o     = m0_arvalid_i? m0_arsize_i : m1_arvalid_i? m1_arsize_i :  3'b0;
    assign arburst_o    = m0_arvalid_i? m0_arburst_i: m1_arvalid_i? m1_arburst_i:  2'b0;
    assign arvalid_o    = m0_arvalid_i? m0_arvalid_i: m1_arvalid_i? m1_arvalid_i:  1'b0;
    
    assign rready_o     = (read_arbiter_state == M0_READ)? m0_rready_i : (read_arbiter_state == M1_READ)? m1_rready_i :  1'b0;

    assign m0_arready_o = m0_arvalid_i? arready_i: 1'b0;
    assign m1_arready_o = m1_arvalid_i? arready_i: 1'b0;
    
    assign m0_rid_o     = (read_arbiter_state == M0_READ)?     rid_i: 4'b0;
    assign m1_rid_o     = (read_arbiter_state == M1_READ)?     rid_i: 4'b0;
    assign m0_rdata_o   = (read_arbiter_state == M0_READ)?   rdata_i:32'b0;
    assign m1_rdata_o   = (read_arbiter_state == M1_READ)?   rdata_i:32'b0;
    assign m0_rresp_o   = (read_arbiter_state == M0_READ)?   rresp_i: 2'b0;
    assign m1_rresp_o   = (read_arbiter_state == M1_READ)?   rresp_i: 2'b0;
    assign m0_rlast_o   = (read_arbiter_state == M0_READ)?   rlast_i: 1'b0;
    assign m1_rlast_o   = (read_arbiter_state == M1_READ)?   rlast_i: 1'b0;
    assign m0_rvalid_o  = (read_arbiter_state == M0_READ)?  rvalid_i: 1'b0;
    assign m1_rvalid_o  = (read_arbiter_state == M1_READ)?  rvalid_i: 1'b0;
    // ===========================================================================
    // write arbiter state machine
    parameter WAIT_AWVALID = 3'b001;
    parameter M0_WRITE     = 3'b010;
    parameter M1_WRITE     = 3'b100;

    reg [ 2: 0] write_arbiter_state, next_write_arbiter_state;

    always @(posedge clk_i) begin
        if(rst) 
            write_arbiter_state <= WAIT_AWVALID              ;
        else
            write_arbiter_state <= next_write_arbiter_state  ;
    end

    always @(*) begin
        case(write_arbiter_state)
            WAIT_AWVALID: next_write_arbiter_state =            m0_awvalid_i? M0_WRITE    : (m1_awvalid_i? M1_WRITE: WAIT_AWVALID);
            M0_WRITE    : next_write_arbiter_state = bvalid_i & m0_bready_i ? WAIT_AWVALID:                               M0_WRITE;
            M1_WRITE    : next_write_arbiter_state = bvalid_i & m1_bready_i ? WAIT_AWVALID:                               M1_WRITE;
            default     : next_write_arbiter_state = WAIT_AWVALID                                                                 ;
        endcase
    end

    //output
    assign awid_o   = m0_awvalid_i? m0_awid_i   : m1_awvalid_i? m1_awid_i   :  4'b0;
    assign awaddr_o = m0_awvalid_i? m0_awaddr_i : m1_awvalid_i? m1_awaddr_i : 32'b0;
    assign awlen_o  = m0_awvalid_i? m0_awlen_i  : m1_awvalid_i? m1_awlen_i  :  8'b0;
    assign awsize_o = m0_awvalid_i? m0_awsize_i : m1_awvalid_i? m1_awsize_i :  3'b0;
    assign awburst_o= m0_awvalid_i? m0_awburst_i: m1_awvalid_i? m1_awburst_i:  2'b0;
    assign awvalid_o= m0_awvalid_i? m0_awvalid_i: m1_awvalid_i? m1_awvalid_i:  1'b0;
    assign wid_o    = m0_awvalid_i? m0_wid_i    : m1_awvalid_i? m1_wid_i    :  4'b0;
    assign wdata_o  = m0_awvalid_i? m0_wdata_i  : m1_awvalid_i? m1_wdata_i  : 32'b0;
    assign wstrb_o  = m0_awvalid_i? m0_wstrb_i  : m1_awvalid_i? m1_wstrb_i  :  4'b0;
    assign wlast_o  = m0_awvalid_i? m0_wlast_i  : m1_awvalid_i? m1_wlast_i  :  1'b0;
    assign wvalid_o = m0_awvalid_i? m0_wvalid_i : m1_awvalid_i? m1_wvalid_i :  1'b0;

    assign bready_o = (write_arbiter_state == M0_WRITE)? m0_bready_i : (write_arbiter_state == M1_WRITE)? m1_bready_i :  1'b0;

    assign m0_awready_o = m0_awvalid_i? awready_i: 1'b0;
    assign m1_awready_o = m1_awvalid_i? awready_i: 1'b0;
    assign m0_wready_o  = m0_awvalid_i? wready_i : 1'b0;
    assign m1_wready_o  = m1_awvalid_i? wready_i : 1'b0;
    
    assign m0_bid_o     = (write_arbiter_state == M0_WRITE)? bid_i    : 4'b0;
    assign m1_bid_o     = (write_arbiter_state == M1_WRITE)? bid_i    : 4'b0;
    assign m0_bresp_o   = (write_arbiter_state == M0_WRITE)? bresp_i  : 2'b0;
    assign m1_bresp_o   = (write_arbiter_state == M1_WRITE)? bresp_i  : 2'b0;
    assign m0_bvalid_o  = (write_arbiter_state == M0_WRITE)? bvalid_i : 1'b0;
    assign m1_bvalid_o  = (write_arbiter_state == M1_WRITE)? bvalid_i : 1'b0;


endmodule