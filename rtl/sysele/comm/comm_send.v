

//           128             11             11*2        11*2->5*2
// MEMORY >---/--- [IQMAP] ---/--- [FIFO] ---/--- [IFFT] ---/---> DA
//
// - FIFO is responsible for feeding IFFT with proper data
//
// parameter modtype: 1 for bpsk
module comm_send
  #(parameter modtype=1)
  (
   input            CLK,
   input            RST,
   
   input            valid_i,
   input [31:0]     data_i,
   output           ack_i, 

   output reg       da_valid,
   output reg [5:0] da1,
   output reg [5:0] da2,

   output           valid_raw,
   output [5:0]     raw       
   );
   
   localparam width=11;

   // --------------------------------------------------
   //   128              n
   // ---/--- [IQMAP] ---/---
   wire [width-1:0] ar1, ai1;
   wire             valid_1;

   generate
      if (modtype == 1) begin
         iqmap_bpsk iqmap_inst
           (
            .CLK(CLK),
            .RST(RST),

            .valid_i(valid_i),
            .data_i(data_i),
            .ack_i(ack_i),

            .xr(ar1),
            .xi(ai1),
            .valid_x(valid_1),

            .valid_raw(valid_raw),
            .raw(raw[0])
            );
         assign raw[5:1] = 5'd0;
      end // if (modtype == 1)
      else if (modtype == 2) begin
          iqmap_qpsk iqmap_inst
            (
             .CLK(CLK),
             .RST(RST),

             .valid_i(valid_i),
             .data_i(data_i),
             .ack_i(ack_i),

             .xr(ar1),
             .xi(ai1),
             .valid_x(valid_1),

             .valid_raw(valid_raw),
             .raw(raw[1:0])
             );
          assign raw[5:2] = 4'd0;
      end // if (modtype == 2)
      else if (modtype == 4) begin
          iqmap_qam16 iqmap_inst
            (
             .CLK(CLK),
             .RST(RST),

             .valid_i(valid_i),
             .data_i(data_i),
             .ack_i(ack_i),

             .xr(ar1),
             .xi(ai1),
             .valid_x(valid_1),

             .valid_raw(valid_raw),
             .raw(raw[3:0])
             );
          assign raw[5:4] = 2'd0;
      end
   endgenerate

   // --------------------------------------------------
   //     n             11
   //  ---/--- [FIFO] ---/--- [IFFT]
   // 
   // Responsible for assuring that a chunk of 64 data pts is
   // provided to IFFT without any gaps
   
   wire [width*2-1:0] din1;
   wire [width*2-1:0] dout2;
   wire               wr_en1;
   wire               rd_en2;

   wire [width-1:0] ar2, ai2;
   wire             valid_2;

   wire             ce2;

   assign din1       = {ar1, ai1};
   assign wr_en1     = valid_1;
   assign {ar2, ai2} = dout2;
   assign rd_en2     = valid_2 && ce2;
   
   fftfifo ifftfifo_inst
     (.CLK(CLK),
      .RST(RST),

      .full(),
      .din(din1),
      .wr_en(wr_en1),
      
      .valid_o(valid_2),
      .dout(dout2),
      .rd_en(rd_en2));   // ;

   // --------------------------------------------------
   //  11*2          11*2*2
   // ---/--- [IFFT] ---/--- 
   wire [width-1:0]   ar3, ai3;
   wire               valid_3;
   wire               rd_en3;
   
   assign rd_en3 = valid_3;
   assign ce2 = 1'b1;

   ifft64
   ifft_inst
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
   // 11*2*2          11*2
   // ---/--- [FIFO] ---/---

   wire [5:0]         da1_w;
   wire [5:0]         da2_w;

   // assign da1_w   = ar3[width-1:width-6];
   // assign da2_w   = ai3[width-1:width-6];
   assign da1_w   = ar3[width-3:width-8];
   assign da2_w   = ai3[width-3:width-8];
   
   // --------------------------------------------------
   // OFFSET
   // da[12]_w: -32 .. 31
   // da[12]: 0..63
   always @(posedge CLK) begin
      da1 <= da1_w + 6'h20 + (ar3[width-7] ? 6'd1 : 6'd0);
      da2 <= da2_w + 6'h20 + (ai3[width-7] ? 6'd1 : 6'd0);
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        da_valid <= 1'b0;
     end else begin
        da_valid <= valid_3;
     end

endmodule
