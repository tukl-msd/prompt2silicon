![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Prompt2Silicon Workshop Designs

## Table of Contents
- [Repository Overview](#repository-overview)
- [Simulating the Student Designs](#simulating-the-student-designs)
- [Generating the GDSII for the Workshop Designs](#generating-the-gdsii-for-the-workshop-designs)
- [Chat Agent and Workflow Demo](#chat-agent-and-workflow-demo)

## Repository Overview
This repository is associated with the paper submitted to **IEEE ISCAS 2026**:  
> _“From RTL to Prompt Coding: Empowering the Next Generation of Chip Designers through LLMs”_  

A preprint will be made available on **arXiv** (link will be added here).

This repository contains all student designs developed during the **LLM-assisted Tiny Tapeout Workshop** with German high-school students (Grades 10–12). The workshop served as a case study to evaluate the methodology introduced in the paper. The workshop demonstrated how **Large Language Models (LLMs)** can guide beginners from natural-language design ideas to functional **VGA chip implementations** using the **Tiny Tapeout** open-source ecosystem.

All designs were created within a 90-minute hands-on session using a browser-based **LLM chat agent** and a new **idea-to-GDSII workflow**. Each project was verified through simulation and successfully synthesized into a **tapeout-ready GDSII design**.

---

### Workshop Designs Overview

| No. | Design Name | Description |
|:---:|:-------------|:-------------|
| 1 | `tt_um_vga_blue_square` | Static blue square centered on screen |
| 2 | `tt_um_vga_checkerboard` | Animated checkerboard pattern |
| 3 | `tt_um_vga_color_cycle` | Color-cycling background animation |
| 4 | `tt_um_vga_pixel_rain` | Falling pixel “rain” effect |
| 5 | `tt_um_vga_moving_sprite` | Sprite moving horizontally across the screen |
| 6 | `tt_um_vga_paddle_game` | Interactive paddle controlled via input |
| 7 | `tt_um_vga_flag_display` | Displays German flag pattern |
| 8 | `tt_um_vga_color_gradient` | Horizontal RGB color gradient |

Each design is located in the `src/` directory.

---

## Simulating the Workshop Designs

To explore or test the designs:

1. Open the corresponding design file in the `src/` folder.  

2. Review the Verilog source code to understand the implemented logic and behavior.

3. Open the **[Tiny Tapeout VGA Playground](https://vga-playground.com/)** in your browser.

4. Copy and paste the Verilog code of the desired design into the Playground’s code editor.

5. Run the simulation directly in the browser to visualize the VGA output and verify its functionality.

---

## Generating the GDSII for the Workshop Designs

The repository supports backend generation via **GitHub Actions**, using the official Tiny Tapeout GDSII workflow.

To generate the GDSII layout for any workshop design:

1. Fork this repository.
2. Open the file `src/project.v`.
3. Instantiate the `vga_core` as one of the workshop designs by inserting its module name.  
   For example:
   ```verilog
   tt_um_vga_blue_square vga_core (
       .clk(clk),
       .rst_n(rst_n),
       .ena(ena),
       .ui_in(ui_in),
       .uo_out(uo_out),
       .uio_in(uio_in),
       .uio_out(uio_out),
       .uio_oe(uio_oe)
   );
   ```
4. Commit and push the changes to your fork.  
5. The **GitHub Actions** backend (TinyTapeout GDS flow) will automatically start.

> **Note:** For some designs, you may need to adjust the `tile_number` in the `info.yaml` file, as shown below:

| Design Name | Tile No. |
|:-------------|:---------:|
| `tt_um_vga_blue_square` | 25 |
| `tt_um_vga_checkerboard` | 26 |
| `tt_um_vga_color_cycle` | 27 |
| `tt_um_vga_pixel_rain` | 28 |
| `tt_um_vga_moving_sprite` | 29 |
| `tt_um_vga_paddle_game` | 30 |
| `tt_um_vga_flag_display` | 31 |
| `tt_um_vga_color_gradient` | 32 |

Once the workflow completes, all artifacts can be viewed in the **Actions** tab of the repository.

## Chat Agent and Workflow Demo

Two hosted versions of the chat agent are available:
- 🇬🇧 **English version** — [Hosted on Hugging Face (link to be added)]  
- 🇩🇪 **German version** — [Hosted on Hugging Face](https://huggingface.co/spaces/lkrupp/prompt2rtl-demo-de)

> ⚠️ **Note:** Using the chat agents requires an **OpenAI API key**.  
> Please ensure that a valid key is configured in the demo application.

To replicate the complete educational workflow used in the workshop:

1. Open the **Chat Agent** (in your preferred language) in one browser tab.  
2. Open the **[Tiny Tapeout VGA Playground](https://vga-playground.com/)** in a second tab for simulation.  
3. Create a new design repository using the **[TinyTapeout Verilog Template](https://github.com/TinyTapeout/ttsky-verilog-template)**.  
4. Begin interacting with the chat agent:
   - Describe your design idea in natural language.  
   - Let the LLM generate Verilog code.  
   - Paste the generated code into the VGA Playground for simulation.
   - Perform debugging or refinement iterations. 
   - Once satisfied, commit the design to your Tiny Tapeout repo and trigger the GDSII workflow.  
> **Note:** Detailed explanations can be found in the paper.


