`timescale 1ns/1ps

module move_rect (
		input									clk,
		input									rst_n,

		input									i_button_c,
		input									i_button_e,
		input									i_button_w,
		input									i_button_s,
		input									i_button_n,

		// MOUSE
		input								i_mouse_valid	,
		input			[12-1: 0]			i_rect_pos_x	,
		input			[12-1: 0]			i_rect_pos_y	,
		input			[ 9-1: 0]			i_mouse_dif_x	,
		input			[ 9-1: 0]			i_mouse_dif_y	,

		output								o_sync_vs,
		output								o_sync_hs,
		output								o_sync_va,
		output								o_sync_ha,
		output								o_sync_de,
		output			[ 8-1: 0]	o_sync_red,
		output			[ 8-1: 0]	o_sync_grn,
		output			[ 8-1: 0]	o_sync_blu 
);

wire	i_pls_c;
wire	i_pls_e;
wire	i_pls_w;
wire	i_pls_s;
wire	i_pls_n;

wire	i_sync_vs;
wire	i_sync_hs;
wire	i_sync_va;
wire	i_sync_ha;
wire	i_sync_de;

button_detector A0_BUTTON (
.clk							(clk							),//i
.rst_n						(rst_n						),//i
.BUTTON_C					(i_button_c				),//i
.BUTTON_E					(i_button_e				),//i
.BUTTON_W					(i_button_w				),//i
.BUTTON_S					(i_button_s				),//i
.BUTTON_N					(i_button_n				),//i
.O_PLS_BUTTON_C		(i_pls_c					),//o
.O_PLS_BUTTON_E		(i_pls_e					),//o
.O_PLS_BUTTON_W		(i_pls_w					),//o
.O_PLS_BUTTON_S		(i_pls_s					),//o
.O_PLS_BUTTON_N		(i_pls_n					) //o
);

sync_gen A1_SYNC (
.disp_clk					(clk							),//i
.rst_disp_n				(rst_n						),//i
.o_sync_vs				(i_sync_vs				),//o
.o_sync_hs				(i_sync_hs				),//o
.o_sync_va				(i_sync_va				),//o
.o_sync_ha				(i_sync_ha				),//o
.o_sync_de				(i_sync_de				) //o
);

draw_rect A2_DRAW (
.clk							(clk							),//i
.rst_n		 				(rst_n		 				),//i
.i_pls_c	 				(i_pls_c	 				),//i
.i_pls_e	 				(i_pls_e	 				),//i
.i_pls_w	 				(i_pls_w	 				),//i
.i_pls_s	 				(i_pls_s	 				),//i
.i_pls_n	 				(i_pls_n	 				),//i
.i_mouse_valid		(i_mouse_valid		),//i
.i_rect_pos_x		(i_rect_pos_x		),//i[12-1: 0]	
.i_rect_pos_y		(i_rect_pos_y		),//i[12-1: 0]	
.i_mouse_dif_x		(i_mouse_dif_x		),//i[ 9-1: 0]	
.i_mouse_dif_y		(i_mouse_dif_y		),//i[ 9-1: 0]	
.i_sync_vs 				(i_sync_vs 				),//i
.i_sync_hs 				(i_sync_hs 				),//i
.i_sync_va 				(i_sync_va 				),//i
.i_sync_ha 				(i_sync_ha 				),//i
.i_sync_de 				(i_sync_de 				),//i
.o_sync_vs 				(o_sync_vs 				),//o
.o_sync_hs 				(o_sync_hs 				),//o
.o_sync_va 				(o_sync_va 				),//o
.o_sync_ha 				(o_sync_ha 				),//o
.o_sync_de 				(o_sync_de 				),//o
.o_sync_red				(o_sync_red				),//o[ 8-1: 0]
.o_sync_grn				(o_sync_grn				),//o[ 8-1: 0]
.o_sync_blu				(o_sync_blu				) //o[ 8-1: 0]
);


endmodule
