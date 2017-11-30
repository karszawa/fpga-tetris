
module slice_bpsk
  (
   input        CLK,
   input        RST,

   input        valid_i,
   input [31:0] data_i,
   output reg   ack_i,

   output reg   valid_o,
   output reg   data_o
   );

`define SW 2
   localparam s_idle = `SW'b01;
   localparam s_active = `SW'b10;
   reg [`SW-1:0] state;
`undef SW

    reg [31:0]   d;

   localparam counter_top = 5'd31;
   reg [4:0]     counter;

   wire          fin = counter == counter_top && !valid_i;
   wire          next_chunk = counter == counter_top && valid_i;

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        state <= s_idle;
     end else begin
         case (state)
         s_idle: 
           if (valid_i)
             state <= s_active;

         s_active:
           if (fin)
             state <= s_idle;

         default:;
         endcase
     end

   always @(posedge CLK)
     case (state)
     s_idle:
       if (valid_i)
         d <= data_i;

     s_active:
       if (next_chunk)
         d <= data_i;
       else
         d <= {1'b0, d[31:1]};
     
     default: ;
     endcase

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        counter <= 5'd0;
     end else begin
         case (state)
         s_idle:
           counter <= 5'd0;
         
         s_active: 
           counter <= counter + 5'd1;

         default: ;
         endcase
     end // else: !if(!RST)

   always @(posedge CLK)
     data_o <= d[0];

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        valid_o <= 1'b0;
     end else begin
         case (state)
         s_idle: 
           valid_o <= 1'b0;

         s_active:
           valid_o <= 1'b1;
         
         default: ;
         endcase
     end // else: !if(!RST)

   always @(posedge CLK or negedge RST)
     if (!RST) begin
        ack_i <= 1'b0;
     end else begin
         case (state)
         s_idle: 
           if (valid_i)
             ack_i <= 1'b1;
           else
             ack_i <= 1'b0;

         s_active:
           if (next_chunk)
             ack_i <= 1'b1;
           else
             ack_i <= 1'b0;

         default: ;
         endcase
     end
    
endmodule
