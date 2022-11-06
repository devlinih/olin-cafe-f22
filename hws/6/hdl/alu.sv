`timescale 1ns/1ps
`default_nettype none

`include "alu_types.sv"

module alu(a, b, control, result, overflow, zero, equal);
   parameter N = 32; // Don't need to support other numbers, just using this as
                     // a constant.

   input wire [N-1:0]   a, b; // Inputs to the ALU.
   input                alu_control_t control; // Sets the current operation.
   output logic [N-1:0] result; // Result of the selected operation.

   output logic         overflow; // Is high if the result of an ADD or SUB
                                  // wraps around the 32 bit boundary.
   output logic         zero;  // Is high if the result is ever all zeros.
   output logic         equal; // is high if a == b.

   // Use *only* structural logic and previously defined modules to implement
   // an ALU that can do all of operations defined in alu_types.sv's
   // alu_op_code_t.

   // Output wires for modules
   wire [31:0] sum, sll, srl, sra;
   wire        c_out;

   shift_left_logical shift_ll (.in    (a),
                                .shamt (b[4:0]),
                                .out   (sll));

   shift_right_logical shift_rl (.in    (a),
                                 .shamt (b[4:0]),
                                 .out   (srl));

   shift_right_arithmetic shift_ra (.in    (a),
                                    .shamt (b[4:0]),
                                    .out   (sra));

   logic [31:0] add_in; // Input for adder
   always_comb add_in = control[2] ? ~b : b;
   adder_n #(.N(32)) adder (.a     (a),
                            .b     (add_in),
                            .c_in  (control[2]),
                            .sum   (sum),
                            .c_out (c_out));

   logic [31:0] op_and, op_or, op_xor; // In schematic these are and, or, xor
   logic [31:0] sltu, slt; // Less than, signed and unsigned
   logic        carry; // Flag to help compute less than unsigned
   logic        shift_overflow; // Test if the shifter overflows

   always_comb begin
      // Internal signals
      overflow       = (~(a[31]^b[31]^control[2]) // +, signs are the same
                                                  // -, signs are different
                        & (a[31]^sum[31]) // Sign of adder result are different
                        & control[3]); // +- or < is being done
      carry          = control[3] & c_out;
      shift_overflow = |b[N-1:5];

      // Operations
      op_and = a & b;
      op_or  = a | b;
      op_xor = a ^ b;
      sltu   = { {(N-1){1'b0}}, ~carry };
      slt    = { {(N-1){1'b0}}, overflow^sum[31] };

      // Result, I know case is behavioral it just makes sense with the enum
      case (control)
        ALU_AND  : result = op_and;
        ALU_OR   : result = op_or;
        ALU_XOR  : result = op_xor;
        // Added sillyness for shifts
        ALU_SLL  : result = shift_overflow ? 'b0 : sll;
        ALU_SRL  : result = shift_overflow ? 'b0 : srl;
        ALU_SRA  : result = shift_overflow ? 'b0 : sra;

        ALU_ADD  : result = sum;
        ALU_SUB  : result = sum;
        ALU_SLT  : result = slt;
        ALU_SLTU : result = sltu;
        default  : result = 0;
      endcase

      // Flags
      equal = &(~(a^b));
      zero  = &(~result);
   end
endmodule
