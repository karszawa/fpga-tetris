
`timescale 1ns/1ns
module lcd_top (
`ifndef FOR_SIM
   input        CLK,
   input        CLK50M,
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

   input        valid_i,
   input [7:0]  recv_data,

   // North, East, South, West and Center buttons
   // Active High
   input        BTN_N,
   input        BTN_E,
   input        BTN_S,
   input        BTN_W,
   input        BTN_C,

   // LCD driver
   inout [3:0]  LCDDATA,
   output       RS,
   output       RW,
   output       EN,

   // LEDs
   output [7:0] LED 
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
   // LCD
   // --------------------------------------------------
   wire [7:0] lcd_char;
   wire [3:0] lcd_col;
   wire       lcd_row;
   wire       lcd_we;
   wire       lcd_busy;
   wire       lcd_update;


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

reg	valid_i_d;
always @ (posedge CLK50M or negedge nRST) begin
	if (~nRST) begin
		valid_i_d	<= 1'b0;
	end else begin
		valid_i_d	<= valid_i;
	end
end

wire valid_i_ris_edge;
assign valid_i_ris_edge = valid_i & ~valid_i_d;

reg valid_i_lvl;
always @ (posedge CLK50M or negedge nRST) begin
	if (~nRST) begin
		valid_i_lvl	<= 1'b0;
	end else if (valid_i_ris_edge) begin
		valid_i_lvl	<= ~valid_i_lvl;
	end
end

reg valid_i_lvl_lcdclk_d1;
reg valid_i_lvl_lcdclk_d2;
reg valid_i_lvl_lcdclk_d3;
always @ (posedge clk240 or negedge rstgen) begin
	if (~rstgen) begin
		valid_i_lvl_lcdclk_d1	<= 1'b0;
		valid_i_lvl_lcdclk_d2	<= 1'b0;
		valid_i_lvl_lcdclk_d3	<= 1'b0;
	end else begin
		valid_i_lvl_lcdclk_d1	<= valid_i_lvl;
		valid_i_lvl_lcdclk_d2	<= valid_i_lvl_lcdclk_d1;
		valid_i_lvl_lcdclk_d3	<= valid_i_lvl_lcdclk_d2;
	end
end

wire valid_i_ris_edge_lcdclk;
assign valid_i_ris_edge_lcdclk = valid_i_lvl_lcdclk_d2^valid_i_lvl_lcdclk_d3;

reg				valid_i_lcdclk_tmp;
reg				valid_i_lcdclk;
reg	[ 8-1: 0]	recv_data_lcdclk;
always @ (posedge clk240 or negedge rstgen) begin
	if (~rstgen) begin
		valid_i_lcdclk_tmp	<= 1'b0;
		valid_i_lcdclk	<= 1'b0;
	end else begin
		valid_i_lcdclk_tmp	<= valid_i_ris_edge_lcdclk;
		valid_i_lcdclk		<= (recv_data_lcdclk!=8'hFA)&(recv_data_lcdclk!=8'hAA)&(recv_data_lcdclk!=8'hEE)&(recv_data_lcdclk!=8'hFE)&(recv_data_lcdclk!=8'h00)&(recv_data_lcdclk!=8'hFF) ? valid_i_lcdclk_tmp : 1'b0 ;
	end
end


always @ (posedge clk240 or negedge rstgen) begin
	if (~rstgen) begin
		recv_data_lcdclk	<= {8{1'b0}};
	end else if (valid_i_ris_edge_lcdclk) begin
		recv_data_lcdclk	<= recv_data;
	end
end

reg	[ 8-1: 0]	last_data_dump;
always @ (posedge clk240 or negedge rstgen) begin
	if (~rstgen) begin
		last_data_dump	<= {8{1'b0}};
	end else if (valid_i_lcdclk) begin
		last_data_dump	<= recv_data_lcdclk;
	end
end
assign LED = last_data_dump;
   
// --------------------------------------------------
// LCD
// --------------------------------------------------
lcd #(
.clk_mhz(720),
.clk_mhz_width(10)
) A1_LCD (
.CLK(clk240),
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

lcd_ctrl_top #(
`ifdef FOR_SIM
.update_period(32'd24_000)
`else
.update_period(32'd240_000_000)
`endif
) A0_LCD_CTRL_TOP (
.CLK(clk240),
.RST(rstgen),
.update(lcd_update),
.lcd_row(lcd_row),
.lcd_col(lcd_col),
.lcd_char(lcd_char),
.lcd_we(lcd_we),
.lcd_busy(lcd_busy),
.valid_i(valid_i_lcdclk),
.recv_data(recv_data_lcdclk)
);

endmodule
