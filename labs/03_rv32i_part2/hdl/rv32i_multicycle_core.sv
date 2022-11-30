`timescale 1ns/1ps
`default_nettype none

`include "alu_types.sv"
`include "rv32i_defines.sv"

module rv32i_multicycle_core(
  clk, rst, ena,
  mem_addr, mem_rd_data, mem_wr_data, mem_wr_ena,
  PC
);

parameter PC_START_ADDRESS=0;

// Standard control signals.
input  wire clk, rst, ena; // <- worry about implementing the ena signal last.

// Memory interface.
output logic [31:0] mem_addr, mem_wr_data;
input   wire [31:0] mem_rd_data;
output logic mem_wr_ena;

// Program Counter
output wire [31:0] PC;
logic [31:0] PC_old;
logic PC_ena;
logic [31:0] PC_next;

// Program Counter Registers
register #(.N(32), .RESET(PC_START_ADDRESS)) PC_REGISTER (
  .clk(clk), .rst(rst), .ena(PC_ena), .d(PC_next), .q(PC)
);
register #(.N(32)) PC_OLD_REGISTER(
  .clk(clk), .rst(rst), .ena(PC_ena), .d(PC), .q(PC_old)
);

//  an example of how to make named inputs for a mux:
/*
    enum logic {MEM_SRC_PC, MEM_SRC_RESULT} mem_src;
    always_comb begin : memory_read_address_mux
      case(mem_src)
        MEM_SRC_RESULT : mem_rd_addr = alu_result;
        MEM_SRC_PC : mem_rd_addr = PC;
        default: mem_rd_addr = 0;
    end
*/

// Register file
logic reg_write;
logic [4:0] rd, rs1, rs2;
logic [31:0] rfile_wr_data;
wire [31:0] reg_data1, reg_data2;
register_file REGISTER_FILE(
  .clk(clk),
  .wr_ena(reg_write), .wr_addr(rd), .wr_data(rfile_wr_data),
  .rd_addr0(rs1), .rd_addr1(rs2),
  .rd_data0(reg_data1), .rd_data1(reg_data2)
);

// ALU and related control signals
// Feel free to replace with your ALU from the homework.
logic [31:0] src_a, src_b;
alu_control_t alu_control;
wire [31:0] alu_result;
wire overflow, zero, equal;
alu_behavioural ALU (
  .a(src_a), .b(src_b), .result(alu_result),
  .control(alu_control),
  .overflow(overflow), .zero(zero), .equal(equal)
);

// Implement your multicycle rv32i CPU here!

// Signals, names on schematic may differ it if was defined for use of rfile, memory, etc.
logic [31:0] result,
             adr,
             instr, data,
             imm_ext,
             data_a, write_data,
             alu_out;

always_comb PC_next = result; // Map PC_next and result together

// Signals from controller
// enum logic {MEM_SRC_PC, MEM_SRC_RESULT} mem_src;
enum logic [2:0] {IMM_I_TYPE, IMM_B_TYPE, IMM_J_TYPE, IMM_S_TYPE, IMM_U_TYPE} imm_src;
enum logic [1:0] {ALUA_PC, ALUA_OLD_PC, ALUA_REG_FILE}            alu_src_a;
enum logic [1:0] {ALUB_REGFILE, ALUB_IMMEDIATE, ALUB_FOUR}        alu_src_b;
enum logic [1:0] {RES_DATA, RES_ALU_RESULT, RES_ALU_OUT}          res_src;
enum logic {POINTER, RES}                                   adr_src;

logic mem_write, ir_write;

// Signals used internally for controller
logic       branch, PC_update;
logic [1:0] alu_op;

// Instruction signals decomposed
logic [24:0] imm_in;
logic [6:0] funct7, op;
logic [2:0] funct3;

always_comb begin : instr_decomp
rs1 = instr[19:15];
rs2 = instr[24:20];
rd = instr[11:7];
imm_in = instr[31:7];
funct7 = instr[31:25];
funct3 = instr[14:12];
op = instr[6:0];
end

//Multicycle control unit

//Main FSM Decoder
enum logic [3:0] {S0_FETCH, S1_DECODE, S2_MEM_ADR, S3_MEM_READ, S4_MEMWB, S5_MEM_WRITE, S6_R_TYPE, S7_ALUWB, S8_I_TYPE} state;
//logic [1:0] ALUop;
always_ff @(negedge clk) begin
  if(rst) begin
  state <= S0_FETCH;
  end else begin
    case(state)
    S0_FETCH : begin
      PC_ena <= 0;
      adr_src <= 0;
      mem_wr_ena <= 0;
      ir_write <= 1;
      reg_write <= 0;
      alu_src_a <= ALUA_PC;
      alu_src_b <= ALUB_FOUR;
      alu_op <= 2'b00;
      res_src <= RES_ALU_RESULT;
      PC_update <= 1;
      state <= S1_DECODE;
    end
    S1_DECODE : begin
      ir_write <= 0;
      alu_src_a <= ALUA_OLD_PC;
      alu_src_b <= ALUB_IMMEDIATE;
      alu_op <= 2'b00;
      case(op)
        OP_LTYPE: state <= S2_MEM_ADR;
        OP_STYPE: state <= S2_MEM_ADR;
        OP_RTYPE: state <= S6_R_TYPE;
        OP_ITYPE: state <= S8_I_TYPE;
      endcase
    end
    S2_MEM_ADR : begin
      alu_src_a <= ALUA_REG_FILE;
      alu_src_b <= ALUB_IMMEDIATE;
      alu_op <= 2'b00;
      case(op)
        OP_LTYPE: state <= S3_MEM_READ;
        OP_STYPE: state <= S5_MEM_WRITE;
      endcase
    end
    S3_MEM_READ : begin
      res_src <= RES_ALU_OUT;
      adr_src <= 1;
      state <= S4_MEMWB;
    end
    S4_MEMWB : begin
      res_src <= RES_DATA;
      reg_write <= 1;
      state <= S0_FETCH;
    end
    S5_MEM_WRITE : begin
      res_src <= RES_DATA;
      adr_src <= 1;
      mem_wr_ena <=1;
      state <= S0_FETCH;
    end
    S6_R_TYPE : begin
      alu_src_a <= ALUA_REG_FILE;
      alu_src_b <= ALUB_REGFILE;
      alu_op <= 2'b10;
      state <= S7_ALUWB;
    end
    S7_ALUWB : begin
      res_src <= RES_ALU_OUT;
      reg_write <= 1;
      state <= S0_FETCH;
    end
    S8_I_TYPE : begin
      alu_src_a <= ALUA_REG_FILE;
      alu_src_b <= ALUB_IMMEDIATE;
      alu_op <= 2'b10;
      state <= S7_ALUWB;
    end
    endcase
  end
end

// ALU Decoder (CL)
//logic [2:0] ALU_control;
always_comb begin : ALU_decoder
   case(alu_op)
     2'b00: alu_control = ALU_ADD;
     2'b01: alu_control = ALU_SUB;
     2'b10: begin
       case(funct3)
         3'b000: begin
           case({op[5],funct7[5]})
             2'b00: alu_control = ALU_ADD;
             2'b01: alu_control = ALU_ADD;
             2'b10: alu_control = ALU_ADD;
             2'b11: alu_control = ALU_SUB;
           endcase
         end
         3'b010: alu_control = ALU_SLT;
         3'b110: alu_control = ALU_OR;
         3'b111: alu_control = ALU_AND;
       endcase
     end
   endcase
end

// Instr Decoder (CL)
always_comb begin : instr_decoder
   case(op)
     OP_LTYPE: imm_src = IMM_I_TYPE;
     OP_ITYPE: imm_src = IMM_I_TYPE;
     OP_JALR: imm_src = IMM_I_TYPE;
     OP_STYPE: imm_src = IMM_S_TYPE;
     OP_BTYPE: imm_src = IMM_B_TYPE;
     OP_JAL: imm_src = IMM_J_TYPE;
     OP_LUI: imm_src = IMM_U_TYPE;
     OP_AUIPC: imm_src = IMM_U_TYPE;
   endcase
end

//Multicycle Core

// Read Address (CL)
always_comb begin : address_read
   case(adr_src)
     POINTER: mem_addr = PC;
     RES: mem_addr = result;
   endcase
end

// Immediate Extension
always_comb begin : set_imm_ext
   case (imm_src)
     IMM_I_TYPE : imm_ext = {{20{instr[31]}}, instr[31:20]};
     IMM_S_TYPE : imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
     IMM_B_TYPE : imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
     IMM_J_TYPE : imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
     IMM_U_TYPE : imm_ext = {{instr[31:12]}, 12'b0};
     default    : imm_ext = 32'b0;
   endcase
end

// ALU A
always_comb begin : alu_a
   case (alu_src_a)
     ALUA_PC       : src_a = PC;
     ALUA_OLD_PC   : src_a = PC_old;
     ALUA_REG_FILE : src_a = data_a;
     default       : src_a = 0;
   endcase
end

// ALU B
always_comb begin : alu_b
   case (alu_src_b)
     ALUB_REGFILE   : src_b = write_data;
     ALUB_IMMEDIATE : src_b = imm_ext;
     ALUB_FOUR      : src_b = 4;
     default        : src_b = 4;
   endcase
end

// Results
always_comb begin : calculate_result
   case (res_src)
     RES_DATA       : result = data;
     RES_ALU_RESULT : result = alu_result;
     RES_ALU_OUT    : result = alu_out;
     default        : result = 0;
   endcase
end

// Registers for multicycle state

// Instruction Reg
always_ff @(posedge clk) begin : instr_reg
   if (rst) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      PC_old <= 32'h0;
      instr <= 32'h0;
      // End of automatics
   end
   else if (ir_write) begin
      PC_old <= PC;
      instr  <= mem_rd_data;
   end
end

// Data Reg
always_ff @(posedge clk) begin : data_reg
   if (rst) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      data <= 32'h0;
      // End of automatics
   end
   else begin
      data <= mem_rd_data;
   end
end

// Register File Reg
always_ff @(posedge clk) begin : rfile_reg
   if (rst) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      data_a <= 32'h0;
      write_data <= 32'h0;
      // End of automatics
   end
   else begin
      data_a     <= reg_data1;
      write_data <= reg_data2;
   end
end

// Result Reg
always_ff @(posedge clk) begin : result_reg
   if (rst) begin
      /*AUTORESET*/
      // Beginning of autoreset for uninitialized flops
      alu_out <= 32'h0;
      // End of automatics
   end
   else begin
      alu_out <= alu_result;
   end
end

endmodule
