`timescale 1ns/1ps
`default_nettype none
/*
  a 1 bit addder that we can daisy chain for
  ripple carry adders
*/

module adder_1(a, b, c_in, sum, c_out);

   input wire a, b, c_in;
   output logic sum, c_out;

   // Midpoints
   logic in_xor;

   always_comb begin
      // See docs/notebook-sketches.pdf for how this was derived (page 1)
      in_xor = a ^ b;

      sum = c_in ^ in_xor;
      c_out = (a & b) | (c_in & in_xor);
   end

endmodule
