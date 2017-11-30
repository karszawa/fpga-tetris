
`timescale 1ps/1ps

`define clk 10_000

module sim_top;
   // Global 100MHz clock
   reg         CLK;
   reg         CLK_33MHZ_FPGA;
   
   // Reset signal; active low
   reg         nRST;

   // North; East; South; West and Center buttons
   // Active High
   reg         BTN_N;
   reg         BTN_E;
   reg         BTN_S;
   reg         BTN_W;
   reg         BTN_C;

   // DIP Switches
   reg [7:0]   DIP;

   // North; East; South; West and Center LEDs
   // Active High
   wire        LED_N;
   wire        LED_E;
   wire        LED_S;
   wire        LED_W;
   wire        LED_C;

   // LEDs
   wire [7:0]  LED;

   // LCD driver
   wire [3:0]  LCDDATA;
   wire        RS;
   wire        RW;
   wire        EN;

   assign (pull0, pull1) LCDDATA = 4'h0;

   always #(`clk/2) CLK <= ~CLK;

   initial begin
      CLK <= 1'b0;
      nRST <= 1'b1;

      BTN_N <= 0;
      BTN_E <= 0;
      BTN_S <= 0;
      BTN_W <= 0;
      BTN_C <= 0;

      // DIP Switches
      DIP <= 0;

      #`clk;
      nRST <= 1'b0;
      #`clk;
      nRST <= 1'b1;

      #(`clk*10);

      while (inst.lcd_busy)
        #`clk;

      BTN_E <= 1'b1;
      #(`clk*1_000_000);
      BTN_E <= 1'b0;
      #(`clk*100_000);

      while (inst.lcd_busy)
        #`clk;

      $finish;
   end

   sysele inst
     (
      .CLK(CLK),
      .CLK_33MHZ_FPGA(CLK_33MHZ_FPGA),
      
      .nRST(nRST),

      .BTN_N(BTN_N),
      .BTN_E(BTN_E),
      .BTN_S(BTN_S),
      .BTN_W(BTN_W),
      .BTN_C(BTN_C),

      .DIP(DIP),

      .LED_N(LED_N),
      .LED_E(LED_E),
      .LED_S(LED_S),
      .LED_W(LED_W),
      .LED_C(LED_C),

      .LED(LED),

      .LCDDATA(LCDDATA),
      .RS(RS),
      .RW(RW),
      .EN(EN)
      );
   
endmodule // sim_top
