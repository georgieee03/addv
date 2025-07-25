LOG_LEVEL ?= 2

# Location of the reference UVM installation; override from the shell if needed
UVM_HOME ?= $(VCS_HOME)/verilog_src/uvm-1.2
UVM_INC  := +incdir+$(UVM_HOME)/src

# Common compile flags
COMP_FLAGS = -full64 -sverilog -ntb_opts uvm +define+DUMP=1 -debug_access+all -kdb \
             -timescale=1ns/1ps +plusarg_save +log_level=$(LOG_LEVEL) \
             $(UVM_INC) +define+UVM +incdir+../uvm_pkg

# Source files
SRC_RTL  = ../../src/*.sv
SRC_PKG  = ../uvm_pkg/uvm_pkg.svh
TB_TOP   = ../tb/tb_async_fifo_uvm.sv

all: sim verdi

compile: clean
	@echo "=== Compiling ==="
	${VCS_HOME}/bin/vcs $(COMP_FLAGS) \
		$(SRC_RTL) \
		$(SRC_PKG) \
		$(TB_TOP) \
	-l compile.log

sim: compile
	@echo "=== Running simulation ==="
	./simv |& tee sim.log

compile_bug: clean
	@echo "=== Compiling (BUGGED) ==="
	${VCS_HOME}/bin/vcs $(COMP_FLAGS) +define+BUGGED \
		$(SRC_RTL) \
		$(SRC_PKG) \
		$(TB_TOP) \
	-l compile.log

sim_bug: compile_bug
	@echo "=== Running simulation (BUGGED) ==="
	./simv |& tee sim.log

verdi:
	@echo "=== Launching Verdi ==="
	${VERDI_HOME}/bin/verdi -dbdir ./simv.daidir -ssf novas.fsdb -nologo &

clean:
	rm -rf simv csrc simv.daidir *.fsdb novas* *.key *.log verdi*

.PHONY: all clean compile compile_bug sim sim_bug verdi 