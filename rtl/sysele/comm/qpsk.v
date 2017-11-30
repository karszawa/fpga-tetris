
module qpsk
  (
   input                    CLK,
   input                    RST,

   input                    valid_i,
   input [1:0]              data_i,

   output reg               valid_x,
   output reg signed [10:0] xr,
   output reg signed [10:0] xi
   );
    
    localparam zero = 11'sd0;
    localparam high = 11'sd8;
    localparam low  = -11'sd8;

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          valid_x <= 1'b0;
      end else begin
          valid_x <= valid_i;
      end

    always @(posedge CLK)
      begin
          case (data_i)
          2'b00: begin
              xr <= high;
              xi <= high;
          end

          2'b01: begin
              xr <= low;
              xi <= high;
          end

          2'b11: begin
              xr <= low;
              xi <= low;
          end

          2'b10: begin
              xr <= high;
              xi <= low;
          end
          endcase // case (d[1:0])
      end


endmodule
