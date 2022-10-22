`timescale 1ns/1ps

// See docs/notebook-sketches.pdf (page 1) for original truth table and sum of
// products.

module decoder_3_to_8(ena, in, out);

   input wire         ena;
   input wire [2:0]   in;
   output logic [7:0] out;

   always_comb begin
      // Implement truth table
      out[0] = ~in[2] & ~in[1] & ~in[0] & ena;
      out[1] = ~in[2] & ~in[1] &  in[0] & ena;
      out[2] = ~in[2] &  in[1] & ~in[0] & ena;
      out[3] = ~in[2] &  in[1] &  in[0] & ena;
      out[4] =  in[2] & ~in[1] & ~in[0] & ena;
      out[5] =  in[2] & ~in[1] &  in[0] & ena;
      out[6] =  in[2] &  in[1] & ~in[0] & ena;
      out[7] =  in[2] &  in[1] &  in[0] & ena;
   end

endmodule
