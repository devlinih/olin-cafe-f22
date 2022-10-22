`timescale 1ns / 1ps
`default_nettype none

module test_mux4;
   logic [1:0] in0, in1, in2, in3;
   logic [1:0] select;
   wire [1:0]  out;

   mux4 #(.N(2)) UUT(.in0(in0), .in1(in1), .in2(in2), .in3(in3),
                     .select(select), .out(out));

   initial begin
      // Collect waveforms
      $dumpfile("mux4.fst");
      $dumpvars(0, UUT);

      $display("Inputs binary values will map to their number, thus select=out");
      $display("select | out");

      // Map multiplexer inputs to their values
      in0 = 0;
      in1 = 1;
      in2 = 2;
      in3 = 3;

      for (int i = 0; i < 4; i = i + 1) begin
         select = i;
         #1;
         $display("%6b | %3b", select, out);
         assert (select === out) else $error("Test failed on select = %b", i);
      end

      $finish;
   end

endmodule
