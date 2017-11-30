module tb_complex_adder ();

wire	[32-1: 0]	A, B, Y;

//	wire signed	[16-1: 0]	AR, AI;
//	wire signed	[16-1: 0]	BR, BI;
//	wire signed	[16-1: 0]	YR, YI;
//	
//	assign AR = -16'd10;
//	assign AI = -16'd1;
//	
//	assign BR = -16'd30;
//	assign BI = -16'd1;
//	
//	assign A = {AR, AI};
//	assign B = {BR, BI};
//	
//	assign YR = Y[32-1:16];
//	assign YI = Y[16-1: 0];
//	
initial begin
	$display ("Y  = %h          \n", Y     );
//		$display ("AR = %d, AI = %d \n", AR, AI);
//		$display ("BR = %d, BI = %d \n", BR, BI);
//		$display ("YR = %d, YI = %d \n", YR, YI);
end

COMPLEX_ADDER A0_UNIT (
//.A		(A		),
//.B		(B		),
.A		(32'd0		),
.B		(32'd0		),
.Y		(Y		) 
);

endmodule
