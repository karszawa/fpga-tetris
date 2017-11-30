
module qam16_inv
  (
   input               CLK,
   input               RST,

   input               valid_i,
   input signed [10:0] ar,
   input signed [10:0] ai,

   output reg          valid_x,
   output reg [3:0]    x
   );

    localparam signed p2 = 11'sd4;
    localparam signed zero = 11'sd0;
    localparam signed m2 = -11'sd4;

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          valid_x <= 1'b0;
      end else begin
          valid_x <= valid_i;
      end

    always @(posedge CLK)
      if (ar < m2) begin
        if (ai < m2) 
          x <= 4'd3;
        else if (ai < zero)
          x <= 4'd2;
        else if (ai < p2)
          x <= 4'd6;
        else
          x <= 4'd7;
      end
      else if (ar < zero) begin
          if (ai < m2)
            x <= 4'd1;
          else if (ai < zero)
            x <= 4'd0;
          else if (ai < p2)
            x <= 4'd4;
          else
            x <= 4'd5;
      end 
      else if (ar < p2) begin
          if (ai < m2)
            x <= 4'd9;
          else if (ai < zero)
            x <= 4'd8;
          else if (ai < p2)
            x <= 4'd12;
          else
            x <= 4'd13;
      end
      else begin
          if (ai < m2)
            x <= 4'd11;
          else if (ai < zero)
            x <= 4'd10;
          else if (ai < p2)
            x <= 4'd14;
          else
            x <= 4'd15;
      end

endmodule
