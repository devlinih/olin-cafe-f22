`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_comparator;
logic [3:0] neighbors;
logic state;
wire next_state;

comparator UUT(.neighbors(neighbors), .state(state), .next_state(next_state));

initial begin
    //collect waveforms
    $dumpfile("comparator.fst");
    $dumpvars(0, UUT);

    $display("neighbors living | state | next_state");
    // Comparator has 5 bits of input, 2^5=32, test all inputs
    for (int i = 0; i < 32; i = i + 1) begin
        state = i[4];
        neighbors = i[3:0];

        // Print truth table for manual review.
        #1 $display("%4b | %1b | %1b", neighbors, state, next_state);
    end

end
endmodule
