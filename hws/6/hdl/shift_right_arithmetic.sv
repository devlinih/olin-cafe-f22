`timescale 1ns/1ps
`default_nettype none

module shift_right_arithmetic(in,shamt,out);
   parameter N = 32; // only used as a constant! Don't feel like you need to a
                     // shifter for arbitrary N.

   //port definitions
   input  wire [N-1:0]         in;    // A 32 bit input
   input  wire [$clog2(N)-1:0] shamt; // Shift ammount
   output wire [N-1:0]         out;   // The same as SRL, but maintain the sign
                                      // bit (MSB) after the shift!

   // It's similar to SRL, but instead of filling in the extra bits with zero,
   // we fill them in with the sign bit. Remember the *repetition operator*:
   // {n{bits}} will repeat bits n times.

   // create version of in extended with the MSB
   logic [2*N-2:0] in_ext;
   always_comb in_ext = {{N-1 {in[N-1]}}, in};


   // Create all 32 multiplexers required
   generate
      genvar i;
      for (i = 0; i < N; i++) begin
         // This generates to the schematic labeled IDEA

         // Many 32x1 muxes
         // This is the power of Emacs

         /* mux32 AUTO_TEMPLATE (
          .\(in*[^0-9]\)@ (in_ext[\2+i]),
          .select (shamt),
          .out (out[i]),
          );*/
         mux32 #(.N(1)) MUX (/*AUTOINST*/
                             // Outputs
                             .out               (out[i]),        // Templated
                             // Inputs
                             .in00              (in_ext[00+i]),  // Templated
                             .in01              (in_ext[01+i]),  // Templated
                             .in02              (in_ext[02+i]),  // Templated
                             .in03              (in_ext[03+i]),  // Templated
                             .in04              (in_ext[04+i]),  // Templated
                             .in05              (in_ext[05+i]),  // Templated
                             .in06              (in_ext[06+i]),  // Templated
                             .in07              (in_ext[07+i]),  // Templated
                             .in08              (in_ext[08+i]),  // Templated
                             .in09              (in_ext[09+i]),  // Templated
                             .in10              (in_ext[10+i]),  // Templated
                             .in11              (in_ext[11+i]),  // Templated
                             .in12              (in_ext[12+i]),  // Templated
                             .in13              (in_ext[13+i]),  // Templated
                             .in14              (in_ext[14+i]),  // Templated
                             .in15              (in_ext[15+i]),  // Templated
                             .in16              (in_ext[16+i]),  // Templated
                             .in17              (in_ext[17+i]),  // Templated
                             .in18              (in_ext[18+i]),  // Templated
                             .in19              (in_ext[19+i]),  // Templated
                             .in20              (in_ext[20+i]),  // Templated
                             .in21              (in_ext[21+i]),  // Templated
                             .in22              (in_ext[22+i]),  // Templated
                             .in23              (in_ext[23+i]),  // Templated
                             .in24              (in_ext[24+i]),  // Templated
                             .in25              (in_ext[25+i]),  // Templated
                             .in26              (in_ext[26+i]),  // Templated
                             .in27              (in_ext[27+i]),  // Templated
                             .in28              (in_ext[28+i]),  // Templated
                             .in29              (in_ext[29+i]),  // Templated
                             .in30              (in_ext[30+i]),  // Templated
                             .in31              (in_ext[31+i]),  // Templated
                             .select            (shamt));         // Templated
      end
   endgenerate
endmodule
