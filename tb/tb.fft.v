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
//wire				rst_n				;
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

reg					flash_audio_reset_b_ris_lvl	;

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

reg		[ 8-1: 0]	cnt_op;
always @ (posedge sys100_clk or negedge rst_n) begin
	if (~rst_n) begin
		cnt_op	<= {8{1'b0}};
	end else begin
		cnt_op	<= cnt_op + 1'b1;
	end
end


wire START, DONE;
wire	[32-1: 0]	A, Y;

wire signed	[16-1: 0]	AR, AI;
wire signed	[16-1: 0]	YR, YI;

assign YR = Y[32-1:16];
assign YI = Y[16-1: 0];

assign A = { AR, AI };

wire	[ 8-1: 0]	w_cnt_op;
//assign w_cnt_op = (cnt_op >= 8'd16) ? 0 : cnt_op;
assign w_cnt_op = { {4{1'b0}}, cnt_op[4-1: 0] };

//assign A =	(w_cnt_op < 8'd4) ? { {24{1'b0}}, w_cnt_op} : 
//			(w_cnt_op < 8'd12) ? (32'd8 - w_cnt_op) : 
//			(w_cnt_op < 8'd16) ? (-32'd16 + w_cnt_op) : {32{1'b0}} ;
assign AR = (cnt_op[1:0]==2'd0) ?  16'd1 :
			(cnt_op[1:0]==2'd1) ?  16'd0 :
			(cnt_op[1:0]==2'd2) ? -16'd1 :
			(cnt_op[1:0]==2'd3) ?  16'd0 : 0;

assign AI = (cnt_op[1:0]==2'd0) ?  16'd0 :
			(cnt_op[1:0]==2'd1) ?  16'd1 :
			(cnt_op[1:0]==2'd2) ?  16'd0 :
			(cnt_op[1:0]==2'd3) ? -16'd1 : 0;

assign START = (cnt_op==8'd15);

FFT16_SEQUENTIAL A1_FFT16 (
.CLK		(sys100_clk		),//i
.RESET		(~rst_n			),//i
.START		(START			),//i
.DONE		(DONE			),//o
.A			(A				),//i[31:0] 
.Y			(Y				) //o[31:0]
);


endmodule

