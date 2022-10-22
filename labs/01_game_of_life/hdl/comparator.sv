`timescale 1ns/1ps
`default_nettype none

module comparator(neighbors, state, next_state);

input wire [3:0] neighbors; // Bus representing number of alive neighbors from
                            // 0 to 8
input wire state;           // Current state of cell
output logic next_state;    // Next state of cell

// Midpoint wires
logic next_living;
logic next_dead;
always_comb begin
    // See docs/notebook-sketches.pdf for how this is derived (page 2)
    next_living = state & (~neighbors[3] & ~neighbors[2] & neighbors[1]);
    next_dead = ~state & (~neighbors[3] & ~neighbors[2] & neighbors[1] & neighbors[0]);
    next_state = next_living | next_dead;
end

endmodule
