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
enum logic [2:0] {IMM_I_TYPE,
                  IMM_B_TYPE,
                  IMM_J_TYPE,
                  IMM_S_TYPE,
                  IMM_U_TYPE,
                  IMM_INVALID} imm_src;
enum logic [1:0] {ALUA_PC, ALUA_PC_OLD, ALUA_REG_FILE, ALUA_DC}      alu_src_a;
enum logic [1:0] {ALUB_REG_FILE, ALUB_IMMEDIATE, ALUB_FOUR, ALUB_DC} alu_src_b;
enum logic [1:0] {RES_DATA, RES_ALU_RESULT, RES_ALU_OUT, RES_DC}     res_src;
enum logic {POINTER, RES}                                            adr_src;

logic ir_write;

// Signals used internally for controller
logic       branch, PC_update;
logic [1:0] alu_op;

// Instruction signals decomposed
logic [24:0] imm_in;
logic [6:0]  funct7, op;
logic [2:0]  funct3;

always_comb begin : instr_decomp
   rs1    = instr[19:15];
   rs2    = instr[24:20];
   rd     = instr[11:7];
   imm_in = instr[31:7];
   funct7 = instr[31:25];
   funct3 = instr[14:12];
   op     = instr[6:0];
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
                  S10_BRANCH   = 4'b0111,
                  S11_JALR     = 4'b0110,
                  S15_ERROR    = 4'b1111
                  } state;

always_comb begin: pc_ena_logic
   //PC_ena = (zero & branch) | PC_update;
   PC_ena = branch | PC_update;
end

// CL for each control signal
always_comb begin : adr_src_logic
   case(state)
     S0_FETCH     : adr_src = POINTER;
     S3_MEM_READ  : adr_src = RES;
     S5_MEM_WRITE : adr_src = RES;
     default      : adr_src = POINTER;
   endcase
end

always_comb begin : mem_wr_ena_logic
   case(state)
     S5_MEM_WRITE : mem_wr_ena = 1;
     default      : mem_wr_ena = 0;
   endcase
end

always_comb begin : ir_write_logic
   case(state)
     S0_FETCH     : ir_write = 1;
     default      : ir_write = 0;
   endcase
end

always_comb begin : reg_write_logic
   case(state)
     S4_MEMWB     : reg_write = 1;
     S7_ALUWB     : reg_write = 1;
     default      : reg_write = 0;
   endcase
end

always_comb begin : alu_src_a_logic
   case(state)
     S0_FETCH     : alu_src_a = ALUA_PC;
     S1_DECODE    : alu_src_a = ALUA_PC_OLD;
     S2_MEM_ADR   : alu_src_a = ALUA_REG_FILE;
     S6_R_TYPE    : alu_src_a = ALUA_REG_FILE;
     S8_I_TYPE    : alu_src_a = ALUA_REG_FILE;
     S9_JAL       : alu_src_a = ALUA_PC_OLD;
     S10_BRANCH   : alu_src_a = ALUA_REG_FILE;
     S11_JALR     : alu_src_a = ALUA_REG_FILE;
     default      : alu_src_a = ALUA_DC;
   endcase
end

always_comb begin : alu_src_b_logic
   case(state)
     S0_FETCH     : alu_src_b = ALUB_FOUR;
     S1_DECODE    : alu_src_b = ALUB_IMMEDIATE;
     S2_MEM_ADR   : alu_src_b = ALUB_IMMEDIATE;
     S6_R_TYPE    : alu_src_b = ALUB_REG_FILE;
     S8_I_TYPE    : alu_src_b = ALUB_IMMEDIATE;
     S9_JAL       : alu_src_b = ALUB_IMMEDIATE;
     S10_BRANCH   : alu_src_b = ALUB_REG_FILE;
     S11_JALR     : alu_src_b = ALUB_IMMEDIATE;
     default      : alu_src_b = ALUB_DC;
   endcase
end

always_comb begin : alu_op_logic
   case(state)
     S0_FETCH     : alu_op = 2'b00;
     S1_DECODE    : alu_op = 2'b00;
     S2_MEM_ADR   : alu_op = 2'b00;
     S6_R_TYPE    : alu_op = 2'b10;
     S8_I_TYPE    : alu_op = 2'b10;
     S9_JAL       : alu_op = 2'b00;
     S10_BRANCH   : alu_op = 2'b11; // Special for just branching
     S11_JALR     : alu_op = 2'b00;
     default      : alu_op = 2'b00; // Don't Care
   endcase
end

// res_src    = RES_ALU_RESULT;
always_comb begin : res_src_logic
   case(state)
     S0_FETCH     : res_src = RES_ALU_RESULT;
     S3_MEM_READ  : res_src = RES_ALU_OUT;
     S4_MEMWB     : res_src = RES_DATA;
     S5_MEM_WRITE : res_src = RES_ALU_OUT;
     S7_ALUWB     : res_src = RES_ALU_OUT;
     S9_JAL       : res_src = RES_ALU_OUT;
     S10_BRANCH   : res_src = RES_ALU_OUT;
     default      : res_src = RES_DC; // Don't care
   endcase
end

always_comb begin : PC_update_logic
   case(state)
     S0_FETCH     : PC_update = 1;
     S9_JAL       : PC_update = 1;
     default      : PC_update = 0;
   endcase
end

always_comb begin : branch_logic
   case(state)
     S10_BRANCH   : case(funct3)
                      FUNCT3_BEQ  : branch =  equal;
                      FUNCT3_BNE  : branch = ~equal;
                      FUNCT3_BLT  : branch =  alu_result[0];
                      FUNCT3_BGE  : branch = ~alu_result[0];
                      FUNCT3_BLTU : branch =  alu_result[0];
                      FUNCT3_BGEU : branch = ~alu_result[0];
                      default     : branch = 0;
                    endcase
     default      : branch = 0;
   endcase
end

// Next state logic
always_ff @(negedge clk) begin
   if(rst) begin
      state <= S0_FETCH;
   end else begin
      case(state)
        S0_FETCH     : state <= S1_DECODE;
        S1_DECODE    : case(op)
                         OP_LTYPE : state <= S2_MEM_ADR;
                         OP_STYPE : state <= S2_MEM_ADR;
                         OP_RTYPE : state <= S6_R_TYPE;
                         OP_ITYPE : state <= S8_I_TYPE;
                         OP_JAL   : state <= S9_JAL;
                         OP_JALR  : state <= S11_JALR;
                         OP_BTYPE : state <= S10_BRANCH;
                         default  : state <= S15_ERROR;
                       endcase
        S2_MEM_ADR   : case(op)
                         OP_LTYPE : state <= S3_MEM_READ;
                         OP_STYPE : state <= S5_MEM_WRITE;
                         default  : state <= S15_ERROR;
                       endcase
        S3_MEM_READ  : state <= S4_MEMWB;
        S4_MEMWB     : state <= S0_FETCH;
        S5_MEM_WRITE : state <= S0_FETCH;
        S6_R_TYPE    : state <= S7_ALUWB;
        S7_ALUWB     : state <= S0_FETCH;
        S8_I_TYPE    : state <= S7_ALUWB;
        S9_JAL       : state <= S7_ALUWB;
        S10_BRANCH   : state <= S0_FETCH;
        S11_JALR     : state <= S9_JAL;
        S15_ERROR    : state <= S15_ERROR;
        default      : state <= S15_ERROR;
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
          FUNCT3_ADD : begin
             case({op[5],funct7[5]})
               2'b00  : alu_control = ALU_ADD;
               2'b01  : alu_control = ALU_ADD;
               2'b10  : alu_control = ALU_ADD;
               2'b11  : alu_control = ALU_SUB;
             endcase
          end
          FUNCT3_SLL  : alu_control = ALU_SLL;
          FUNCT3_SLT  : alu_control = ALU_SLT;
          FUNCT3_SLTU : alu_control = ALU_SLTU;
          FUNCT3_XOR  : alu_control = ALU_XOR;
          FUNCT3_SHIFT_RIGHT : begin
             case(funct7[5])
               0      : alu_control = ALU_SRL;
               1      : alu_control = ALU_SRA;
             endcase
          end
          FUNCT3_OR   : alu_control = ALU_OR;
          FUNCT3_AND  : alu_control = ALU_AND;
       endcase
     end
     2'b11: begin // Branching
        case(funct3)
          FUNCT3_BEQ  : alu_control = ALU_SUB;
          FUNCT3_BNE  : alu_control = ALU_SUB;
          FUNCT3_BLT  : alu_control = ALU_SLT;
          FUNCT3_BGE  : alu_control = ALU_SLT;
          FUNCT3_BLTU : alu_control = ALU_SLTU;
          FUNCT3_BGEU : alu_control = ALU_SLTU;
          default     : alu_control = ALU_INVALID;
        endcase
     end
     default: alu_control = ALU_INVALID; // Don't care
   endcase
end

// Instr Decoder (CL)
always_comb begin : instr_decoder
   case(op)
     OP_LTYPE : imm_src = IMM_I_TYPE;
     OP_ITYPE : imm_src = IMM_I_TYPE;
     OP_JALR  : imm_src = IMM_I_TYPE;
     OP_STYPE : imm_src = IMM_S_TYPE;
     OP_BTYPE : imm_src = IMM_B_TYPE;
     OP_JAL   : imm_src = IMM_J_TYPE;
     OP_LUI   : imm_src = IMM_U_TYPE;
     OP_AUIPC : imm_src = IMM_U_TYPE;
     default  : imm_src = IMM_INVALID;
   endcase
end

//Multicycle Core

// Hardware write_data to mem_wr_data
always_comb mem_wr_data = write_data;

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
     IMM_INVALID: imm_ext = 32'b0;
     default    : imm_ext = 32'b0;
   endcase
end

// ALU A
always_comb begin : alu_a
   case (alu_src_a)
     ALUA_PC       : src_a = PC;
     ALUA_PC_OLD   : src_a = PC_old;
     ALUA_REG_FILE : src_a = data_a;
     ALUA_DC       : src_a = 0;
     default       : src_a = 0;
   endcase
end

// ALU B
always_comb begin : alu_b
   case (alu_src_b)
     ALUB_REG_FILE  : src_b = write_data;
     ALUB_IMMEDIATE : src_b = imm_ext;
     ALUB_FOUR      : src_b = 4;
     ALUB_DC        : src_b = 0;
     default        : src_b = 0;
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
