
`timescale 1ns/1ns

module test_lcd_comm;

   reg CLK;
   reg RST;

   reg start;
   reg [7:0] data_w;
   reg       write;

   wire      busy;
   wire      rs;
   wire      rw;
   wire      e;
   wire [3:0] LCD_DATA;
   reg [3:0]  lcddata;

   lcd_comm 
     #(.clk_mhz(240),
       .clk_mhz_width(8)
       )
   inst
   (
    .CLK(CLK),
    .RST(RST),

    .start(start),
    .data_w(data_w),
    .data_r(),
    .write(write),

    .busy(busy),

    .rs(rs),
    .rw(rw),
    .e(e),
    .LCD_DATA(LCD_DATA)
    );

   assign LCD_DATA = rw ? lcddata : 8'hzz;
   
    initial begin
       CLK <= 1'b0;
       RST <= 1'b1;
       write <= 1'b0;
       start <= 1'b0;
       data_w <= 8'h0;
       lcddata <= 4'b1000;

       #11;
       RST <= 1'b0;
       #11;
       RST <= 1'b1;

       while (busy)
         #100;

       #100;
       start <= 1'b1;
       data_w <= 8'h5a;
       write <= 1'b1;
       #4;
       start <= 1'b0;

       #300000;
       lcddata <= 4'b0000;
       #100000;

       $finish;
    end

   always #2 CLK <= ~CLK;

endmodule // test_lcd_comm

  
