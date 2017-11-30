
module iqmap_qam16
  (
   input         CLK,
   input         RST,

   input         valid_i,
   input [31:0]  data_i,
   output        ack_i,

   output [10:0] xr,
   output [10:0] xi,
   output        valid_x,

   output        valid_raw,
   output [3:0]  raw
   );
    
    wire [3:0]   data_slice;
    wire         valid_slice;

    slice_qam16
      slice
        (
         .CLK(CLK),
         .RST(RST),

         .valid_i(valid_i),
         .data_i(data_i),
         .ack_i(ack_i),

         .data_o(data_slice),
         .valid_o(valid_slice)
         );

    assign raw = data_slice;
    assign valid_raw = valid_slice;

    qam16 qam16
      (
       .CLK(CLK),
       .RST(RST),

       .valid_i(valid_slice),
       .data_i(data_slice),

       .valid_x(valid_x),
       .xr(xr),
       .xi(xi));

endmodule

// Local Variables:
// compile-command: "cd ../../verilator/comm/iqmap_qam16; ./runtest.sh"
// End:
