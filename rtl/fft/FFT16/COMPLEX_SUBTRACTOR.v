module COMPLEX_SUBTRACTOR (
    input		[32-1: 0]		A,
	input		[32-1: 0]		B,
	output		[32-1: 0]		Y 
);
			    
wire signed [15:0] AR, AI, BR, BI, YR, YI;

assign {AR, AI} = A;
assign {BR, BI} = B;

assign YR = AR - BR;
assign YI = AI - BI;

assign Y = {YR, YI};

endmodule
