
module key2char #(
parameter update_period  = 32'd240_000_000) (
   input        CLK,
   input        RST,

   input           valid_i,
   input [ 8-1: 0] recv_data,

   output [7:0] char,
   output       valid_o
   );

   localparam s_idle = 2'd0;
   localparam s_wait = 2'd1;
   localparam s_char = 2'd2;
   reg [1:0]    state;

   reg	[ 8-1: 0]	lcd_mem[31:0];

   reg	[ 5-1: 0]    counter;
   reg	[ 5-1: 0]    w_pointer;

   reg	[32-1: 0]	cnt_wait;

always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
		state	<= s_idle;
	end else if ( (state==s_char) & (&counter) ) begin
		state	<= s_idle;
	end else if ( (state==s_idle) & (cnt_wait>=update_period) ) begin
		state	<= s_char;
	end
end

always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
		cnt_wait	<= {32{1'b0}};
	end else if (state==s_char) begin
		cnt_wait	<= {32{1'b0}};
	end else if ( (state==s_idle) & (cnt_wait>=update_period) ) begin
		cnt_wait	<= {32{1'b0}};
	end else if (state==s_idle) begin
		cnt_wait	<= cnt_wait + 1'b1;
	end
end

always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
		counter	<= {5{1'b0}};
	end else if (state==s_idle) begin
		counter	<= {5{1'b0}};
	end else if ( (state==s_char) & (&counter) ) begin
		counter	<= {5{1'b0}};
	end else if (state==s_char) begin
		counter	<= counter + 1'b1;
	end
end

always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
		w_pointer	<= {5{1'b0}};
	end else if (valid_i) begin
		w_pointer	<= w_pointer + 1'b1;
	end
end
always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
		lcd_mem[5'h00] <= 8'h48 ; // H
		lcd_mem[5'h01] <= 8'h45 ; // E
		lcd_mem[5'h02] <= 8'h4C ; // L
		lcd_mem[5'h03] <= 8'h4C ; // L
		lcd_mem[5'h04] <= 8'h4F ; // O
		lcd_mem[5'h05] <= 8'h20 ; //  
		lcd_mem[5'h06] <= 8'h46 ; // F
		lcd_mem[5'h07] <= 8'h50 ; // P
		lcd_mem[5'h08] <= 8'h47 ; // G
		lcd_mem[5'h09] <= 8'h41 ; // A
		lcd_mem[5'h0A] <= 8'h20 ; //  
		lcd_mem[5'h0B] <= 8'h57 ; // W
		lcd_mem[5'h0C] <= 8'h45 ; // E
		lcd_mem[5'h0D] <= 8'h4C ; // L
		lcd_mem[5'h0E] <= 8'h43 ; // C
		lcd_mem[5'h0F] <= 8'h4F ; // O
		lcd_mem[5'h10] <= 8'h4D ; // M
		lcd_mem[5'h11] <= 8'h45 ; // E
		lcd_mem[5'h12] <= 8'h20 ; //  
		lcd_mem[5'h13] <= 8'h54 ; // T
		lcd_mem[5'h14] <= 8'h4F ; // O
		lcd_mem[5'h15] <= 8'h20 ; //  
		lcd_mem[5'h16] <= 8'h49 ; // I
		lcd_mem[5'h17] <= 8'h4B ; // K
		lcd_mem[5'h18] <= 8'h45 ; // E
		lcd_mem[5'h19] <= 8'h44 ; // D
		lcd_mem[5'h1A] <= 8'h41 ; // A
		lcd_mem[5'h1B] <= 8'h20 ; //  
		lcd_mem[5'h1C] <= 8'h4C ; // L
		lcd_mem[5'h1D] <= 8'h41 ; // A
		lcd_mem[5'h1E] <= 8'h42 ; // B
		lcd_mem[5'h1F] <= 8'h21 ; // !
	end else if (valid_i) begin
		lcd_mem[w_pointer] <= recv_data;
	end
end

   assign valid_o = (state==s_char);

   assign char =(state==s_char) ? lcd_mem[counter] : 8'h20 ;
//	assign char =(counter==5'h00) ? 8'h48 : // H
//				(counter==5'h01) ? 8'h45 : // E
//				(counter==5'h02) ? 8'h4C : // L
//				(counter==5'h03) ? 8'h4C : // L
//				(counter==5'h04) ? 8'h4F : // O
//				(counter==5'h05) ? 8'h20 : //  
//				(counter==5'h06) ? 8'h46 : // F
//				(counter==5'h07) ? 8'h50 : // P
//				(counter==5'h08) ? 8'h47 : // G
//				(counter==5'h09) ? 8'h41 : // A
//				(counter==5'h0A) ? 8'h20 : //  
//				(counter==5'h0B) ? 8'h57 : // W
//				(counter==5'h0C) ? 8'h45 : // E
//				(counter==5'h0D) ? 8'h4C : // L
//				(counter==5'h0E) ? 8'h43 : // C
//				(counter==5'h0F) ? 8'h4F : // O
//				(counter==5'h10) ? 8'h4D : // M
//				(counter==5'h11) ? 8'h45 : // E
//				(counter==5'h12) ? 8'h20 : //  
//				(counter==5'h13) ? 8'h54 : // T
//				(counter==5'h14) ? 8'h4F : // O
//				(counter==5'h15) ? 8'h20 : //  
//				(counter==5'h16) ? 8'h49 : // I
//				(counter==5'h17) ? 8'h4B : // K
//				(counter==5'h18) ? 8'h45 : // E
//				(counter==5'h19) ? 8'h44 : // D
//				(counter==5'h1A) ? 8'h41 : // A
//				(counter==5'h1B) ? 8'h20 : //  
//				(counter==5'h1C) ? 8'h4C : // L
//				(counter==5'h1D) ? 8'h41 : // A
//				(counter==5'h1E) ? 8'h42 : // B
//			/*	(counter==5'h1F)?*/8'h21 ; // !

   
endmodule
