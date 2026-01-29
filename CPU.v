`timescale 1ns / 1ps
`include "Add4.v"
`include "Adder32.v"
`include "ALU.v"
`include "DataMemory.v"
`include "MemoriaDeInstrucoes.v"
`include "Registradores.v"
`include "ShiftLeft2.v"
`include "SignalExtend.v"

module CPU (
    input clk,
    input reset
);

    // ==========================================
    // 1. FIOS E SINAIS DE CONTROLE
    // ==========================================
    
    // --- PC e Instrução ---
    reg [31:0] pc;              // O registrador PC deve ser declarado aqui
    wire [31:0] pc_next;        // O próximo valor do PC (decisão entre PC+4 e Branch)
    wire [31:0] pc_plus_4;
    wire [31:0] instruction;

    // --- Sinais de Controle (Wires aguardando sua Control Unit) ---
    wire reg_dst;
    wire branch;
    wire mem_read;
    wire mem_to_reg;
    wire [3:0] alu_op;          // CORREÇÃO: Sua ALU pede 4 bits 
    wire mem_write;
    wire alu_src;
    wire reg_write;

    // --- Dados e Endereços ---
    wire [4:0]  write_register_addr;
    wire [31:0] write_data_reg;
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;
    wire [31:0] sign_extended;
    
    wire [31:0] alu_input_b;
    wire [31:0] alu_result;
    wire zero_flag;
    
    wire [31:0] mem_read_data;
    
    // --- Branch ---
    wire [31:0] branch_offset_shifted;
    wire [31:0] branch_target;
    wire pc_src; // Sinal lógico para o multiplexador do PC

    // ==========================================
    // 2. LÓGICA DO PC (Fetch Stage Manual)
    // ==========================================
    // Implementado aqui manualmente porque a sua FetchUnit.v não aceita branch.
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

    // ==========================================
    // 3. INSTANCIAÇÃO DOS MÓDULOS
    // ==========================================

    // --- Memória de Instruções ---
    MemoriaDeInstrucoes InstrMem (
        .addr(pc),              // Conecta ao PC atual
        .instrucao(instruction) // Sai a instrução [cite: 59]
    );

    // --- Somador PC + 4 ---
    Add4 PCAdder (
        .in(pc),                // [cite: 1]
        .out(pc_plus_4)
    );

    // --- Decodificação e Registradores ---
    
    // Mux para definir registrador de escrita (Rt ou Rd)
    assign write_register_addr = (reg_dst) ? instruction[15:11] : instruction[20:16];

    Registradores RegFile (
        // ATENÇÃO: Seu arquivo Registradores.v NÃO tem porta de Clock 
        .ReadRegister1(instruction[25:21]), 
        .ReadRegister2(instruction[20:16]), 
        .WriteRegister(write_register_addr),
        .WriteData(write_data_reg), 
        .RegWrite(reg_write), 
        .ReadData1(read_data_1), 
        .ReadData2(read_data_2)
    );

    // Extensão de Sinal (Sign Extend)
    SignExtend Extend (        // Nome do módulo é SignExtend, não SignalExtend 
        .in(instruction[15:0]),
        .out(sign_extended)
    );

    // --- Execução (ALU) ---

    // Mux da ALU (Imediato vs Registrador)
    assign alu_input_b = (alu_src) ? sign_extended : read_data_2;

    ALU MainALU (
        .A(read_data_1),
        .B(alu_input_b),
        .ALUOperation(alu_op),  // Conecta 4 bits 
        .ALUResult(alu_result),
        .Zero(zero_flag)
    );

    // --- Cálculo de Endereço de Branch ---
    
    ShiftLeft2 Shifter (
        .in(sign_extended),
        .out(branch_offset_shifted) // [cite: 77]
    );

    Adder32 BranchAdder (
        .a(pc_plus_4),
        .b(branch_offset_shifted),
        .sum(branch_target)     // Nome da porta é .sum [cite: 3]
    );

    // --- Memória de Dados ---

    DataMemory DataMem (
        .clk(clk),              // Este módulo possui clock [cite: 44]
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .address(alu_result),
        .writeData(read_data_2),
        .readData(mem_read_data)
    );

    // --- Write Back ---

    // Mux MemToReg
    assign write_data_reg = (mem_to_reg) ? mem_read_data : alu_result;


    // ==========================================
    // 4. LÓGICA DE PRÓXIMO PC
    // ==========================================
    
    // Porta AND para decidir o Branch (Branch ativado E ALU Zero)
    assign pc_src = branch & zero_flag;

    // Mux do PC
    assign pc_next = (pc_src) ? branch_target : pc_plus_4;

endmodule