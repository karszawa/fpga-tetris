
module sim_lcd;

   reg       CLK;
   reg       RST;

   wire [3:0] LCD_DATA;
   reg [3:0]  lcddata;

   wire  RS;
   wire  RW;
   wire  EN;

   reg       row;
   reg [3:0] col;
   reg [7:0] char;
   reg       we;

   reg       update;

  lcd inst
    (
     .CLK(CLK),
     .RST(RST),

     .LCD_DATA(LCD_DATA),
     .RS(RS),
     .RW(RW),
     .EN(EN),

     .row(row),
     .col(col),
     .char(char),
     .we(we),

     .busy(busy),

     .update(update)
     );

   assign LCD_DATA = RW ? lcddata : 8'hzz;

    initial begin
       CLK <= 1'b0;
       RST <= 1'b1;
       lcddata <= 4'b0000;
       update <= 1'b0;

       #11;
       RST <= 1'b0;
       #10;
       RST <= 1'b1;

       while (busy)
         #100;

       #10;

       update <= 1'b1;

       #4;

       update <= 1'b0;

       while (busy)
         #100;

       #100;
       
       $finish;
    end

   always #2 CLK <= ~CLK;
   

endmodule // sim_lcd

