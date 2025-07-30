# Makefile for compiling and running VHDL testbench with GHDL

# Files
VHDL_SOURCES = calc_multi.vhdl calc_multi_tb.vhdl alu.vhdl counter.vhdl reg.vhdl
TOP_ENTITY = calc_multi_tb
VCD_FILE = calc_multi_sim.vcd

# Default target
all: run

# Analyze VHDL files
analyze:
	ghdl -a alu.vhdl
	ghdl -a counter.vhdl
	ghdl -a reg.vhdl
	ghdl -a calc_multi.vhdl
	ghdl -a calc_multi_tb.vhdl

# Elaborate the testbench
elaborate: analyze
	ghdl -e $(TOP_ENTITY)

# Run the simulation and generate VCD
run: elaborate
	ghdl -r $(TOP_ENTITY) --vcd=$(VCD_FILE)

# Clean build files
clean:
	rm -f *.o *.cf $(TOP_ENTITY) $(VCD_FILE)

.PHONY: all analyze elaborate run clean
