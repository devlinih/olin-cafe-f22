`default_nettype none
`timescale 1ns/1ps

module register_file(clk, //Note - intentionally does not have a reset!
                     wr_ena, wr_addr, wr_data,
                     rd_addr0, rd_data0,
                     rd_addr1, rd_data1);
   // Not parametrizing, these widths are defined by the RISC-V Spec!
   input wire clk;

   // Write channel
   input wire        wr_ena;
   input wire [4:0]  wr_addr;
   input wire [31:0] wr_data;

   // Two read channels
   input wire   [4:0]  rd_addr0, rd_addr1;
   output logic [31:0] rd_data0, rd_data1;

   // Register outputs: to make it easier to use a generate statement, put it
   // in one large [32*32-1:0] bus. Indexed as register_out[32*(N+1)-1:32*N].
   logic [32*32-1:0] register_out;
   always_comb register_out[31:0] = 32'd0; // ties reg x00 to ground.

   // Write enable for registers
   logic [31:0] register_ena;

   // Setup registers x01 to x32
   generate
      genvar i;
      for (i=1; i<32; i=i+1) begin // Start at 1 because x00 is zero
         register #(.N(32)) REGISTER (.clk (clk),
                                      .ena (register_ena[i]),
                                      .rst (1'b0),
                                      .d   (wr_data),
                                      .q   (register_out[32*(i+1)-1:32*i]));
      end
   endgenerate

   // Setup write decoder
   decoder32 write0 (// Inputs
                     .in(wr_addr),
                     .ena(wr_ena),
                     // Outputs
                     .out(register_ena));

   // Outputs
   /* mux32 AUTO_TEMPLATE (
    .\(in*[^0-9]\)@ (register_out[32*(\2+1)-1:32*\2]),
    )
   */
   mux32 #(.N(32)) read0 (// Inputs
                          .select(rd_addr0),
                          // Outputs
                          .out(rd_data0),
                          /*AUTOINST*/
                          // Inputs
                          .in00                 (register_out[32*(00+1)-1:32*00]), // Templated
                          .in01                 (register_out[32*(01+1)-1:32*01]), // Templated
                          .in02                 (register_out[32*(02+1)-1:32*02]), // Templated
                          .in03                 (register_out[32*(03+1)-1:32*03]), // Templated
                          .in04                 (register_out[32*(04+1)-1:32*04]), // Templated
                          .in05                 (register_out[32*(05+1)-1:32*05]), // Templated
                          .in06                 (register_out[32*(06+1)-1:32*06]), // Templated
                          .in07                 (register_out[32*(07+1)-1:32*07]), // Templated
                          .in08                 (register_out[32*(08+1)-1:32*08]), // Templated
                          .in09                 (register_out[32*(09+1)-1:32*09]), // Templated
                          .in10                 (register_out[32*(10+1)-1:32*10]), // Templated
                          .in11                 (register_out[32*(11+1)-1:32*11]), // Templated
                          .in12                 (register_out[32*(12+1)-1:32*12]), // Templated
                          .in13                 (register_out[32*(13+1)-1:32*13]), // Templated
                          .in14                 (register_out[32*(14+1)-1:32*14]), // Templated
                          .in15                 (register_out[32*(15+1)-1:32*15]), // Templated
                          .in16                 (register_out[32*(16+1)-1:32*16]), // Templated
                          .in17                 (register_out[32*(17+1)-1:32*17]), // Templated
                          .in18                 (register_out[32*(18+1)-1:32*18]), // Templated
                          .in19                 (register_out[32*(19+1)-1:32*19]), // Templated
                          .in20                 (register_out[32*(20+1)-1:32*20]), // Templated
                          .in21                 (register_out[32*(21+1)-1:32*21]), // Templated
                          .in22                 (register_out[32*(22+1)-1:32*22]), // Templated
                          .in23                 (register_out[32*(23+1)-1:32*23]), // Templated
                          .in24                 (register_out[32*(24+1)-1:32*24]), // Templated
                          .in25                 (register_out[32*(25+1)-1:32*25]), // Templated
                          .in26                 (register_out[32*(26+1)-1:32*26]), // Templated
                          .in27                 (register_out[32*(27+1)-1:32*27]), // Templated
                          .in28                 (register_out[32*(28+1)-1:32*28]), // Templated
                          .in29                 (register_out[32*(29+1)-1:32*29]), // Templated
                          .in30                 (register_out[32*(30+1)-1:32*30]), // Templated
                          .in31                 (register_out[32*(31+1)-1:32*31])); // Templated
   mux32 #(.N(32)) read1 (// Inputs
                          .select(rd_addr1),
                          // Outputs
                          .out(rd_data1),
                          /*AUTOINST*/
                          // Inputs
                          .in00                 (register_out[32*(00+1)-1:32*00]), // Templated
                          .in01                 (register_out[32*(01+1)-1:32*01]), // Templated
                          .in02                 (register_out[32*(02+1)-1:32*02]), // Templated
                          .in03                 (register_out[32*(03+1)-1:32*03]), // Templated
                          .in04                 (register_out[32*(04+1)-1:32*04]), // Templated
                          .in05                 (register_out[32*(05+1)-1:32*05]), // Templated
                          .in06                 (register_out[32*(06+1)-1:32*06]), // Templated
                          .in07                 (register_out[32*(07+1)-1:32*07]), // Templated
                          .in08                 (register_out[32*(08+1)-1:32*08]), // Templated
                          .in09                 (register_out[32*(09+1)-1:32*09]), // Templated
                          .in10                 (register_out[32*(10+1)-1:32*10]), // Templated
                          .in11                 (register_out[32*(11+1)-1:32*11]), // Templated
                          .in12                 (register_out[32*(12+1)-1:32*12]), // Templated
                          .in13                 (register_out[32*(13+1)-1:32*13]), // Templated
                          .in14                 (register_out[32*(14+1)-1:32*14]), // Templated
                          .in15                 (register_out[32*(15+1)-1:32*15]), // Templated
                          .in16                 (register_out[32*(16+1)-1:32*16]), // Templated
                          .in17                 (register_out[32*(17+1)-1:32*17]), // Templated
                          .in18                 (register_out[32*(18+1)-1:32*18]), // Templated
                          .in19                 (register_out[32*(19+1)-1:32*19]), // Templated
                          .in20                 (register_out[32*(20+1)-1:32*20]), // Templated
                          .in21                 (register_out[32*(21+1)-1:32*21]), // Templated
                          .in22                 (register_out[32*(22+1)-1:32*22]), // Templated
                          .in23                 (register_out[32*(23+1)-1:32*23]), // Templated
                          .in24                 (register_out[32*(24+1)-1:32*24]), // Templated
                          .in25                 (register_out[32*(25+1)-1:32*25]), // Templated
                          .in26                 (register_out[32*(26+1)-1:32*26]), // Templated
                          .in27                 (register_out[32*(27+1)-1:32*27]), // Templated
                          .in28                 (register_out[32*(28+1)-1:32*28]), // Templated
                          .in29                 (register_out[32*(29+1)-1:32*29]), // Templated
                          .in30                 (register_out[32*(30+1)-1:32*30]), // Templated
                          .in31                 (register_out[32*(31+1)-1:32*31])); // Templated

endmodule
