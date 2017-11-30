module audio_proc (
	// 27Mhz Clock and Board Reset
	input				clk					,// FPGA Clock: 27Mhz
	input				rst_n				,// Active low

	// USER IF
	input					btn_c				,
	input					btn_n				,
	input					btn_e				,
	input					btn_s				,
	input					btn_w				,

	input					iAudio_sync			,
	input		[20-1: 0]	iAudio_L			,
	input		[20-1: 0]	iAudio_R			,

	output	reg				oAudio_sync			,
	output	reg	[20-1: 0]	oAudio_L			,
	output	reg	[20-1: 0]	oAudio_R			,

	output		[ 8-1: 0]	tp
);

wire				btn_c_pls	;
wire				btn_e_pls	;
wire				btn_w_pls	;
wire				btn_s_pls	;
wire				btn_n_pls	;

reg					mode_mute		;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		oAudio_sync	<= 1'b0;
	end else begin
		oAudio_sync	<= iAudio_sync;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		oAudio_L	<= {20{1'b0}};
		oAudio_R	<= {20{1'b0}};
	end else begin
		oAudio_L	<= (mode_mute) ? {20{1'b0}} : iAudio_L;
		oAudio_R	<= (mode_mute) ? {20{1'b0}} : iAudio_R;
	end
end


always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		mode_mute	<= 1'b0;
	end else if (btn_s_pls) begin
		mode_mute	<= ~mode_mute;
	end
end

button_detector A_BUTTON_PLS (
.clk				(clk				),//i
.rst_n				(rst_n				),//i
.BUTTON_C			(btn_c				),//i
.BUTTON_E			(btn_e				),//i
.BUTTON_W			(btn_w				),//i
.BUTTON_S			(btn_s				),//i
.BUTTON_N			(btn_n				),//i
.O_PLS_BUTTON_C		(btn_c_pls			),//o
.O_PLS_BUTTON_E		(btn_e_pls			),//o
.O_PLS_BUTTON_W		(btn_w_pls			),//o
.O_PLS_BUTTON_S		(btn_s_pls			),//o
.O_PLS_BUTTON_N		(btn_n_pls			) //o
);

assign tp = {8{1'b0}};
endmodule
