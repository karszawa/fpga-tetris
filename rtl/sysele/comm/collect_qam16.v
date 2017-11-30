
module collect_qam16
  (
   input             CLK,
   input             RST,

   input             valid_i,
   input [3:0]       data_i,

   output reg        valid_o,
   output reg [31:0] data_o
   );

   localparam counter_top = 3'd7;
   reg [2:0]          counter;

   always @(posedge CLK) begin
       if (valid_i)
         data_o <= {data_i, data_o[31:4]};
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 3'd0;
     end else begin
         if (valid_i)
           counter <= counter + 3'd1;
     end

   always @(posedge CLK) begin
       if (counter == counter_top)
         valid_o <= 1'b1;
       else
         valid_o <= 1'b0;
   end

    
endmodule
