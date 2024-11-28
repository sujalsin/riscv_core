# RISC-V Core Implementation

A basic RISC-V processor core implementation supporting the RV32I instruction set. This project implements a single-cycle processor with full support for integer operations, memory access, and control flow instructions.

## Architecture Overview

```
                                    RISC-V Core
+--------------------------------------------------------------------------------+
|                                                                                |
|                     +------------+          +--------------+                    |
|                     |            |          |              |                    |
|         +---------->| Instr Mem  |--------->|   Decoder    |                   |
|         |          |            |          |              |                    |
|         |          +------------+          +--------------+                    |
|    +----+----+                                    |                            |
|    |         |                                    v                            |
|    |   PC    |                            +--------------+                     |
|    |         |                            |              |                     |
|    +----+----+                            |   Control    |                     |
|         ^                                 |    Unit      |                     |
|         |                                 |              |                     |
|         |                                 +--------------+                     |
|         |                                       |                              |
|         |                                       v                              |
|    +----+----+     +--------------+     +--------------+     +------------+   |
|    |         |     |              |     |              |     |            |   |
|    | Next PC |<----| Branch/Jump  |<----| Register File|<--->|    ALU     |   |
|    |  Logic  |     |   Control    |     |              |     |            |   |
|    +---------+     +--------------+     +--------------+     +------------+   |
|                                               ^                    |          |
|                                               |                    v          |
|                                         +------------+       +------------+   |
|                                         |            |       |            |   |
|                                         | Data Mem   |<----->| Mem Access |   |
|                                         |            |       |            |   |
|                                         +------------+       +------------+   |
|                                                                             |
+-----------------------------------------------------------------------------+
```

## Project Structure
- `src/`: RTL design files
  - `riscv_core.sv`: Top-level processor core
  - `alu.sv`: Arithmetic Logic Unit
  - `register_file.sv`: Register File
  - `control_unit.sv`: Control Unit
  - `instruction_decoder.sv`: Instruction Decoder
- `tb/`: Testbench files
  - `riscv_core_tb.sv`: Main testbench
  - `instruction_memory.sv`: Instruction memory model
  - `data_memory.sv`: Data memory model
- `sim/`: Simulation files and scripts
- `build/`: Build artifacts

## Features
- RV32I base integer instruction set
- Single-cycle implementation
- 32 general-purpose registers
- 4KB instruction memory
- 4KB data memory
- Support for all basic instruction types:
  - R-type: Register-Register operations
  - I-type: Immediate operations
  - S-type: Store operations
  - B-type: Branch operations
  - U-type: Upper immediate operations
  - J-type: Jump operations

## Instruction Pipeline
```
Fetch → Decode → Execute → Memory → Writeback
```

1. **Fetch**: PC → Instruction Memory → Instruction
2. **Decode**: Instruction → Control Signals + Register Values
3. **Execute**: ALU Operation + Branch/Jump Decision
4. **Memory**: Load/Store Operations
5. **Writeback**: Update Register File

## Supported Instructions
- Arithmetic: ADD, SUB, ADDI
- Logical: AND, OR, XOR, ANDI, ORI, XORI
- Shifts: SLL, SRL, SRA, SLLI, SRLI, SRAI
- Comparison: SLT, SLTU, SLTI, SLTIU
- Memory: LW, SW
- Control Flow: BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jumps: JAL, JALR

## Building and Running
Prerequisites:
- Verilator (for simulation)
- GTKWave (for viewing waveforms)
- Make

Commands:
```bash
# Run simulation
make sim

# View waveforms
make wave

# Clean build artifacts
make clean
```

## Test Program
The testbench includes a simple test program that verifies:
1. Immediate value loading
2. Arithmetic operations
3. Memory access
4. Branch and jump functionality

Example test sequence:
```
# Test program sequence
addi x1, x0, 10          # x1 = 10
addi x2, x0, 20          # x2 = 20
add  x3, x1, x2          # x3 = x1 + x2 = 30
sub  x4, x2, x1          # x4 = x2 - x1 = 10
and  x5, x1, x2          # x5 = x1 & x2
or   x6, x1, x2          # x6 = x1 | x2
xor  x7, x1, x2          # x7 = x1 ^ x2
slt  x8, x1, x2          # x8 = (x1 < x2) ? 1 : 0
sw   x3, 0(x0)           # Store x3 to memory[0]
lw   x9, 0(x0)           # Load memory[0] into x9
```

## Simulation Output
The testbench provides detailed output including:
- Register file updates
- Memory access operations
- Final register values
- Memory contents
- VCD waveform for detailed analysis

## Future Enhancements
- Pipeline implementation
- Branch prediction
- Cache implementation
- Privilege levels
- Interrupts and exceptions
- RV32M extension (multiplication/division)
- RV32F extension (single-precision floating-point)
