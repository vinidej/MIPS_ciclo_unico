`timescale 1ns / 1ps
`include "CPU.v"

module simulacao;

    reg clk;
    reg reset;

    CPU uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Configuração e Reset
    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, simulacao);

        // Sequencia de Reset
        reset = 1; 
        #10;
        reset = 0; 
        
        // Timeout de segurança (caso entre em loop infinito)
        #500; 
        $display("Simulacao encerrada por tempo limite.");
        $finish;
    end

    always @(posedge clk) begin
        if (!reset) begin
            // Caso 1: Detecta a instrução de soma dentro do loop (ADD $t0, $t0, $t1)y
            if (uut.pc == 32'd16) begin
                // O valor que está sendo somado (o contador $t1) está entrando na ALU
                // via read_data_2 neste momento.
                $display("Somando o numero: %d", uut.read_data_2);
            end

            // Caso 2: Detecta a instrução FINAL (SW $t0, 0($zero))
            // Sabemos que ela está no endereço 28 (0x1C)
            if (uut.pc == 32'd28) begin
                $display("-----------------------------------------");
                // No comando SW, o valor a ser salvo ($t0) sai pelo read_data_2
                $display("SOMATORIO CALCULADO COMPLETO: %d", uut.read_data_2);
                $display("-----------------------------------------");
                $finish; // Encerra a simulação com sucesso
            end
        end
    end

endmodule