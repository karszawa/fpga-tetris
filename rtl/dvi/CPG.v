`timescale 1ns/1ps

module CPG (
	input					Clock, 
	input					Reset,

	input					VideoReady,
	output					VideoValid,
	output	[23:0]			Video 
);

reg		[32-1: 0]		cnt_idle;
always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		cnt_idle <= {32{1'b0}};
	end else if (~VideoValid) begin
		cnt_idle <= cnt_idle + 1'b1;
	end
end

assign VideoValid = (cnt_idle>=32'd5000);

reg		[ 8-1: 0]		cnt_color_r;
reg		[ 8-1: 0]		cnt_color_g;
reg		[ 8-1: 0]		cnt_color_b;
reg		[13-1: 0]		cnt_color;
reg		[13-1: 0]		cnt_line;
reg		[ 3-1: 0]		cnt_frame;
always @ (posedge Clock or negedge Reset) begin
	if (~Reset) begin
		cnt_color   <= {13{1'b0}};
		cnt_line		<= {13{1'b0}};
		cnt_frame	<= { 2{1'b0}};
		cnt_color_r <= {8{1'b1}};
		cnt_color_g <= {8{1'b0}};
		cnt_color_b <= {8{1'b0}};
	end else if (VideoReady&VideoValid) begin
		if (cnt_color == 1024-1) begin
			if (cnt_line == 768-1) begin
				cnt_line    <= 0;
				cnt_frame  <= cnt_frame+1;
			end else begin
				cnt_line    <= cnt_line+1;
			end
			if ((cnt_line == 768-1)&(cnt_frame==2'b11)) begin
				cnt_color   <= 0;
	 			cnt_color_r <= cnt_color_r - 8'h4;
				cnt_color_g <= cnt_color_g + 8'h4;
				cnt_color_b <= cnt_color_b + 8'h4;
			end else begin
				cnt_color   <= 0;
	 			cnt_color_r <= cnt_color_r - 8'h2;
				cnt_color_g <= cnt_color_g + 8'h2;
				cnt_color_b <= cnt_color_b + 8'h2;
			end
		end else begin
			cnt_color   <= cnt_color   + 1'h1;
			cnt_color_r <= cnt_color_r - 8'h1;
			cnt_color_g <= cnt_color_g + 8'h1;
			cnt_color_b <= cnt_color_b + 8'h1;
		end
	end
end 

assign Video = {cnt_color_r,cnt_color_g,cnt_color_b};

endmodule
