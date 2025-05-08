# Digital Circuit and System - Lab08: SRAM Controller Design

**Institute of Electronics, NYCU**  
**NYCU CERES LAB**  
**May 8, 2024**

## Introduction

This lab focuses on designing an SRAM controller to handle memory read and write operations using a single-port SRAM block. Students will collect input data, aggregate it, and manage SRAM access while satisfying timing and synthesis constraints.

## SRAM Overview

- **Single-port SRAM**: Supports either a read or write in a single cycle, not both.
- **Memory size**: 64 (depth) × 32 (width)
- **Access constraints**:
  - Only one address can be accessed per cycle.
  - Registers are recommended before and after the SRAM macro to reduce timing issues.

## Project Description

### Write Operation:
- Input is an 8-bit stream arriving continuously for 256 clock cycles.
- Every 4 bytes are grouped into a 32-bit word and stored in SRAM.
- Total data fills all 64 locations of the 64×32 SRAM.

### Read Operation:
- Once all data is written, `PATTERN.v` provides an address.
- The circuit must read and output the 32-bit value stored at that address.
- The read data must pass through a register and be output in the next clock cycle.

### Data Packing Format:
SRAM_in = {Data3, Data2, Data1, Data0}
Cycle 1: Data0
Cycle 2: Data1
Cycle 3: Data2
Cycle 4: Data3

## I/O Specification

### Inputs
- `clk`: Clock signal (positive edge-triggered)
- `rst_n`: Active-low asynchronous reset
- `in_valid`: High when input data is valid
- `data_in[7:0]`: 8-bit data stream
- `read_address[5:0]`: Address for SRAM read

### Outputs
- `out_valid`: High when output data is valid
- `data_out[31:0]`: 32-bit output from SRAM (via a register)

## Specification and Constraints

- Asynchronous reset (`rst_n`) asserted once at the beginning.
- All outputs must reset to 0 after reset.
- `out_valid` must never overlap with `in_valid`.
- All output signals must be synchronous to the positive clock edge.
- Input delay: `0.5 * cycle`
- **Cycle time is fixed at 6 ns**.
- Must use the provided SRAM memory (black-box macro).
- Registers are required at the output of SRAM to avoid critical path violations.

## Synthesis and Area Constraints

- Latches are not allowed in your synthesized design.
- Use `./08_check` to verify absence of latches.
- Timing report slack must be non-negative (MET).
- SRAM area must not be 0.
- Total cell area must be less than **100,000**.
- The SRAM macro must be correctly instantiated and counted in area report.

## Simulation and Testing

### Flow
1. **RTL Simulation**:  
   Run: `./01_run_vcs_rtl`

2. **Synthesis**:  
   Run: `./01_run_dc_shell`  
   Verify: `./08_check` (no latches, MET, SRAM used)

3. **Gate-Level Simulation**:  
   Run: `./01_run_vcs_gate`

### Debugging:
- Use `nWave &` and `*.fsdb` files to observe waveform.
- Use Shift+L in nWave to reload waveform.
