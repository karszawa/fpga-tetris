
module qam16
  (
   input                    CLK,
   input                    RST,

   input                    valid_i,
   input [3:0]              data_i,

   output reg               valid_x,
   output reg signed [10:0] xr,
   output reg signed [10:0] xi
   );

    localparam p3 =  11'sd6;
    localparam p1 =  11'sd2;
    localparam m1 = -11'sd2;
    localparam m3 = -11'sd6;

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          valid_x <= 1'b0;
      end else begin
          valid_x <= valid_i;
      end

    always @(posedge CLK)
      case (data_i)
      4'd0: begin
          xr <= m1;
          xi <= m1;
      end
      4'd1: begin
          xr <= m1;
          xi <= m3;
      end
      4'd2: begin
          xr <= m3;
          xi <= m1;
      end
      4'd3: begin
          xr <= m3;
          xi <= m3;
      end
      4'd4: begin
          xr <= m1;
          xi <= p1;
      end
      4'd5: begin
          xr <= m1;
          xi <= p3;
      end
      4'd6: begin
          xr <= m3;
          xi <= p1;
      end
      4'd7: begin
          xr <= m3;
          xi <= p3;
      end
      4'd8: begin
          xr <= p1;
          xi <= m1;
      end
      4'd9: begin
          xr <= p1;
          xi <= m3;
      end
      4'd10: begin
          xr <= p3;
          xi <= m1;
      end
      4'd11: begin
          xr <= p3;
          xi <= m3;
      end
      4'd12: begin
          xr <= p1;
          xi <= p1;
      end
      4'd13: begin
          xr <= p1;
          xi <= p3;
      end
      4'd14: begin
          xr <= p3;
          xi <= p1;
      end
      4'd15: begin
          xr <= p3;
          xi <= p3;
      end
      default:
        ;
      endcase // case (d[1:0])

endmodule
