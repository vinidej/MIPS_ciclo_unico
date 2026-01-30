# ==========================================
# Makefile para CPU MIPS Single Cycle
# ==========================================

# Ferramentas
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Arquivo principal (Testbench)
# Como simulacao.v faz 'include "CPU.v"', basta compilar ele.
DUT = simulacao.v

# Nome do executável compilado
EXEC = cpu_sim

# Nome do arquivo de onda gerado
# ATENÇÃO: Isso deve ser IGUAL ao nome dentro do $dumpfile("cpu_wave.vcd") no Verilog
VCD = cpu_wave.vcd

# Regras "phony" (não são arquivos reais)
.PHONY: all sim run view clean

# --- Fluxo Principal ---
# Ao digitar 'make', ele fará tudo na ordem: limpar -> compilar -> rodar -> visualizar
all: clean sim run view

# 1. Compilação
sim: $(DUT)
	@echo "--- Compilando a CPU e Testbench ---"
	$(IVERILOG) -o $(EXEC) $(DUT)

# 2. Execução (Geração do VCD)
run: $(EXEC)
	@echo "--- Rodando a Simulação ---"
	$(VVP) $(EXEC)

# 3. Visualização
view: $(VCD)
	@echo "--- Abrindo GTKWave ---"
	$(GTKWAVE) $(VCD)

# Limpeza
clean:
	@echo "--- Limpando arquivos antigos ---"
	rm -f $(EXEC) $(VCD)