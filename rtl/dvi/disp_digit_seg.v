`timescale 1ns/1ps

module disp_digit_seg #(
	parameter	MAX_H     	= 7'd64 	,
	parameter	MAX_V     	= 7'd96 	,
	parameter	BOUNDARY	= 7'd5		,
	parameter	THICKNESS	= 7'd5
)(
	input		[ 4-1: 0]	i_digit		,// 0 ~ F

	input		[ 8-1: 0]	i_red		,
	input		[ 8-1: 0]	i_grn		,
	input		[ 8-1: 0]	i_blu		,

	input		[ 7-1: 0]	cnt_h		,// cnt_h < 1056
	input		[ 7-1: 0]	cnt_v		,// cnt_v < 628

	output		[ 8-1: 0]	o_red		,
	output		[ 8-1: 0]	o_grn		,
	output		[ 8-1: 0]	o_blu		,

	output					o_area		
);

parameter HEIGHT = (MAX_V - 2*BOUNDARY - 3*THICKNESS)/2;

reg		[ 7-1: 0]	w_7segment	;

reg		[ 7-1: 0]	w_7seg_area	;

assign o_area = !w_7seg_area;
assign o_red = (o_area) ? i_red : 8'h0 ;
assign o_grn = (o_area) ? i_grn : 8'h0 ;
assign o_blu = (o_area) ? i_blu : 8'h0 ;

// w_7segment[0] /*{{{*/
always @ (*) begin
	if (w_7segment[0]) begin
		if ((cnt_v >=BOUNDARY)&(cnt_v < (BOUNDARY+THICKNESS) )) begin
			if ((cnt_h >=(BOUNDARY+THICKNESS))&(cnt_h < (MAX_H-BOUNDARY-THICKNESS))) begin
				w_7seg_area[0]	<= 1'b1;
			end else begin
				w_7seg_area[0]	<= 1'b0;
			end
		end else begin
			w_7seg_area[0]	<= 1'b0;
		end
	end else begin
		w_7seg_area[0]	<= 1'b0;
	end
end
// w_7segment[0] /*}}}*/
// w_7segment[1] /*{{{*/
always @ (*) begin
	if (w_7segment[1]) begin
		if ((cnt_v >=(BOUNDARY+THICKNESS))&(cnt_v < (BOUNDARY+THICKNESS+HEIGHT) )) begin
			if ( ( cnt_h >= BOUNDARY ) & ( cnt_h < (BOUNDARY+THICKNESS) ) ) begin
				w_7seg_area[1]	<= 1'b1;
			end else begin
				w_7seg_area[1]	<= 1'b0;
			end
		end else begin
			w_7seg_area[1]	<= 1'b0;
		end
	end else begin
		w_7seg_area[1]	<= 1'b0;
	end
end
// w_7segment[1] /*}}}*/
// w_7segment[2] /*{{{*/
always @ (*) begin
	if (w_7segment[2]) begin
		if ((cnt_v >=(BOUNDARY+THICKNESS))&(cnt_v < (BOUNDARY+THICKNESS+HEIGHT) )) begin
			if ((cnt_h >=(MAX_H-BOUNDARY-THICKNESS))&(cnt_h < (MAX_H-BOUNDARY))) begin
				w_7seg_area[2]	<= 1'b1;
			end else begin
				w_7seg_area[2]	<= 1'b0;
			end
		end else begin
			w_7seg_area[2]	<= 1'b0;
		end
	end else begin
		w_7seg_area[2]	<= 1'b0;
	end
end
// w_7segment[2] /*}}}*/
// w_7segment[3] /*{{{*/
always @ (*) begin
	if (w_7segment[3]) begin
		if ((cnt_v >=(BOUNDARY+THICKNESS+HEIGHT))&(cnt_v < (BOUNDARY+THICKNESS+HEIGHT+THICKNESS) )) begin
			if ((cnt_h >=(BOUNDARY+THICKNESS))&(cnt_h < (MAX_H-BOUNDARY-THICKNESS))) begin
				w_7seg_area[3]	<= 1'b1;
			end else begin
				w_7seg_area[3]	<= 1'b0;
			end
		end else begin
			w_7seg_area[3]	<= 1'b0;
		end
	end else begin
		w_7seg_area[3]	<= 1'b0;
	end
end
// w_7segment[3] /*}}}*/
// w_7segment[4] /*{{{*/
always @ (*) begin
	if (w_7segment[4]) begin
		if ((cnt_v >=(BOUNDARY+THICKNESS+HEIGHT+THICKNESS))&(cnt_v < (BOUNDARY+THICKNESS+HEIGHT+THICKNESS+HEIGHT) )) begin
			if ( ( cnt_h >= BOUNDARY ) & ( cnt_h < (BOUNDARY+THICKNESS) ) ) begin
				w_7seg_area[4]	<= 1'b1;
			end else begin
				w_7seg_area[4]	<= 1'b0;
			end
		end else begin
			w_7seg_area[4]	<= 1'b0;
		end
	end else begin
		w_7seg_area[4]	<= 1'b0;
	end
end
// w_7segment[4] /*}}}*/
// w_7segment[5] /*{{{*/
always @ (*) begin
	if (w_7segment[5]) begin
		if ((cnt_v >=(BOUNDARY+THICKNESS+HEIGHT+THICKNESS))&(cnt_v < (BOUNDARY+THICKNESS+HEIGHT+THICKNESS+HEIGHT) )) begin
			if ((cnt_h >=(MAX_H-BOUNDARY-THICKNESS))&(cnt_h < (MAX_H-BOUNDARY))) begin
				w_7seg_area[5]	<= 1'b1;
			end else begin
				w_7seg_area[5]	<= 1'b0;
			end
		end else begin
			w_7seg_area[5]	<= 1'b0;
		end
	end else begin
		w_7seg_area[5]	<= 1'b0;
	end
end
// w_7segment[5] /*}}}*/
// w_7segment[6] /*{{{*/
always @ (*) begin
	if (w_7segment[6]) begin
		if ((cnt_v >=(BOUNDARY+THICKNESS+HEIGHT+THICKNESS+HEIGHT))&(cnt_v < (BOUNDARY+THICKNESS+HEIGHT+THICKNESS+HEIGHT+THICKNESS) )) begin
			if ((cnt_h >=(BOUNDARY+THICKNESS))&(cnt_h < (MAX_H-BOUNDARY-THICKNESS))) begin
				w_7seg_area[6]	<= 1'b1;
			end else begin
				w_7seg_area[6]	<= 1'b0;
			end
		end else begin
			w_7seg_area[6]	<= 1'b0;
		end
	end else begin
		w_7seg_area[6]	<= 1'b0;
	end
end
// w_7segment[6] /*}}}*/

always @ (*) begin
	case(i_digit)
		4'h0:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b0;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'h1:begin/*{{{*/
			w_7segment[0] = 1'b0;
			w_7segment[1] = 1'b0;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b0;
			w_7segment[4] = 1'b0;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b0;
		end/*}}}*/
		4'h2:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b0;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b0;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'h3:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b0;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b0;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'h4:begin/*{{{*/
			w_7segment[0] = 1'b0;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b0;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b0;
		end/*}}}*/
		4'h5:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b0;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b0;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'h6:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b0;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'h7:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b0;
			w_7segment[4] = 1'b0;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b0;
		end/*}}}*/
		4'h8:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'h9:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b0;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'hA:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b0;
		end/*}}}*/
		4'hB:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'hC:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b0;
			w_7segment[3] = 1'b0;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b0;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'hD:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b1;
			w_7segment[3] = 1'b0;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b1;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'hE:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b0;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b0;
			w_7segment[6] = 1'b1;
		end/*}}}*/
		4'hF:begin/*{{{*/
			w_7segment[0] = 1'b1;
			w_7segment[1] = 1'b1;
			w_7segment[2] = 1'b0;
			w_7segment[3] = 1'b1;
			w_7segment[4] = 1'b1;
			w_7segment[5] = 1'b0;
			w_7segment[6] = 1'b0;
		end/*}}}*/
		default:begin/*{{{*/
			w_7segment[0] = 1'b0;
			w_7segment[1] = 1'b0;
			w_7segment[2] = 1'b0;
			w_7segment[3] = 1'b0;
			w_7segment[4] = 1'b0;
			w_7segment[5] = 1'b0;
			w_7segment[6] = 1'b0;
		end/*}}}*/
	endcase
end

endmodule

