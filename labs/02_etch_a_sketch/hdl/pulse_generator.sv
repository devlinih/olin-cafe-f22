/*
  Outputs a pulse generator with a period of "ticks".
  out should go high for one cycle every "ticks" clocks.
*/
module pulse_generator(clk, rst, ena, ticks, out);
   parameter N = 8;

   input wire clk, rst, ena;
   input wire [N-1:0] ticks;
   output logic       out;

   logic [N-1:0] counter;
   logic [N-1:0] next_state;

   // See schematic for details
   always_comb begin
      out = ~|counter;
      next_state = ena ? ((counter == ticks) ? 'b0 : counter + 1)
                       : counter;
   end

   always_ff @(posedge clk) begin
      counter <= rst ? 'b0 : next_state;
   end
endmodule
