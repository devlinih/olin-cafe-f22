`timescale 1ns / 1ps
`default_nettype none

module test_adder_1;
   logic a;
   logic b;
   logic c_in;
   wire sum;
   wire c_out;

   add1 UUT(.a(a),
            .b(b),
            .c_in(c_in),
            .sum(sum),
            .c_out(c_out));

   initial begin
      // Collect waveforms
      $dumpfile("add1.fst");
      $dumpvars(0, UUT);

      // The three inputs are mapped to the first 3 bits in the int i
      $display("c_in b a | sum c_out");
      for (int i = 0; i < 8; i = i + 1) begin
         c_in = i[2];
         b = i[1];
         a = i[0];

         #1 $display("%4b %1b %1b | %3b %5b", c_in, b, a, sum, c_out);
      end

      $finish;
   end

endmodule
