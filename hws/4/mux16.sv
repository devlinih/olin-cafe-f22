`timescale 1ns/1ps
`default_nettype none

module mux16(in00, in01, in02, in03, in04, in05, in06, in07,
             in08, in09, in10, in11, in12, in13, in14, in15,
             select, out);

   // Parameters
   parameter N = 32;

   // Ports
   input wire [(N-1):0] in00, in01, in02, in03, in04, in05, in06, in07,
                        in08, in09, in10, in11, in12, in13, in14, in15;
   input wire [3:0]     select;
   output logic [(N-1):0] out;

   // Intermediate wires
   wire [(N-1):0] mid0, mid1, mid2, mid3;

   // Implementation

   // 1st layer
   mux4 #(.N(N)) mux4_0 (.in0(in00), .in1(in01), .in2(in02), .in3(in03),
                         .select(select[1:0]), .out(mid0));
   mux4 #(.N(N)) mux4_1 (.in0(in04), .in1(in05), .in2(in06), .in3(in07),
                         .select(select[1:0]), .out(mid1));
   mux4 #(.N(N)) mux4_2 (.in0(in08), .in1(in09), .in2(in10), .in3(in11),
                         .select(select[1:0]), .out(mid2));
   mux4 #(.N(N)) mux4_3 (.in0(in12), .in1(in13), .in2(in14), .in3(in15),
                         .select(select[1:0]), .out(mid3));

   // Output layer
   mux4 #(.N(N)) mux4_4 (.in0(mid0), .in1(mid1), .in2(mid2), .in3(mid3),
                         .select(select[3:2]), .out(out));
endmodule
