module ControlUnit(
    input wire [5:0] Opcode,      // Bits 31-26 da instrução
    output reg RegDst,            // Escolhe destino: 0=rt, 1=rd
    output reg Branch,            // 1 se for instrução de desvio (BEQ)
    output reg MemRead,           // 1 se for ler da memória (LW)
    output reg MemToReg,          // 0=ALU, 1=Memória
    output reg [1:0] ALUOp,       // 00=LW/SW, 01=BEQ, 10=R-Type
    output reg MemWrite,          // 1 se for escrever na memória (SW)
    output reg ALUSrc,            // 0=RegB, 1=Imediato
    output reg RegWrite           // 1 se for escrever no Banco de Registradores
);

    always @(*) begin
        // Zera todos os sinais para evitar latch, depois ativa os necessários
        {RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 9'b0;

        case (Opcode)
            // --- Tipo R (ADD, SUB, AND, OR, SLT) ---
            // Opcode: 000000
            6'b000000: begin
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end

            // --- Load Word (LW) ---
            // Opcode: 100011 (35 decimal)
            6'b100011: begin
                ALUSrc   = 1'b1;
                MemToReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 2'b00;
            end

            // --- Store Word (SW) ---
            // Opcode: 101011 (43 decimal)
            6'b101011: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end

            // --- Branch Equal (BEQ) ---
            // Opcode: 000100 (4 decimal)
            6'b000100: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            
            // Adicione outros opcodes (ex: ADDI, JUMP) aqui se necessário
            
        endcase
    end
endmodule