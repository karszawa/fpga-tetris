`timescale 1ns/1ps

module move_rect (
	input clk,
	input rst_n,

	input i_button_c,
	input i_button_e,
	input i_button_w,
	input i_button_s,
	input i_button_n,

	output o_sync_vs,
	output o_sync_hs,
	output o_sync_va,
	output o_sync_ha,
	output o_sync_de,
	output [ 8-1: 0] o_sync_red,
	output [ 8-1: 0] o_sync_grn,
	output [ 8-1: 0] o_sync_blu 
);

wire i_pls_c;
wire i_pls_e;
wire i_pls_w;
wire i_pls_s;
wire i_pls_n;

wire i_sync_vs;
wire i_sync_hs;
wire i_sync_va;
wire i_sync_ha;
wire i_sync_de;

reg [9:0] blk_pos_x = 5'b0;
reg [9:0] blk_pos_y = 5'b0;
reg [1023:0] board;
reg [3:0] block_id;
reg [1:0] block_rad;
reg [3:0] state;
	
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		blk_pos_x <= 5'b0;
		blk_pos_y <= 5'b0;
		block_id <= 4'b0;
		block_rad <= 2'b0;
		// board <= 1024'h1000_0000_0111;
		board <= 1024'b0;
	end else begin
		// can move?
		blk_pos_x <= blk_pos_x
			+ ((i_pls_e == 0 || blk_pos_x >= 9) ? 5'b0 : +5'b1)
			+ ((i_pls_w == 0 || blk_pos_x <= 0) ? 5'b0 : -5'b1);

		// can rotate?
		if (i_pls_n != 0) begin
			block_rad <= (block_rad + 1) % 4;
		end
		
		// can increment y?
		if (i_pls_s != 0 && blk_pos_y < 20) begin
			blk_pos_y <= blk_pos_y + 1;
		end else begin
			// count up and put object if count is larger than X
		end	
	end
end

button_detector A0_BUTTON (
	.clk (clk),//i
	.rst_n (rst_n),//i
	.BUTTON_C (i_button_c),//i
	.BUTTON_E (i_button_e),//i
	.BUTTON_W (i_button_w),//i
	.BUTTON_S (i_button_s),//i
	.BUTTON_N (i_button_n),//i
	.O_PLS_BUTTON_C (i_pls_c),//o
	.O_PLS_BUTTON_E (i_pls_e),//o
	.O_PLS_BUTTON_W	(i_pls_w),//o
	.O_PLS_BUTTON_S	(i_pls_s),//o
	.O_PLS_BUTTON_N	(i_pls_n) //o
);

sync_gen A1_SYNC (
	.disp_clk (clk),//i
	.rst_disp_n (rst_n),//i
	.o_sync_vs (i_sync_vs),//o
	.o_sync_hs (i_sync_hs),//o
	.o_sync_va (i_sync_va),//o
	.o_sync_ha (i_sync_ha),//o
	.o_sync_de (i_sync_de) //o
);

draw_rect A2_DRAW (
	.clk (clk),//i
	.rst_n (rst_n),//i
	.i_sync_vs (i_sync_vs),//i
	.i_sync_hs (i_sync_hs),//i
	.i_sync_va (i_sync_va),//i
	.i_sync_ha (i_sync_ha),//i
	.i_sync_de (i_sync_de),//i
	.blk_pos_x (blk_pos_x),
	.blk_pos_y (blk_pos_y),
	.blk_id (block_id),
	.blk_rad (block_rad),
	.board (board),
	.o_sync_vs (o_sync_vs),//o
	.o_sync_hs (o_sync_hs),//o
	.o_sync_va (o_sync_va),//o
	.o_sync_ha (o_sync_ha),//o
	.o_sync_de (o_sync_de),//o
	.o_sync_red (o_sync_red),//o[ 8-1: 0]
	.o_sync_grn (o_sync_grn),//o[ 8-1: 0]
	.o_sync_blu (o_sync_blu) //o[ 8-1: 0]
);

/*update_position UPDATE_POSITION (
	.clk (clk),
    .i_pls_e (i_pls_e),
    .i_pls_w (i_pls_w),
    .board (board),
    .block_id (block_id),
    .block_rad (block_rad),
    .blk_pos_x (blk_pos_x),
    .blk_pos_y (blk_pos_y),
    .state (state)
);*/

endmodule
