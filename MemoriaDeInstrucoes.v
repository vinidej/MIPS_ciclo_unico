module MemoriaDeInstrucoes(
    input wire [31:0] addr,
    output wire [31:0] instrucao
);

    reg [31:0] memoria [255:0];
    integer i;

    initial begin
        // --- PROGRAMA: SOMATÓRIO DE 5 ATE 1 ---
        
        // 0. ADDI $t0, $zero, 0   (Inicializa SOMA = 0)
        // Hex: 20080000
        memoria[0] = 32'h20080000;

        // 1. ADDI $t1, $zero, 5   (Inicializa N = 5)
        // Hex: 20090005
        memoria[1] = 32'h20090005;

        // 2. ADDI $t2, $zero, 1   (Passo de decremento = 1)
        // Hex: 200A0001
        memoria[2] = 32'h200A0001;

        // --- LOOP START (Endereço Instr: 3) ---
        // 3. BEQ $t1, $zero, 3    (Se N == 0, pula 3 instruções para o FIM)
        // Offset = 3 (Pula instr 4, 5, 6 e cai na 7)
        // Hex: 11200003
        memoria[3] = 32'h11200003;

        // 4. ADD $t0, $t0, $t1    (Soma = Soma + N)
        // Hex: 01094020
        memoria[4] = 32'h01094020;

        // 5. SUB $t1, $t1, $t2    (N = N - 1)
        // Hex: 012A4822
        memoria[5] = 32'h012A4822;

        // 6. BEQ $zero, $zero, -4 (Pulo incondicional para LOOP START)
        // Offset = -4 (Volta para a instrução 3)
        // 0xFFFF = -1, 0xFFFC = -4
        // Hex: 1000FFFC
        memoria[6] = 32'h1000FFFC;

        // --- FIM ---
        // 7. SW $t0, 0($zero)     (Salva o resultado 15 na RAM, endereço 0)
        // Hex: AC080000
        memoria[7] = 32'hAC080000;

        // Limpa o resto
        for (i = 8; i < 256; i = i + 1) begin
            memoria[i] = 32'b0;
        end
    end

    assign instrucao = memoria[addr[9:2]];
endmodule