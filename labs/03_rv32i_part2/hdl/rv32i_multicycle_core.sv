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
wire [31:0] PC_old;
logic PC_ena;
logic [31:0] PC_next;

// Program Counter
register #(.N(32), .RESET(PC_START_ADDRESS)) PC_REGISTER (
  .clk(clk), .rst(rst), .ena(PC_ena), .d(PC_next), .q(PC)
);
// Old Program Counter
register #(.N(32)) PC_OLD_REGISTER(
  .clk(clk), .rst(rst), .ena(ir_write), .d(PC), .q(PC_old)
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
always_comb rfile_wr_data = result;
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
             imm_ext;

// Register output signals (must be wires)
wire [31:0]  instr,
             data,
             data_a,
             write_data,
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
enum logic [3:0] {S0_FETCH     = 4'b0000,
                  S1_DECODE    = 4'b0001,
                  S2_MEM_ADR   = 4'b0010,
                  S3_MEM_READ  = 4'b1001,
                  S4_MEMWB     = 4'b1100,
                  S5_MEM_WRITE = 4'b1010,
                  S6_R_TYPE    = 4'b0011,
                  S7_ALUWB     = 4'b1000,
                  S8_I_TYPE    = 4'b0100,
                  S9_JAL       = 4'b0101,
                  S10_BRANCH   = 4'B0111,
                  S11_JALR     = 4'b0110
                  } state;

logic branch_logic;
always_comb begin: pc_ena_logic
   //PC_ena = (zero & branch) | PC_update;
   PC_ena = branch | PC_update;
end

always_ff @(negedge clk) begin
   if(rst) begin
      state <= S0_FETCH;
   end else begin
      case(state)
        S0_FETCH : begin
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
           PC_update <= 0;
           alu_op <= 2'b00;
           case(op)
             OP_LTYPE: state <= S2_MEM_ADR;
             OP_STYPE: state <= S2_MEM_ADR;
             OP_RTYPE: state <= S6_R_TYPE;
             OP_ITYPE: state <= S8_I_TYPE;
             OP_JAL: state <= S9_JAL;
             OP_JALR: state <= S11_JALR;
             OP_BTYPE: state <= S10_BRANCH;
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
        S10_BRANCH : begin
           //branch <= (zero & ~funct3[0]) | (~zero & funct3[0]);
           case(funct3)
             FUNCT3_BEQ: branch <= zero & ~funct3[0];
             FUNCT3_BNE: branch <= ~zero & funct3[0];
           endcase
           alu_src_a <= ALUA_REG_FILE;
           alu_src_b <= ALUB_REGFILE;
           alu_op <= 2'b01;
           res_src <= alu_out;
           state <= S0_FETCH;
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
         FUNCT3_ADD: begin
           case({op[5],funct7[5]})
             2'b00: alu_control = ALU_ADD;
             2'b01: alu_control = ALU_ADD;
             2'b10: alu_control = ALU_ADD;
             2'b11: alu_control = ALU_SUB;
           endcase
         end
         FUNCT3_SLL: alu_control = ALU_SLL;
         FUNCT3_SLT: alu_control = ALU_SLT;
         FUNCT3_SLTU: alu_control = ALU_SLTU;
         FUNCT3_XOR: alu_control = ALU_XOR;
         FUNCT3_SHIFT_RIGHT: begin
           case(funct7[5])
           0: alu_control = ALU_SRL;
           1: alu_control = ALU_SRA;
           endcase
         end
         FUNCT3_OR: alu_control = ALU_OR;
         FUNCT3_AND: alu_control = ALU_AND;
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

// Non-architectural registers to hold state

// Instruction Reg
register #(.N(32)) INSTRUCTION_REGISTER(.rst(rst), .clk(clk),
                                        .ena(ir_write),
                                        .d(mem_rd_data),
                                        .q(instr));
// Data Reg
register #(.N(32)) DATA_REGISTER(.rst(rst), .clk(clk),
                                 .ena(1'b1),
                                 .d(mem_rd_data),
                                 .q(data));
// Register File Data Regs
register #(.N(32)) RFILE_DATA_A_REG(.rst(rst), .clk(clk),
                                    .ena(1'b1),
                                    .d(reg_data1),
                                    .q(data_a));
register #(.N(32)) RFILE_DATA_B_REG(.rst(rst), .clk(clk),
                                    .ena(1'b1),
                                    .d(reg_data2),
                                    .q(write_data));
// Result Reg
register #(.N(32)) ALU_RESULT_REG(.rst(rst), .clk(clk),
                                  .ena(1'b1),
                                  .d(alu_result),
                                  .q(alu_out));

endmodule
