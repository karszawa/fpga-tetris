
module lcd_ctrl_top #(
parameter number_of_bits = 8,
parameter update_period  = 32'd240_000_000) (
   input        CLK,
   input        RST,

   output       update,
   output       lcd_row, 
   output [3:0] lcd_col,
   output [7:0] lcd_char,
   output       lcd_we,

   input        lcd_busy,

   input        valid_i,
   input [7:0]  recv_data
);

   wire         ber_valid_o;
   wire [31:0]  error_rate;

   reg	[32-1: 0]	cnt_wait;

   wire         start_update;
   wire [7:0]   char;
   wire         n2c_valid_o;

always @ (posedge CLK or negedge RST) begin
	if (~RST) begin
		cnt_wait	<= {32{1'b0}};
	end else if (cnt_wait>=update_period) begin
		cnt_wait	<= {32{1'b0}};
	end else  begin
		cnt_wait	<= cnt_wait + 1'b1;
	end
end
assign start_update = (cnt_wait==update_period);


key2char #(
.update_period		(update_period	)
) A0_KEY2CHAR (
.CLK				(CLK			),
.RST				(RST			),
.valid_i			(valid_i		),//i
.recv_data			(recv_data		),//i[ 8-1: 0]
.char				(char			),
.valid_o			(n2c_valid_o	)
);

lcd_control A1_LCD_CTRL (
.CLK					(CLK			),
.RST					(RST			),
.start_update			(start_update	),
.lcd_row				(lcd_row		), 
.lcd_col				(lcd_col		),
.lcd_char				(lcd_char		),
.lcd_we					(lcd_we			),
.lcd_busy				(lcd_busy		),
.valid_i				(n2c_valid_o	),
.update					(update			),
.char					(char			)
);

endmodule // lcd_test

   
