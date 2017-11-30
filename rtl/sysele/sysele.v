
`timescale 1ns/1ns
//`define FOR_SIM
  `define DETOUR

module sysele
  #(
    // set 1 to use external ADC-DAC board
    parameter with_dac_adc = 0,

    // set 1 to enable convolution coding and viterbi algorithm
    parameter with_error_correction = 0,

    // 1 -- BPSK
    // 2 -- QPSK
    // 4 -- 16QAM
    parameter modtype = 1,

    // DAC-cable-ADC delay
    parameter ad1_delay_init = 3,
    parameter ad2_delay_init = 3,
    parameter ad_valid_delay_init = 8
    )
  (
   // Global 100MHz clock
`ifndef FOR_SIM
   input        CLK,
   input        CLK_33MHZ_FPGA,
   input        CLK_DIFF_FPGA_P,
   input        CLK_DIFF_FPGA_N,
`else//FOR_SIM
   input		clk_40,
   input		clk_100,
   input		clk_200,
   input		clk_120,
   input		clk_240,
   input		locked1,
   input		locked2,
`endif//FOR_SIM
   
   // Reset signal, active low
   input        nRST,

   // North, East, South, West and Center buttons
   // Active High
   input        BTN_N,
   input        BTN_E,
   input        BTN_S,
   input        BTN_W,
   input        BTN_C,

   // DIP Switches
   input [7:0]  DIP,

   // North, East, South, West and Center LEDs
   // Active High
   output       LED_N,
   output       LED_E,
   output       LED_S,
   output       LED_W,
   output       LED_C,

   // LEDs
   output [7:0] LED,

   // LCD driver
   inout [3:0]  LCDDATA,
   output       RS,
   output       RW,
   output       EN,

   // DAC interface
   output [9:4] DA2,
   output       DACLK,
   output [9:4] DA1,

   // ADC interface
   input [7:0]  ADN,
   input [7:0]  ADP,
   input        DCON,
   input        DCOP,
   output       ADC_nOE,
   output       SCLK,
   inout        SDIO,
   output       CSB,
   output       ADCLKP,
   output       ADCLKN
   );

   // ==================================================
   // WIRES
   // ==================================================
   // --------------------------------------------------
   // CLOCKS
   // --------------------------------------------------
   // For IODELAY in adc_sync
    wire        clk40;
   wire         clk200;
    wire        clk100;

    wire        clk240;
    wire        clk120;

   wire         clkcomm;
   wire         clkadc;
    wire        clk_ber;

   // --------------------------------------------------
   // PLLS
   // --------------------------------------------------
   wire          locked, locked1, locked2;
   wire          rstgen;

   // --------------------------------------------------
   // ADC
   // --------------------------------------------------
   wire          adclk;
   wire [7:0]    ad;
   wire [7:0]    ad_delayed;
   wire [7:0]    ad1;
   wire [7:0]    ad2;
   wire          ad_dco;

   // ch1, ch2
   wire [7:0]    ad1_240;
   wire [7:0]    ad2_240;

    wire [7:0]   ad1_comm;
    wire [7:0]   ad2_comm;

   // SPI signals
   wire [7:0]  adc_recvdata;

   wire        adc_spi_button;

   // --------------------------------------------------
   // DAC
   // --------------------------------------------------
   wire          daclk;

   wire [5:0]    da1_nd;
   wire [5:0]    da2_nd;

   // --------------------------------------------------
   // LCD
   // --------------------------------------------------
   wire [7:0] lcd_char;
   wire [3:0] lcd_col;
   wire       lcd_row;
   wire       lcd_we;
   wire       lcd_busy;
   wire       lcd_update;

   // --------------------------------------------------
   // BER
   // --------------------------------------------------

   // --------------------------------------------------
   // COMM
   // --------------------------------------------------
   wire [3:0] ad1_delay;
   wire [3:0] ad2_delay;
   wire [3:0] ad_valid_delay;

   wire [3:0] ad1_delay_comm;
   wire [3:0] ad2_delay_comm;
   wire [3:0] ad_valid_delay_comm;

   // ==================================================
   // INSTANCES AND ASSIGNMENTS
   // ==================================================
   // **************************************************
   // CLOCK GENERATORS
   // **************************************************
   // --------------------------------------------------
   // PLLS
   // --------------------------------------------------

`ifndef FOR_SIM
   wire      clk_fpga;
   IBUFDS CDIFF(.I(CLK_DIFF_FPGA_P), .IB(CLK_DIFF_FPGA_N), .O(clk_fpga));
   pll pll(
           .CLKIN1_IN(clk_fpga),
           .RST_IN(!nRST),
           .CLKOUT0_OUT(clk40),
           .CLKOUT1_OUT(clk200),
           .CLKOUT2_OUT(clk100),
           .LOCKED_OUT(locked1));

   pll2 pll2(
             .CLKIN1_IN(clk100),
             .RST_IN(!nRST),
             .CLKOUT0_OUT(clk240),
             .CLKOUT1_OUT(clk120),
             .LOCKED_OUT(locked2));
`else
assign clk40  = clk_40;
assign clk100 = clk_100;
assign clk200 = clk_200;
assign clk120 = clk_120;
assign clk240 = clk_240;
`endif

   rstgen rstmod(.CLK(clk40),
                 .nRST(nRST),
                 .locked(locked),
                 .rstgen(rstgen));

   assign locked = locked1 & locked2;

   // --------------------------------------------------
   // ADC
   // --------------------------------------------------
`ifndef FOR_SIM
`ifdef DETOUR
	assign ADCLKN = clkcomm;
	assign ADCLKP =~clkcomm;
`else//DETOUR
   OBUFDS 
     ADCLK(.I(clkadc),
           .O(ADCLKN),
           .OB(ADCLKP));

`endif//DETOUR
   IODELAY 
     #(.REFCLK_FREQUENCY(200.0),
       .ODELAY_VALUE(25),
       .DELAY_SRC("O"),
       .IDELAY_TYPE("FIXED"),
       .SIGNAL_PATTERN("CLOCK"))
   odelay_adc
     (.C(clk200),
      .DATAOUT(clkadc),
      .CE(1'b1),
      .DATAIN(1'b0),
      .IDATAIN(1'b0),
      .INC(1'b0),
      .ODATAIN(clkcomm),
      .RST(!rstgen),
      .T(1'b0));
`else
	assign ADCLKN = clkcomm;
	assign ADCLKP =~clkcomm;
`endif // FOR_SIM
      
   adc_sync adc_sync_inst
     (
      .DCOP(DCOP),
      .DCON(DCON),

      .clk240(clkcomm),
      .clk200(clk200),

      .nRST(nRST),
      .RST(rstgen),

      .ADP(ADP),
      .ADN(ADN),

      // edge
      .ad1_240(ad2_240),
      .ad2_240(ad1_240)
      );

   adc_test adc_test_inst(
                          .CLK(clkcomm),
                          .RST(rstgen),

                          .SDIO(SDIO),
                          .SCLK(SCLK),
                          .CSB(CSB),

                          .recvdata(adc_recvdata),

                          .button(adc_spi_button));

   assign ADC_nOE = 1'b0;

   // --------------------------------------------------
   // DAC
   // --------------------------------------------------
   assign DACLK  = clkcomm;

   dac_delay dac_delay_inst
     (.clkcomm(clkcomm),
      .clk200(clk200),
      
      .RST(rstgen),
      .DA1(DA1),
      .DA2(DA2),

      .da1_nd(da1_nd),
      .da2_nd(da2_nd));
      
   // --------------------------------------------------
   // COMM
   // --------------------------------------------------
   assign clkcomm = clk240;

    wire [31:0] data_comm_i;
    wire        ack_comm_i;
    wire        toggle_comm;
    wire        valid_comm_i;
    reg         enable_comm;

    always @(posedge clkcomm or negedge nRST)
      if (!nRST) begin
          enable_comm <= 1'b0;
          // enable_comm <= 1'b1;
      end else begin
          if (toggle_comm)
            enable_comm <= ~enable_comm;
      end

    wire        clk_lfsr;
    wire [31:0] out_lfsr;
    wire        ack_lfsr;

    wire       valid_raw_comm;
    wire [7:0] raw_send_comm;
    wire [7:0] raw_recv_comm;

    wire       valid_comm_o;
    wire [31:0] data_comm_o;

    lfsr32 lfsr_inst
      (
       .CLK(clk_lfsr),
       .RST(rstgen),

       .en(ack_lfsr),
       .out(out_lfsr)
       );

    assign valid_comm_i = enable_comm;
    assign data_comm_i = out_lfsr;
    assign ack_lfsr = ack_comm_i;

    generate
        if (with_dac_adc) begin
            assign ad1_comm = ad1_240;
            assign ad2_comm = ad2_240;

            assign ad1_delay_comm = ad1_delay;
            assign ad2_delay_comm = ad2_delay;
            assign ad_valid_delay_comm = ad_valid_delay;
        end
        else begin
            assign ad1_comm = {1'b1, da1_nd, 1'b0};
            assign ad2_comm = {1'b1, da2_nd, 1'b0};

            assign ad1_delay_comm = 4'd0;
            assign ad2_delay_comm = 4'd0;
            assign ad_valid_delay_comm = 4'd0;
        end
    endgenerate

    localparam valid_delay_min = with_dac_adc ? 32 : 1;

    generate
        if (with_error_correction) begin : GEN_ERROR_CORRECTION
            wire        clk_ec = clk120;
            assign clk_lfsr = clk_ec;
            assign clk_ber = clk_ec;

            ec_comm
              #(.modtype(modtype),
                .valid_delay_min(valid_delay_min))
            ec_comm_inst
              (
               .clkcomm(clkcomm),
               .clk_ec(clk_ec),
               .RST(rstgen),

               .valid_send_i(valid_comm_i),
               .data_send_i(data_comm_i),
               .ack_send_i(ack_comm_i),

               .valid_recv_o(),
               .data_recv_o(),

               .ad1(ad1_comm),
               .ad2(ad2_comm),

               .da1(da1_nd),
               .da2(da2_nd),

	           .valid_raw(valid_raw_comm),
	           .raw_send_d(raw_send_comm),
	           .raw_recv(raw_recv_comm),

               .ad1_delay(ad1_delay_comm),
               .ad2_delay(ad2_delay_comm),
               .ad_valid_delay(ad_valid_delay_comm));

        end
        else begin : GEN_NO_CORRECTION
            assign clk_lfsr = clkcomm;
            assign clk_ber  = clkcomm;

            comm
              #(.modtype(modtype),
                .valid_delay_min(valid_delay_min))
            comm_inst
              (
               .CLK(clkcomm),
               .RST(rstgen),

               .ad1(ad1_comm),
               .ad2(ad2_comm),

               .da1(da1_nd),
               .da2(da2_nd),

               .valid_i(valid_comm_i),
               .data_i(data_comm_i),
               .ack_i(ack_comm_i),

               .valid_o(),
               .data_o(),
               .ack_o(1'b1),

               .ad1_delay(ad1_delay_comm),
               .ad2_delay(ad2_delay_comm),
               .ad_valid_delay(ad_valid_delay_comm),

	           .valid_raw(valid_raw_comm),
	           .raw_send_d(raw_send_comm),
	           .raw_recv(raw_recv_comm)
               );
        end
    endgenerate   

   // **************************************************
   // misc
   // **************************************************
   // --------------------------------------------------
   // CONTROL
   // --------------------------------------------------
   control
     #(
       .ad1_delay_init(ad1_delay_init),
       .ad2_delay_init(ad2_delay_init),
       .ad_valid_delay_init(ad_valid_delay_init)
       )
     control_inst
     (.clkcomm(clkcomm),

      .RST(rstgen),

      .DIP(DIP),
		.LED(LED),

      .BTN_N(BTN_N),
      .BTN_E(BTN_E),
      .BTN_S(BTN_S),
      .BTN_W(BTN_W),
      .BTN_C(BTN_C),

      .adc_spi_button(adc_spi_button),
      .ad1_delay(ad1_delay),
      .ad2_delay(ad2_delay),
      .ad_valid_delay(ad_valid_delay),
      .toggle_comm(toggle_comm));
   
   // --------------------------------------------------
   // LEDS AND SWITCHES
   // --------------------------------------------------
    reg [27:0]  counter240;
    reg         ledcr;

    always @(posedge clkcomm or negedge nRST)
      if (!nRST) begin
          counter240 <= 0;
      end else begin
          if (counter240 == 120_000_000)
            counter240 <= 0;
          else
            counter240 <= counter240 + 1;
      end

    always @(posedge clkcomm or negedge nRST)
      if (!nRST) begin
          ledcr <= 1'b0;
      end else begin
          if (counter240 == 120_000_000)
            ledcr <= ~ledcr;
      end

    assign LED_C = ledcr;
    assign LED_S = enable_comm;
   assign LED_E = 1'b0;
   assign LED_W = 1'b0;
   assign LED_N = 1'b0;
   
   // --------------------------------------------------
   // LCD
   // --------------------------------------------------
   lcd
     #(.clk_mhz(720),
       .clk_mhz_width(10))
     lcd_inst
     (
      .CLK(clk_ber),
      .RST(rstgen),

      .LCD_DATA(LCDDATA),
      .RS(RS),
      .RW(RW),
      .EN(EN),

      .row(lcd_row),
      .col(lcd_col),
      .char(lcd_char),
      .we(lcd_we),

      .busy(lcd_busy),

      .update(lcd_update)
      );
   
   lcd_ber_top
     #(
`ifdef FOR_SIM
       .update_period(32'd006_000_000)
`else//FOR_SIM
       .update_period(32'd240_000_000)
`endif//FOR_SIM
       )
	  lcd_ber_top_inst
     (
      .CLK(clk_ber),
      .RST(rstgen),

      .update(lcd_update),
      .lcd_row(lcd_row),
      .lcd_col(lcd_col),
      .lcd_char(lcd_char),
      .lcd_we(lcd_we),

      .lcd_busy(lcd_busy),

      .valid_i(valid_raw_comm),
      .sent_data(raw_send_comm),
      .recv_data(raw_recv_comm)
      );
   
endmodule // sysele
`ifdef FOR_SIM
module OBUFDS (
input I,
output O,
output OB
);
assign O  =  I;
assign OB = ~I;
endmodule
module IBUFDS (
input I,
input IB,
output O 
);
assign O  =  I;
endmodule
`endif
