
//`define SIMULATION

module top
  (
   // Global 100MHz clock
   input         CLK,
   
   // Reset signal, active low
   input         nRST,

   // North, East, South, West and Center buttons
   // Active High
   input         BTN_N,
   input         BTN_E,
   input         BTN_S,
   input         BTN_W,
   input         BTN_C,

   // DIP Switches
   input [7:0]   DIP,

   // North, East, South, West and Center LEDs
   // Active High
   output        LED_N,
   output        LED_E,
   output        LED_S,
   output        LED_W,
   output        LED_C,

   // LEDs
   output [7:0]  LED
   );

   // ==================================================
   // WIRES
   // ==================================================

   reg	[16-1: 0]	counter;

always @ (posedge CLK or negedge nRST) begin
	if (~nRST) begin
		counter	<= {16{1'b0}};
	end else begin
		counter	<= counter + 1'b1;
	end
end




   // **************************************************
   // misc
   // **************************************************
   // --------------------------------------------------
   // LEDS AND SWITCHES
   // --------------------------------------------------
// assign LED = 8'h55;
assign LED = counter[16-1: 8];
assign LED_N = 1'b0;
assign LED_E = 1'b0;
assign LED_W = 1'b0;
assign LED_S = 1'b0;
assign LED_C = 1'b0;

//switch sw_btn_c
//  (.CLK(CLK),
//   .RST(nRST),
//   
//   .sw(BTN_C),
//   
//   .pos(),
//   .neg(),
//   .d(LED_C));

// flashing flash_c
//   (.clk(CLK),
//    .rst(nRST),
//    .d(LED_C));
   

endmodule // sysele

module flashing
  #(
    parameter counter_bits = 28,
    parameter counter_bits_1 = counter_bits - 1)
   (
    input  clk,
    input  rst,
    
    output d);
   reg [counter_bits_1:0] counter;
   always @(posedge clk or negedge rst)begin
      if(!rst)
  	counter <= {counter_bits{1'b0}};
      else
  	counter <= counter + {{counter_bits_1{1'b0}}, 1'b1};
   end
   
   assign d = counter[counter_bits_1];
endmodule // flashing

