
module control
  #(
    parameter ad1_delay_init = 3,
    parameter ad2_delay_init = 3,
    parameter ad_valid_delay_init = 8
    )
  (
   input            clkcomm,

   input            RST,

   // DIP Switches
   input [7:0]      DIP,
	output [7:0]     LED,

   // North, East, South, West and Center LEDs
   // Active High
   input            BTN_N,
   input            BTN_E,
   input            BTN_S,
   input            BTN_W,
   input            BTN_C,

   output           adc_spi_button,
   output reg [3:0] ad1_delay,
   output reg [3:0] ad2_delay,
   output reg [3:0] ad_valid_delay,

   output           toggle_comm
   );

   localparam dip_ad1 = 8'd128;
	localparam dip_ad2 = 8'd129;
	localparam dip_adv = 8'd130;
	localparam dip_valid_comm = 8'd0;

   wire         ad1_incr_button = DIP == dip_ad1 && BTN_N;
   wire         ad1_decr_button = DIP == dip_ad1 && BTN_S;
   wire         ad2_incr_button = DIP == dip_ad2 && BTN_N;
   wire         ad2_decr_button = DIP == dip_ad2 && BTN_S;
   wire         adv_incr_button = DIP == dip_adv && BTN_N;
   wire         adv_decr_button = DIP == dip_adv && BTN_S;
   wire         valid_comm_button = DIP == dip_valid_comm && BTN_C;

   assign       adc_spi_button = DIP == dip_valid_comm && BTN_S;
	
	assign LED = DIP == dip_ad1 ? ad1_delay :
	             DIP == dip_ad2 ? ad2_delay :
					 DIP == dip_adv ? ad_valid_delay :
					 8'd0;

   wire         ad1_incr;
   wire         ad1_decr;
   wire         ad2_incr;
   wire         ad2_decr;
   wire         adv_incr;
   wire         adv_decr;

    switch valid_comm_sw
      (.CLK(clkcomm),
       .RST(RST),

       .sw(valid_comm_button),

       .pos(toggle_comm));

   switch sw_ad1_incr
     (.CLK(clkcomm),
      .RST(RST),

      .sw(ad1_incr_button),
      .pos(ad1_incr));

   switch sw_ad1_decr
     (.CLK(clkcomm),
      .RST(RST),

      .sw(ad1_decr_button),
      .pos(ad1_decr));

   switch sw_ad2_incr
     (.CLK(clkcomm),
      .RST(RST),

      .sw(ad2_incr_button),
      .pos(ad2_incr));

   switch sw_ad2_decr
     (.CLK(clkcomm),
      .RST(RST),
      .sw(ad2_decr_button),
      .pos(ad2_decr));

   switch sw_adv_incr
     (.CLK(clkcomm),
      .RST(RST),
      .sw(adv_incr_button),
      .pos(adv_incr));

   switch sw_adv_decr
     (.CLK(clkcomm),
      .RST(RST),
      .sw(adv_decr_button),
      .pos(adv_decr));

   always @(posedge clkcomm or negedge RST)
     if (!RST) begin
         ad1_delay <= ad1_delay_init;
     end else begin
        if (ad1_incr)
          ad1_delay <= ad1_delay + 4'd1;
        else if (ad1_decr)
          ad1_delay <= ad1_delay - 4'd1;
     end

   always @(posedge clkcomm or negedge RST)
     if (!RST) begin
         ad2_delay <= ad2_delay_init;
     end else begin
        if (ad2_incr)
          ad2_delay <= ad2_delay + 4'd1;
        else if (ad2_decr)
          ad2_delay <= ad2_delay - 4'd1;
     end

   always @(posedge clkcomm or negedge RST)
     if (!RST) begin
         ad_valid_delay <= ad_valid_delay_init;
     end else begin
        if (adv_incr)
          ad_valid_delay <= ad_valid_delay + 4'd1;
        else if (adv_decr)
          ad_valid_delay <= ad_valid_delay - 4'd1;
     end


endmodule
