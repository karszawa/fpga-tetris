
module collect_qpsk
  (
   input             CLK,
   input             RST,

   input             valid_i,
   input [1:0]       data_i,

   output reg        valid_o,
   output reg [31:0] data_o
   );
    
   localparam counter_top = 4'd15;
   reg [3:0]          counter;

   always @(posedge CLK) begin
       if (valid_i)
         data_o <= {data_i, data_o[31:2]};
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 4'd0;
     end else begin
         if (valid_i)
           counter <= counter + 4'd1;
     end

   always @(posedge CLK) begin
       if (counter == counter_top)
         valid_o <= 1'b1;
       else
         valid_o <= 1'b0;
   end

endmodule
