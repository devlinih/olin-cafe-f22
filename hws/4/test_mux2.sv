`timescale 1ns / 1ps
`default_nettype none

module test_mux2;
   logic in0, in1, select;
   wire  out;

   mux2 #(.N(1)) UUT(.in0(in0), .in1(in1), .select(select), .out(out));

   initial begin
      // Collect waveforms
      $dumpfile("mux2.fst");
      $dumpvars(0, UUT);

      $display("Inputs binary values will map to their number, thus select=out");
      $display("select | out");

      // Map multiplexer inputs to their values
      in0 = 0;
      in1 = 1;

      for (int i = 0; i < 2; i = i + 1) begin
         select = i;
         #1;
         $display("%6b | %3b", select, out);
         assert (select === out) else $error("Test failed on select = %b", i);
      end

      $finish;
   end

endmodule
