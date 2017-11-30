
module comm
  #(
    // modtype
    // 1 -> BPSK
    // 2 -> QPSK
    // 4 -> 16QAM
    parameter modtype = 1,

    // min value of latency from da_valid to ad_valid
    // selection width is 4, which means that max is valid_delay_min + 16
    parameter valid_delay_min = 24
    )
   (
    input         CLK,
    input         RST,

    input [7:0]   ad1,
    input [7:0]   ad2,

    output [5:0]  da1,
    output [5:0]  da2,

    input         valid_i,
    input [31:0]  data_i,
    output        ack_i,

    output        valid_o,
    output [31:0] data_o,
    input         ack_o,

    input [3:0]   ad1_delay,
    input [3:0]   ad2_delay,
    input [3:0]   ad_valid_delay,

    output [7:0]  raw_send_d,
    output [7:0]  raw_recv,
    output        valid_raw
    );

   wire           valid_raw_send;
   wire           valid_raw_recv;
   wire [7:0]     raw_send;

   assign valid_raw = valid_raw_recv;

   // **************************************************
   // DELAY
   //   8*2             8*2
   // ---/--- [DELAY] ---/---> comm_recv
   // **************************************************
   wire [7:0]     ad1_dl, ad2_dl;
   wire           da_valid;
   wire           ad_valid;

   variable_delay
     #(.width(1),
       .sel_width(4),
       .delay_min(valid_delay_min),
       .with_reset(1),
       .rstval(1'b0))
   ad_valid_delay_inst
     (.CLK(CLK),
      .RST(RST),
      .ce(1'b1),
      .din(da_valid),
      .sel(ad_valid_delay),
      .dout(ad_valid));

`ifdef SIMULATION
assign raw_send_d = raw_send;
`else
   fifo_raw_send fifo_raw_send
     (.clk(CLK),
      .rst(!RST),

      .din(raw_send),
      .wr_en(valid_raw_send),
      .full(),
      
      .rd_en(valid_raw_recv),
      .empty(),
      .dout(raw_send_d));
`endif
   
   variable_delay
     #(.width(8),
       .sel_width(4),
       .delay_min(1))
   ad1_delay_inst
     (.CLK(CLK),
      .RST(RST),

      .ce(1'b1),
      .din(ad1),
      .sel(ad1_delay),
      .dout(ad1_dl));

   variable_delay
     #(.width(8),
       .sel_width(4),
       .delay_min(1))
   ad2_delay_inst
     (.CLK(CLK),
      .RST(RST),

      .ce(1'b1),
      .din(ad2),
      .sel(ad2_delay),
      .dout(ad2_dl));

    // **************************************************
    // PRBS >--- [MOD] ---> AD
    // DA  >--- [DEMOD] ---> PRBS
    // **************************************************
    // **************************************************
    // SEND
    // **************************************************
    comm_send
      #(.modtype(modtype))
    comm_send_inst
      (
       .CLK(CLK),
       .RST(RST),
        
       .valid_i(valid_i),
       .data_i(data_i),
       .ack_i(ack_i),

       .da_valid(da_valid),
       .da1(da1),
       .da2(da2),

       .valid_raw(valid_raw_send),
       .raw(raw_send[5:0])       
       );

    assign raw_send [7:6] = 2'd0;
    
    // **************************************************
    // RECV
    // **************************************************
    comm_recv
      #(.modtype(modtype))
    comm_recv_inst
      (
       .CLK(CLK),
       .RST(RST),

       // discard
       .valid_o(valid_o),
       .data_o(data_o),
       .ack_o(ack_o),

       .ad1(ad1_dl),
       .ad2(ad2_dl),
       .ad_valid(ad_valid),

       .valid_raw(valid_raw_recv),
       .raw(raw_recv[5:0])       
       );
    assign raw_recv[7:6] = 2'b00;
          
endmodule
