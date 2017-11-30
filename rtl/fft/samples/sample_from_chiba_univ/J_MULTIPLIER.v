module J_MULTIPLIER (
    input		[32-1: 0]	A,
	output		[32-1: 0]	Y 
);
		    
wire signed [15:0] AR;
wire signed [15:0] AI;
wire signed [15:0] YR;
wire signed [15:0] YI;
						    
assign {AR, AI} = A;        // j×(AR+j×AI) = -AI+j×AR
assign Y = {-AI, AR};

endmodule
