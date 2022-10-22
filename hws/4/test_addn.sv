`timescale 1ns / 1ps
`default_nettype none

module test_addn;
   logic [2:0] a, b;
   logic       c_in;
   wire  [2:0] sum;
   wire        c_out;

   addn #(.N(3)) UUT(.a(a), .b(b), .c_in(c_in), .sum(sum), .c_out(c_out));

   initial begin
      // Collect waveforms
      $dumpfile("addn.fst");
      $dumpvars(0, UUT);

      $display("a | b | c_in || c_out | sum");

      for (int i = 0; i < 128; i = i + 1) begin
         a = i[2:0];
         b = i[5:3];
         c_in = i[6];
         #1;
         $display("%b | %b | %b || %b | %b", a, b, c_in, c_out, sum);
         // assert (select === out) else $error("Test failed on select = %b", i);
      end

      $finish;
   end

endmodule
