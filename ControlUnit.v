module ControlUnit(
    input wire [5:0] Opcode,
    output reg RegDst,
    output reg Branch,
    output reg MemRead,
    output reg MemToReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);

    always @(*) begin
        // Zera tudo por padrão
        {RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 9'b0;

        case (Opcode)
            // R-Type
            6'b000000: begin
                RegDst = 1'b1;
                RegWrite = 1'b1;
                ALUOp = 2'b10;
            end
            // LW
            6'b100011: begin
                ALUSrc = 1'b1;
                MemToReg = 1'b1;
                RegWrite = 1'b1;
                MemRead = 1'b1;
                ALUOp = 2'b00;
            end
            // SW
            6'b101011: begin
                ALUSrc = 1'b1;
                MemWrite = 1'b1;
                ALUOp = 2'b00;
            end
            // BEQ
            6'b000100: begin
                Branch = 1'b1;
                ALUOp = 2'b01;
            end
            // --- NOVO: ADDI (Opcode 001000) ---
            // Funciona quase igual ao LW, mas escreve o resultado da ALU (não da memória)
            6'b001000: begin
                ALUSrc = 1'b1;      // Usa o imediato (número constante)
                RegWrite = 1'b1;    // Escreve no registrador
                ALUOp = 2'b00;      // Operação de SOMA (igual LW/SW)
                // MemToReg fica 0 (pega da ALU), RegDst fica 0 (grava em rt)
            end
        endcase
    end
endmodule