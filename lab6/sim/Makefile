all: sim verdi

compile: clean
	${VCS_HOME}/bin/vcs -full64 -sverilog -debug_access+all -kdb \
		-timescale=1ns/1ps \
		-ntb_opts uvm \
		+plusarg_save \
		+define+DUMP=1 \
		+UVM_CONFIG_DB_TRACE \
		+UVM_PHASE_TRACE \
		+UVM_OBJECTION_TRACE \
		+UVM_VERBOSITY=UVM_HIGH \
		+incdir+../src/common \
		+incdir+../src/master \
		+incdir+../src/slave \
		+incdir+../tb \
		../src/*.sv \
		../src/common/apb_if.sv \
		../src/common/apb_common_pkg.sv \
		../src/master/apb_master_pkg.sv \
		../src/slave/apb_slave_pkg.sv \
		../src/matmul/*.sv \
		../tb/matmul_tb.sv \
	-l compile.log

sim: compile
	./simv |& tee sim.log

verdi:
	${VERDI_HOME}/bin/verdi -dbdir ./simv.daidir -ssf novas.fsdb -nologo &

clean:
	rm -rf simv csrc simv.daidir *.fsdb novas* *.key *.log verdi*

.PHONY: all clean compile sim verdi
