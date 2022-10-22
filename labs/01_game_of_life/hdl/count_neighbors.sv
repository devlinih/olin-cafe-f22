`default_nettype none
`timescale 1ns/1ps

// A module for counting the number of living neighbors for a Conway cell. In
// other words, adds 8 1-bit numbers, outputting a 4 bit number between 0000
// and 1000.

// See docs/notebook-sketches.pdf (page 1)

module count_neighbors(in, sum);

   input  wire  [7:0] in;
   output logic [3:0] sum;

   // First layer of summing, add 1-bit inputs into 2-bit busses
   wire [1:0] sum_2_0, sum_2_1, sum_2_2, sum_2_3;
   adder_1 adder_1_0 (in[7], in[6], 1'b0, sum_2_3[0], sum_2_3[1]);
   adder_1 adder_1_1 (in[5], in[4], 1'b0, sum_2_2[0], sum_2_2[1]);
   adder_1 adder_1_2 (in[3], in[2], 1'b0, sum_2_1[0], sum_2_1[1]);
   adder_1 adder_1_3 (in[1], in[0], 1'b0, sum_2_0[0], sum_2_0[1]);

   // Second layer of summing, add 4 2-bit busses into 2 3-bit busses
   wire [2:0] sum_3_0, sum_3_1;
   adder_n #(.N(2)) adder_2bit_0 (sum_2_3, sum_2_2, 1'b0, sum_3_1[1:0], sum_3_1[2]);
   adder_n #(.N(2)) adder_2bit_1 (sum_2_1, sum_2_0, 1'b0, sum_3_0[1:0], sum_3_0[2]);

   // Final layer of summing, add 2 3-bit busses into a 4-bit bus.
   adder_n #(.N(3)) adder_3bit (sum_3_1, sum_3_0, 1'b0, sum[2:0], sum[3]);

endmodule
