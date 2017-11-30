//`define FOR_SIM
//
`define USE_SYSELE

module DVI_TOP (
	input					clk, // 100Mhz
	input					rst_n,
`ifdef DVI_ONLY_FPGA_TOP
	input					CLK_33MHZ_FPGA, // 33Mhz
`else
	input					clk_75,
`endif
	//--------------------------------------------------------------------------
	//	Chrontel 7301C Interface
	//--------------------------------------------------------------------------
	output	[11:0]			DVI_D,
	output					DVI_DE, 
	output					DVI_H, 
	output					DVI_V, 
	output					DVI_RESET_B,
	output					DVI_XCLK_N, DVI_XCLK_P,
	//--------------------------------------------------------------------------
	//
	input                   BUTTON_C, // B21
	input                   BUTTON_E, // A23
	input                   BUTTON_W, // C21
	input                   BUTTON_S, // B22
	input                   BUTTON_N, // A22

	// MOUSE
	input					mouse_valid	,
	input	[12-1: 0]		rect_pos_x	,
	input	[12-1: 0]		rect_pos_y	,
	input	[ 9-1: 0]		mouse_dif_x	,
	input	[ 9-1: 0]		mouse_dif_y	,

	//--------------------------------------------------------------------------
	// TELE_TX/RX
	//--------------------------------------------------------------------------
	output                  TELE_TX, // P21 (HDR2_64)
	input                   TELE_RX, // AB26(HDR1_64)
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	LCD Interface
	//--------------------------------------------------------------------------
	inout	[ 4-1: 0]		LCD_DATA	,
	output					LCD_RS		,
	output					LCD_RW		,
	output					LCD_EN  	,
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	I2C Bus Interface
	//--------------------------------------------------------------------------
	inout					I2C_SCL_DVI,
	inout					I2C_SDA_DVI, 
	//--------------------------------------------------------------------------
	output      			LED_C,
	output      			LED_E,
	output      			LED_W,
	output      			LED_S,
	output      			LED_N,
	output      			LED_ERR_1,
	output      			LED_ERR_0,
	output [7:0]			TP
);

`ifdef DVI_ONLY_FPGA_TOP
// Instantiate the module
wire Clock, Reset;
wire lcd_clk, rst_lcd_n;
wire clk_for_crg, clk_for_lcd;
wire CLKIN_IBUFG_OUT;
wire CLK0_OUT;
wire LOCKED_OUT, LOCKED_OUT_LCD;
//clockgen A_CRG (
crg A_CRG (
    .CLKIN_IN(CLK_33MHZ_FPGA), 
    .RST_IN(~rst_n), 
    .CLKFX_OUT(Clock), 
    .CLKIN_IBUFG_OUT(CLKIN_IBUFG_OUT), 
    .CLK0_OUT(CLK0_OUT),
    .LOCKED_OUT(LOCKED_OUT)
);
`ifndef USE_SYSELE
lcdclock A_CRG_LCD (
    .CLKIN_IN(clk), 
    .RST_IN(~rst_n), 
    .CLKFX_OUT(lcd_clk), 
    .CLKIN_IBUFG_OUT( /* OPEN */ ), 
    .CLK0_OUT( /* OPEN */ ),
    .LOCKED_OUT(LOCKED_OUT_LCD)
);
`else
assign lcd_clk = 1'b0;
assign LOCKED_OUT_LCD = 1'b1;
`endif

assign Reset = rst_n&LOCKED_OUT;
assign rst_lcd_n = rst_n&LOCKED_OUT_LCD;
//assign Reset = rst_n;
//assign rst_lcd_n = rst_n;

`else
assign CLK0_OUT = clk_75;
assign CLKIN_IBUFG_OUT = clk_75;
assign Clock = clk_75;
assign Reset = rst_n;
assign lcd_clk = clk_75;
assign rst_lcd_n = rst_n;
`endif


wire	O_PLS_BUTTON_C;
wire	O_PLS_BUTTON_E;
wire	O_PLS_BUTTON_W;
wire	O_PLS_BUTTON_S;
wire	O_PLS_BUTTON_N;

reg		[ 2-1: 0]	DISP_MODE;
reg		[ 5-1: 0]	FPGA_MODE;
	
wire o_sync_vs;
wire o_sync_hs;
wire o_sync_va;
wire o_sync_ha;
wire o_sync_de;

wire	[ 8-1: 0]	o_red;
wire	[ 8-1: 0]	o_grn;
wire	[ 8-1: 0]	o_blu;
wire				o_area;

wire				i_disp_wen	;
wire				i_disp_men	;
wire	[ 7-1: 0]	i_disp_adr	;
wire	[ 4-1: 0]	i_disp_d	;

wire				o_tx_flag	;
wire	[7-1: 0]	o_tx_addr	;
wire	[4-1: 0]	o_tx_data	;

wire				o_rx_flag	;
wire	[7-1: 0]	o_rx_addr	;
wire	[4-1: 0]	o_rx_data	;

wire				w_rx_flag	;
wire	[7-1: 0]	w_rx_addr	;
wire	[4-1: 0]	w_rx_data	;

wire							o_rect_vs		;
wire							o_rect_hs		;
wire							o_rect_va		;
wire							o_rect_ha		;
wire							o_rect_de		;
wire		[ 8-1: 0]	o_rect_red	;
wire		[ 8-1: 0]	o_rect_grn	;
wire		[ 8-1: 0]	o_rect_blu	;

wire					o_err_flag	;
wire		[ 7-1: 0]	o_err_addr	;
wire		[ 4-1: 0]	o_err_data	;
wire					o_err_detected;

always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		FPGA_MODE[0]	<= {1{1'b0}};
		DISP_MODE		<= 2'b01;
	end else if (O_PLS_BUTTON_C) begin
		FPGA_MODE[0]	<= ~FPGA_MODE[0];
		DISP_MODE		<= DISP_MODE + 1'b1;
	end
end

always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		FPGA_MODE[1]	<= {1{1'b0}};
	end else if (O_PLS_BUTTON_E) begin
		FPGA_MODE[1]	<= ~FPGA_MODE[1];
	end
end

always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		FPGA_MODE[2]	<= {1{1'b0}};
	end else if (O_PLS_BUTTON_W) begin
		FPGA_MODE[2]	<= ~FPGA_MODE[2];
	end
end

always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		FPGA_MODE[3]	<= {1{1'b0}};
	end else if (O_PLS_BUTTON_S) begin
		FPGA_MODE[3]	<= ~FPGA_MODE[3];
	end
end

always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		FPGA_MODE[4]	<= {1{1'b0}};
	end else if (O_PLS_BUTTON_N) begin
		FPGA_MODE[4]	<= ~FPGA_MODE[4];
	end
end

assign LED_ERR_1 = DISP_MODE[1];
assign LED_ERR_0 = DISP_MODE[0];

assign LED_C = FPGA_MODE[0];
assign LED_E = FPGA_MODE[1];
assign LED_W = FPGA_MODE[2];
assign LED_S = FPGA_MODE[3];
assign LED_N = FPGA_MODE[4];

wire [23:0]			CPG_Video;
wire 				CPG_VideoReady;
wire 				CPG_VideoValid;

wire [23:0]			Video;
wire 				VideoReady;
wire 				VideoValid;

assign Video		= (DISP_MODE==2'd0) ? CPG_Video      : (DISP_MODE==2'd1) ? {o_rect_red, o_rect_grn, o_rect_blu} : {o_red, o_grn, o_blu} ;
assign VideoValid	= (DISP_MODE==2'd0) ? CPG_VideoValid : (DISP_MODE==2'd1) ?	o_rect_vs& o_rect_hs& o_rect_va& o_rect_ha& o_rect_de :
																				o_sync_vs& o_sync_hs& o_sync_va& o_sync_ha& o_sync_de ;

assign CPG_VideoReady = (DISP_MODE==2'd0) ? VideoReady : 1'b0 ;

reg [ 7-1: 0] r_disp_adr;
reg [ 4-1: 0] r_disp_d;
always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		r_disp_adr <= {7{1'b0}};
		r_disp_d   <= {4{1'b0}};
	end else if (i_disp_wen==1'b0) begin
		r_disp_adr <= r_disp_adr + 1'b1;
		r_disp_d   <= (r_disp_d==4'd9) ? 4'd0 : r_disp_d + 1'b1 ;
	end
end

assign w_rx_flag = (o_err_flag) ? o_err_flag : (o_rx_addr<=7'd122) ? o_rx_flag : 1'b0 ;
assign w_rx_addr = (o_err_flag) ? o_err_addr : (o_rx_addr<=7'd122) ? o_rx_addr : 7'd0 ;
assign w_rx_data = (o_err_flag) ? o_err_data : (o_rx_addr<=7'd122) ? o_rx_data : 4'd0 ;

assign i_disp_wen	= (DISP_MODE==2'd0) ? 1'b1 : (DISP_MODE==2'd1) ? 1'b1 : (DISP_MODE==2'd2) ? ~o_tx_flag : ((DISP_MODE==2'd3)&(FPGA_MODE[3]==1'b1)) ? ~w_rx_flag : ~o_rx_flag ;
assign i_disp_men	= (DISP_MODE==2'd0) ? 1'b1 : (DISP_MODE==2'd1) ? 1'b1 : (DISP_MODE==2'd2) ? ~o_tx_flag : ((DISP_MODE==2'd3)&(FPGA_MODE[3]==1'b1)) ? ~w_rx_flag : ~o_rx_flag ;
assign i_disp_adr	= (DISP_MODE==2'd0) ?    0 : (DISP_MODE==2'd1) ?	0 : (DISP_MODE==2'd2) ?  o_tx_addr : ((DISP_MODE==2'd3)&(FPGA_MODE[3]==1'b1)) ?  w_rx_addr :  o_rx_addr ;
assign i_disp_d		= (DISP_MODE==2'd0) ?    0 : (DISP_MODE==2'd1) ?	0 : (DISP_MODE==2'd2) ?  o_tx_data : ((DISP_MODE==2'd3)&(FPGA_MODE[3]==1'b1)) ?  w_rx_data :  o_rx_data ;

wire W_TELE_TX;
wire W_TELE_RX;

assign TELE_TX	= W_TELE_TX ;
assign W_TELE_RX= (FPGA_MODE[4]) ? TELE_RX : W_TELE_TX ;

button_detector A_BUTTON (
	.clk				(Clock				),//i
	.rst_n				(Reset				),//i
	.BUTTON_C			(BUTTON_C			),//i
	.BUTTON_E			(BUTTON_E			),//i
	.BUTTON_W			(BUTTON_W			),//i
	.BUTTON_S			(BUTTON_S			),//i
	.BUTTON_N			(BUTTON_N			),//i
	.O_PLS_BUTTON_C		(O_PLS_BUTTON_C		),//o
	.O_PLS_BUTTON_E		(O_PLS_BUTTON_E		),//o
	.O_PLS_BUTTON_W		(O_PLS_BUTTON_W		),//o
	.O_PLS_BUTTON_S		(O_PLS_BUTTON_S		),//o
	.O_PLS_BUTTON_N		(O_PLS_BUTTON_N		) //o
);

DVI A_DVI (
	.Clock			(Clock			),
	.Reset			(~Reset			),
	.DVI_D			(DVI_D			),
	.DVI_DE			(DVI_DE			),
	.DVI_H			(DVI_H			),
	.DVI_V			(DVI_V			),
	.DVI_RESET_B	(DVI_RESET_B	),
	.DVI_XCLK_N		(DVI_XCLK_N		),
	.DVI_XCLK_P		(DVI_XCLK_P		),
	.I2C_SCL_DVI	(I2C_SCL_DVI	),
	.I2C_SDA_DVI	(I2C_SDA_DVI	),
	.Video			(Video			),
	.VideoReady		(VideoReady		),
	.VideoValid		(VideoValid		)
);

display A_DISPLAY (
	.disp_clk		(Clock   		),//i
	.rst_disp_n		(Reset    		),//i
	.i_disp_wen		(i_disp_wen		),//i
	.i_disp_men		(i_disp_men		),//i
	.i_disp_adr		(i_disp_adr		),//i[ 7-1: 0]
	.i_disp_d		(i_disp_d		),//i[ 4-1: 0]
	.o_sync_vs		(o_sync_vs		),//o
	.o_sync_hs		(o_sync_hs		),//o
	.o_sync_va		(o_sync_va		),//o
	.o_sync_ha		(o_sync_ha		),//o
	.o_sync_de		(o_sync_de		),//o
	.o_red    		(o_red    		),//o[ 8-1: 0]
	.o_grn			(o_grn			),//o[ 8-1: 0]
	.o_blu			(o_blu			),//o[ 8-1: 0]
	.o_area			(o_area			) //o
);

CPG A_CPG (
	.Clock			(Clock			),
	.Reset			(Reset			),
	.Video			(CPG_Video		),
	.VideoReady		(CPG_VideoReady	),
	.VideoValid		(CPG_VideoValid	)
);

tele_crg A_TELE_CRG (
.src_clk			(Clock			),
.rst_src_n			(Reset			),
.src_clk_1			(tele_clk_1		),
.src_clk_2			(tele_clk_2		),
.src_clk_4			(tele_clk_4		),
.src_clk_8			(tele_clk_8		),
.src_clk_16			(tele_clk_16	) 
);

tele_tx A_TELE_TX(
	.clk			(tele_clk_1		),//i
	.rst_n			(Reset			),//i
	.o_tx			(W_TELE_TX		),//o
	.o_tx_flag		(o_tx_flag		),//o
	.o_tx_addr		(o_tx_addr		),//o[7-1: 0]	
	.o_tx_data		(o_tx_data		) //o[4-1: 0]	
);

tele_rx A_TELE_RX(
	.clk			(tele_clk_1		),//i
	.rst_n			(Reset			),//i
	.i_rx			(W_TELE_RX		),//i
	.o_rx_flag		(o_rx_flag		),//o
	.o_rx_addr		(o_rx_addr		),//o[7-1: 0]	
	.o_rx_data		(o_rx_data		) //o[4-1: 0]	
);

`ifdef FOR_SIM
reg W_TELE_TX_1D;
always @(posedge tele_clk_1 or negedge Reset) begin
	if (~Reset) begin
		W_TELE_TX_1D <= 1'b0;
	end else begin
		W_TELE_TX_1D <= W_TELE_TX;
	end
end
`endif//FOR_SIM

tele_err A_TELE_ERR (
.Clock				(tele_clk_1		),//i
.Reset				(Reset			),//i
`ifdef FOR_SIM
.i_update			(1'b1			),//i
.i_period			(20'd100000		),//i[20-1: 0]
.i_tx				(W_TELE_TX^W_TELE_TX_1D		),//i
`else
.i_update			(O_PLS_BUTTON_E	),//i
.i_period			(20'd300000000	),//i[20-1: 0]
.i_tx				(W_TELE_TX		),//i
`endif
.i_rx				(W_TELE_RX		),//i
.o_flag				(o_err_flag		),//o
.o_addr				(o_err_addr		),//o[ 7-1: 0]
.o_data				(o_err_data		),//o[ 4-1: 0]
.o_err_detected		(o_err_detected	) //o
);

move_rect A_RECT (
.clk				(Clock			),//i
.rst_n				(Reset			),//i
.i_button_c			(BUTTON_C		),//i
.i_button_e			(BUTTON_E		),//i
.i_button_w			(BUTTON_W		),//i
.i_button_s			(BUTTON_S		),//i
.i_button_n			(BUTTON_N		),//i
.i_mouse_valid		(mouse_valid	),//i
.i_rect_pos_x		(rect_pos_x		),//i[12-1: 0]	
.i_rect_pos_y		(rect_pos_y		),//i[12-1: 0]	
.i_mouse_dif_x		(mouse_dif_x	),//i[ 9-1: 0]	
.i_mouse_dif_y		(mouse_dif_y	),//i[ 9-1: 0]	
.o_sync_vs			(o_rect_vs		),//o
.o_sync_hs			(o_rect_hs		),//o
.o_sync_va			(o_rect_va		),//o
.o_sync_ha			(o_rect_ha		),//o
.o_sync_de			(o_rect_de		),//o
.o_sync_red			(o_rect_red		),//o[ 8-1: 0]
.o_sync_grn			(o_rect_grn		),//o[ 8-1: 0]
.o_sync_blu     	(o_rect_blu     ) //o[ 8-1: 0]
);

`ifndef USE_SYSELE
lcd_top A_LCD (
.CLK				(lcd_clk		),//i
.RST				(rst_lcd_n		),//i
.LCD_DATA			(LCD_DATA		),//io[3:0]
.RS					(LCD_RS			),//o
.RW					(LCD_RW			),//o
.EN                 (LCD_EN         ) //o
);
`endif
   
////////////////////////////////////////////////////////////////////
// TEST PIN OUTPUT
reg [32-1: 0] cnt_clk;
always @ (posedge Clock or negedge Reset) begin
    if (~Reset) begin
	     cnt_clk <= {32{1'b0}};
	 end else begin
         cnt_clk <= cnt_clk+1'b1;
	 end
end

assign TP[1:0] = cnt_clk[27:26];

`ifndef USE_SYSELE
reg [32-1: 0] cnt_clk_lcd;
always @ (posedge lcd_clk or negedge rst_n) begin
    if (~rst_n) begin
	     cnt_clk_lcd <= {32{1'b0}};
	 end else begin
	     cnt_clk_lcd <= cnt_clk_lcd+1'b1;
	 end
end

assign TP[3:2] = cnt_clk_lcd[27:26];
`else
assign TP[3:2] = {2{1'b0}};
`endif

reg [32-1: 0] cnt_clk_raw;
always @ (posedge CLKIN_IBUFG_OUT or negedge rst_n) begin
    if (~rst_n) begin
	     cnt_clk_raw <= {32{1'b0}};
	 end else begin
	     cnt_clk_raw <= cnt_clk_raw+1'b1;
	 end
end

assign TP[5:4] = cnt_clk_raw[27:26];

assign TP[7:6] = {2{o_err_detected}};


endmodule
