module ALUControl(
    input wire [1:0] ALUOp,       // Vem da ControlUnit (00=LW/SW, 01=BEQ, 10=R-Type)
    input wire [5:0] Funct,       // Vem da instrução (bits 5-0)
    output reg [3:0] ALUCtl       // Vai para a ALU (4 bits para casar com sua ALU)
);

    always @(*) begin
        case (ALUOp)
            // ------------------------------------------------
            // 1. Instruções de Acesso à Memória (LW, SW)
            // A ALU precisa somar o registrador base + deslocamento
            // ------------------------------------------------
            2'b00: ALUCtl = 4'b0010; // Envia código de SOMA (ADD) para ALU

            // ------------------------------------------------
            // 2. Instrução de Desvio (BEQ)
            // A ALU subtrai para verificar se (A - B) == 0
            // ------------------------------------------------
            2'b01: ALUCtl = 4'b0110; // Envia código de SUBTRAÇÃO (SUB) para ALU

            // ------------------------------------------------
            // 3. Instruções Tipo-R (ADD, SUB, AND, OR, SLT, NOR)
            // O código exato depende do campo 'Funct'
            // ------------------------------------------------
            2'b10: begin
                case (Funct)
                    6'b100000: ALUCtl = 4'b0010; // add -> SOMA
                    6'b100010: ALUCtl = 4'b0110; // sub -> SUBTRAÇÃO
                    6'b100100: ALUCtl = 4'b0000; // and -> AND
                    6'b100101: ALUCtl = 4'b0001; // or  -> OR
                    6'b101010: ALUCtl = 4'b0111; // slt -> SLT
                    6'b100111: ALUCtl = 4'b1100; // nor -> NOR
                    default:   ALUCtl = 4'b0000; // Default seguro
                endcase
            end

            // Caso padrão
            default: ALUCtl = 4'b0000;
        endcase
    end
endmodule