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
             pc, old_pc,
             adr,
             read_data, write_data,
             instr, data,
             imm_ext,
             a, write_data,
             alu_out;

// Signals from controller
// enum logic {MEM_SRC_PC, MEM_SRC_RESULT} mem_src;
enum logic {IMM_I_TYPE, IMM_B_TYPE, IMM_J_TYPE, IMM_S_TYPE, IMM_U_TYPE} imm_src;
enum logic {ALUA_PC, ALUA_OLD_PC, ALUA_REG_FILE}            alu_src_a;
enum logic {ALUB_REGFILE, ALUB_IMMEDIATE, ALUB_FOUR}        alu_src_b;
enum logic {RES_DATA, RES_ALU_RESULT, RES_ALU_OUT}          res_src;

logic pc_write, adr_src, mem_write, ir_write, reg_write;

// Signals used internally for controller
logic       branch, pc_update;
logic [1:0] alu_op;

// Instruction signals decomposed 
logic [24:0] imm_in;
logic [6:0] funct7, op;
logic [2:0] funct3;

always_comb : begin : instr_decomp
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
logic [1:0] ALUop
always_ff @(negedge clk) : begin

end

// ALU Decoder (CL)
//logic [2:0] ALU_control; 
always_comb : begin : ALU_decoder
case(ALUop)
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
always_comb : begin : Instr_decoder
if (~op[6:2] | (~op[6:5] & op[4] & ~op[3:2]) | (op[6:5] & ~op[4:3] & op[2])) : Immext
end

//Multicycle Core 

// Read Address (CL)
always_comb : begin : address_read

end

// Immediate Extension
always_comb : begin : imm_ext

end

// ALU A
always_comb : begin : alu_a
   case (alu_src_a)
     ALUA_PC       : src_a = pc;
     ALUA_OLD_PC   : src_a = old_pc;
     ALUA_REG_FILE : src_a = a;
     default       : src_a = 0;
   endcase
end

// ALU B
always_comb : begin : alu_b
   case (alu_src_b)
     ALUB_REGFILE   : src_b = write_data;
     ALUB_IMMEDIATE : src_b = imm_ext;
     ALUB_FOUR      : src_b = 4;
     default        : src_b = 4;
   endcase
end

// Results
always_comb : begin : result
   case (res_src)
     RES_DATA       : result = data;
     RES_ALU_RESULT : result = alu_result;
     RES_ALU_OUT    : result = alu_out;
     default        : result = 0;
   endcase
end

endmodule
