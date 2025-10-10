# Prompt2Silicon Workshop Designs

## How it works
This repository contains the chip designs created during the **LLM-assisted TinyTapeout Workshop** conducted with German high-school students (Grades 10–12) at RPTU University of Kaiserslautern-Landau.  
Each design was developed within a 90-minute session using an **LLM-based chat agent** integrated into a browser-based **idea-to-GDSII learning workflow**.

The workflow guides students through:
1. **Idea formulation** (describing the desired circuit in natural language)
2. **RTL code generation and debugging** (Verilog)
3. **Simulation and verification** (Tiny Tapeout VGA Playground)
4. **Synthesis and tapeout preparation** using the TinyTapeout Verilog template

Detailed **chatbot and workflow demo instructions**, as well as steps on **how to perform the backend flow** for the student designs, can be found in the **`README.md`** of this repository.

---

## How to test
To explore or test the designs:

1. Open the corresponding design file in the `src/` folder.  
   This folder contains all **eight student group designs** created during the workshop.
2. Review the Verilog source code to understand the implemented logic and behavior.
3. To simulate the design, open the **[Tiny Tapeout VGA Playground](https://vga-playground.com/)** in your browser.
4. Copy and paste the Verilog code of the desired design into the Playground’s code editor.
5. Run the simulation directly in the browser to visualize the design’s VGA output and verify its functionality.

---

## External hardware
- All designs target **VGA display output**.  
- Therefore, a **VGA PMOD adapter**, e.g. [TinyVGA PMOD Adapter](https://store.tinytapeout.com/products/TinyVGA-Pmod-p678647356), and a **VGA monitor** are required.  
- The **Tiny Tapeout development board** provides a PMOD interface for connecting the VGA adapter.

---

## Acknowledgment
This repository is associated with the following paper:  
> _“From RTL to Prompt Coding: Empowering the Next Generation of Chip Designers through LLMs”_

The workshop and accompanying designs were conducted and supervised by  
**Dr.-Ing. Lukas Krupp**, Microelectronic System Design Research Group,  
**RPTU University of Kaiserslautern-Landau**.

---
