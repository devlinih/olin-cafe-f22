`timescale 1ns/1ps
`default_nettype none

module mux4(in0, in1, in2, in3, select, out);
   // Parameters
   parameter N = 32;

   // Ports
   input wire [(N-1):0] in0, in1, in2, in3;
   input wire [1:0] select;
   output logic [(N-1):0] out;

   // Intermediate wires
   wire [(N-1):0] mid0, mid1;

   // Implementation

   // 1st layer
   mux2 #(.N(N)) mux2_0 (.in0(in0), .in1(in1), .select(select[0]), .out(mid0));
   mux2 #(.N(N)) mux2_1 (.in0(in2), .in1(in3), .select(select[0]), .out(mid1));
   // Output layer
   mux2 #(.N(N)) mux2_2 (.in0(mid0), .in1(mid1), .select(select[1]), .out(out));
endmodule
