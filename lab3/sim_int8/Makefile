all: sim verdi

compile: clean
	@echo "=== Compiling ==="
	${VCS_HOME}/bin/vcs -full64 -sverilog +define+DUMP=1 -debug_access+all -kdb -timescale=1ns/1ps \
		../src/params.sv \
		../src/int8_matmul.sv \
		../src/int8_matmul_with_ram.sv \
		../src/output_logic.sv \
		../src/ram.sv \
		../src/seq_mac.sv \
		../src/systolic_data_setup.sv \
		../tb/int8_matmul_tb.sv \
	-l compile.log

sim: compile
	@echo "=== Running simulation ==="
	./simv |& tee sim.log

verdi:
	@echo "=== Launching Verdi ==="
	${VERDI_HOME}/bin/verdi -dbdir ./simv.daidir -ssf novas.fsdb -nologo &

clean:
	rm -rf simv csrc simv.daidir *.fsdb novas* *.key *.log verdi*

.PHONY: all clean compile sim verdi
