
module dpram
  #(parameter width=11)
  (
   input                  clk_a,
   input                  en_a,
   input                  we_a,
   input [5:0]            addr_a,
   input [width-1:0]      di_a,
   output reg [width-1:0] do_a,
   
   input                  clk_b,
   input                  en_b,
   input                  we_b,
   input [5:0]            addr_b,
   input [width-1:0]      di_b,
   output reg [width-1:0] do_b
   );

    reg [width-1:0]       ram [0:63];

    always @(posedge clk_a)
      if (en_a) begin
          if (we_a)
            ram[addr_a] <= di_a;
          do_a <= ram[addr_a];
      end
          
    always @(posedge clk_b)
      if (en_b) begin
          if (we_b)
            ram[addr_b] <= di_b;
          do_b <= ram[addr_b];
      end

endmodule
