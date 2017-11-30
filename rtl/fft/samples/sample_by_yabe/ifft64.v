
module ifft64
  #(parameter width=11)
    (
     input              CLK,
     input              RST,

     input              valid_a,
     input [width-1:0]  ar,
     input [width-1:0]  ai,

     output             valid_o,
     output [width-1:0] xr,
     output [width-1:0] xi
     );

    fft64
      #(.width(width),
        .mult_aw(16),
        .mult_bw(16),
        .mult_pw(32),
        .compmult_delay(4),
        .inverse(1))
    ifft_inst
    (
     .CLK(CLK),
     .RST(RST),

     .valid_a(valid_a),
     .ar(ar),
     .ai(ai),

     .valid_o(valid_o),
     .xr(xr),
     .xi(xi)
     );

endmodule
