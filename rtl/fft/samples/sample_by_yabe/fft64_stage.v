
module fft64_stage
  #(parameter width=11,
    parameter first=1,
    parameter mult_aw=16,
    parameter mult_bw=16,
    parameter mult_pw=32,
    parameter compmult_delay=4,
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
       .period(32),
       .counter_width(5))
   interlace_1
     (.CLK(CLK),
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

   wire valid_2;
   wire [width-1:0] ar2, ai2, br2, bi2;

   butterfly2
     #(.width(width))
   butterfly2_1
     (.CLK(CLK),
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

   wire             valid_3;
   wire [width-1:0] ar3, ai3, br3, bi3;
   twiddle64
     #(.width(width),
       .aw(mult_aw),
       .bw(mult_bw),
       .pw(mult_pw),
       .compmult_delay(compmult_delay),
       .inverse(inverse)
       )
   twiddle64_1
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
   
   fft32_stage
     #(.width(width),
       .first(0),
       .mult_aw(mult_aw),
       .mult_bw(mult_bw),
       .mult_pw(mult_pw),
       .compmult_delay(compmult_delay),
       .inverse(inverse))
   fft32_inst
     (.CLK(CLK),
      .RST(RST),
      .ce(ce),

      .valid_a(valid_3),
      .ar(ar3),
      .ai(ai3),
      .valid_b(valid_3),
      .br(br3),
      .bi(bi3),

      .valid_o(valid_o),
      .xr(xr),
      .xi(xi),
      .yr(yr),
      .yi(yi));

endmodule
