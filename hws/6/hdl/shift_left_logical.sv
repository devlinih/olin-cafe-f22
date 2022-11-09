`timescale 1ns/1ps
`default_nettype none

module shift_left_logical(in, shamt, out);
   parameter N = 32; // only used as a constant! Don't feel like you need to a
                     // shifter for arbitrary N.

   input wire [N-1:0] in; // the input number that will be shifted left. Fill in
                          // the remainder with zeros.
   input wire [$clog2(N)-1:0] shamt; // the amount to shift by (think of it as a
                                     // decimal number from 0 to 31).
   output logic [N-1:0] out;

   // create version of in concated with a bunch of zeros
   logic [2*N-2:0] in_ext;
   always_comb in_ext = {in, {N-1 {1'b0}}};

   // cheat for now to test if the others work

   // Create all 32 multiplexers required
   generate
      genvar i;
      for (i = 0; i < N; i++) begin
         // This generates to the schematic labeled IDEA

         // Many 32x1 muxes
         // This is the power of Emacs

         /* mux32 AUTO_TEMPLATE (
          .\(in*[^0-9]\)@ (in_ext[N-1+i-\2]),
          .select (shamt),
          .out (out[i]),
          );*/
         mux32 #(.N(1)) MUX (/*AUTOINST*/
                             // Outputs
                             .out               (out[i]),        // Templated
                             // Inputs
                             .in00              (in_ext[N-1+i-00]), // Templated
                             .in01              (in_ext[N-1+i-01]), // Templated
                             .in02              (in_ext[N-1+i-02]), // Templated
                             .in03              (in_ext[N-1+i-03]), // Templated
                             .in04              (in_ext[N-1+i-04]), // Templated
                             .in05              (in_ext[N-1+i-05]), // Templated
                             .in06              (in_ext[N-1+i-06]), // Templated
                             .in07              (in_ext[N-1+i-07]), // Templated
                             .in08              (in_ext[N-1+i-08]), // Templated
                             .in09              (in_ext[N-1+i-09]), // Templated
                             .in10              (in_ext[N-1+i-10]), // Templated
                             .in11              (in_ext[N-1+i-11]), // Templated
                             .in12              (in_ext[N-1+i-12]), // Templated
                             .in13              (in_ext[N-1+i-13]), // Templated
                             .in14              (in_ext[N-1+i-14]), // Templated
                             .in15              (in_ext[N-1+i-15]), // Templated
                             .in16              (in_ext[N-1+i-16]), // Templated
                             .in17              (in_ext[N-1+i-17]), // Templated
                             .in18              (in_ext[N-1+i-18]), // Templated
                             .in19              (in_ext[N-1+i-19]), // Templated
                             .in20              (in_ext[N-1+i-20]), // Templated
                             .in21              (in_ext[N-1+i-21]), // Templated
                             .in22              (in_ext[N-1+i-22]), // Templated
                             .in23              (in_ext[N-1+i-23]), // Templated
                             .in24              (in_ext[N-1+i-24]), // Templated
                             .in25              (in_ext[N-1+i-25]), // Templated
                             .in26              (in_ext[N-1+i-26]), // Templated
                             .in27              (in_ext[N-1+i-27]), // Templated
                             .in28              (in_ext[N-1+i-28]), // Templated
                             .in29              (in_ext[N-1+i-29]), // Templated
                             .in30              (in_ext[N-1+i-30]), // Templated
                             .in31              (in_ext[N-1+i-31]), // Templated
                             .select            (shamt));         // Templated
      end
   endgenerate
endmodule
