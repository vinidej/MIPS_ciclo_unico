`timescale 1ns / 1ps
`include "Add4.v"
`include "Adder32.v"
`include "ALU.v"
`include "DataMemory.v"
`include "MemoriaDeInstrucoes.v"
`include "Registradores.v"
`include "ShiftLeft2.v"
`include "SignalExtend.v"
`include "ALUControl.v"
`include "ControlUnit.v"

module CPU (
    input clk,
    input reset
);

    // ==========================================
    // 1. DECLARAÇÃO DE FIOS (WIRES) INTERNOS
    // ==========================================

    // --- PC e Instrução ---
    reg [31:0] pc;
    wire [31:0] pc_next, pc_plus_4;
    wire [31:0] instruction;

    // --- Sinais da Unidade de Controle Principal ---
    wire reg_dst, branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [1:0] alu_op_main; // Sinais de controle para a ALU Control

    // --- Sinais da ALU Control ---
    wire [3:0] alu_control_fio; // Operação final de 4 bits para a ALU 

    // --- Dados e Endereços ---
    wire [4:0]  write_register_mux;
    wire [31:0] write_data_reg_mux;
    wire [31:0] read_data_1, read_data_2;
    wire [31:0] sign_extended;
    wire [31:0] alu_input_b_mux;
    wire [31:0] alu_result;
    wire zero_flag;
    wire [31:0] mem_read_data;
    
    // --- Lógica de Branch ---
    wire [31:0] branch_offset_shifted;
    wire [31:0] branch_target;
    wire pc_src;

    // ==========================================
    // 2. LÓGICA DO REGISTRADOR PC
    // ==========================================
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

    // ==========================================
    // 3. INSTANCIAÇÃO DOS MÓDULOS (CONEXÕES)
    // ==========================================

    // --- Estágio FETCH ---
    MemoriaDeInstrucoes InstrMem (
        .addr(pc),
        .instrucao(instruction)
    );

    Add4 PC_Plus_4_Adder (
        .in(pc),
        .out(pc_plus_4)
    );

    // --- Unidade de Controle Principal ---
    // Decodifica o Opcode (bits 31-26)
    // --- Unidade de Controle Principal ---
    ControlUnit MainControl (
        .Opcode(instruction[31:26]),  // Maiúscula
        .RegDst(reg_dst),               // Maiúscula
        .Branch(branch),                // Maiúscula
        .MemRead(mem_read),             // Maiúscula
        .MemToReg(mem_to_reg),          // Maiúscula
        .ALUOp(alu_op_main),            // Maiúscula
        .MemWrite(mem_write),           // Maiúscula
        .ALUSrc(alu_src),               // Maiúscula
        .RegWrite(reg_write)            // Maiúscula
    );

    // --- Estágio DECODE ---
    // MUX RegDst: Escolhe entre bits 20-16 (Rt) ou 15-11 (Rd) [cite: 31]
    assign write_register_mux = (reg_dst) ? instruction[15:11] : instruction[20:16];

    Registradores RegFile (
        .ReadRegister1(instruction[25:21]),
        .ReadRegister2(instruction[20:16]),
        .WriteRegister(write_register_mux),
        .WriteData(write_data_reg_mux),
        .RegWrite(reg_write),
        .ReadData1(read_data_1),
        .ReadData2(read_data_2)
    );

    SignalExtend Extender (
        .in(instruction[15:0]),
        .out(sign_extended)
    );

    // --- Estágio EXECUTE ---
    // ALU Control: Usa ALUOp do controle e Funct (bits 5-0) da instrução
    // --- Estágio EXECUTE ---
    ALUControl AC_Unit (
        .ALUOp(alu_op_main),         // Nome corrigido (Maiúscula)
        .Funct(instruction[5:0]),    // Nome corrigido (Maiúscula)
        .ALUCtl(alu_control_fio)     // Nome corrigido (era alu_control)
    );

    // MUX ALUSrc: Escolhe entre ReadData2 ou Imediato Estendido [cite: 34]
    assign alu_input_b_mux = (alu_src) ? sign_extended : read_data_2;

    ALU MainALU (
        .A(read_data_1), 
        .B(alu_input_b_mux),
        .ALUOperation(alu_control_fio),
        .ALUResult(alu_result),
        .Zero(zero_flag)
    );

    // Lógica de Endereço de Branch
    ShiftLeft2 Shifter (
        .in(sign_extended),
        .out(branch_offset_shifted)
    );

    Adder32 BranchAddrAdder (
        .a(pc_plus_4),
        .b(branch_offset_shifted),
        .sum(branch_target)
    );

    // --- Estágio MEMORY ---
    DataMemory MemData (
        .clk(clk),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .address(alu_result),
        .writeData(read_data_2),
        .readData(mem_read_data)
    );

    // Lógica do Próximo PC (Mux de Branch)
    assign pc_src = branch & zero_flag;
    assign pc_next = (pc_src) ? branch_target : pc_plus_4;

    // --- Estágio WRITE BACK ---
    // MUX MemToReg: Escolhe entre Dado da Memória ou Resultado da ALU [cite: 41]
    assign write_data_reg_mux = (mem_to_reg) ? mem_read_data : alu_result;

endmodule