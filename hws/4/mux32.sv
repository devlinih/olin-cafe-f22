`timescale 1ns/1ps
`default_nettype none

module mux32(in00, in01, in02, in03, in04, in05, in06, in07,
             in08, in09, in10, in11, in12, in13, in14, in15,
             in16, in17, in18, in19, in20, in21, in22, in23,
             in24, in25, in26, in27, in28, in29, in30, in31,
             select, out);

   // Parameters
   parameter N = 32;

   // Ports
   input wire [(N-1):0] in00, in01, in02, in03, in04, in05, in06, in07,
                        in08, in09, in10, in11, in12, in13, in14, in15,
                        in16, in17, in18, in19, in20, in21, in22, in23,
                        in24, in25, in26, in27, in28, in29, in30, in31;
   input wire [4:0]     select;
   output logic [(N-1):0] out;

   // Intermediate wires
   wire [(N-1):0] mid0, mid1;

   // Implementation

   // 1st layer
   mux16 #(.N(N)) mux16_0 (.in00(in00), .in01(in01), .in02(in02), .in03(in03),
                           .in04(in04), .in05(in05), .in06(in06), .in07(in07),
                           .in08(in08), .in09(in09), .in10(in10), .in11(in11),
                           .in12(in12), .in13(in13), .in14(in14), .in15(in15),
                           .select(select[3:0]), .out(mid0));
   mux16 #(.N(N)) mux16_1 (.in00(in16), .in01(in17), .in02(in18), .in03(in19),
                           .in04(in20), .in05(in21), .in06(in22), .in07(in23),
                           .in08(in24), .in09(in25), .in10(in26), .in11(in27),
                           .in12(in28), .in13(in29), .in14(in30), .in15(in31),
                           .select(select[3:0]), .out(mid1));

   // Output layer
   mux2 #(.N(N)) mux2_0 (.in0(mid0), .in1(mid1),
                         .select(select[4]), .out(out));
endmodule
