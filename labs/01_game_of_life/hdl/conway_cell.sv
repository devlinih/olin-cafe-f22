`default_nettype none
`timescale 1ns/1ps

module conway_cell(clk, rst, ena, state_0, state_d, state_q, neighbors);
input wire clk;
input wire rst;
input wire ena;

input wire state_0;
output logic state_d; // NOTE - this is only an output of the module for debugging purposes.
output logic state_q;

input wire [7:0] neighbors;

wire [3:0] living;

count_neighbors those_living(neighbors, living);
comparator do_i_live(living, state_q, state_d);

always_ff @(posedge clk) begin
   // Assuming reset works regardless of if enable is true or not.
   state_q <= rst ? state_0 : (ena ? state_d : state_q);
end

endmodule
