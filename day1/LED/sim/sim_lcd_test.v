module sim_lcd_test;
   reg        CLK;
   reg        RST;

   wire       update;
   wire       lcd_row; 
   wire [3:0] lcd_col;
   wire [7:0] lcd_char;
   wire       lcd_we;

   reg        lcd_busy;
   reg        start;
   
   
   lcd_test inst
     (
      .CLK(CLK),
      .RST(RST),

      .update(update),
      .lcd_row(lcd_row), 
      .lcd_col(lcd_col),
      .lcd_char(lcd_char),
      .lcd_we(lcd_we),

      .lcd_busy(lcd_busy),
      .start(start)
      );

   initial begin
      CLK <= 1'b0;
      RST <= 1'b1;
      start <= 1'b0;
      lcd_busy <= 1'b1;
      
      #11;
      RST <= 1'b0;
      #11;
      RST <= 1'b1;

      #100;
      lcd_busy <= 1'b0;
      #100;
      start <= 1'b1;
      #10;
      start <= 1'b0;
      
      #1000;
      $finish;
      
   end

   always #5 CLK <= ~CLK;

endmodule
   
