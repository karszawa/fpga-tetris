
module twiddle4 
  #(parameter width = 8,
    parameter inverse = 0
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
   output reg signed [width-1:0] xr,
   output reg signed [width-1:0] xi,
   output reg signed [width-1:0] yr,
   output reg signed [width-1:0] yi
   );

   reg                           j;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        j <= 1'b0;
     end else begin
        if (ce)
          if (valid_i) 
            j <= ~j;
     end


   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
        if (ce)
          valid_o <= valid_i;
     end

   always @(posedge CLK) 
     if (ce) begin
        xr <= ar;
        xi <= ai;
     end

   always @(posedge CLK) 
     if (ce) begin
        if (j == 1'b0) begin
           yr <= br;
           yi <= bi;
        end else begin
           if (inverse == 0) begin
              // * (-j)
              yr <= bi;
              yi <= -br;
           end else begin
              // * j
              yr <= -bi;
              yi <= br;
           end
        end      
     end
   
endmodule
