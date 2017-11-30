module FFT16(
		        A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15,
				        Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8, Y9, Y10, Y11, Y12, Y13, Y14, Y15, CLK);
input [31:0] A0;
input [31:0] A1;
input [31:0] A2;
input [31:0] A3;
input [31:0] A4;
input [31:0] A5;
input [31:0] A6;
input [31:0] A7;
input [31:0] A8;
input [31:0] A9;
input [31:0] A10;
input [31:0] A11;
input [31:0] A12;
input [31:0] A13;
input [31:0] A14;
input [31:0] A15;
output [31:0] Y0;
output [31:0] Y1;
output [31:0] Y2;
output [31:0] Y3;
output [31:0] Y4;
output [31:0] Y5;
output [31:0] Y6;
output [31:0] Y7;
output [31:0] Y8;
output [31:0] Y9;
output [31:0] Y10;
output [31:0] Y11;
output [31:0] Y12;
output [31:0] Y13;
output [31:0] Y14;
output [31:0] Y15;
input CLK;

wire [31:0] B0;    // C0～C15 はフリップフロップの入力
wire [31:0] B1;
wire [31:0] B2;
wire [31:0] B3;
wire [31:0] B4;
wire [31:0] B5;
wire [31:0] B6;
wire [31:0] B7;
wire [31:0] B8;
wire [31:0] B9;
wire [31:0] B10;
wire [31:0] B11;
wire [31:0] B12;
wire [31:0] B13;
wire [31:0] B14;
wire [31:0] B15;

wire [31:0] C0;    // C0～C15 はフリップフロップの出力
wire [31:0] C1;
wire [31:0] C2;
wire [31:0] C3;
wire [31:0] C4;
wire [31:0] C5;
wire [31:0] C6;
wire [31:0] C7;
wire [31:0] C8;
wire [31:0] C9;
wire [31:0] C10;
wire [31:0] C11;
wire [31:0] C12;
wire [31:0] C13;
wire [31:0] C14;
wire [31:0] C15;

RADIX4 U1 ( .A0(A0), .A1(A4), .A2( A8), .A3(A12), .W1K(32'h40000000), .W2K(32'h40000000), .W3K(32'h40000000), .Y0(B0), .Y1(B4), .Y2( B8), .Y3(B12) );
RADIX4 U2 ( .A0(A1), .A1(A5), .A2( A9), .A3(A13), .W1K(32'h3B21E782), .W2K(32'h2D41D2BF), .W3K(32'h187EC4DF), .Y0(B1), .Y1(B5), .Y2( B9), .Y3(B13) );
RADIX4 U3 ( .A0(A2), .A1(A6), .A2(A10), .A3(A14), .W1K(32'h2D41D2BF), .W2K(32'h0000C000), .W3K(32'hD2BFD2BF), .Y0(B2), .Y1(B6), .Y2(B10), .Y3(B14) );
RADIX4 U4 ( .A0(A3), .A1(A7), .A2(A11), .A3(A15), .W1K(32'h187EC4DF), .W2K(32'hD2BFD2BF), .W3K(32'hC4DF187E), .Y0(B3), .Y1(B7), .Y2(B11), .Y3(B15) );

RADIX4 U5 ( .A0( C0), .A1( C1), .A2( C2), .A3( C3), .W1K(32'h40000000), .W2K(32'h40000000), .W3K(32'h40000000), .Y0(Y0), .Y1( Y8), .Y2(Y4), .Y3(Y12) );
RADIX4 U6 ( .A0( C4), .A1( C5), .A2( C6), .A3( C7), .W1K(32'h40000000), .W2K(32'h40000000), .W3K(32'h40000000), .Y0(Y2), .Y1(Y10), .Y2(Y6), .Y3(Y14) );
RADIX4 U7 ( .A0( C8), .A1( C9), .A2(C10), .A3(C11), .W1K(32'h40000000), .W2K(32'h40000000), .W3K(32'h40000000), .Y0(Y1), .Y1( Y9), .Y2(Y5), .Y3(Y13) );
RADIX4 U8 ( .A0(C12), .A1(C13), .A2(C14), .A3(C15), .W1K(32'h40000000), .W2K(32'h40000000), .W3K(32'h40000000), .Y0(Y3), .Y1(Y11), .Y2(Y7), .Y3(Y15) );

FF32 U9  (.D(B0),  .Q(C0),  .CLK(CLK));
FF32 U10 (.D(B1),  .Q(C1),  .CLK(CLK));
FF32 U11 (.D(B2),  .Q(C2),  .CLK(CLK));
FF32 U12 (.D(B3),  .Q(C3),  .CLK(CLK));
FF32 U13 (.D(B4),  .Q(C4),  .CLK(CLK));
FF32 U14 (.D(B5),  .Q(C5),  .CLK(CLK));
FF32 U15 (.D(B6),  .Q(C6),  .CLK(CLK));
FF32 U16 (.D(B7),  .Q(C7),  .CLK(CLK));
FF32 U17 (.D(B8),  .Q(C8),  .CLK(CLK));
FF32 U18 (.D(B9),  .Q(C9),  .CLK(CLK));
FF32 U19 (.D(B10), .Q(C10), .CLK(CLK));
FF32 U20 (.D(B11), .Q(C11), .CLK(CLK));
FF32 U21 (.D(B12), .Q(C12), .CLK(CLK));
FF32 U22 (.D(B13), .Q(C13), .CLK(CLK));
FF32 U23 (.D(B14), .Q(C14), .CLK(CLK));
FF32 U24 (.D(B15), .Q(C15), .CLK(CLK));

endmodule
