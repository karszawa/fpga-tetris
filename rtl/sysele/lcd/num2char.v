`define LCD_TEST

module num2char
  (
   input        CLK,
   input        RST,

   input        start_update,
   input [31:0] error_rate,

   output [7:0] char,
   output       valid_o
   );

   localparam s_idle = 2'd0;
   localparam s_wait = 2'd1;
   localparam s_char = 2'd2;
   reg [1:0]    state;

   wire [3:0]   bcd[0:9];
   reg [3:0]    bcdreg[0:9];
   wire         en;
   wire         fin;
   localparam counter_top = 5'd31;
   reg [4:0]    counter;

   assign en = state == s_idle && start_update;
   assign valid_o = state == s_char;
`ifndef LCD_TEST
   assign char = bcdreg[9] + "0";
`else//LCD_TEST // ASCII TABLE
   assign char =(counter==5'h00) ? 8'h48 : // H
				(counter==5'h01) ? 8'h45 : // E
				(counter==5'h02) ? 8'h4C : // L
				(counter==5'h03) ? 8'h4C : // L
				(counter==5'h04) ? 8'h4F : // O
				(counter==5'h05) ? 8'h20 : //  
				(counter==5'h06) ? 8'h46 : // F
				(counter==5'h07) ? 8'h50 : // P
				(counter==5'h08) ? 8'h47 : // G
				(counter==5'h09) ? 8'h41 : // A
				(counter==5'h0A) ? 8'h20 : //  
				(counter==5'h0B) ? 8'h57 : // W
				(counter==5'h0C) ? 8'h45 : // E
				(counter==5'h0D) ? 8'h4C : // L
				(counter==5'h0E) ? 8'h43 : // C
				(counter==5'h0F) ? 8'h4F : // O
				(counter==5'h10) ? 8'h4D : // M
				(counter==5'h11) ? 8'h45 : // E
				(counter==5'h12) ? 8'h20 : //  
				(counter==5'h13) ? 8'h54 : // T
				(counter==5'h14) ? 8'h4F : // O
				(counter==5'h15) ? 8'h20 : //  
				(counter==5'h16) ? 8'h49 : // I
				(counter==5'h17) ? 8'h4B : // K
				(counter==5'h18) ? 8'h45 : // E
				(counter==5'h19) ? 8'h44 : // D
				(counter==5'h1A) ? 8'h41 : // A
				(counter==5'h1B) ? 8'h20 : //  
				(counter==5'h1C) ? 8'h4C : // L
				(counter==5'h1D) ? 8'h41 : // A
				(counter==5'h1E) ? 8'h42 : // B
			/*	(counter==5'h1F)?*/8'h21 ; // !
`endif

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
        case (state)
          s_idle:
            if (start_update)
              state <= s_wait;

          s_wait:
            if (fin)
              state <= s_char;

          s_char:
            if (counter == counter_top)
              state <= s_idle;
          
          default: ;
        endcase
     end // else: !if(!RST)
   generate
      genvar    g;

      for (g=0; g<=9; g=g+1) begin : GENERATE_BCD
         always @(posedge CLK) begin
            if (fin)
              bcdreg[g] <= bcd[g];
            else
              if (g == 0)
                bcdreg[g] <= 4'd0;
              else
                bcdreg[g] <= bcdreg[g-1];
         end
      end
   endgenerate

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 4'd0;
     end else begin
        case (state)
          s_char: 
            counter <= counter + 4'd1;
          
          default: 
            counter <= 4'd0;
        endcase
     end

   bin2bcd32 bin2bcd_inst
     (
      .CLK(CLK),
      .RST(RST),

      .en(en),
      .bin(error_rate),

      .bcd0(bcd[0]),
      .bcd1(bcd[1]),
      .bcd2(bcd[2]),
      .bcd3(bcd[3]),
      .bcd4(bcd[4]),
      .bcd5(bcd[5]),
      .bcd6(bcd[6]),
      .bcd7(bcd[7]),
      .bcd8(bcd[8]),
      .bcd9(bcd[9]),

      .busy(busy),
      .fin(fin)
      );
   
endmodule
