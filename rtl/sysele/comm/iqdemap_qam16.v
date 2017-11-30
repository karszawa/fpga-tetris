
module iqdemap_qam16
  (
   input               CLK,
   input               RST,

   input               valid_i,
   input signed [10:0] ar,
   input signed [10:0] ai,

   output              valid_o,
   output [31:0]       data_o,

   output              valid_raw,
   output [3:0]        raw
   );

    wire [3:0]         data_inv;
    wire               valid_inv;              


    qam16_inv qam16_inv
      (
       .CLK(CLK),
       .RST(RST),

       .valid_i(valid_i),
       .ar(ar),
       .ai(ai),

       .valid_x(valid_inv),
       .x(data_inv)
       );

    assign raw = data_inv;
    assign valid_raw = valid_inv;

    collect_qam16 collect
      (
       .CLK(CLK),
       .RST(RST),

       .valid_i(valid_inv),
       .data_i(data_inv),

       .valid_o(valid_o),
       .data_o(data_o)
       );
    
endmodule

// Local Variables:
// compile-command: "cd ../../verilator/comm/iqdemap_qam16; ./runtest.sh"
// End:
