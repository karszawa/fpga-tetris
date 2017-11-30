
module bpsk_inv
  (
   input               CLK,
   input               RST,

   input               valid_i,
   input signed [10:0] ar,
   input signed [10:0] ai,

   output reg          valid_x,
   output reg          x
   );

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          valid_x <= 1'b0;
      end else begin
          valid_x <= valid_i;
      end

    always @(posedge CLK)
      if (ar > 0)
        x <= 1'b1;
      else
        x <= 1'b0;
    
endmodule
