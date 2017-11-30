
// internal lfsr 32bit
// tap 32, 22, 2, 1

module lfsr32
  #(
    parameter taps = ((1 << 31) | (1 << 21) | (1 << 1) | 1),
    parameter init_state = 32'haaaa_aaaa
    )
  (
   input         CLK,
   input         RST,

   input         en,
   output [31:0] out
   );

    reg [31:0]   state;
    wire         o;

    assign o = state[0];
    wire [31:0]  masked = o ? taps : 32'd0;

    assign out = state;

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          state <= init_state;
      end else begin
          if (en)
            state <= ((state >> 1) ^ masked);
      end
    
endmodule
