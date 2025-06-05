#Makefile for AXI UVM Testbench

SIM        = vcs
TOP        = tb/tb_top.sv
TEST       ?= axi_virtual_test
SEED       ?= 123
OUT        = simv
COV        = 0

ifeq ($(COV), 1)
 COV_FLAGS = -cm line+cond+tgl+fsm+branch+assert+user
else
 COV_FLAGS = 
endif

COMPILE_OPTS = -full64 -sverilog +acc +vpi -debug_pp $(COV_FLAGS)
RUN_OPTS     = +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED)

.PHONY: all run cov clean help

all:
  $(SIM) $(COMPILE_OPTS) $(TOP) -o $(OUT)

run: all
  $(OUT) $(RUN_OPTS) 

cov:
  dve -cov -dir simv.vdb &

clean:
  rm -rf csrc simv* *.log *.key *.vdb ucli.key DVEfiles *.h *.daidir

help:
  @echo "Usage:"
  @echo "	make run TEST=<test_name> SEED=<seed> COV=1"
  @echo "	make cov #Launch coverage viewer"
  @echo "	make clean"
