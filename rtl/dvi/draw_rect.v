`timescale 1ns/1ps

module draw_rect (
	input clk,
	input rst_n,

	input i_sync_vs,
	input i_sync_hs,
	input i_sync_va,
	input i_sync_ha,
	input i_sync_de,
	input [4:0] blk_pos_x,
	input [4:0] blk_pos_y,
	input [4:0] blk_id,
	input [4:0] blk_rad,
	input [1023:0] board,

	output reg o_sync_vs,
	output reg o_sync_hs,
	output reg o_sync_va,
	output reg o_sync_ha,
	output reg o_sync_de,
	output reg [8-1:0] o_sync_red,
	output reg [8-1:0] o_sync_grn,
	output reg [8-1:0] o_sync_blu 
);

parameter MAX_W = 11'd1024;
parameter MAX_H	= 11'd768;

parameter COLOR_BLANK = 4'd0;
parameter COLOR_OUTER = 4'd1;
parameter COLOR_BLOCK = 4'd2;
parameter COLOR_TARGET = 4'd3;

// 4 bits * 2 positions * 4 blocks * 4 rads * 2 types 
parameter [4 * 2 * 4 * 4 * 2 - 1 : 0] BLOCKS = {	
	// Type I
	{ 4'd0, 4'd0 }, { 4'd0, 4'd1 }, { 4'd0, 4'd2 }, { 4'd0, 4'd3 },
	{ 4'd0, 4'd0 }, { 4'd1, 4'd0 }, { -4'd1, 4'd0 }, { -4'd2, 4'd0 },
	{ 4'd0, 4'd0 }, { 4'd0, 4'd1 }, { 4'd0, 4'd2 }, { 4'd0, 4'd3 },
	{ 4'd0, 4'd0 }, { 4'd1, 4'd0 }, { -4'd1, 4'd0 }, { -4'd2, 4'd0 },

	// Type J
	{ 4'd0, 4'd0 }, { -4'd1, 4'd0 }, { 4'd0, 4'd1 }, { 4'd1, 4'd1 },
	{ 4'd0, 4'd0 }, { 4'd0, -4'd0 }, { 4'd0, 4'd1 }, { -4'd1, 4'd1 },
	{ -4'd1, 4'd0 }, { -4'd1, 4'd1 }, { 4'd0, 4'd1 }, { 4'd1, 4'd1 },
	{ 4'd1, -4'd0 }, { 4'd0, -4'd1 }, { 4'd0, 4'd0 }, { 4'd0, 4'd1 }
};

parameter IW = 4 * 2 * 4 * 4;
parameter RW = 4 * 2 * 4;

reg [11-1: 0] r_cnt_x;
reg	[11-1: 0] r_cnt_y;

reg [3:0] area;

wire [9:0] board_y;
assign board_y = r_cnt_y >> 5;

wire [9:0] board_x;
assign board_x = r_cnt_x >> 5;

wire [9:0] offset;
assign offset = (board_y * 10 + board_x) * 4;

wire [9:0] blk_offset;
assign blk_offset = blk_id * IW + blk_rad * RW;

// AREA
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		area <= 0;
	end else begin
		if (board_x >= 10 || board_y >= 20) begin
			area <= COLOR_OUTER;
		end else if (
			(
				board_x == blk_pos_x + $signed(BLOCKS[blk_offset+ 0 +: 4]) &&
				board_y == blk_pos_y + $signed(BLOCKS[blk_offset+ 4 +: 4])
			) || (
				board_x == blk_pos_x + $signed(BLOCKS[blk_offset+ 8 +: 4]) &&
				board_y == blk_pos_y + $signed(BLOCKS[blk_offset+12 +: 4])
			) || (
				board_x == blk_pos_x + $signed(BLOCKS[blk_offset+16 +: 4]) &&
				board_y == blk_pos_y + $signed(BLOCKS[blk_offset+20 +: 4])
			) || (
				board_x == blk_pos_x + $signed(BLOCKS[blk_offset+24 +: 4]) &&
				board_y == blk_pos_y + $signed(BLOCKS[blk_offset+28 +: 4])
			)
		) begin
			area <= COLOR_TARGET;
		end else if (board[offset +: 4] != 0) begin
			area <= COLOR_BLOCK;
		end else begin
			area <= COLOR_BLANK;
		end
	end
end

assign i_sync_all = i_sync_vs & i_sync_hs & i_sync_va & i_sync_ha & i_sync_de;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		r_cnt_x	<= 11'd0;
		r_cnt_y	<= 11'd0;
	end else if (i_sync_all) begin
		if (r_cnt_x == (MAX_W - 1)) begin
			r_cnt_x	<= 11'd0;
			
			if (r_cnt_y == (MAX_H - 1)) begin
				r_cnt_y	<= 11'd0;
			end else begin
				r_cnt_y	<= r_cnt_y + 1;
			end
		end else begin
			r_cnt_x	<= r_cnt_x + 1;
		end
	end
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		o_sync_vs <= 1'b0;
		o_sync_hs <= 1'b0;
		o_sync_va <= 1'b0;
		o_sync_ha <= 1'b0;
		o_sync_de <= 1'b0;
		o_sync_red <= 8'd0;
		o_sync_grn <= 8'd0;
		o_sync_blu <= 8'd0;
	end else begin
		o_sync_vs <= i_sync_vs;
		o_sync_hs <= i_sync_hs;
		o_sync_va <= i_sync_va;
		o_sync_ha <= i_sync_ha;
		o_sync_de <= i_sync_de;
		
		o_sync_red	<= (area == COLOR_BLANK ? 8'd0:
					   (area == COLOR_OUTER ? 8'd200:
					   (area == COLOR_BLOCK ? 8'd100:
					   (area == COLOR_TARGET ? 8'd0 : 8'd0))));
					
		o_sync_grn	<= (area == COLOR_BLANK ? 8'd0:
					   (area == COLOR_OUTER ? 8'd200:
					   (area == COLOR_BLOCK ? 8'd0:
					   (area == COLOR_TARGET ? 8'd100 : 8'd0))));
					   
		o_sync_blu	<= (area == COLOR_BLANK ? 8'd0:
					   (area == COLOR_OUTER ? 8'd200:
					   (area == COLOR_BLOCK ? 8'd0:
					   (area == COLOR_TARGET ? 8'd100 : 8'd0))));
	end
end

endmodule
