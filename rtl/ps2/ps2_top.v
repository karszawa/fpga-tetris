module ps2_top (
	input		sys50_clk	,
	input		rst_n		,

	inout		MOUSE_CLK		,// L2
	inout		MOUSE_DATA		,// K1
	inout		KEYBOARD_CLK	,// J1
	inout		KEYBOARD_DATA	,// H2

	//
	output				mouse_valid,
	output	[12-1: 0]	mpos_x	,// current mouse position, 12 bits
	output	[12-1: 0]	mpos_y	,
	output	[ 9-1: 0]	mdif_x	,// incremental mouse position, 8 bits
	output	[ 9-1: 0]	mdif_y	,// [8] sign


	output				mbtn_left,
	output				mbtn_middle,
	output				mbtn_right,

	output				key_valid,
	output	[ 8-1: 0]	key_data,

	output	[ 8-1: 0]	TP
);

wire			key_command_valid;
wire	[7:0]	key_command_data;
wire	[2:0]	btn_click;

ps2_mouse A0_MOUSE (
.clk			(sys50_clk		),//i
.reset			(~rst_n			),//i
.ps2_clk		(MOUSE_CLK		),//io
.ps2_data		(MOUSE_DATA		),//io
.mouse_valid	(mouse_valid	),//o
.mx				(mpos_x			),//o[11:0]
.my				(mpos_y			),//o[11:0]
.dx				(mdif_x			),//o[ 8:0]
.dy				(mdif_y			),//o[ 8:0]
.btn_click		(btn_click		) //o[2:0]
);
assign	mbtn_left	= btn_click[2];
assign	mbtn_middle	= btn_click[1];
assign	mbtn_right	= btn_click[0];
   
ps2_keyboard A1_KEYBOARD (
.CLOCK_50						(sys50_clk				),//i
.reset							(~rst_n					),//i
.the_command					(key_command_data		),//i[7:0]	
.send_command					(key_command_valid		),//i
.PS2_CLK						(KEYBOARD_CLK			),//io
.PS2_DAT						(KEYBOARD_DAT			),//io
.command_was_sent				(command_was_sent		),//o
.error_communication_timed_out	(error_communication	),//o
.received_data					(key_data				),//o[7:0]	
.received_data_en				(key_valid       		) //o
);

wire	[ 8-1: 0]	TP_CTRL;
ps2_keyboard_ctrl A2_KEYBOARD_CTRL (
.clk					(sys50_clk				),//i
.rst_n					(rst_n					),//i
.o_command_valid		(key_command_valid		),//o
.o_command_data			(key_command_data		),//o[ 8-1: 0]
.i_command_ack			(command_was_sent		),//i
.i_command_err			(error_communication	),//i
.tp						(TP_CTRL				) //o[ 8-1: 0]
);

reg	[12-1: 0]	mpos_x_d;
reg	[12-1: 0]	mpos_y_d;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		mpos_x_d	<= {12{1'b0}};
		mpos_y_d	<= {12{1'b0}};
	end else begin
		mpos_x_d	<= mpos_x;
		mpos_y_d	<= mpos_y;
	end
end

wire mpos_x_chg;
assign mpos_x_chg = (mpos_x!=mpos_x_d);
reg  mpos_x_chg_lvl;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		mpos_x_chg_lvl	<= 1'b0;
	end else if (mpos_x_chg) begin
		mpos_x_chg_lvl	<= ~mpos_x_chg_lvl;
	end
end

wire mpos_y_chg;
assign mpos_y_chg = (mpos_y!=mpos_y_d);
reg  mpos_y_chg_lvl;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		mpos_y_chg_lvl	<= 1'b0;
	end else if (mpos_y_chg) begin
		mpos_y_chg_lvl	<= ~mpos_y_chg_lvl;
	end
end

reg	mbtn_left_d1;
reg	mbtn_middle_d1;
reg	mbtn_right_d1;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		mbtn_left_d1	<= 1'b0;
		mbtn_middle_d1	<= 1'b0;
		mbtn_right_d1	<= 1'b0;
	end else begin
		mbtn_left_d1	<= mbtn_left	;
		mbtn_middle_d1	<= mbtn_middle	;
		mbtn_right_d1	<= mbtn_right	;
	end
end

wire mbtn_left_ris_edge;
assign mbtn_left_ris_edge	= mbtn_left		& ~mbtn_left_d1		;
reg mbtn_left_lvl;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		mbtn_left_lvl	<= 1'b0;
	end else if (mbtn_left_ris_edge) begin
		mbtn_left_lvl	<= ~mbtn_left_lvl;
	end
end

reg mbtn_middle_lvl;
wire mbtn_middle_ris_edge;
assign mbtn_middle_ris_edge	= mbtn_middle	& ~mbtn_middle_d1	;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		mbtn_middle_lvl	<= 1'b0;
	end else if (mbtn_middle_ris_edge) begin
		mbtn_middle_lvl	<= ~mbtn_middle_lvl;
	end
end

reg mbtn_right_lvl;
wire mbtn_right_ris_edge;
assign mbtn_right_ris_edge	= mbtn_right	& ~mbtn_right_d1	;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		mbtn_right_lvl	<= 1'b0;
	end else if (mbtn_right_ris_edge) begin
		mbtn_right_lvl	<= ~mbtn_right_lvl;
	end
end


reg	key_valid_d1;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		key_valid_d1	<= 1'b0;
	end else begin
		key_valid_d1	<= key_valid;
	end
end

wire key_valid_ris_edge;
assign	key_valid_ris_edge = key_valid & ~key_valid_d1;

reg key_valid_lvl;
always @ (posedge sys50_clk or negedge rst_n) begin
	if (~rst_n) begin
		key_valid_lvl	<= 1'b0;
	end else if (key_valid_ris_edge) begin
		key_valid_lvl	<= ~key_valid_lvl;
	end
end

assign TP = {	TP_CTRL[1:0], //command_was_sent	,
				              //error_communication ,
				mpos_x_chg_lvl		,
				mpos_y_chg_lvl		,
				mbtn_left_lvl		,
				mbtn_middle_lvl		,
				mbtn_right_lvl		,
				key_valid_lvl		};

endmodule

