`timescale 1ns/1ps
`define MODE_FF

module disp_digit #(
	parameter	MAX_DISP	=  128		,
	parameter	POW_DISP	=    6		,
	parameter	SYNC_H     	=11'd1024	,
	parameter	SYNC_V     	=10'd768	,
	parameter	MAX_H     	= 7'd64 	,
	parameter	MAX_V     	= 7'd96 	,
	parameter	NUM_H     	= (SYNC_H/MAX_H),
	parameter	NUM_V     	= (SYNC_V/MAX_V),
	parameter	BOUNDARY	= 7'd5		,
	parameter	THICKNESS	= 7'd5
)(
	input					disp_clk			,
	input					rst_disp_n			,

	input					i_sync_vs			,
	input					i_sync_hs			,
	input					i_sync_va			,
	input					i_sync_ha			,
	input					i_sync_de			,

	input					i_disp_wen			, // WRITE TO DISP
	input					i_disp_men			,
	input		[ 7-1: 0]	i_disp_adr			,
	input		[ 4-1: 0]	i_disp_d			,

	output	reg				o_sync_vs			,
	output	reg				o_sync_hs			,
	output	reg				o_sync_va			,
	output	reg				o_sync_ha			,
	output	reg				o_sync_de			,
	output	reg	[ 8-1: 0]	o_red    			,
	output	reg	[ 8-1: 0]	o_grn				,
	output	reg	[ 8-1: 0]	o_blu				,		
	output					o_area				
);

reg		[ 7-1: 0]	r_cnt_h   ;
reg		[ 7-1: 0]	r_cnt_v   ;

reg		[ 4-1: 0]	r_cnt_row ;
reg		[ 4-1: 0]	r_cnt_clmn;

reg		[ 4-1: 0]	disp_buf_0[MAX_DISP-1:0];
reg		[ 4-1: 0]	disp_buf_1[MAX_DISP-1:0];

wire	[ 8-1: 0]	w_red    ;
wire	[ 8-1: 0]	w_grn	 ;
wire	[ 8-1: 0]	w_blu	 ;

wire	[ 4-1: 0]	seg_i_digit	;
wire	[ 8-1: 0]	seg_i_red	;
wire	[ 8-1: 0]	seg_i_grn	;
wire	[ 8-1: 0]	seg_i_blu	;
wire	[ 7-1: 0]	seg_cnt_h	;
wire	[ 7-1: 0]	seg_cnt_v	;
wire	[ 8-1: 0]	seg_o_red	;
wire	[ 8-1: 0]	seg_o_grn	;
wire	[ 8-1: 0]	seg_o_blu	;
wire				seg_o_area	;
assign o_area = seg_o_area;

wire [ 4-1: 0]	BUF_Q  ;

`ifdef MODE_FF
assign seg_i_digit	= (i_sync_de) ? disp_buf_1[NUM_H*r_cnt_row + r_cnt_clmn] : {4{1'b0}} ;
`else
assign seg_i_digit	= (i_sync_de) ? BUF_Q : {4{1'b0}} ;
`endif
assign seg_i_red	= (i_sync_de) ? 8'hFF : {8{1'b0}} ;
assign seg_i_grn	= (i_sync_de) ? 8'hFF : {8{1'b0}} ;
assign seg_i_blu	= (i_sync_de) ? 8'hFF : {8{1'b0}} ;

assign seg_cnt_h	= (i_sync_de) ? r_cnt_h : {7{1'b0}} ;
assign seg_cnt_v	= (i_sync_de) ? r_cnt_v : {7{1'b0}} ;

assign w_red = seg_o_red	;
assign w_grn = seg_o_grn	;
assign w_blu = seg_o_blu	;

assign w_sync_vs_fal = ~i_sync_vs & o_sync_vs;

// r_cnt_h
always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		r_cnt_h		<= {7{1'b0}};
	end else if (w_sync_vs_fal) begin
		r_cnt_h		<= {7{1'b0}};
	end else if (i_sync_de) begin
		if (r_cnt_h>=(MAX_H-1)) begin
			r_cnt_h <= {7{1'b0}};
		end else begin
			r_cnt_h <= r_cnt_h + 1'b1;
		end
	end
end

// r_cnt_clmn
always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		r_cnt_clmn	<= {4{1'b0}};
	end else if (w_sync_vs_fal) begin
		r_cnt_clmn	<= {4{1'b0}};
	end else if (i_sync_de) begin
		if (r_cnt_h>=(MAX_H-1)) begin
			if (r_cnt_clmn>=(NUM_H-1)) begin
				r_cnt_clmn	<= {4{1'b0}};
			end else begin
				r_cnt_clmn <= r_cnt_clmn + 1'b1;
			end
		end
	end
end

// r_cnt_v
always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		r_cnt_v		<= {7{1'b0}};
	end else if (w_sync_vs_fal) begin
		r_cnt_v		<= {7{1'b0}};
	end else if (i_sync_de) begin
		if ( (r_cnt_h>=(MAX_H-1) ) & (r_cnt_clmn>=(NUM_H-1)) ) begin
			if (r_cnt_v>=(MAX_V-1)) begin
				r_cnt_v <= {7{1'b0}};
			end else begin
				r_cnt_v <= r_cnt_v + 1'b1;
			end
		end
	end
end

// r_cnt_row
always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		r_cnt_row	<= {4{1'b0}};
	end else if (w_sync_vs_fal) begin
		r_cnt_row	<= {4{1'b0}};
	end else if (i_sync_de) begin
		if ( (r_cnt_h>=(MAX_H-1) ) & (r_cnt_clmn>=(NUM_H-1)) ) begin
			if (r_cnt_v>=(MAX_V-1)) begin
				r_cnt_row	<= r_cnt_row + 1'b1;
			end
		end
	end
end

// UPDATE DISP_BUF
`ifdef MODE_FF
always @ (posedge disp_clk) begin
	if ((i_disp_wen==1'b0)&(i_disp_men==1'b0)) begin
		if (i_disp_adr < MAX_DISP) begin
			disp_buf_0[i_disp_adr]	<= i_disp_d;
		end
	end
end
assign update_disp_buf = ~i_sync_vs&o_sync_vs;
integer i;
always @ (posedge disp_clk) begin
	if (update_disp_buf) begin
		for (i=0;i<MAX_DISP;i=i+1) begin
			disp_buf_1[i] <= disp_buf_0[i];
		end
	end
end
`else // `ifdef MODE_FF
wire            BUF0_WEN;
wire            BUF0_MEN;
wire [ 6-1: 0]	BUF0_ADR;
wire [ 4-1: 0]	BUF0_D  ;
wire [ 4-1: 0]	BUF0_Q  ;
wire            BUF1_WEN;
wire            BUF1_MEN;
wire [ 6-1: 0]	BUF1_ADR;
wire [ 4-1: 0]	BUF1_D  ;
wire [ 4-1: 0]	BUF1_Q  ;

reg index_disp_buf;
reg readied_disp_buf;

always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		readied_disp_buf <= 1'b0;
	end else if ((i_disp_wen==1'b0)&(i_disp_men==1'b0)&(i_disp_adr < MAX_DISP)) begin
		readied_disp_buf <= 1'b1;
	end else if (~i_sync_vs&o_sync_vs) begin
		if (readied_disp_buf) readied_disp_buf <= 1'b0;
	end
end

always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		index_disp_buf <= 1'b0;
	end else if (~i_sync_vs&o_sync_vs) begin
		if (readied_disp_buf) index_disp_buf <= ~index_disp_buf;
	end
end

assign BUF0_WEN = (index_disp_buf==1'b0) ? i_disp_wen : {1{1'b1}}  ;
assign BUF0_MEN = (index_disp_buf==1'b0) ? i_disp_men : ~i_sync_de ;
assign BUF0_ADR = (index_disp_buf==1'b0) ? i_disp_adr : (NUM_H*r_cnt_row+r_cnt_clmn) ;
assign BUF0_D   = (index_disp_buf==1'b0) ? i_disp_d   : {4{1'b0}} ;

assign BUF1_WEN = (index_disp_buf==1'b1) ? i_disp_wen : {1{1'b1}}  ;
assign BUF1_MEN = (index_disp_buf==1'b1) ? i_disp_men : ~i_sync_de ;
assign BUF1_ADR = (index_disp_buf==1'b1) ? i_disp_adr : (NUM_H*r_cnt_row+r_cnt_clmn) ;
assign BUF1_D   = (index_disp_buf==1'b1) ? i_disp_d   : {4{1'b0}} ;

assign BUF_Q = (index_disp_buf==1'b0) ? BUF1_Q : BUF0_Q ;


srf64x4 BUF0 (
.clk	(disp_clk	),//i
.wen	(BUF0_WEN	),//i
.men	(BUF0_MEN	),//i
.adr	(BUF0_ADR	),//i[ 6-1: 0]	
.d  	(BUF0_D  	),//i[ 4-1: 0]	
.q  	(BUF0_Q  	) //o[ 4-1: 0]	
);


srf64x4 BUF1 (
.clk	(disp_clk	),//i
.wen	(BUF1_WEN	),//i
.men	(BUF1_MEN	),//i
.adr	(BUF1_ADR	),//i[ 6-1: 0]	
.d  	(BUF1_D  	),//i[ 4-1: 0]	
.q  	(BUF1_Q  	) //o[ 4-1: 0]	
);

`endif// `ifdef MODE_FF

// OUTPUT
always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		o_sync_vs	<= 1'b0;
		o_sync_hs	<= 1'b0;
		o_sync_va	<= 1'b0;
		o_sync_ha	<= 1'b0;
		o_sync_de	<= 1'b0;
		o_red    	<= 8'b0;
		o_grn		<= 8'b0;
		o_blu		<= 8'b0;
	end else begin
		o_sync_vs	<= i_sync_vs;
		o_sync_hs	<= i_sync_hs;
		o_sync_va	<= i_sync_va;
		o_sync_ha	<= i_sync_ha;
		o_sync_de	<= i_sync_de;
		o_red    	<= w_red    ;
		o_grn		<= w_grn	;
		o_blu		<= w_blu	;
	end
end

disp_digit_seg #(
.MAX_H     	(MAX_H			),
.MAX_V     	(MAX_V			),
.BOUNDARY	(BOUNDARY		),
.THICKNESS	(THICKNESS		)
) A_SEG (
.i_digit	(seg_i_digit	),//i[ 4-1: 0]
.i_red		(seg_i_red		),//i[ 8-1: 0]
.i_grn		(seg_i_grn		),//i[ 8-1: 0]
.i_blu		(seg_i_blu		),//i[ 8-1: 0]
.cnt_h		(seg_cnt_h		),//i[ 7-1: 0]
.cnt_v		(seg_cnt_v		),//i[ 7-1: 0]
.o_red		(seg_o_red		),//o[ 8-1: 0]
.o_grn		(seg_o_grn		),//o[ 8-1: 0]
.o_blu		(seg_o_blu		),//o[ 8-1: 0]
.o_area		(seg_o_area		) //o
);

endmodule
