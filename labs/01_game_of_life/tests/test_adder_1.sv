`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_adder_1;
   // flip all logic/wires from the UUT (unit under test)
   logic a;
   logic b;
   logic c_in;
   wire sum;
   wire c_out;

   adder_1 UUT(.a(a),
               .b(b),
               .c_in(c_in),
               .sum(sum),
               .c_out(c_out));

   initial begin
      // Collect waveforms
      $dumpfile("adder_1.fst");
      $dumpvars(0, UUT);

      $display("c_in b a | sum c_out");
      // Adder has 3 inputs, 2^3=8 conditions. Test all of them.
      for (int i = 0; i < 8; i = i + 1) begin
         c_in = i[2];
         b = i[1];
         a = i[0];

         // Print truth table for manual review
         #1 $display("%4b %1b %1b | %3b %5b", c_in, b, a, sum, c_out);
      end

      $finish;
   end

endmodule
