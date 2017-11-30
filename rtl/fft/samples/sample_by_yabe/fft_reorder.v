
module fft_reorder
  #(parameter width = 8,
    parameter points = 64,
    parameter logpoints = 6
    )
  (
   input              CLK,
   input              RST,

   input              ce,

   input              valid_i,
   input [width-1:0]  ar,
   input [width-1:0]  ai,
   input [width-1:0]  br,
   input [width-1:0]  bi,

   output reg         valid_o,
   output [width-1:0] xr,
   output [width-1:0] xi,
   output [width-1:0] yr,
   output [width-1:0] yi
   );

    wire [2*width-1:0] di_a = {ar, ai};
    wire [2*width-1:0] di_b = {br, bi};
    wire [2*width-1:0] do_a, do_b;

    assign {xr, xi} = do_a;
    assign {yr, yi} = do_b;

    reg [5:0]          addr_a, addr_b;
    wire [5:0]         addr_a_rev, addr_b_rev;
    wire [5:0]         addr_a_rev_p1, addr_b_rev_p1;        
    wire [5:0]         addr_a_rev_p1_rev, addr_b_rev_p1_rev;

    localparam s_input  = 1'b0;
    localparam s_output = 1'b1;
    reg                state;
    reg [4:0]          counter;
    wire               we;

    assign we = state == s_input;

    dpram
      #(.width(2*width))
    ram_inst
      (.clk_a(CLK),
       .clk_b(CLK),

       .en_a(1'b1),
       .we_a(we),
       .addr_a(addr_a),
       .di_a(di_a),
       .do_a(do_a),

       .en_b(1'b1),
       .we_b(we),
       .addr_b(addr_b),
       .di_b(di_b),
       .do_b(do_b));

    assign addr_a_rev_p1 = addr_a_rev + 2;
    assign addr_b_rev_p1 = addr_b_rev + 2;

    genvar             g;
    generate
        for (g = 0; g < 6; g = g + 1) begin : GENERATE_REV 
            assign addr_a_rev[g] = addr_a[5-g];
            assign addr_b_rev[g] = addr_b[5-g];
            assign addr_a_rev_p1_rev[g] = addr_a_rev_p1[5-g];
            assign addr_b_rev_p1_rev[g] = addr_b_rev_p1[5-g];
        end
    endgenerate

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          state <= s_input;
      end else begin
          case (state)
          s_input:
            if (valid_i && counter == 31)
              state <= s_output;

          s_output:
            if (counter == 31)
              state <= s_input;
          endcase
      end // else: !if(!RST)

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          addr_a <= 6'd0;
          addr_b <= 6'd32;
      end else begin
          case (state)
          s_input:
            if (valid_i) begin
                if (counter == 31) begin
                    addr_a <= 6'd0;
                    addr_b <= 6'd1;
                end
                else begin
                    addr_a <= addr_a_rev_p1_rev;
                    addr_b <= addr_b_rev_p1_rev;
                end
            end

          s_output:
            if (counter == 31) begin
                addr_a <= 6'd0;
                addr_b <= 6'd32;
            end
            else begin
                addr_a <= addr_a + 6'd2;
                addr_b <= addr_b + 6'd2;
            end
          endcase
      end


    always @(posedge CLK or negedge RST)
      if (!RST) begin
          counter <= 0;
      end else begin
          case (state)
          s_input:
            if (valid_i)
              counter <= counter + 1;

          s_output:
            counter <= counter + 1;
          endcase
      end // else: !if(!RST)

    always @(posedge CLK or negedge RST)
      if (!RST) begin
          valid_o <= 1'b0;
      end else begin
          valid_o <= state == s_output;
      end
endmodule
