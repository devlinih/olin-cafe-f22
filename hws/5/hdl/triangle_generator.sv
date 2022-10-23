// Generates "triangle" waves (counts from 0 to 2^N-1, then back down again)

// The triangle should increment/decrement only if the ena signal is high, and
// hold its value otherwise.

module triangle_generator(clk, rst, ena, out);
   parameter N = 8;

   input wire clk, rst, ena;
   output logic [N-1:0] out;

   // See block diagram
   typedef enum logic {COUNTING_UP, COUNTING_DOWN} state_t;
   state_t state; // state is direction on diagram
   state_t next_state;

   // See block diagram, replace count with out
   logic [N-1:0] next_out;

   always_comb begin
      if (ena) begin
         // Next out
         case(state)
           COUNTING_UP: next_out = out + 1;
           COUNTING_DOWN: next_out = out - 1;
         endcase

         // Next direction
         case(out)
           // -2 is 111...110 by two's comp definition
           -2: next_state = COUNTING_DOWN;
           1:  next_state = COUNTING_UP;
           default: next_state = state;
         endcase
      end // if (ena)
      else begin
         next_out = out;
         next_state = state;
      end
   end // always_comb

   always_ff @(posedge clk)begin
      out <= rst ? 'b0 : next_out;
      state <= rst ? COUNTING_UP : next_state;
   end
endmodule
