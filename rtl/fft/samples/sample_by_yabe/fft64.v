
module fft64
  #(parameter width=11,
    parameter mult_aw=16,
    parameter mult_bw=16,
    parameter mult_pw=32,
    parameter compmult_delay=4,
    parameter inverse=0)
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

`ifdef SIMULATION
assign valid_o	= valid_a;
assign xr		= ar;
assign xi		= ai;
`else//SIMULATION

   wire                rd_en;
   wire                valid_1;
   wire [width-1:0]    ar1, ai1, br1, bi1;
   parameter zero = {width{1'b0}};
   wire                ce;
	wire                full;

   assign ce = !full;
   

   fft64_top
     #(.width(width),
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

      .valid_o(valid_1),
      .xr(ar1),
      .xi(ai1),
      .yr(br1),
      .yi(bi1)
      );


   wire [width*4-1:0]  din;
   wire                empty;
   wire [width*2-1:0]  dout;
   
   assign din = {ar1, ai1, br1, bi1};
   assign {xr, xi} = dout;
   assign valid_o = !empty;

   fifo_2w1r_fwft
     #(.read_width(2*width),
       .depth_log2(8))
   fifo_inst
     (.CLK(CLK),
      .RST(RST),

      .din(din),
      .wr_en(valid_1),
      .full(full),

      .dout(dout),
      .rd_en(rd_en),
      .empty(empty));

    assign rd_en = valid_o;
`endif//SIMULATION

endmodule
