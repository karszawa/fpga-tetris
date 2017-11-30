module FFT16_SEQUENTIAL(A, Y, CLK, START, DONE, RESET);
input [31:0] A;
output [31:0] Y;
input CLK;
input START;
output DONE;
input RESET;
						    
reg [31:0] A0;
reg [31:0] A1;
reg [31:0] A2;
reg [31:0] A3;
reg [31:0] A4;
reg [31:0] A5;
reg [31:0] A6;
reg [31:0] A7;
reg [31:0] A8;
reg [31:0] A9;
reg [31:0] A10;
reg [31:0] A11;
reg [31:0] A12;
reg [31:0] A13;
reg [31:0] A14;
reg [31:0] A15;

wire [31:0] Y0;
wire [31:0] Y1;
wire [31:0] Y2;
wire [31:0] Y3;
wire [31:0] Y4;
wire [31:0] Y5;
wire [31:0] Y6;
wire [31:0] Y7;
wire [31:0] Y8;
wire [31:0] Y9;
wire [31:0] Y10;
wire [31:0] Y11;
wire [31:0] Y12;
wire [31:0] Y13;
wire [31:0] Y14;
wire [31:0] Y15;

reg [31:0] YR0;
reg [31:0] YR1;
reg [31:0] YR2;
reg [31:0] YR3;
reg [31:0] YR4;
reg [31:0] YR5;
reg [31:0] YR6;
reg [31:0] YR7;
reg [31:0] YR8;
reg [31:0] YR9;
reg [31:0] YR10;
reg [31:0] YR11;
reg [31:0] YR12;
reg [31:0] YR13;
reg [31:0] YR14;
reg [31:0] YR15;

wire SEL;

always@(posedge CLK) begin
	A0 <= A1;    // シリアルパラレル変換用シフトレジスタ
	A1 <= A2;
	A2 <= A3;
	A3 <= A4;
	A4 <= A5;
	A5 <= A6;
	A6 <= A7;
	A7 <= A8;
	A8 <= A9;
	A9 <= A10;
	A10 <= A11;
	A11 <= A12;
	A12 <= A13;
	A13 <= A14;
	A14 <= A15;
	A15 <= A;
	
	YR0 <= SEL ? Y0 : YR1;    // パラレルシリアル変換用シフトレジスタ
	YR1 <= SEL ? Y1 : YR2;    // SEL が 1 のとき、
	YR2 <= SEL ? Y2 : YR3;    //    FFT16の出力値がシフトレジスタにロードされる。
	YR3 <= SEL ? Y3 : YR4;
	YR4 <= SEL ? Y4 : YR5;
	YR5 <= SEL ? Y5 : YR6;
	YR6 <= SEL ? Y6 : YR7;
	YR7 <= SEL ? Y7 : YR8;
	YR8 <= SEL ? Y8 : YR9;
	YR9 <= SEL ? Y9 : YR10;
	YR10 <= SEL ? Y10 : YR11;
	YR11 <= SEL ? Y11 : YR12;
	YR12 <= SEL ? Y12 : YR13;
	YR13 <= SEL ? Y13 : YR14;
	YR14 <= SEL ? Y14 : YR15;
	YR15 <= Y15;
end
																																																																																																																									    
assign Y = YR0;

FFT16 U1_FFT16 ( 
.A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), .A5(A5), .A6(A6), .A7(A7), .A8(A8), .A9(A9), .A10(A10), .A11(A11), .A12(A12), .A13(A13), .A14(A14), .A15(A15),
.Y0(Y0), .Y1(Y1), .Y2(Y2), .Y3(Y3), .Y4(Y4), .Y5(Y5), .Y6(Y6), .Y7(Y7), .Y8(Y8), .Y9(Y9), .Y10(Y10), .Y11(Y11), .Y12(Y12), .Y13(Y13), .Y14(Y14), .Y15(Y15), .CLK(CLK));
    
CONTROLLER U2_CTRL (.START(START), .DONE(DONE), .SEL(SEL), .CLK(CLK), .RESET(RESET));

endmodule
