`default_nettype none
`timescale 1ns/1ps

module decoder32(in, ena, out);
   input  wire  [4:0]  in;
   input  wire         ena;
   output logic [31:0] out;

   // Because it has to be structural...
   always_comb begin
      out[0]  = ena & ~in[4] & ~in[3] & ~in[2] & ~in[1] & ~in[0];
      out[1]  = ena & ~in[4] & ~in[3] & ~in[2] & ~in[1] &  in[0];
      out[2]  = ena & ~in[4] & ~in[3] & ~in[2] &  in[1] & ~in[0];
      out[3]  = ena & ~in[4] & ~in[3] & ~in[2] &  in[1] &  in[0];
      out[4]  = ena & ~in[4] & ~in[3] &  in[2] & ~in[1] & ~in[0];
      out[5]  = ena & ~in[4] & ~in[3] &  in[2] & ~in[1] &  in[0];
      out[6]  = ena & ~in[4] & ~in[3] &  in[2] &  in[1] & ~in[0];
      out[7]  = ena & ~in[4] & ~in[3] &  in[2] &  in[1] &  in[0];
      out[8]  = ena & ~in[4] &  in[3] & ~in[2] & ~in[1] & ~in[0];
      out[9]  = ena & ~in[4] &  in[3] & ~in[2] & ~in[1] &  in[0];
      out[10] = ena & ~in[4] &  in[3] & ~in[2] &  in[1] & ~in[0];
      out[11] = ena & ~in[4] &  in[3] & ~in[2] &  in[1] &  in[0];
      out[12] = ena & ~in[4] &  in[3] &  in[2] & ~in[1] & ~in[0];
      out[13] = ena & ~in[4] &  in[3] &  in[2] & ~in[1] &  in[0];
      out[14] = ena & ~in[4] &  in[3] &  in[2] &  in[1] & ~in[0];
      out[15] = ena & ~in[4] &  in[3] &  in[2] &  in[1] &  in[0];
      out[16] = ena &  in[4] & ~in[3] & ~in[2] & ~in[1] & ~in[0];
      out[17] = ena &  in[4] & ~in[3] & ~in[2] & ~in[1] &  in[0];
      out[18] = ena &  in[4] & ~in[3] & ~in[2] &  in[1] & ~in[0];
      out[19] = ena &  in[4] & ~in[3] & ~in[2] &  in[1] &  in[0];
      out[20] = ena &  in[4] & ~in[3] &  in[2] & ~in[1] & ~in[0];
      out[21] = ena &  in[4] & ~in[3] &  in[2] & ~in[1] &  in[0];
      out[22] = ena &  in[4] & ~in[3] &  in[2] &  in[1] & ~in[0];
      out[23] = ena &  in[4] & ~in[3] &  in[2] &  in[1] &  in[0];
      out[24] = ena &  in[4] &  in[3] & ~in[2] & ~in[1] & ~in[0];
      out[25] = ena &  in[4] &  in[3] & ~in[2] & ~in[1] &  in[0];
      out[26] = ena &  in[4] &  in[3] & ~in[2] &  in[1] & ~in[0];
      out[27] = ena &  in[4] &  in[3] & ~in[2] &  in[1] &  in[0];
      out[28] = ena &  in[4] &  in[3] &  in[2] & ~in[1] & ~in[0];
      out[29] = ena &  in[4] &  in[3] &  in[2] & ~in[1] &  in[0];
      out[31] = ena &  in[4] &  in[3] &  in[2] &  in[1] & ~in[0];
      out[32] = ena &  in[4] &  in[3] &  in[2] &  in[1] &  in[0]; 
  end
   
endmodule
