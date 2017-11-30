`timescale 1ns/1ps

module sync_gen #(
	parameter	PARAM_VFP	=    3,
	parameter	PARAM_VS 	=    6, 
	parameter	PARAM_VBP	=   29,
	parameter	PARAM_VA	=  768,
	parameter	PARAM_HFP	=   24, 
	parameter	PARAM_HS 	=  136, 
	parameter	PARAM_HBP	=  144,
	parameter	PARAM_HA	= 1024 
)(
	input					disp_clk			,
	input					rst_disp_n			,

	output	reg				o_sync_vs			,
	output	reg				o_sync_hs			,
	output	reg				o_sync_va			,
	output	reg				o_sync_ha			,
	output	reg				o_sync_de			 
);

parameter PARAM_V_TOTAL = (PARAM_VFP+PARAM_VS+PARAM_VBP+PARAM_VA);
parameter PARAM_H_TOTAL = (PARAM_HFP+PARAM_HS+PARAM_HBP+PARAM_HA);

reg		[11-1: 0]	r_cnt_h;
reg		[10-1: 0]	r_cnt_v;

reg					w_sync_vs;
reg					w_sync_hs;
reg					w_sync_va;
reg					w_sync_ha;

always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		r_cnt_h	<= {11{1'b0}};
	end else if (r_cnt_h>=(PARAM_H_TOTAL-1)) begin
		r_cnt_h	<= {11{1'b0}};
	end else begin
		r_cnt_h	<= r_cnt_h + 1'b1;
	end
end

always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		r_cnt_v	<= {11{1'b0}};
	end else if (r_cnt_h==(PARAM_HFP-1)) begin
		if (r_cnt_v>=(PARAM_V_TOTAL-1)) begin
			r_cnt_v	<= {11{1'b0}};
		end else begin
			r_cnt_v	<= r_cnt_v + 1'b1;
		end
	end
end

// OUTPUT
always @ (posedge disp_clk or negedge rst_disp_n) begin
	if (~rst_disp_n) begin
		o_sync_vs	<= 1'b0;
		o_sync_hs	<= 1'b0;
		o_sync_va	<= 1'b0;
		o_sync_ha	<= 1'b0;
		o_sync_de	<= 1'b0;
	end else begin
		o_sync_vs	<= w_sync_vs;
		o_sync_hs	<= w_sync_hs;
		o_sync_va	<= w_sync_va;
		o_sync_ha	<= w_sync_ha;
		o_sync_de	<= w_sync_va&w_sync_ha;
	end
end

// W_SYNC_VS/VA
always @ (*) begin
	if (r_cnt_v < PARAM_VFP) begin
		w_sync_vs <= 1'b1;
		w_sync_va <= 1'b0;
	end else if (r_cnt_v < (PARAM_VFP+PARAM_VS) ) begin
		w_sync_vs <= 1'b0;
		w_sync_va <= 1'b0;
	end else if (r_cnt_v < (PARAM_VFP+PARAM_VS+PARAM_VBP) ) begin
		w_sync_vs <= 1'b1;
		w_sync_va <= 1'b0;
	end else if (r_cnt_v < (PARAM_VFP+PARAM_VS+PARAM_VBP+PARAM_VA) ) begin
		w_sync_vs <= 1'b1;
		w_sync_va <= 1'b1;
	end else begin
		w_sync_vs <= 1'b0;
		w_sync_va <= 1'b0;
	end
end

// W_SYNC_HS/HA
always @ (*) begin
	if (r_cnt_h < PARAM_HFP) begin
		w_sync_hs <= 1'b1;
		w_sync_ha <= 1'b0;
	end else if (r_cnt_h < (PARAM_HFP+PARAM_HS) ) begin
		w_sync_hs <= 1'b0;
		w_sync_ha <= 1'b0;
	end else if (r_cnt_h < (PARAM_HFP+PARAM_HS+PARAM_HBP) ) begin
		w_sync_hs <= 1'b1;
		w_sync_ha <= 1'b0;
	end else if (r_cnt_h < (PARAM_HFP+PARAM_HS+PARAM_HBP+PARAM_HA) ) begin
		w_sync_hs <= 1'b1;
		w_sync_ha <= 1'b1;
	end else begin
		w_sync_hs <= 1'b0;
		w_sync_ha <= 1'b0;
	end
end


endmodule
