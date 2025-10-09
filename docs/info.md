# Prompt2Silicon Workshop Designs

## How it works
This repository contains the chip designs created during the **LLM-assisted TinyTapeout Workshop** conducted with German high-school students (Grades 10–12) at RPTU University of Kaiserslautern-Landau.  
Each design was developed within a 90-minute session using an **LLM-based chat agent** integrated into a browser-based **idea-to-GDSII learning workflow**.

The workflow guides students through:
1. **Idea formulation** (describing the desired circuit in natural language)
2. **RTL code generation and debugging** (Verilog)
3. **Simulation and verification** (Tiny Tapeout VGA Playground)
4. **Synthesis and tapeout preparation** using the TinyTapeout SKY130 flow

---

## How to test
To explore or test the designs:
1. Open the corresponding design folder (each represents one student group’s project).  
2. Review the included `verilog/` source files and `info.yaml` metadata.
3. Use the [TinyTapeout simulation environment](https://tinytapeout.com/faq/simulate/) or the [TinyTapeout template repository](https://github.com/TinyTapeout/ttsky-verilog-template) to:
   - Simulate the design (`make sim`)
   - Generate the layout (`make gds`)
   - View the GDS in KLayout or Magic

Alternatively, you can run the designs directly in the **browser-based workflow** (used during the workshop) — see instructions in the main project’s `README.md`.

---

## External hardware
Some designs target VGA display output or LED visualization:
- **VGA monitor** (connected via TinyTapeout board)
- **8× LED matrix** or **on-board LEDs**
- **Push buttons** for user input in interactive designs

Each design’s specific hardware interface is documented in its subfolder.

---

## Acknowledgment
This repository is part of the **Prompt2Silicon** educational initiative and the associated **ISCAS 2026 paper**:  
> _“LLM-Assisted Chip Design Education: From RTL to Prompt Coding”_

Workshop conducted by [Your Name / Institution].

---

Would you like me to add a short `README.md` for the root of the repository as well — including citation, structure overview, and link to your paper (for GitHub and Zenodo integration)? That helps make it directly citable in IEEE format.
