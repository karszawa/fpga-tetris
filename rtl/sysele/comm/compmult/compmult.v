
/*
 * 3-stage inferred-multiplier compmult
 * delay = 3
 * 
 * This module includes complex multiplier using 
 * 4 inferred real multiplier.
 */
module compmult
  #(parameter a_width = 16,
    parameter b_width = 16,
    parameter p_width = 32
    )
  (
   input                             CLK,
   input                             RST,

   input signed [a_width - 1:0]      ar,
   input signed [a_width - 1:0]      ai,

   input signed [b_width - 1:0]      br,
   input signed [b_width - 1:0]      bi,

   output reg signed [p_width - 1:0] pr,
   output reg signed [p_width - 1:0] pi,

   input                             valid_i,
   output reg                        valid_o,

   input                             ce
   );

   reg                               valid1;
   reg signed [a_width-1:0]          ar1, ai1;
   reg signed [b_width-1:0]          br1, bi1;

   reg                               valid2;
   reg signed [p_width-1:0]          rr, ri, ir, ii;

   
   // Stage 1: Latch input
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid1 <= 1'b0;
     end else begin
        if (ce)
          valid1 <= valid_i;
     end


   always @(posedge CLK)
     if (ce) begin
        ar1 <= ar;
        ai1 <= ai;
        br1 <= br;
        bi1 <= bi;
     end

   // Stage 2: Multipiler
   always @(posedge CLK)
     if (ce) begin
        rr <= ar1 * br1;
        ri <= ar1 * bi1;
        ir <= ai1 * br1;
        ii <= ai1 * bi1;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid2 <= 1'b0;
     end else begin
        if (ce)
          valid2 <= valid1;
     end


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        if (ce)
          valid_o <= valid2;
     end

   always @(posedge CLK) begin
      if (ce) begin
         pr <= rr - ii;
         pi <= ir + ri;
      end
   end

endmodule
