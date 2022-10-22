`timescale 1ns/1ps

// See docs/notebook-sketches.pdf (page 1) for original truth table and sum of
// products

module decoder_2_to_4(ena, in, out);

   input wire         ena;
   input wire [1:0]   in;
   output logic [3:0] out;

   logic [1:0] in_b;
   always_comb begin
      // Implement truth table
      in_b = ~in;
      out[0] = in_b[0] & in_b[1] & ena;
      out[1] = in[0] & in_b[1] & ena;
      out[2] = in_b[0] & in[1] & ena;
      out[3] = in[0] & in[1] & ena;
   end

endmodule
