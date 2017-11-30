
module qpsk_inv
  (
   input               CLK,
   input               RST,

   input               valid_i,
   input signed [10:0] ar,
   input signed [10:0] ai,

   output reg          valid_x,
   output reg [1:0]    x
   );

    reg signed [10:0]  add;
    reg signed [10:0]  sub;
   
    reg                 valid_z;

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          valid_x <= 1'b0;
      end else begin
          valid_z <= valid_i;
          valid_x <= valid_z;
      end

    
    always @(posedge CLK)
      begin
          add <= ai;
          sub <= ar;
      end

    always @(posedge CLK)
      begin
          if (add > 0)
            begin
                if (sub > 0)
                  x <= 2'b00;
                else
                  x <= 2'b01;
            end
          else
            begin
                if (sub > 0)
                  x <= 2'b10;
                else
                  x <= 2'b11;
            end
      end // always @ (posedge CLK)

endmodule
