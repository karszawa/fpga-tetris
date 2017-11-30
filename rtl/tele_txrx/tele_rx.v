`timescale 1ns/1ps

module tele_rx (
	input					clk,		// 100Mhz
	input					rst_n,

	input					i_rx	,

	output	reg				o_rx_flag,
	output	reg	[7-1: 0]	o_rx_addr,
	output	reg	[4-1: 0]	o_rx_data 
);

parameter	D_META	= 5;

reg		[D_META-1: 0]	i_rx_d;

reg		[16-1: 0]	rx_stream_buf;

wire				t_rx_flag;
wire	[7-1: 0]	t_rx_addr;
wire	[4-1: 0]	t_rx_data;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		i_rx_d	<=	{D_META{1'b0}};
	end else begin
		i_rx_d	<= {i_rx_d[D_META-2:0], i_rx};
	end
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		rx_stream_buf	<= {16{1'b0}};
	end else begin
		rx_stream_buf	<= { rx_stream_buf[16-2:0], i_rx_d[D_META-1] };
	end
end

assign	t_rx_check_sum = rx_stream_buf[ 0];
assign	w_rx_check_sum = ^rx_stream_buf[15: 1];
assign	flag_rx_check_sum = (t_rx_check_sum==w_rx_check_sum);

assign	t_rx_flag	= ( rx_stream_buf[16-1:12] == 4'b1010 ) & flag_rx_check_sum;

assign	t_rx_addr	= (t_rx_flag==1'b1) ? rx_stream_buf[11: 5] : 6'd0 ;
assign	t_rx_data	= (t_rx_flag==1'b1) ? rx_stream_buf[ 4: 1] : 4'd0 ;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		o_rx_flag	<= {1{1'b0}};
		o_rx_addr	<= {7{1'b0}};
		o_rx_data	<= {4{1'b0}};
	end else if ( t_rx_flag ) begin
		o_rx_flag	<= t_rx_flag;
		o_rx_addr	<= t_rx_addr;
		o_rx_data	<= t_rx_data;
	end else begin
		o_rx_flag	<= {1{1'b0}};
		o_rx_addr	<= {7{1'b0}};
		o_rx_data	<= {4{1'b0}};
	end
end

endmodule

