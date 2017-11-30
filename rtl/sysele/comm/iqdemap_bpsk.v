
module iqdemap_bpsk 
  (
   input               CLK,
   input               RST,

   input               valid_i,
   input signed [10:0] ar,
   input signed [10:0] ai,

   output              valid_o,
   output [31:0]       data_o,

   output              valid_raw,
   output              raw
   );

    wire               data_inv;
    wire               valid_inv;              

    bpsk_inv bpsk_inv
      (
       .CLK(CLK),
       .RST(RST),

       .valid_i(valid_i),
       .ar(ar),
       .ai(ai),

       .valid_x(valid_inv),
       .x(data_inv)
       );

    assign valid_raw = valid_inv;
    assign raw       = data_inv;

    collect_bpsk collect
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
// compile-command: "cd ../../verilator/comm/iqdemap_bpsk; ./runtest.sh"
// End:
