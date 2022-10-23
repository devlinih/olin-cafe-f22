module comparator_lt(a, b, out);
   // Note: this assumes that the two inputs are signed: aka should be
   // interpreted as two's complement.
   parameter N = 32;

   input wire signed [N-1:0] a, b;
   output logic              out;

   // Inputs and outputs for subtractor
   wire [N-1:0] diff;
   wire         c_out;
   adder_n #(.N(N)) subtractor (.a(a), .b(~b), // Invert b
                                .c_in(1'b1),   // Add 1 for the 2s compliment
                                .c_out(c_out),
                                .sum(diff));

   // Other values (see Schematic)
   logic op_signs_a_b;
   logic op_signs_a_sum;
   logic overflow;

   always_comb begin
      op_signs_a_b = a[N-1] ^ b[N-1];
      op_signs_a_sum = a[N-1] ^ diff[N-1];
      overflow = op_signs_a_b & op_signs_a_sum;
      out = overflow ^ diff[N-1];
   end
endmodule
