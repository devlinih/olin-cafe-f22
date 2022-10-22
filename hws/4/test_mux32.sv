`timescale 1ns / 1ps
`default_nettype none

module test_mux32;
   logic [4:0] in00, in01, in02, in03, in04, in05, in06, in07,
               in08, in09, in10, in11, in12, in13, in14, in15,
               in16, in17, in18, in19, in20, in21, in22, in23,
               in24, in25, in26, in27, in28, in29, in30, in31;
   logic [4:0] select;
   wire [4:0]  out;

   mux32 #(.N(5)) UUT(.in00(in00), .in01(in01), .in02(in02), .in03(in03),
                      .in04(in04), .in05(in05), .in06(in06), .in07(in07),
                      .in08(in08), .in09(in09), .in10(in10), .in11(in11),
                      .in12(in12), .in13(in13), .in14(in14), .in15(in15),
                      .in16(in16), .in17(in17), .in18(in18), .in19(in19),
                      .in20(in20), .in21(in21), .in22(in22), .in23(in23),
                      .in24(in24), .in25(in25), .in26(in26), .in27(in27),
                      .in28(in28), .in29(in29), .in30(in30), .in31(in31),
                      .select(select), .out(out));

   initial begin
      // Collect waveforms
      $dumpfile("mux32.fst");
      $dumpvars(0, UUT);

      $display("Inputs binary values will map to their number, thus select=out");
      $display("select | out");

      // Map multiplexer inputs to their values
      in00 = 00;
      in01 = 01;
      in02 = 02;
      in03 = 03;
      in04 = 04;
      in05 = 05;
      in06 = 06;
      in07 = 07;
      in08 = 08;
      in09 = 09;
      in10 = 10;
      in11 = 11;
      in12 = 12;
      in13 = 13;
      in14 = 14;
      in15 = 15;
      in16 = 16;
      in17 = 17;
      in18 = 18;
      in19 = 19;
      in20 = 20;
      in21 = 21;
      in22 = 22;
      in23 = 23;
      in24 = 24;
      in25 = 25;
      in26 = 26;
      in27 = 27;
      in28 = 28;
      in29 = 29;
      in30 = 30;
      in31 = 31;

      for (int i = 0; i < 32; i = i + 1) begin
         select = i;
         #1;
         $display("%6b | %4b", select, out);
         assert (select === out) else $error("Test failed on select = %b", i);
      end

      $finish;
   end

endmodule
