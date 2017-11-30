
module ec_comm
  #(
    parameter modtype = 1,
    parameter valid_delay_min = 32
    )
  (
   input         clk_ec,
   input         clkcomm, 
   input         RST,

   input         valid_send_i,
   input [31:0]  data_send_i,
   output        ack_send_i,

   output        valid_recv_o,
   output [31:0] data_recv_o,

   output        valid_raw,
   output [7:0]  raw_send_d,
   output [7:0]  raw_recv,

   input [7:0]   ad1,
   input [7:0]   ad2,

   output [5:0]  da1,
   output [5:0]  da2,

   input [3:0]   ad1_delay,
   input [3:0]   ad2_delay,
   input [3:0]   ad_valid_delay
   );

    wire         valid_send_fifo;
    wire [31:0]  data_send_fifo;
    wire         valid_recv_fifo;
    wire [31:0]  data_recv_fifo;
    wire         ack_recv_fifo;
    wire         valid_comm_o;
    wire [31:0]  data_comm_o;
    wire         valid_comm_i;
    wire [31:0]  data_comm_i;
    wire         ack_comm_i;

    ec ec_inst
      (
       .CLK(clk_ec),
       .RST(RST),

       .valid_send_i(valid_send_i),
       .data_send_i(data_send_i),
       .ack_send_i(ack_send_i),

       .valid_send_o(valid_send_fifo),
       .data_send_o(data_send_fifo),

       .valid_recv_i(valid_recv_fifo),
       .data_recv_i(data_recv_fifo),
       .ack_recv_i(ack_recv_fifo),

       .valid_recv_o(valid_recv_o),
       .data_recv_o(data_recv_o),

       .valid_raw(valid_raw),
       .raw_send_d(raw_send_d),
       .raw_recv(raw_recv)
       );

    fifo_ec_comm fifo_send
      (
       .rst(!RST),

       .wr_clk(clk_ec),
       .wr_en(valid_send_fifo),
       .din(data_send_fifo),
       .full(),

       .rd_clk(clkcomm),
       .valid(valid_comm_i),
       .dout(data_comm_i),
       .rd_en(ack_comm_i),
       .empty()
       );

    wire         empty;
    fifo_ec_comm fifo_recv
      (
       .rst(!RST),

       .wr_clk(clkcomm),
       .wr_en(valid_comm_o),
       .din(data_comm_o),
       .full(),

       .rd_clk(clk_ec),
       .valid(valid_recv_fifo),
       .dout(data_recv_fifo),
       .rd_en(!empty),
       .empty(empty)
       );
    
    comm
      #(.modtype(modtype),
        .valid_delay_min(valid_delay_min))
    comm_inst
      (
       .CLK(clkcomm),
       .RST(RST),

       .ad1(ad1),
       .ad2(ad2),

       .da1(da1),
       .da2(da2),

       .valid_i(valid_comm_i),
       .data_i(data_comm_i),
       .ack_i(ack_comm_i),

       .valid_o(valid_comm_o),
       .data_o(data_comm_o),
       .ack_o(1'b1),

       .ad1_delay(ad1_delay),
       .ad2_delay(ad2_delay),
       .ad_valid_delay(ad_valid_delay),

	   .raw_send_d(),
	   .raw_recv(),
	   .valid_raw()
       );
    
endmodule
