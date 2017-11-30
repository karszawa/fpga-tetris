
module bpsk
  (
   input                    CLK,
   input                    RST,

   input                    valid_i,
   input                    data_i,

   output reg               valid_x,
   output reg signed [10:0] xr,
   output signed [10:0]     xi
   );

    assign xi = 11'sd0;
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
          if (data_i)
            xr <= high;
          else
            xr <= low;
      end
    
endmodule
