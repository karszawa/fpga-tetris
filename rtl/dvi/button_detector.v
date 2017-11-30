`timescale 1ns/1ps

module button_detector (
	input			clk,
	input			rst_n,

	input           BUTTON_C, // B21
	input           BUTTON_E, // A23
	input           BUTTON_W, // C21
	input           BUTTON_S, // B22
	input           BUTTON_N, // A22

	output	reg		O_PLS_BUTTON_C,
	output	reg		O_PLS_BUTTON_E,
	output	reg		O_PLS_BUTTON_W,
	output	reg		O_PLS_BUTTON_S,
	output	reg		O_PLS_BUTTON_N 
);

reg	[ 5-1: 0] BUTTON_C_D;
reg	[ 5-1: 0] BUTTON_E_D;
reg	[ 5-1: 0] BUTTON_W_D;
reg	[ 5-1: 0] BUTTON_S_D;
reg	[ 5-1: 0] BUTTON_N_D;
always @ (posedge clk) begin
	BUTTON_C_D <= {BUTTON_C_D[3:0], BUTTON_C};
	BUTTON_E_D <= {BUTTON_E_D[3:0], BUTTON_E};
	BUTTON_W_D <= {BUTTON_W_D[3:0], BUTTON_W};
	BUTTON_S_D <= {BUTTON_S_D[3:0], BUTTON_S};
	BUTTON_N_D <= {BUTTON_N_D[3:0], BUTTON_N};
end
wire BUTTON_C_D_EDGE_RIS;
wire BUTTON_E_D_EDGE_RIS;
wire BUTTON_W_D_EDGE_RIS;
wire BUTTON_S_D_EDGE_RIS;
wire BUTTON_N_D_EDGE_RIS;
assign BUTTON_C_D_EDGE_RIS = BUTTON_C_D[3] & ~BUTTON_C_D[4];
assign BUTTON_E_D_EDGE_RIS = BUTTON_E_D[3] & ~BUTTON_E_D[4];
assign BUTTON_W_D_EDGE_RIS = BUTTON_W_D[3] & ~BUTTON_W_D[4];
assign BUTTON_S_D_EDGE_RIS = BUTTON_S_D[3] & ~BUTTON_S_D[4];
assign BUTTON_N_D_EDGE_RIS = BUTTON_N_D[3] & ~BUTTON_N_D[4];

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		O_PLS_BUTTON_C	<= 1'b0;
		O_PLS_BUTTON_E	<= 1'b0;
		O_PLS_BUTTON_W	<= 1'b0;
		O_PLS_BUTTON_S	<= 1'b0;
		O_PLS_BUTTON_N	<= 1'b0;
	end else begin
		O_PLS_BUTTON_C	<= BUTTON_C_D_EDGE_RIS;
		O_PLS_BUTTON_E	<= BUTTON_E_D_EDGE_RIS;
		O_PLS_BUTTON_W	<= BUTTON_W_D_EDGE_RIS;
		O_PLS_BUTTON_S	<= BUTTON_S_D_EDGE_RIS;
		O_PLS_BUTTON_N	<= BUTTON_N_D_EDGE_RIS;
	end
end

endmodule
