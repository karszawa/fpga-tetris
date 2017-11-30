`timescale 1ns/1ps

module tele_err (
	input						Clock,
	input						Reset,

	input						i_update,
	input		[20-1: 0]		i_period,

	input						i_tx,
	input						i_rx,

	output	reg					o_flag,
	output	reg	[ 7-1: 0]		o_addr,
	output	reg	[ 4-1: 0]		o_data,
	output						o_err_detected
);


reg [20-1: 0]	ErrCnt;
reg [20-1: 0]	Period;
reg [ 3-1: 0]	cnt_data_out;
reg				r_update;

assign data_out_done = (cnt_data_out==3'd4) ? 1 : 0;
assign o_err_detected = (i_rx!=i_tx);
always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		ErrCnt <= 0;
		Period <= 0;
	end else if( Period >= i_period ) begin
		// この時の ErrCntを表示する
		if (data_out_done) begin
			Period <= 0;
			ErrCnt <= 0;
		end
	end else begin
		Period <= Period + 1;
		if(o_err_detected) ErrCnt <= ErrCnt + 1;
	end
end

always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		r_update	<= 1;
	end else if (i_update) begin
		r_update	<= 1;
	end else if( Period >= i_period ) begin
		if (cnt_data_out==3'd4) begin
			r_update	<= 0;
		end
	end
end

always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		cnt_data_out <= 0;
		o_flag	<= 0;
		o_addr	<= 0;
		o_data	<= 0;
	end else if( Period >= i_period ) begin
		if (cnt_data_out==3'd4) begin
			cnt_data_out <= 0;
		end else begin
			cnt_data_out <= cnt_data_out + 1;
		end
		o_flag	<= 1&r_update;
		o_addr	<= (cnt_data_out==3'd0) ? 7'd123 : (cnt_data_out==3'd1) ? 7'd124 : (cnt_data_out==3'd2) ? 7'd125 : (cnt_data_out==3'd3) ? 7'd126 : 7'd127 ;
		o_data	<= (cnt_data_out==3'd0) ? ErrCnt[19:16] : (cnt_data_out==3'd1) ? ErrCnt[15:12] : (cnt_data_out==3'd2) ? ErrCnt[11:8] : (cnt_data_out==3'd3) ? ErrCnt[7:4] : ErrCnt[3:0] ;
	end else begin
		cnt_data_out <= 0;
		o_flag	<= 0;
		o_addr	<= 0;
		o_data	<= 0;
	end
end

endmodule
