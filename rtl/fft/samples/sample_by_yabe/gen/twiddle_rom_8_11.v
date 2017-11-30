module twiddle_rom_8_11
  (
   input CLK,
   input RST,

   input [1:0] index,
   output signed [11:0] twiddle_r,
   output signed [11:0] twiddle_i
   );

  wire signed [11:0] romr[0:3];
  wire signed [11:0] romi[0:3];

     assign romr[0] = 1024;
     assign romi[0] = 0;
     assign romr[1] = 724;
     assign romi[1] = -724;
     assign romr[2] = 0;
     assign romi[2] = -1024;
     assign romr[3] = -724;
     assign romi[3] = -724;
  
     assign twiddle_r = romr[index];
     assign twiddle_i = romi[index];
endmodule