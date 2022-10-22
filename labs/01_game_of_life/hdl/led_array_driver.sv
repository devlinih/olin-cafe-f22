`default_nettype none
`timescale 1ns/1ps

module led_array_driver(ena, x, cells, rows, cols);

   // Layout of cells in matrix and how they map (assuming N is 5)
   //     4 3 2 1 0
   //   +----------
   // 4 | 0 1 2 3 4
   // 3 | 5 6 7 8 9
   // 2 | 10 ...  14
   // 1 | 15 ...  19
   // 0 | 20 ...  24


   // Module I/O and parameters
   parameter N    = 5; // Size of Conway Cell Grid.
   parameter ROWS = N;
   parameter COLS = N;

   // I/O declarations
   input wire                 ena;   // Enable
   input wire   [$clog2(N):0] x;     // Bus representing which column we are showing
   input wire   [N*N-1:0]     cells; // Bus representing every conway cell
   output logic [N-1:0]       rows;  // Bus representing row connections
   output logic [N-1:0]       cols;  // Bus representing column connections


   // You can check parameters with the $error macro within initial blocks.
   initial begin
      if ((N <= 0) || (N > 8)) begin
         $error("N must be within 0 and 8.");
      end
      if (ROWS != COLS) begin
         $error("Non square led arrays are not supported. (%dx%d)", ROWS, COLS);
      end
      if (ROWS < N) begin
         $error("ROWS/COLS must be >= than the size of the Conway Grid.");
      end
   end

   // Decode x
   wire [N-1:0] x_decoded;
   decoder_3_to_8 COL_DECODER(ena, x, x_decoded);

   // cols is the first N bits of the decoder output
   assign cols = x_decoded[N-1:0];

   // Handle a single row
   // rows[0] = ~| (cols & cells[N-1:0]);
   // rows[1] = ~| (cols & cells[2*N-1:N]);
   // rows[2] = ~| (cols & cells[3*N-1:2*N]);

   // The pattern, if row is a genvar
   // rows[row] = ~| (cols & cells[(row+1)*N-1:row*N]);

   // The above commented code as a generate statement
   generate
      genvar row;
      for (row = 0; row < N; row = row+1) begin
         always_comb rows[row] = ~| (cols & cells[(row+1)*N-1:row*N]);
      end
   endgenerate

endmodule
