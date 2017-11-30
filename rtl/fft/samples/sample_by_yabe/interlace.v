
// used for intermediate and last stages
// all the data for one transform
// (16 points for fft16, 64 points for fft64)
// must be supplied sequentially without
// bubbles (invalid data points).

// valid_a, b ___/~~~~~~~~~~~~~~ ... ~~~~~~~~\___ ... (no invalid data in-between)
// data       ===X a(0) X a(1) X ... X a(63) X=== ...

// More than `period' invalid data should be inserted between
// each transformation
// also valid_a == valid_b must be hold.
// (these two are automatically fulfilled by upper module)

module interlace
  #(parameter period = 8,
    parameter counter_width = 32,
    parameter width=8,
    parameter first=0
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

   output             valid_x,
   output [width-1:0] xr,
   output [width-1:0] xi,

   output             valid_y,
   output [width-1:0] yr,
   output [width-1:0] yi
   );

   wire               valid_b_d;
   wire [width-1:0]       br_d;
   wire [width-1:0]       bi_d;

   wire                   valid_x_p;
   wire [width-1:0]       xr_p;
   wire [width-1:0]       xi_p;

   localparam counter_top_v = period - 1;
   localparam counter_width_1 = counter_width > 1 ? counter_width : 1;
   localparam counter_top = counter_top_v[counter_width_1-1:0];
   reg [counter_width_1-1:0] counter;

   reg                     straight;

   wire                    straight_change;

   wire                    valid_cross;

   assign valid_cross = valid_a || valid_b_d;
   
   generate
      if (period > 1) begin
         assign straight_change = counter == counter_top;
         
`define ZERO ({{{(counter_width-1){1'b0}}, 1'b0}})
`define ONE  ({{{(counter_width-1){1'b0}}, 1'b1}})
         always @(posedge CLK or negedge RST)
           if (!RST) begin
              counter <= `ZERO;
           end else begin
              if (ce)
                if (valid_cross) begin
                   if (straight_change)
                     counter <= `ZERO;
                   else
                     counter <= counter + `ONE;
                end
           end
`undef ZERO
`undef ONE
      end
      else begin
         assign straight_change = 1'b1;
      end
   endgenerate


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        straight <= 1'b1;
     end else begin
        if (ce) begin
          if (valid_cross) begin
             if (straight_change)
               straight <= ~straight;
          end
          else
            straight <= 1'b1;
        end
     end

   // --------------------------------------------------
   // input-side delay (b)
   // --------------------------------------------------
   generate
      if (first == 0) begin
         delay
           #(.width(width),
             .depth(period))
         brin_delay
           (.CLK(CLK),
            .RST(RST),

            .ce(ce),

            .valid_i(valid_b),
            .a(br),

            .valid_o(valid_b_d),
            .x(br_d));

         delay
           #(.width(width),
             .depth(period))
         biin_delay
           (.CLK(CLK),
            .RST(RST),

            .ce(ce),

            .valid_i(valid_b),
            .a(bi),

            // valid_o is the same as valid_b_d
            .valid_o(),
            .x(bi_d));
      end // if (first != 0)
      else begin
         assign valid_b_d = 1'b0;
         assign br_d = 0;
         assign bi_d = 0;
      end
   endgenerate
   // --------------------------------------------------
   // cross
   // --------------------------------------------------
   cross_switch
     #(.width(width))
   cross_r
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),
      .straight(straight),
      
      .valid_a(valid_a),
      .a(ar),
      .valid_b(valid_b_d),
      .b(br_d),

      .valid_x(valid_x_p),
      .x(xr_p),
      .valid_y(valid_y),
      .y(yr));
   
   cross_switch
     #(.width(width))
   cross_i
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),
      .straight(straight),
      
      .valid_a(valid_a),
      .a(ai),
      .valid_b(valid_b_d),
      .b(bi_d),

      .valid_x(),
      .x(xi_p),
      .valid_y(),
      .y(yi));

   // --------------------------------------------------
   // output-side delay (x)
   // --------------------------------------------------
   delay
     #(.width(width),
       .depth(period))
   xrout_delay
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_x_p),
      .a(xr_p),

      .valid_o(valid_x),
      .x(xr));
   
   delay
     #(.width(width),
       .depth(period))
   xiout_delay
     (.CLK(CLK),
      .RST(RST),

      .ce(ce),

      .valid_i(valid_x_p),
      .a(xi_p),

      .valid_o(),
      .x(xi));

endmodule
