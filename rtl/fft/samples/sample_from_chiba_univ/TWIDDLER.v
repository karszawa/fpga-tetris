module TWIDDLER (
	input		[32-1: 0]	A,
	input		[32-1: 0]	W,
	output		[32-1: 0]	Y 
);
			    
wire signed [15:0] AR;
wire signed [15:0] AI;
wire signed [15:0] WR;
wire signed [15:0] WI;
wire signed [31:0] YR;
wire signed [31:0] YI;
	
assign {AR, AI} = A;
assign {WR, WI} = W;

assign YR = AR * WR - AI * WI;
assign YI = AR * WI + AI * WR;

assign Y = {YR[29:14], YI[29:14]}; 
/* 下位14ビットを切り捨て、上位2ビット(オーバフロー分)も捨てる */
endmodule
