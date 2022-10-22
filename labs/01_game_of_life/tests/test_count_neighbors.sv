`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_count_neighbors;
   // flip all logic/wires from the UUT (unit under test)
   logic [7:0] in;
   wire  [3:0] sum;
   

   count_neighbors UUT(.in(in),
                       .sum(sum));

   initial begin
      // Collect waveforms
      $dumpfile("count_neighbors.fst");
      $dumpvars(0, UUT);
     
      $display("in | out (binary) | out (decimal)");
      // Has 8 bits of input, test all 256 conditions
      for (int i = 0; i < 256; i = i + 1) begin
         in = i;
         // Print truth table for manual review
         #1 $display("%8b | %4b | %1d", in, sum, sum);
      end
      
      $finish;      
   end

endmodule
