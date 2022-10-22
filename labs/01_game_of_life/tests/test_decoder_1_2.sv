`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_decoders;
   // flip all logic/wires from the UUT (unit under test)
   logic ena;
   logic in;
   wire [1:0] out;

   decoder_1_to_2 UUT(.ena(ena),
                   .in(in),
                   .out(out));

   initial begin
      // Collect waveforms
      $dumpfile("decoders_1_2.fst");
      $dumpvars(0, UUT);
      
      ena = 1;
      $display("ena in | out");
      for (int i = 0; i < 2; i = i + 1) begin
         in = i[0];
         #1 $display("%1b %2b | %4b", ena, in, out);
      end

      ena = 0;
      for (int i = 0; i < 8; i = i + 1) begin
         in = i[2:0];
         #1 $display("%1b %2b | %4b", ena, in, out);
      end
      
      $finish;      
   end

endmodule
