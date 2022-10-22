`timescale 1ns/1ps
`default_nettype none

module addn(a, b, c_in, sum, c_out);

   parameter N = 32;

   input wire   [N:0] a, b;
   input wire         c_in;
   output logic [N:0] sum;
   output logic       c_out;

   wire [N:0] carry;

   assign carry[0] = c_in;
   generate
      genvar i;
      for (i = 0; i < N; i = i+1) begin
         add1 ADD (.a(a[i]),
                   .b(b[i]),
                   .c_in(carry[i]),
                   .sum(sum[i]),
                   .c_out(carry[i+1]));
      end
   endgenerate
   assign c_out = carry[N];
endmodule
