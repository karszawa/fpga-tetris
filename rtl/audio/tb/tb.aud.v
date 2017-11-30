`timescale 1ns/1ps

`define DEBUG

module tb ();

wire rst_n		;
wire sys13p5_clk	;
wire sys27_clk		;
wire sys54_clk		;
wire sys108_clk		;
wire sys100_clk	;
wire sys200_clk	;
wire sys400_clk	;
wire sys800_clk	;
wire sys120_clk	;
wire sys240_clk	;
wire sys480_clk	;
wire sys960_clk	;
wire disp40_clk	;
wire disp80_clk	;
wire disp160_clk;
wire disp320_clk;

wire sys_clk;
wire rst_sys_n;
assign sys_clk = disp40_clk;
assign rst_sys_n = rst_n;
wire disp_clk;
wire rst_disp_n;
assign disp_clk = disp40_clk;
assign rst_disp_n = rst_n;

wire				clk					;
wire				rst_n				;
wire				audio_bit_clk		;
wire				flash_audio_reset_b	;
wire				audio_sdata_in		;
wire				audio_sdata_out		;
wire				audio_sync			;
	    
wire				btn_c				;
wire				btn_n				;
wire				btn_e				;
wire				btn_s				;
wire				btn_w				;
wire	[ 8-1: 0]	tp					;

wire	[32-1: 0]	lfsr_out			;

reg		[ 8-1: 0]	r_cnt_audio_reset	;

crg A0_CRG (
.rst_n			(rst_n			),//o
.sys13p5_clk	(sys13p5_clk	),//o
.sys27_clk		(sys27_clk		),//o
.sys54_clk		(sys54_clk		),//o
.sys108_clk		(sys108_clk		),//o
.sys100_clk		(sys100_clk		),//o
.sys200_clk		(sys200_clk		),//o
.sys400_clk		(sys400_clk		),//o
.sys800_clk		(sys800_clk		),//o
.sys120_clk		(sys120_clk		),//o
.sys240_clk		(sys240_clk		),//o
.sys480_clk		(sys480_clk		),//o
.sys960_clk		(sys960_clk		),//o
.disp40_clk		(disp40_clk		),//o
.disp80_clk		(disp80_clk		),//o
.disp160_clk	(disp160_clk	),//o
.disp320_clk	(disp320_clk	) //o
);

reg r_btn_c;
reg r_btn_n;
reg r_btn_e;
reg r_btn_s;
reg r_btn_w;
initial begin
r_btn_c <= 1'b1;
r_btn_n <= 1'b1;
r_btn_e <= 1'b1;
r_btn_s <= 1'b1;
r_btn_w <= 1'b1;
#500
r_btn_c <= 1'b0;
#50
r_btn_c <= 1'b1;
end

assign btn_c = r_btn_c;
assign btn_n = r_btn_n;
assign btn_e = r_btn_e;
assign btn_s = r_btn_s;
assign btn_w = r_btn_w;

always @ (posedge sys13p5_clk or negedge rst_n or posedge flash_audio_reset_b) begin
	if (~rst_n) begin
		r_cnt_audio_reset	<= {8{1'b0}};
	end else if (r_cnt_audio_reset>= 8'd1) begin
		r_cnt_audio_reset	<= 8'd2;
	end else if (flash_audio_reset_b) begin
		r_cnt_audio_reset	<= 8'd1;
	end
end

assign audio_bit_clk = (r_cnt_audio_reset>=8'd2) ? 1'bz : ~sys13p5_clk;
assign audio_sdata_in = lfsr_out[0];
audio A_AUDIO (
.clk					(sys27_clk				),//i
.rst_n					(rst_n					),//i
.audio_bit_clk			(audio_bit_clk			),//i
.flash_audio_reset_b	(flash_audio_reset_b	),//o
.audio_sdata_in			(audio_sdata_in			),//i
.audio_sdata_out		(audio_sdata_out		),//o
.audio_sync				(audio_sync				),//o
.btn_c					(btn_c					),//i
.btn_n					(btn_n					),//i
.btn_e					(btn_e					),//i
.btn_s					(btn_s					),//i
.btn_w					(btn_w					),//i
.tp						(tp						),//o[ 8-1: 0]	
);

lfsr32 A_LFSR (
.CLK			(audio_bit_clk	),//i
.RST			(rst_n			),//i
.en				(1'b1			),//i
.out			(lfsr_out		) //o[31:0]
);


endmodule

