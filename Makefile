STA_HOME = $(abspath ./yosys-sta)
RTL_HOME = $(abspath ./rtl)

export DESIGN    = ysyx_23060001
export SDC_FILE  = $(abspath ./npc.sdc)
export RTL_FILES = $(shell find $(abspath ./rtl) -name "*.v" -or -name "*.sv")
export VERILOG_INCLUDE_DIRS = $(RTL_HOME)/include

sta:
	make -C $(STA_HOME) -e -f $(STA_HOME)/Makefile sta
clean:
	make -C $(STA_HOME) -e -f $(STA_HOME)/Makefile clean 
.PHONY: sta