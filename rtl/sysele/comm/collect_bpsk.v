
module collect_bpsk
  (
   input             CLK,
   input             RST,

   input             valid_i,
   input             data_i,

   output reg        valid_o,
   output reg [31:0] data_o
   );

   localparam counter_top = 5'd31;
   reg [4:0]          counter;
   
   always @(posedge CLK) begin
       if (valid_i)
         data_o <= {data_i, data_o[31:1]};
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 5'd0;
     end else begin
         if (valid_i)
           counter <= counter + 5'd1;
     end

   always @(posedge CLK) begin
       if (counter == counter_top)
         valid_o <= 1'b1;
       else
         valid_o <= 1'b0;
   end

endmodule
