# Configurable Synchronous FIFO

[![Language](https://img.shields.io/badge/Language-Verilog-blue?style=flat-square)](https://en.wikipedia.org/wiki/Verilog)
[![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado-orange?style=flat-square)](https://www.xilinx.com/products/design-tools/vivado.html)
[![Simulation](https://img.shields.io/badge/Simulation-ModelSim-green?style=flat-square)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html)
[![Status](https://img.shields.io/badge/Status-Simulation%20Verified-brightgreen?style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)](LICENSE)

A configurable synchronous FIFO (First-In First-Out) buffer designed in Verilog. The design features a parameterized data width and depth, overflow and underflow protection, and a modular architecture with three sub-modules — an input controller, a core memory buffer, and an FSM-based output controller.

---

## Table of Contents

- [Features](#features)
- [Module Architecture](#module-architecture)
- [Parameters](#parameters)
- [Port Description](#port-description)
- [File Structure](#file-structure)
- [Functional Description](#functional-description)
- [How to Run](#how-to-run)
- [Simulation Results](#simulation-results)
- [Schematic](#schematic)
- [Synthesis Results](#synthesis-results)
- [Known Limitations](#known-limitations)
- [Author](#author)
- [License](#license)

---

## Features

- Single clock domain synchronous design
- Configurable data width via `WIDTH` parameter (default: 8-bit)
- Configurable FIFO depth via `DEPTH` parameter — supports 8, 16, and 32 entries
- Pointer width auto-calculated using `$clog2(DEPTH)` — no manual changes needed
- Overflow flag — asserted when a write is attempted on a full FIFO
- Underflow flag — asserted when a read is attempted on an empty FIFO
- Full and Empty status flags exposed directly at the top-level port
- FSM-based output controller for controlled read sequencing
- Clean modular design — each sub-module has a single, well-defined responsibility
- Verified on Xilinx Artix-7 FPGA using Vivado

---

## Module Architecture

The design is organized into three sub-modules, all instantiated under `FIFO_top_module`:

```
FIFO_top_module
├── mod_input    (mod_input.v)  — Input gating controller
├── fifo_memory  (fifo_memory.v) — Core circular buffer with pointer logic
└── mod_output   (mod_output.v) — 3-state FSM output read controller
```

### Data Flow

```
             en, d_in                              
                │                                      
                ▼                                      
         ┌─────────────┐    temp_data   ┌─────────────────────┐    fifo_out    ┌──────────────┐   d_out
         │  mod_input  │ ─────────────► │    fifo_memory      │ ─────────────► │  mod_output  │  ─────────►
         │  (gating)   │ ─────────────► │  (circular buffer)  │ ◄───────────── │  (FSM read)  │
         └─────────────┘    wr_en       └─────────────────────┘    rd_en       └──────────────┘
                                                  │                
                                                  │
                                                  ▼
                                           full, empty,
                                        overflow, underflow
```

---

## Parameters

| Parameter | Type    | Default | Description |
|-----------|---------|---------|-------------|
| `WIDTH`   | integer | `8`     | Data bus width in bits |
| `DEPTH`   | integer | `8`     | Number of FIFO entries (supported: 8, 16, 32) |

`PTR_WIDTH` is a derived `localparam` inside `fifo_memory`, automatically set to `$clog2(DEPTH)`.

**Instantiation with custom parameters:**

```verilog
// 8-bit wide, 16-deep FIFO
FIFO_top_module #(
    .WIDTH (8),
    .DEPTH (16)
) fifo_inst (
    .clk         (clk),
    .rst         (rst),
    .en          (en),
    .d_in        (d_in),
    .d_out_top   (d_out_top),
    .full_flag   (full_flag),
    .empty_flag  (empty_flag),
    .overflow    (overflow),
    .underflow   (underflow)
);
```

---

## Port Description

### Top-level Module — `FIFO_top_module`

| Signal       | Direction | Width   | Description |
|--------------|-----------|---------|-------------|
| `clk`        | Input     | 1       | System clock |
| `rst`        | Input     | 1       | Active-high synchronous reset |
| `en`         | Input     | 1       | User write enable |
| `d_in`       | Input     | WIDTH   | Write data input |
| `d_out_top`  | Output    | WIDTH   | Read data output |
| `full_flag`  | Output    | 1       | High when FIFO is full |
| `empty_flag` | Output    | 1       | High when FIFO is empty |
| `overflow`   | Output    | 1       | High when write is attempted on a full FIFO |
| `underflow`  | Output    | 1       | High when read is attempted on an empty FIFO |

### Sub-module Ports

<details>
<summary>mod_input — Input Controller</summary>

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clk`  | Input  | 1     | System clock |
| `rst`  | Input  | 1     | Active-high synchronous reset |
| `en`   | Input  | 1     | User write request |
| `flag` | Input  | 1     | Full flag from fifo_memory |
| `din`  | Input  | WIDTH | Data input from user |
| `out`  | Output | WIDTH | Gated data to fifo_memory |
| `w_en` | Output | 1     | Write enable to fifo_memory |

</details>

<details>
<summary>fifo_memory — FIFO Core</summary>

| Signal           | Direction | Width | Description |
|------------------|-----------|-------|-------------|
| `clk`            | Input  | 1     | System clock |
| `rst`            | Input  | 1     | Active-high synchronous reset |
| `w_en`           | Input  | 1     | Write enable |
| `r_en`           | Input  | 1     | Read enable |
| `din`            | Input  | WIDTH | Write data |
| `full`           | Output | 1     | FIFO full flag |
| `empty`          | Output | 1     | FIFO empty flag |
| `d_out`          | Output | WIDTH | Read data output |
| `overflow_flag`  | Output | 1     | Overflow error flag |
| `underflow_flag` | Output | 1     | Underflow error flag |

</details>

<details>
<summary>mod_output — Output FSM Controller</summary>

| Signal  | Direction | Width | Description |
|---------|-----------|-------|-------------|
| `clk`   | Input  | 1     | System clock |
| `rst`   | Input  | 1     | Active-high synchronous reset |
| `empty` | Input  | 1     | Empty flag from fifo_memory |
| `din`   | Input  | WIDTH | Read data from fifo_memory |
| `r_en`  | Output | 1     | Read enable to fifo_memory |
| `d_out` | Output | WIDTH | Data output to external system |

</details>

---

## File Structure

```
Configurable-Sync-FIFO/
│
├── rtl/
│   ├── FIFO_top_module.v    — Top-level module (instantiates all three sub-modules)
│   ├── fifo_memory.v        — fifo_memory: core circular buffer
│   ├── mod_input.v          — mod_input: input gating controller
│   └── mod_output.v         — mod_output: 3-state FSM read controller
│
├── tb/
│   └── FIFO_top_module_tb.v — Testbench for the top-level module
│
├── docs/
│   ├── schematic.png        — RTL schematic from Vivado Elaborated Design
│   ├── waveform.png         — Simulation waveform from ModelSim
│   └── synthesis_report.png — Resource utilization report from Vivado
│
└── README.md
```

---

## Functional Description

### Write Operation

When `en=1` and the FIFO is not full, `mod_input` passes the data to `fifo_memory` and asserts `w_en`. The FIFO stores the data at the current write pointer location and increments the pointer. If `en=1` and the FIFO is full, the write is blocked and the `overflow` flag is asserted.

### Read Operation

The `mod_output` FSM continuously monitors the `empty` flag and sequences reads automatically. The FSM introduces a **2-cycle latency** from when data enters the FIFO to when it appears at `d_out_top`.

| State      | Encoding | Description |
|------------|----------|-------------|
| `IDLE`     | `2'b00`  | Waits until the FIFO has at least one entry |
| `FETCH`    | `2'b01`  | Transition cycle; moves to TRANSMIT if still non-empty |
| `TRANSMIT` | `2'b10`  | Asserts `r_en` for one cycle; data is captured at `d_out` |

```
          __    __    __    __    __    __
clk    __/  \__/  \__/  \__/  \__/  \__/
          IDLE  FETCH  TRANSMIT  IDLE
r_en   ___________________/‾‾‾\________
d_out  ___________________________/DATA\
```

### Full / Empty Detection — MSB Wrap-Around Method

Both pointers carry one extra MSB bit beyond the address width:

- **EMPTY:** The entire pointer value of `w_ptr` equals `r_ptr` — no unread data exists
- **FULL:** The lower address bits are equal, but the MSBs differ — the write pointer has wrapped around and caught up with the read pointer

```verilog
assign full  = (w_ptr[PTR_WIDTH-1:0] == r_ptr[PTR_WIDTH-1:0]) &&
               (w_ptr[PTR_WIDTH]     != r_ptr[PTR_WIDTH]);
assign empty = (w_ptr == r_ptr);
```

### Reset Behaviour

On `rst=1` (active-high, synchronous), all memory locations are cleared to zero, both read and write pointers are reset to zero, the data output is cleared, and all status flags are deasserted.

---

## How to Run

### Xilinx Vivado (Simulation + Synthesis)

**Step 1 — Create a new project:**
1. Open Vivado → Create Project → RTL Project
2. Add all files from `rtl/` as design sources
3. Add `tb/FIFO_top_module_tb.v` as a simulation source
4. Set `FIFO_top_module` as the top module

**Step 2 — Run Behavioral Simulation:**
```
Flow Navigator → Run Simulation → Run Behavioral Simulation
```

**Step 3 — In the Tcl Console:**
```tcl
run 500ns
```

**Step 4 — Synthesis and Implementation:**
```
Flow Navigator → Run Synthesis
Flow Navigator → Run Implementation
```

---

### ModelSim / QuestaSim

```tcl
# Step 1: Compile all source files
vlog rtl/fifo_memory.v
vlog rtl/mod_input.v
vlog rtl/mod_output.v
vlog rtl/FIFO_top_module.v
vlog tb/FIFO_top_module_tb.v

# Step 2: Start simulation
vsim FIFO_top_module_tb

# Step 3: Add signals to waveform window
add wave -divider "Clock and Reset"
add wave /FIFO_top_module_tb/clk
add wave /FIFO_top_module_tb/rst

add wave -divider "User Interface"
add wave /FIFO_top_module_tb/en
add wave /FIFO_top_module_tb/din
add wave /FIFO_top_module_tb/d_out_top

add wave -divider "Status Flags"
add wave /FIFO_top_module_tb/full_flag
add wave /FIFO_top_module_tb/empty_flag
add wave /FIFO_top_module_tb/overflow
add wave /FIFO_top_module_tb/underflow

# Step 4: Run simulation
run 500ns
```

---

## Simulation Results

The testbench covers the following scenarios:

- Sequential write of multiple bytes into the FIFO
- Sequential read of stored data
- Overflow detection — write attempted when FIFO is full
- Underflow detection — read attempted when FIFO is empty
- Reset during operation

### Waveform

![image alt](https://github.com/siva-vlsi/Configurable-Sync-FIFO/blob/main/docs/waveform.png.jpg?raw=true)

Key observations:
- Input data sequence: `0xAA → 0x8A → 0x94 → 0xF4 → 0x0A → 0xF2 → 0xFA`
- Output data appears 2 clock cycles after FIFO becomes non-empty (FSM latency)
- A brief `overflow` pulse is visible when a write is attempted on the full FIFO
- Simulation window: 475 ns
- Parameters confirmed in waveform: `depth = 8`, `width = 8`

---

## Schematic

RTL schematic generated from Vivado's Elaborated Design view.

![image alt](https://github.com/siva-vlsi/Configurable-Sync-FIFO/blob/main/docs/schematic.png.jpg?raw=true)

**Summary:** 3 Cells · 21 I/O Ports · 41 Nets

The schematic confirms the expected module interconnects:
- `mod_input` receives `clk`, `en`, `rst`, `d_in[7:0]` and feeds `temp_data` and `wr_en` to `fifo_memory`
- `fifo_memory` outputs `fifo_out`, `full`, `empty`, `overflow_flag`, and `underflow_flag`
- `mod_output` drives `d_out_top[7:0]` and generates `rd_en` back into `fifo_memory`

---

## Synthesis Results

**Target Device:** Xilinx Artix-7 (XC7A35T or equivalent)  
**Tool:** Xilinx Vivado

![image alt](https://github.com/siva-vlsi/Configurable-Sync-FIFO/blob/main/docs/synthesis_report.png.jpeg?raw=true)

| Resource | Used | Available | Utilization |
|----------|-----:|----------:|------------:|
| LUT      | 5    | 32,600    | 0.02%       |
| FF       | 6    | 65,200    | 0.01%       |
| IO       | 13   | 106       | 12.26%      |

The design is extremely lightweight — only 5 LUTs and 6 flip-flops for an 8-bit, 8-deep FIFO. Increasing `DEPTH` to 16 or 32 will increase FF usage proportionally as the pointer registers and memory array scale up.

---

## Known Limitations

- No `almost_full` or `almost_empty` flags — planned for a future revision
- The `mod_output` FSM introduces a fixed **2-cycle read latency**
- Asynchronous (dual-clock) FIFO is not supported in this version
- BRAM inference is not explicitly constrained — depths beyond 32 may be inefficient without a synthesis attribute

---

## Author

**Kothapalli Siva Manikanta**  
Swarnandhra College of Engineering and Technology  
GitHub: [@siva-vlsi](https://github.com/siva-vlsi)

---

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2026 Kothapalli Siva Manikanta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
