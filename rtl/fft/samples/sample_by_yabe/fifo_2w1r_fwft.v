 
// upper first
module fifo_2w1r_fwft
  #(parameter read_width = 8,
    parameter depth_log2 = 8
    )
  (
   input                       CLK,
   input                       RST,

   input [2*read_width-1:0]    din,
   input                       wr_en,
   output reg                  full,

   output reg [read_width-1:0] dout,
   input                       rd_en,
   output reg                  empty
   );

   localparam depth = (1<<depth_log2);
   reg [read_width-1:0]     memu[0:depth-1];
   reg [read_width-1:0]     meml[0:depth-1];

   localparam ptr_zero = {(depth_log2){1'b0}};
   localparam ptr_one  = {{(depth_log2-1){1'b0}}, 1'b1};
   reg [depth_log2-1:0] wrptr;
   reg [depth_log2-1:0] rdptr;
   reg                  u;

   wire [depth_log2-1:0] wrptr_next = wrptr + ptr_one; 

   reg                  empty_1;

   wire [read_width-1:0]     dout_next;

   wire                 next_empty = wrptr != rdptr;
   
   always @(posedge CLK or negedge RST)
     if (!RST) begin
        empty <= 1'b1;
     end else begin
        if (wrptr != rdptr)
          empty <= 1'b0;
        if (wrptr == rdptr && rd_en && !full)
          empty <= 1'b1;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        full <= 1'b0;
     end else begin
        if (wrptr_next == rdptr && wr_en)
          full <= 1'b1;
        else if (wrptr != rdptr)
          full <= 1'b0;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        wrptr <= ptr_zero;
     end else begin
        if (wr_en && !full)
          wrptr <= wrptr + ptr_one;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        rdptr <= ptr_zero;
     end else begin
        if (rd_en && ~u && !empty)
          rdptr <= rdptr + ptr_one;
     end

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        u <= 1'b0;
     end else begin
        if (rd_en && !empty)
          u <= ~u;
     end

   always @(posedge CLK)
     if (wr_en && !full)
       memu[wrptr] <= din[2*read_width-1:read_width];

   always @(posedge CLK)
     if (wr_en && !full)
       meml[wrptr] <= din[read_width-1:0];

   always @(posedge CLK)
     if (empty)
       dout <= memu[rdptr];
     else if (rd_en) begin
        if (u)
          dout <= memu[rdptr];
        else
          dout <= meml[rdptr];
     end

endmodule
