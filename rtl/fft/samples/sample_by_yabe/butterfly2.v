
module butterfly2
  #(parameter width = 8
    )
  (
   input                         CLK,
   input                         RST,
   
   input                         valid_i,
   input                         ce, 

   input signed [width-1:0]      ar,
   input signed [width-1:0]      ai,
   
   input signed [width-1:0]      br,
   input signed [width-1:0]      bi,

   output reg                    valid_o,

   output reg signed [width-1:0] xr,
   output reg signed [width-1:0] xi,

   output reg signed [width-1:0] yr,
   output reg signed [width-1:0] yi
   );

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        if (ce)
          valid_o <= valid_i;
     end

   always @(posedge CLK) begin
      if (ce) begin
         xr <= ar + br;
         xi <= ai + bi;
         yr <= ar - br;
         yi <= ai - bi;
      end
   end

endmodule // butterfly2

