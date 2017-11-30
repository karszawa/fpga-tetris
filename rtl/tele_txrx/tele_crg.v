`timescale 1ns/1ps

module tele_crg (
	input			src_clk			,
	input			rst_src_n		,
	output			src_clk_1		,
	output	reg		src_clk_2		,
	output	reg		src_clk_4		,
	output	reg		src_clk_8		,
	output	reg		src_clk_16		 
);

reg [ 4-1: 0] cnt_src_clk;
always @ (posedge src_clk or negedge rst_src_n) begin
	if (~rst_src_n) begin
		cnt_src_clk <= {4{1'b0}};
	end else begin
		cnt_src_clk <= cnt_src_clk + 1'b1;
	end
end

assign t_src_clk_16 = cnt_src_clk[3];
assign t_src_clk_8 = cnt_src_clk[2];
assign t_src_clk_4 = cnt_src_clk[1];
assign t_src_clk_2 = cnt_src_clk[0];

assign src_clk_1 = src_clk;

always @ (posedge src_clk) begin
	src_clk_2 <= t_src_clk_2;
end
always @ (posedge src_clk_2) begin
	src_clk_4 <= t_src_clk_4;
end
always @ (posedge src_clk_4) begin
	src_clk_8 <= t_src_clk_8;
end
always @ (posedge src_clk_8) begin
	src_clk_16 <= t_src_clk_16;
end


endmodule
