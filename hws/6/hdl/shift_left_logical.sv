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
          .\(in*[^0-9]\)@ (in_ext[\2-i+N-1]),
          .select (shamt),
          .out (out[i]),
          );*/
         mux32 #(.N(1)) MUX (/*AUTOINST*/
                             // Outputs
                             .out               (out[i]),        // Templated
                             // Inputs
                             .in00              (in_ext[00-i+N-1]), // Templated
                             .in01              (in_ext[01-i+N-1]), // Templated
                             .in02              (in_ext[02-i+N-1]), // Templated
                             .in03              (in_ext[03-i+N-1]), // Templated
                             .in04              (in_ext[04-i+N-1]), // Templated
                             .in05              (in_ext[05-i+N-1]), // Templated
                             .in06              (in_ext[06-i+N-1]), // Templated
                             .in07              (in_ext[07-i+N-1]), // Templated
                             .in08              (in_ext[08-i+N-1]), // Templated
                             .in09              (in_ext[09-i+N-1]), // Templated
                             .in10              (in_ext[10-i+N-1]), // Templated
                             .in11              (in_ext[11-i+N-1]), // Templated
                             .in12              (in_ext[12-i+N-1]), // Templated
                             .in13              (in_ext[13-i+N-1]), // Templated
                             .in14              (in_ext[14-i+N-1]), // Templated
                             .in15              (in_ext[15-i+N-1]), // Templated
                             .in16              (in_ext[16-i+N-1]), // Templated
                             .in17              (in_ext[17-i+N-1]), // Templated
                             .in18              (in_ext[18-i+N-1]), // Templated
                             .in19              (in_ext[19-i+N-1]), // Templated
                             .in20              (in_ext[20-i+N-1]), // Templated
                             .in21              (in_ext[21-i+N-1]), // Templated
                             .in22              (in_ext[22-i+N-1]), // Templated
                             .in23              (in_ext[23-i+N-1]), // Templated
                             .in24              (in_ext[24-i+N-1]), // Templated
                             .in25              (in_ext[25-i+N-1]), // Templated
                             .in26              (in_ext[26-i+N-1]), // Templated
                             .in27              (in_ext[27-i+N-1]), // Templated
                             .in28              (in_ext[28-i+N-1]), // Templated
                             .in29              (in_ext[29-i+N-1]), // Templated
                             .in30              (in_ext[30-i+N-1]), // Templated
                             .in31              (in_ext[31-i+N-1]), // Templated
                             .select            (shamt));         // Templated
      end
   endgenerate
endmodule
