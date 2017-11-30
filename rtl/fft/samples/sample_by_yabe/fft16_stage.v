
module fft16_stage
  #(parameter width=8,
    parameter first=1,
    parameter mult_aw=16,
    parameter mult_bw=16,
    parameter mult_pw=32,
    parameter compmult_delay=1,
    parameter inverse=0
    )
  (
   input              CLK,
   input              RST,

   input              ce,

   input              valid_a,
   input [width-1:0]  ar,
   input [width-1:0]  ai,
   input              valid_b,
   input [width-1:0]  br,
   input [width-1:0]  bi,

   output             valid_o,
   output [width-1:0] xr,
   output [width-1:0] xi,
   output [width-1:0] yr,
   output [width-1:0] yi
   );

   wire [width-1:0]   zero = {width{1'b0}};

   wire               valid_1;
   wire [width-1:0]   ar1, ai1, br1, bi1;

   wire               valid_b_;
   wire [width-1:0]   br_, bi_;

   generate
      if (first) begin
         assign br_ = {width{1'b0}};
         assign bi_ = {width{1'b0}};
         assign valid_b_ = 1'b0;
      end else begin
         assign br_ = br;
         assign bi_ = bi;
         assign valid_b_ = valid_b;
      end
   endgenerate
   
   interlace
     #(.width(width),
       .first(first),
       .period(8),
       .counter_width(3))
   interlace_1
     (
      .CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_a(valid_a),
      .ar(ar),
      .ai(ai),
      
      .valid_b(valid_b_),
      .br(br_),
      .bi(bi_),

      .valid_x(valid_1),
      .xr(ar1),
      .xi(ai1),

      .valid_y(),
      .yr(br1),
      .yi(bi1));

   wire               valid_2;
   wire [width-1:0]   ar2, ai2, br2, bi2;
   
   butterfly2
     #(.width(width))
   butterfly2_1
     (
      .CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_1),
      .ar(ar1),
      .ai(ai1),
      .br(br1),
      .bi(bi1),

      .valid_o(valid_2),
      .xr(ar2),
      .xi(ai2),
      .yr(br2),
      .yi(bi2));

   wire               valid_3;
   wire [width-1:0]   ar3, ai3, br3, bi3;

   twiddle16
     #(.width(width),
       .aw(mult_aw),
       .bw(mult_bw),
       .pw(mult_pw),
       .compmult_delay(compmult_delay),
       .inverse(inverse)
       )
   twiddle16_1
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_2),
      .ar(ar2),
      .ai(ai2),
      .br(br2),
      .bi(bi2),

      .valid_o(valid_3),
      .xr(ar3),
      .xi(ai3),
      .yr(br3),
      .yi(bi3));

   wire               valid_4;
   wire [width-1:0]   ar4, ai4, br4, bi4;

   interlace
     #(.period(4),
       .counter_width(2),
       .width(width),
       .first(0))
   interlace_2
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_a(valid_3),
      .valid_b(valid_3),
      .ar(ar3),
      .ai(ai3),
      .br(br3),
      .bi(bi3),

      .valid_x(valid_4),
      .xr(ar4),
      .xi(ai4),
      .valid_y(),
      .yr(br4),
      .yi(bi4));

   wire               valid_5;
   wire [width-1:0]   ar5, ai5, br5, bi5;
   
   butterfly2
     #(.width(width))
   butterfly2_2
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_4),
      .ar(ar4),
      .ai(ai4),
      .br(br4),
      .bi(bi4),

      .valid_o(valid_5),
      .xr(ar5),
      .xi(ai5),
      .yr(br5),
      .yi(bi5));

   wire               valid_6;
   wire [width-1:0]   ar6, ai6, br6, bi6;
   twiddle8
     #(.width(width),
       .aw(mult_aw),
       .bw(mult_bw),
       .pw(mult_pw),
       .compmult_delay(compmult_delay),
       .inverse(inverse)
       )
   twiddle8_2
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_5),
      .ar(ar5),
      .ai(ai5),
      .br(br5),
      .bi(bi5),

      .valid_o(valid_6),
      .xr(ar6),
      .xi(ai6),
      .yr(br6),
      .yi(bi6));
   
   wire               valid_7;
   wire [width-1:0]   ar7, ai7, br7, bi7;
   interlace
     #(.period(2),
       .counter_width(1),
       .width(width),
       .first(0))
   interlace_3
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_a(valid_6),
      .valid_b(valid_6),
      .ar(ar6),
      .ai(ai6),
      .br(br6),
      .bi(bi6),

      .valid_x(valid_7),
      .xr(ar7),
      .xi(ai7),
      .valid_y(),
      .yr(br7),
      .yi(bi7));

   wire               valid_8;
   wire [width-1:0]   ar8, ai8, br8, bi8;
   butterfly2
     #(.width(width))
   butterfly2_3
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_7),
      .ar(ar7),
      .ai(ai7),
      .br(br7),
      .bi(bi7),

      .valid_o(valid_8),
      .xr(ar8),
      .xi(ai8),
      .yr(br8),
      .yi(bi8));

   wire               valid_9;
   wire [width-1:0]   ar9, ai9, br9, bi9;
   twiddle4
     #(.width(width),
       .inverse(inverse))
   twiddle4_1
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_8),
      .ar(ar8),
      .ai(ai8),
      .br(br8),
      .bi(bi8),

      .valid_o(valid_9),
      .xr(ar9),
      .xi(ai9),
      .yr(br9),
      .yi(bi9));

   wire               valid_10;
   wire [width-1:0]   ar10, ai10, br10, bi10;
   interlace
     #(.period(1),
       .counter_width(1),
       .width(width),
       .first(0))
   interlace_4
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_a(valid_9),
      .valid_b(valid_9),
      .ar(ar9),
      .ai(ai9),
      .br(br9),
      .bi(bi9),

      .valid_x(valid_10),
      .xr(ar10),
      .xi(ai10),
      .valid_y(),
      .yr(br10),
      .yi(bi10));

   butterfly2
     #(.width(width))
   butterfly2_4
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_10),
      .ar(ar10),
      .ai(ai10),
      .br(br10),
      .bi(bi10),

      .valid_o(valid_o),
      .xr(xr),
      .xi(xi),
      .yr(yr),
      .yi(yi));
   
endmodule

