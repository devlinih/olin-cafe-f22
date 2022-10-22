`timescale 1ns/1ps
`default_nettype none

module practice(rst, clk, ena, seed, out);
   input wire rst, clk, ena, seed;
   output logic out;

   logic d, q0, q1;
   always_comb d = ena ? (q1 ^ q0) : seed;
   always_ff @(posedge clk) begin
      q0  <= rst ? 1'b0 : d;
      q1  <= rst ? 1'b0 : q0;
      out <= rst ? 1'b0 : q1;
   end
endmodule
