
module cross_switch
  #(parameter width=8)
  (
   input                  CLK,
   input                  RST,

   input                  ce,
   input                  straight,

   input                  valid_a,
   input [width-1:0]      a,

   input                  valid_b,
   input [width-1:0]      b,

   output reg             valid_x, 
   output reg [width-1:0] x,
   output reg             valid_y,
   output reg [width-1:0] y
   );

   always @(posedge CLK) begin
      if (ce) begin
         if (straight) begin
            x <= a;
            y <= b;
         end
         else begin
            x <= b;
            y <= a;
         end
      end
   end // always @ (posedge CLK)

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_x <= 1'b0;
        valid_y <= 1'b0;
     end else begin
        if (ce) begin
           if (straight) begin
              valid_x <= valid_a;
              valid_y <= valid_b;
           end else begin
              valid_x <= valid_b;
              valid_y <= valid_a;
           end
        end
     end


endmodule // cross_switch

