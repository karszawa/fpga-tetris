
module delay
  #(parameter width = 8,
    parameter depth = 4)
  (
   input              CLK,
   input              RST,

   input              ce,

   input              valid_i,
   input [width-1:0]  a,

   output             valid_o,
   output [width-1:0] x
   );

   reg [width-1:0]    r[0:depth-1];
   genvar             g;
   assign x = r[depth-1];

   reg                vr[0:depth-1];
   assign valid_o = vr[depth-1];
   
   generate
      for (g=1; g<depth; g=g+1) begin : GEN_R
         always @(posedge CLK) begin
            if (ce)
              r[g] <= r[g-1];
         end

         always @(posedge CLK or negedge RST)
           if (!RST) begin
              vr[g] <= 1'b0;
           end else begin
              if (ce)
                vr[g] <= vr[g-1];
           end

      end
   endgenerate

   always @(posedge CLK) begin
      if (ce)
        r[0] <= a;
   end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        vr[0] <= 1'b0;
     end else begin
        if (ce)
          vr[0] <= valid_i;
     end

endmodule
