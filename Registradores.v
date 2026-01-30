module Registradores(
    input wire clk,                  // <--- ADICIONADO: Sinal de Clock
    input wire [4:0] ReadRegister1,  // Endereço do registrador para leitura 1
    input wire [4:0] ReadRegister2,  // Endereço do registrador para leitura 2
    input wire [4:0] WriteRegister,  // Endereço do registrador para escrita
    input wire [31:0] WriteData,     // Dados a serem escritos
    input wire RegWrite,             // Habilitação de escrita
    output wire [31:0] ReadData1,    // Dados lidos do registrador 1
    output wire [31:0] ReadData2     // Dados lidos do registrador 2
);

    // Banco de registradores: 32 registradores de 32 bits
    reg [31:0] registers [31:0];

    // Inicialização (apenas para simulação)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;  // Zera todos
        end
    end

    // Leitura combinacional (Assíncrona - acontece o tempo todo)
    // O registrador 0 é hardcoded como zero no MIPS, mas sua inicialização já cuida disso.
    // Se quiser forçar zero na leitura: assign ReadData1 = (ReadRegister1 == 0) ? 0 : registers[ReadRegister1];
    assign ReadData1 = registers[ReadRegister1];
    assign ReadData2 = registers[ReadRegister2];

    // Escrita Síncrona (Acontece apenas na borda de subida do Clock)
    always @(posedge clk) begin
        // Escreve apenas se RegWrite estiver ativo E se não for o registrador $zero (0)
        if (RegWrite && (WriteRegister != 5'b0)) begin
            registers[WriteRegister] <= WriteData;
        end
    end

endmodule