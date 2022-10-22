`timescale 1ns/1ps
`default_nettype none

module add1(a, b, c_in, sum, c_out);
   input wire a, b, c_in;
   output logic sum, c_out;

   // Midpoints
   logic in_xor;

   always_comb begin
      in_xor = a ^ b;

      sum = c_in ^ in_xor;
      c_out = (a & b) | (c_in & in_xor);
   end
endmodule
