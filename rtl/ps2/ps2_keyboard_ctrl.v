
module ps2_keyboard_ctrl (
	input					clk					,
	input					rst_n				,
	output					o_command_valid		,
	output		[ 8-1: 0]	o_command_data		,
	input					i_command_ack		,
	input					i_command_err		,
	output		[ 8-1: 0]	tp						 
);

parameter	S_IDLE		= 3'd0;
parameter	S_SEND_RST	= 3'd1;
parameter	S_WAIT_ACK	= 3'd2;
parameter	S_DONE_INIT	= 3'd3;

reg		[ 3-1: 0]	curSTATE;
reg		[ 3-1: 0]	nxtSTATE;

reg		[32-1: 0]	cnt_wait;

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		curSTATE	<= S_IDLE;
	end else begin
		curSTATE	<= nxtSTATE;
	end
end

always @ (*) begin
	case (curSTATE)
		S_IDLE:begin
//			if (cnt_wait >= 32'd500_000_000) begin
			if (cnt_wait >= 32'd500) begin
				nxtSTATE	<= S_SEND_RST;
			end else begin
				nxtSTATE	<= S_IDLE;
			end
		end
		S_SEND_RST:begin
			nxtSTATE	<= S_WAIT_ACK;
		end
		S_WAIT_ACK:begin
			if (i_command_ack) begin
				nxtSTATE	<= S_DONE_INIT;
			end else if (i_command_err) begin
				nxtSTATE	<= S_SEND_RST;
			end else begin
				nxtSTATE	<= S_WAIT_ACK;
			end
		end
		S_DONE_INIT:begin
		end
		default:begin
			nxtSTATE	<= S_IDLE;
		end
	endcase
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cnt_wait	<= {32{1'b0}};
	end else if (curSTATE==S_IDLE) begin
		cnt_wait	<= cnt_wait + 1'b1;
	end else begin
		cnt_wait	<= {32{1'b0}};
	end
end

assign	o_command_valid	= (curSTATE==S_SEND_RST) ?  1'b1 : 1'b0  ;
assign	o_command_data	= (curSTATE==S_SEND_RST) ? 8'hFF : 8'h00 ;

assign	tp = { {6{1'b0}}, curSTATE[1:0] };

endmodule
