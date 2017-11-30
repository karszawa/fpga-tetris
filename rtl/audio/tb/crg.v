`timescale 1ns/1ps

module crg (
	output	reg		rst_n			,
	output	reg		sys13p5_clk		,
	output	reg		sys27_clk		,
	output	reg		sys54_clk		,
	output	reg		sys108_clk		,
	output	reg		sys100_clk		,
	output	reg		sys200_clk		,
	output	reg		sys400_clk		,
	output	reg		sys800_clk		,
	output	reg		sys120_clk		,
	output	reg		sys240_clk		,
	output	reg		sys480_clk		,
	output	reg		sys960_clk		,
	output	reg		disp40_clk		,
	output	reg		disp80_clk		,
	output	reg		disp160_clk		,
	output	reg		disp320_clk		 
);

real PERIOD_SYS = (1000.0/1600.0);
real PERIOD_DISP= (1000.0/640.0);
real PERIOD_SYS2= (1000.0/1920.0);
real PERIOD_SYS3= (1000.0/216.0);
//real PERIOD_SYS = 0.625;
//real PERIOD_DISP= 1.5625;

reg rst_clk_n;
reg sys1600_clk;
reg sys1920_clk;
reg sys216_clk;
reg disp640_clk;

initial begin
	rst_n = 1;
	#200 rst_n = 0;
	#200 rst_n = 1;
end

initial begin
	rst_clk_n = 1;
	#50 rst_clk_n = 0;
	#50 rst_clk_n = 1;
end

// sys1600_clk;
initial begin
	sys1600_clk = 0;
//	forever # (0.3125) sys1600_clk = ~sys1600_clk;
	forever # (PERIOD_SYS/2.0) sys1600_clk = ~sys1600_clk;
end

// sys1920_clk;
initial begin
	sys1920_clk = 0;
	forever # (PERIOD_SYS2/2.0) sys1920_clk = ~sys1920_clk;
end

// sys216_clk;
initial begin
	sys216_clk = 0;
	forever # (PERIOD_SYS3/2.0) sys216_clk = ~sys216_clk;
end

// disp640_clk;
initial begin
	disp640_clk = 0;
//	forever # (0.78125) disp640_clk = ~disp640_clk;
	forever # (PERIOD_DISP/2.0) disp640_clk = ~disp640_clk;
end

reg [ 4-1: 0] cnt_clk_sys;
always @ (posedge sys1600_clk or negedge rst_clk_n) begin
	if (~rst_clk_n) begin
		cnt_clk_sys <= {4{1'b0}};
	end else begin
		cnt_clk_sys <= cnt_clk_sys + 1'b1;
	end
end

assign t_sys100_clk = cnt_clk_sys[3];
assign t_sys200_clk = cnt_clk_sys[2];
assign t_sys400_clk = cnt_clk_sys[1];
assign t_sys800_clk = cnt_clk_sys[0];

always @ (posedge sys1600_clk) begin
	sys800_clk <= t_sys800_clk;
end
always @ (posedge sys800_clk) begin
	sys400_clk <= t_sys400_clk;
end
always @ (posedge sys400_clk) begin
	sys200_clk <= t_sys200_clk;
end
always @ (posedge sys200_clk) begin
	sys100_clk <= t_sys100_clk;
end

reg [ 4-1: 0] cnt_clk_sys2;
always @ (posedge sys1920_clk or negedge rst_clk_n) begin
	if (~rst_clk_n) begin
		cnt_clk_sys2 <= {4{1'b0}};
	end else begin
		cnt_clk_sys2 <= cnt_clk_sys2 + 1'b1;
	end
end

assign t_sys120_clk = cnt_clk_sys2[3];
assign t_sys240_clk = cnt_clk_sys2[2];
assign t_sys480_clk = cnt_clk_sys2[1];
assign t_sys960_clk = cnt_clk_sys2[0];

always @ (posedge sys1920_clk) begin
	sys960_clk <= t_sys960_clk;
end
always @ (posedge sys960_clk) begin
	sys480_clk <= t_sys480_clk;
end
always @ (posedge sys480_clk) begin
	sys240_clk <= t_sys240_clk;
end
always @ (posedge sys240_clk) begin
	sys120_clk <= t_sys120_clk;
end

reg [ 4-1: 0] cnt_clk_sys3;
always @ (posedge sys216_clk or negedge rst_clk_n) begin
	if (~rst_clk_n) begin
		cnt_clk_sys3 <= {4{1'b0}};
	end else begin
		cnt_clk_sys3 <= cnt_clk_sys3 + 1'b1;
	end
end

assign t_sys13p5_clk = cnt_clk_sys3[3];
assign t_sys27_clk   = cnt_clk_sys3[2];
assign t_sys54_clk   = cnt_clk_sys3[1];
assign t_sys108_clk  = cnt_clk_sys3[0];

always @ (posedge sys216_clk) begin
	sys108_clk <= t_sys108_clk;
end
always @ (posedge sys108_clk) begin
	sys54_clk <= t_sys54_clk;
end
always @ (posedge sys54_clk) begin
	sys27_clk <= t_sys27_clk;
end
always @ (posedge sys27_clk) begin
	sys13p5_clk <= t_sys13p5_clk;
end

reg [ 4-1: 0] cnt_clk_disp;
always @ (posedge disp640_clk or negedge rst_clk_n) begin
	if (~rst_clk_n) begin
		cnt_clk_disp <= {4{1'b0}};
	end else begin
		cnt_clk_disp <= cnt_clk_disp + 1'b1;
	end
end

assign t_disp40_clk	= cnt_clk_disp[3];
assign t_disp80_clk	= cnt_clk_disp[2];
assign t_disp160_clk	= cnt_clk_disp[1];
assign t_disp320_clk	= cnt_clk_disp[0];

always @ (posedge disp80_clk) begin
	disp40_clk  <= t_disp40_clk	;
end
always @ (posedge disp160_clk) begin
	disp80_clk  <= t_disp80_clk	;
end
always @ (posedge disp320_clk) begin
	disp160_clk <= t_disp160_clk	;
end
always @ (posedge disp640_clk) begin
	disp320_clk <= t_disp320_clk	;
end

endmodule
