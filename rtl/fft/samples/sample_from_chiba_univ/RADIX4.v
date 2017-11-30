module RADIX4 (
    input		[32-1: 0]	A0,
	input		[32-1: 0]	A1,
	input		[32-1: 0]	A2,
	input		[32-1: 0]	A3,

	input		[32-1: 0]	W1K,
	input		[32-1: 0]	W2K,
	input		[32-1: 0]	W3K,

	output		[32-1: 0]	Y0,
	output		[32-1: 0]	Y1,
	output		[32-1: 0]	Y2,
	output		[32-1: 0]	Y3 
);
	
wire [32-1: 0] B0;
wire [32-1: 0] B1;
wire [32-1: 0] B2;
wire [32-1: 0] B3;
wire [32-1: 0] B3J;
wire [32-1: 0] C0;
wire [32-1: 0] C1;
wire [32-1: 0] C2;
wire [32-1: 0] C3;
																				    
COMPLEX_ADDER U1 (.A(A0), .B(A2), .Y(B0));
COMPLEX_ADDER U2 (.A(A1), .B(A3), .Y(B1));
COMPLEX_SUBTRACTOR U3 (.A(A0), .B(A2), .Y(B2));
COMPLEX_SUBTRACTOR U4 (.A(A1), .B(A3), .Y(B3));

J_MULTIPLIER U5 (.A(B3), .Y(B3J));

COMPLEX_ADDER U6 (.A(B0), .B(B1), .Y(C0));
COMPLEX_SUBTRACTOR U7 (.A(B0), .B(B1), .Y(C1));
COMPLEX_SUBTRACTOR U8 (.A(B2), .B(B3J), .Y(C2));
COMPLEX_ADDER U9 (.A(B2), .B(B3J), .Y(C3));

assign Y0 = C0;
TWIDDLER U10(.A(C1), .W(W2K), .Y(Y1));
TWIDDLER U11(.A(C2), .W(W1K), .Y(Y2));
TWIDDLER U12(.A(C3), .W(W3K), .Y(Y3));

endmodule
