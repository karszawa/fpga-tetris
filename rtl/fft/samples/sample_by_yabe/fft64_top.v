
module fft64_top
  #(parameter width=11,
    parameter mult_aw=16,
    parameter mult_bw=16,
    parameter mult_pw=32,
    parameter compmult_delay=4,
    parameter inverse=1)
  (
   input              CLK,
   input              RST,

   input              ce,

   input              valid_a,
   input [width-1:0]  ar,
   input [width-1:0]  ai,

   output             valid_o,
   output [width-1:0] xr,
   output [width-1:0] xi,
   output [width-1:0] yr,
   output [width-1:0] yi
   );

  wire valid_1;
  wire [width-1:0] ar1, ai1, br1, bi1;
   parameter zero = {width{1'b0}};

  fft64_stage
    #(.width(width),
      .first(1),
      .mult_aw(mult_aw),
      .mult_bw(mult_bw),
      .mult_pw(mult_pw),
      .compmult_delay(compmult_delay),
      .inverse(inverse))
   fft64_inst
     (
      .CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_a(valid_a),
      .ar(ar),
      .ai(ai),
      .valid_b(1'b0),
      .br(zero),
      .bi(zero),

      .valid_o(valid_1),
      .xr(ar1),
      .xi(ai1),
      .yr(br1),
      .yi(bi1)
      );

   fft_reorder 
     #(.width(width),
       .points(64),
       .logpoints(6)
       )
   fft_reorder_inst
     (
      .CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_1),
      .ar(ar1),
      .ai(ai1),
      .br(br1),
      .bi(bi1),

      .valid_o(valid_o),
      .xr(xr),
      .xi(xi),
      .yr(yr),
      .yi(yi)
      )   ;

endmodule
