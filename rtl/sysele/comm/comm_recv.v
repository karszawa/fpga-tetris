
// ****************************************************************************************************
//       8*2               11*2           11*2         11*2               128
// AD  ---/--- [RESCALE] ---/--- [FIFO] ---/--- [FFT] ---/--- [IQDEMAP] ---/---> MEMORY

module comm_recv
  #(parameter modtype=1)
  (
   input         CLK,
   input         RST,
  
   output        valid_o,
   output [31:0] data_o,
   input         ack_o, 

   input [7:0]   ad1,
   input [7:0]   ad2,
   input         ad_valid,

   output        valid_raw,
   output [5:0]  raw       
   );

   localparam width=11;

   // --------------------------------------------------
   //   8*2               11*2
   // ---/--- [RESCALE] ---/---
   wire [width-1:0] ar1, ai1;
   wire             valid_1;

   rescale
     #(.width(width))
   rescale_inst
   (
    .CLK(CLK),
    .RST(RST),

    .ad1i(ad1),
    .ad2i(ad2),
    .valid_i(ad_valid),

    .ad1o(ar1),
    .ad2o(ai1),
    .valid_o(valid_1)
    );

   // --------------------------------------------------
   //  11*2           11*2
   // ---/--- [FIFO] ---/---
   //
   // Responsible for assuring that a chunk of 64 data pts is
   // provided to FFT without any gaps
   wire [2*width-1:0] din1;

   wire [width-1:0]   ar2, ai2;
   wire               valid_2;
   wire [2*width-1:0] dout2;
   wire               rd_en2;

   assign din1 = {ar1, ai1};
   assign {ar2, ai2} = dout2;
   assign rd_en2 = valid_2;
   assign wr_en1 = valid_1;

   fftfifo fftfifo_inst
     (
      .CLK(CLK),
      .RST(RST),

      .full(),
      .din(din1),
      .wr_en(wr_en1),

      .valid_o(valid_2),
      .dout(dout2),
      .rd_en(rd_en2));

   // --------------------------------------------------
   //   11*2         11*2*2
   // ---/--- [FFT] ---/---

   wire               valid_3;
   wire [width-1:0]   ar3, ai3;
   wire               rd_en3;

   assign rd_en3 = valid_3;
   
   fft64
     #(.width(width),
       .inverse(0))
   fft_inst
     (
      .CLK(CLK),
      .RST(RST),

      .valid_a(valid_2),
      .ar(ar2),
      .ai(ai2),

      .valid_o(valid_3),
      .xr(ar3),
      .xi(ai3)
      );

   // --------------------------------------------------
   //   11*2            128
   // ---/--- [DEMAP] ---/---

   generate
      if (modtype == 1) begin
         iqdemap_bpsk iqdemap_inst
           (
            .CLK(CLK),
            .RST(RST),

            .valid_i(valid_3),
            .ar(ar3),
            .ai(ai3),

            .valid_o(valid_o),
            .data_o(data_o),
            // .ack_o(ack_o),

            .valid_raw(valid_raw),
            .raw(raw[0])
            );

         assign raw[5:1] = 5'h0;
      end // if (modtype == 1)
      else if (modtype == 2) begin
         iqdemap_qpsk iqdemap_inst
           (
            .CLK(CLK),
            .RST(RST),

            .valid_i(valid_3),
            .ar(ar3),
            .ai(ai3),

            .valid_o(valid_o),
            .data_o(data_o),
            // .ack_o(ack_o),

            .valid_raw(valid_raw),
            .raw(raw[1:0])
            );
         assign raw[5:2] = 4'h0;
      end
      else if (modtype == 4) begin
         iqdemap_qam16 iqdemap_inst
           (
            .CLK(CLK),
            .RST(RST),

            .valid_i(valid_3),
            .ar(ar3),
            .ai(ai3),

            .valid_o(valid_o),
            .data_o(data_o),
            // .ack_o(ack_o),

            .valid_raw(valid_raw),
            .raw(raw[3:0])
            );
         assign raw[5:4] = 2'h0;
      end
   endgenerate
     
endmodule
