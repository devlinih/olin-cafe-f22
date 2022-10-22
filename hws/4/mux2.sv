`timescale 1ns/1ps
`default_nettype none

module mux2(in0, in1, select, out);
   // Parameters
   parameter N = 32;

   // Ports
   input wire [(N-1):0] in0, in1;
   input wire select;
   output logic [(N-1):0] out;

   always_comb out = select ? in1 : in0;
endmodule
