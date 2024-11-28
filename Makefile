# Makefile for RISC-V Core simulation

# Tools
VERILATOR = verilator
VERILATOR_FLAGS = --trace --timing -Wall -Wno-UNUSED
GTKWAVE = gtkwave

# Directories
SRC_DIR = src
TB_DIR = tb
BUILD_DIR = build
SIM_DIR = sim

# Source files
RTL_SRCS = $(SRC_DIR)/riscv_core.sv \
           $(SRC_DIR)/alu.sv \
           $(SRC_DIR)/register_file.sv \
           $(SRC_DIR)/instruction_decoder.sv \
           $(SRC_DIR)/control_unit.sv

TB_SRCS = $(TB_DIR)/riscv_core_tb.sv \
          $(TB_DIR)/instruction_memory.sv \
          $(TB_DIR)/data_memory.sv

# Targets
.PHONY: all clean sim wave

all: sim

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(SIM_DIR):
	mkdir -p $(SIM_DIR)

sim: $(BUILD_DIR) $(SIM_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) \
		--prefix Vriscv_core \
		--top-module riscv_core_tb \
		--exe --build $(RTL_SRCS) $(TB_SRCS) \
		-o $(BUILD_DIR)/Vriscv_core
	$(BUILD_DIR)/Vriscv_core

wave: $(SIM_DIR)/riscv_core_tb.vcd
	$(GTKWAVE) $(SIM_DIR)/riscv_core_tb.vcd &

clean:
	rm -rf $(BUILD_DIR) $(SIM_DIR)
