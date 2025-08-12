# RISC-V Single-Cycle CPU with UVM Verification

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)
![Verification](https://img.shields.io/badge/Verification-UVM-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

This repository contains the SystemVerilog RTL for a 32-bit, single-cycle CPU implementing the **RV32I base integer instruction set**. The design is validated by a comprehensive **UVM verification environment** featuring constrained-random stimulus, a reference model for automatic checking, and functional coverage.

## Key Components

* **RTL Core:** A simple single-cycle CPU designed for clarity and functional correctness.
* **UVM Testbench:** A robust verification environment built with standard UVM components:
    * Constrained-Random Sequences
    * Reference Model & Scoreboard for self-checking
    * Functional Coverage Collector
    * Self-checking Assertions
