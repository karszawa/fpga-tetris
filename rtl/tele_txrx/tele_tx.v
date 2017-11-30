`timescale 1ns/1ps

module tele_tx (
	input			clk,	// 100Mhz
	input			rst_n,

	output	reg		o_tx,

	output	reg				o_tx_flag,
	output	reg	[7-1: 0]	o_tx_addr,
	output	reg	[4-1: 0]	o_tx_data 
);

parameter	S_IDLE= 2'b00;	//IDLE
parameter	S_RDY = 2'b01;	//READY
parameter	S_RUN = 2'b10;	//RUN

reg		[ 2-1: 0]	state_cur;
reg		[ 2-1: 0]	state_nxt;

reg		[20-1: 0]	cnt_idle;
reg		[20-1: 0]	cnt_rdy;
reg		[ 4-1: 0]	cnt_run;

reg		[ 7-1: 0]	r_addr;
wire	[ 4-1: 0]	w_data;

wire				flag_start;
wire				flag_rdy_done;
wire				flag_run_done;

reg		[16-1: 0]	w_tx;

//	reg		[2-1: 0]	cnt_clk;
//	reg					clk_div_2;	// 50Mhz
//	reg					clk_div_4;	// 25Mhz
//	
//	always @ (posedge clk or negedge rst_n) begin
//		if (~rst_n) begin
//			cnt_clk	<= {2{1'b0}};
//		end else begin
//			cnt_clk	<= cnt_clk + 1'b1;
//		end
//	end
//	
//	always @ (posedge clk or negedge rst_n) begin
//		if (~rst_n) begin
//			clk_div_2	<= 1'b0;
//			clk_div_4	<= 1'b0;
//		end else begin
//			clk_div_2	<= cnt_clk[0];
//			clk_div_4	<= cnt_clk[1];
//		end
//	end


always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		state_cur	<=	S_IDLE;
	end else begin
		state_cur	<=	state_nxt;
	end
end

always @ (*) begin
	if (state_cur==S_IDLE) begin
		if (flag_start)	state_nxt	<= S_RDY;
		else			state_nxt	<= S_IDLE;
	end else if (state_cur==S_RDY) begin
		if (flag_rdy_done)	state_nxt	<= S_RUN;
		else				state_nxt	<= S_RDY;
	end else if (state_cur==S_RUN) begin
		if (flag_run_done)	state_nxt	<= S_RDY;
		else				state_nxt	<= S_RUN;
	end else begin
		state_nxt	<= S_RDY;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cnt_idle	<= {20{1'b0}};
	end else if (state_cur==S_IDLE) begin
		cnt_idle	<= cnt_idle + 1'b1;
	end
end

assign	flag_start	= (state_cur==S_IDLE)&(cnt_idle==20'd2000);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cnt_rdy		<= {20{1'b0}};
	end else if ((state_cur!=S_RDY)&(state_nxt==S_RDY)) begin
		cnt_rdy		<= {20{1'b0}};
	end else if (state_cur==S_RDY) begin
		cnt_rdy		<= cnt_rdy + 1'b1;
	end
end

assign	flag_rdy_done	= (state_cur==S_RDY)&(cnt_rdy==20'd20);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		cnt_run		<= {4{1'b0}};
	end else if ((state_cur!=S_RUN)&(state_nxt==S_RUN)) begin
		cnt_run		<= {4{1'b0}};
	end else if (state_cur==S_RUN) begin
		cnt_run		<= cnt_run + 1'b1;
	end
end

assign	flag_run_done	= (state_cur==S_RUN)&(cnt_run==4'd15);

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		r_addr	<=	{7{1'b0}};
	end else if ((state_cur==S_RUN)&(state_nxt!=S_RUN)) begin
		r_addr	<=	r_addr + 1'b1;
	end
end

assign w_data = r_addr[3:0];

always @ (*) begin
	if (state_cur==S_RUN) begin
		w_tx[ 0]	= 1'b1;
		w_tx[ 1]	= 1'b0;
		w_tx[ 2]	= 1'b1;
		w_tx[ 3]	= 1'b0;
		w_tx[ 4]	= r_addr[6];
		w_tx[ 5]	= r_addr[5];
		w_tx[ 6]	= r_addr[4];
		w_tx[ 7]	= r_addr[3];
		w_tx[ 8]	= r_addr[2];
		w_tx[ 9]	= r_addr[1];
		w_tx[10]	= r_addr[0];
		w_tx[11]	= w_data[3];
		w_tx[12]	= w_data[2];
		w_tx[13]	= w_data[1];
		w_tx[14]	= w_data[0];
		w_tx[15]	= ^w_tx[14:0];
	end else begin
		w_tx		= {15{1'b0}};
	end
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		o_tx	<= 1'b0;
	end else if (state_cur==S_RUN) begin
		if		(cnt_run==4'h0) o_tx	<= w_tx[ 0];
		else if (cnt_run==4'h1) o_tx	<= w_tx[ 1];
		else if (cnt_run==4'h2) o_tx	<= w_tx[ 2];
		else if (cnt_run==4'h3) o_tx	<= w_tx[ 3];
		else if	(cnt_run==4'h4) o_tx	<= w_tx[ 4];
		else if (cnt_run==4'h5) o_tx	<= w_tx[ 5];
		else if (cnt_run==4'h6) o_tx	<= w_tx[ 6];
		else if (cnt_run==4'h7) o_tx	<= w_tx[ 7];
		else if	(cnt_run==4'h8) o_tx	<= w_tx[ 8];
		else if (cnt_run==4'h9) o_tx	<= w_tx[ 9];
		else if (cnt_run==4'hA) o_tx	<= w_tx[10];
		else if (cnt_run==4'hB) o_tx	<= w_tx[11];
		else if	(cnt_run==4'hC) o_tx	<= w_tx[12];
		else if (cnt_run==4'hD) o_tx	<= w_tx[13];
		else if (cnt_run==4'hE) o_tx	<= w_tx[14];
		else if (cnt_run==4'hF) o_tx	<= w_tx[15];
	end else begin
		o_tx	<= 1'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		o_tx_flag	<= {1{1'b0}};
		o_tx_addr	<= {7{1'b0}};
		o_tx_data	<= {4{1'b0}};
	end else if ( flag_run_done ) begin
		o_tx_flag	<= flag_run_done;
		o_tx_addr	<= r_addr;
		o_tx_data	<= w_data;
	end else begin
		o_tx_flag	<= {1{1'b0}};
		o_tx_addr	<= {7{1'b0}};
		o_tx_data	<= {4{1'b0}};
	end
end

endmodule
