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
      out = counter >= ticks;
      next_state = ena ? (out ? 'b0 : counter+1)
                       : counter;
   end

   always_ff @(posedge clk) begin
      // counter <= rst ? N'b0 : next_state;

      // Why does not specifying bus size make it work? I know linting
      // complains but just curious as to why
      counter <= rst ? 'b0 : next_state;
   end
endmodule
