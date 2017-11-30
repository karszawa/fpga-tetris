
module twiddle16
  #(parameter width = 11,
    parameter aw = 16,
    parameter bw = 16,
    parameter pw = 32,
    parameter compmult_delay = 1,
    parameter inverse = 0 // 0 for FFT, 1 for FFT
    )
  (
   input                         CLK,
   input                         RST,

   input                         ce,

   input                         valid_i,
   input signed [width-1:0]      ar,
   input signed [width-1:0]      ai,
   input signed [width-1:0]      br,
   input signed [width-1:0]      bi,

   output reg                    valid_o,
   output signed [width-1:0] xr,
   output signed [width-1:0] xi,
   output reg signed [width-1:0] yr,
   output reg signed [width-1:0] yi
   );

   reg [2:0]                 index;
   wire signed [width:0]   twiddle_r, twiddle_i;
   wire signed [pw-1:0] pr, pi;

   wire signed [aw-1:0] br_, bi_;
   wire signed [bw-1:0] tr_, ti_;

   assign br_ = {{(aw-width){br[width-1]}}, br};
   assign bi_ = {{(aw-width){bi[width-1]}}, bi};
   assign tr_ = {{(bw-width-1){twiddle_r[width]}}, twiddle_r};
   assign ti_ = {{(bw-width-1){twiddle_i[width]}}, twiddle_i};

   wire                 valid_o_;
   wire signed [width-1:0] yr_, yi_;

   assign yr_ = pr[width+width-2:width-1];
   assign yi_ = pi[width+width-2:width-1];

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        if (ce)
          valid_o <= valid_o_;
     end

   always @(posedge CLK) begin
      if (ce) begin
         yr <= yr_ + {{(width-1){1'b0}}, pr[width-2]};
         yi <= yi_ + {{(width-1){1'b0}}, pi[width-2]};
      end
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        index <= 3'd0;
     end else begin
        if (ce)
          if (valid_i)
            index <= index + 3'd1;
     end

   generate
      if (width == 11)
         if (inverse == 0)
           twiddle_rom_16_11 rom_inst
             (.CLK(CLK),
              .RST(RST),
    
              .index(index),
              .twiddle_r(twiddle_r),
              .twiddle_i(twiddle_i));
         else if (inverse == 1)
           twiddle_rom_16_11_b rom_inst
             (.CLK(CLK),
              .RST(RST),
    
              .index(index),
              .twiddle_r(twiddle_r),
              .twiddle_i(twiddle_i));
      else
        initial begin
           $display("Unsupported width %d.\nPlease generate rom.", width);
           $finish;
        end
   endgenerate

   /* verilator lint_off WIDTH */
   compmult compmult_inst
     (.CLK(CLK),
      .RST(RST),
      
      .ce(ce),

      .valid_i(valid_i),
      .ar(br_),
      .ai(bi_),
      .br(tr_),
      .bi(ti_),

      .valid_o(valid_o_),
      .pr(pr),
      .pi(pi));
   /* verilator lint_on WIDTH */

   delay
     #(.width(width),
       .depth(compmult_delay + 1))
   ar_delay
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_i),
      .a(ar),
      .valid_o(),
      .x(xr));

   delay
     #(.width(width),
       .depth(compmult_delay + 1))
   ai_delay
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_i),
      .a(ai),
      .valid_o(),
      .x(xi));
   
endmodule

