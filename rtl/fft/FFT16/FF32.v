module FF32(D, Q, CLK);
input [31:0] D;
input CLK;
output [31:0] Q;

reg [31:0] Q;

always@(posedge CLK) begin
	Q <= D;
end

endmodule
