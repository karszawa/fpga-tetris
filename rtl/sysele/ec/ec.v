
module ec
  (
   input         CLK,
   input         RST,

   input         valid_send_i,
   input [31:0]  data_send_i,
   output        ack_send_i,

   output        valid_send_o,
   output [31:0] data_send_o,

   input         valid_recv_i,
   input [31:0]  data_recv_i,
   output        ack_recv_i,

   output        valid_recv_o,
   output [31:0] data_recv_o,

   output        valid_raw,
   output [7:0]  raw_send_d,
   output [7:0]  raw_recv
   );

    // **************************************************
    // SEND
    // **************************************************

    wire         valid_slice_send;
    wire         data_slice_send;

    slice_bpsk slice_send
      (.CLK(CLK),
       .RST(RST),

       .valid_i(valid_send_i),
       .data_i(data_send_i),
       .ack_i(ack_send_i),

       .valid_o(valid_slice_send),
       .data_o(data_slice_send));

    wire         valid_conv;
    wire [1:0]   data_conv;

    convolution convolution_inst
      (.CLK(CLK),
       .RST(RST),

       .valid_i(valid_slice_send),
       .data_i(data_slice_send),

       .valid_o(valid_conv),
       .data_o(data_conv));

    collect_qpsk collect_send
      (.CLK(CLK),
       .RST(RST),

       .valid_i(valid_conv),
       .data_i(data_conv),

       .valid_o(valid_send_o),
       .data_o(data_send_o));

    // **************************************************
    // RECV
    // **************************************************

    wire         valid_slice_recv;
    wire [1:0]   data_slice_recv;

    slice_qpsk slice_recv
      (.CLK(CLK),
       .RST(RST),

       .valid_i(valid_recv_i),
       .data_i(data_recv_i),
       .ack_i(ack_recv_i),

       .valid_o(valid_slice_recv),
       .data_o(data_slice_recv));

    wire         valid_viterbi;
    wire         data_viterbi;

    viterbi viterbi_inst
      (.CLK(CLK),
       .RST(RST),

       .valid_i(valid_slice_recv),
       .data_i(data_slice_recv),

       .valid_o(valid_viterbi),
       .data_o(data_viterbi));

    collect_bpsk collect_recv
      (.CLK(CLK),
       .RST(RST),

       .valid_i(valid_viterbi),
       .data_i(data_viterbi),

       .valid_o(valid_recv_o),
       .data_o(data_recv_o));

    // **************************************************
    // RAW
    // **************************************************
    wire         valid_raw_send;
    wire [7:0]   raw_send;

    assign valid_raw = valid_viterbi;

    assign valid_raw_send = valid_slice_send;
    assign raw_send = {7'd0, data_slice_send};
    assign raw_recv = {7'd0, data_viterbi};

    fifo_raw_send fifo_raw_send
      (.clk(CLK),
       .rst(!RST),

       .din(raw_send),
       .wr_en(valid_raw_send),
       .full(),
        
       .rd_en(valid_raw),
       .empty(),
       .dout(raw_send_d));

endmodule
