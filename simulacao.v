`timescale 1ns / 1ps
`include "CPU.v"

module simulacao; // Nome padronizado

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

    // Teste
    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, simulacao);

        $display("--- Inicio da Simulacao ---");
        
        // Sequencia de Reset Correta
        reset = 1; // Reseta o PC para 0
        #10;
        reset = 0; // Solta o processador

        #200; // Tempo de execucao

        $display("--- Fim da Simulacao ---");
        $finish;
    end

    // Monitoramento (Debug)
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time: %3d | PC: %d | Instr: %h | ResultALU: %d", 
                     $time, uut.pc, uut.instruction, uut.alu_result);
        end
    end

endmodule