![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Prompt2Silicon Workshop Designs & Demo

## Table of Contents
- [Repository Overview](#repository-overview)
- [Simulating the Workshop Designs](#simulating-the-workshop-designs)
- [Generating the GDSII for the Workshop Designs](#generating-the-gdsii-for-the-workshop-designs)
- [Chat Agent and Workflow Demo](#chat-agent-and-workflow-demo)
- [Contact Information](#contact-information)

## Repository Overview
This repository is associated with the paper:  
> _“From RTL to Prompt Coding: Empowering the Next Generation of Chip Designers through LLMs”_  

📄 **arXiv preprint:** https://arxiv.org/abs/2601.13815

This repository contains all student designs developed during the **LLM-assisted Tiny Tapeout Workshop** with German high-school students (Grades 10–12). The 90-minute workshop served as a case study to evaluate the methodology introduced in the paper. The workshop demonstrated how **Large Language Models (LLMs)** can guide beginners from natural-language design ideas to functional **VGA chip implementations** using the **Tiny Tapeout** open-source ecosystem.

The **LLM-based chat agent** used during the workshop is **hosted on Hugging Face** (available in English and German), and this repository provides **instructions on how to [replicate the workflow](#chat-agent-and-workflow-demo)**.

---

### Workshop Designs Overview
The designs are located in the `src/` directory.

| No. | File Name | Design Name | Description |
|:---:|:-----------|:-------------|:-------------|
| 1 | `blue_car.v` | `tt_um_vga_blue_car` | Interactive VGA design where a blue car can be moved horizontally across the screen using pins 0 (left) and 1 (right). |
| 2 | `aquarium.v` | `tt_um_vga_aquarium` | Animation of multiple fish swimming in an aquarium. |
| 3 | `pixelart_cat.v` | `tt_um_vga_pixelart_cat` | Static pixel-art style cat image. |
| 4 | `blue_square.v` | `tt_um_vga_blue_square` | Static VGA design showing a centered blue square. |
| 5 | `stick_figure.v` | `tt_um_vga_stick_figure` | Interactive animation where a stick figure jumps from left to right depending on pins 1 (left) and 2 (right). |
| 6 | `red_car.v` | `tt_um_vga_red_car` | Interactive VGA design where a red car can be moved horizontally across the screen using pins 0 (left) and 1 (right). |
| 7 | `unicorn.v` | `tt_um_vga_unicorn` | Animation of a unicorn catching a carrot. |
| 8 | `tree.v` | `tt_um_vga_tree` | Animation of a tree with leaves gently falling. |

---

## Simulating the Workshop Designs

To explore or test the workshop designs:

1. Open the corresponding design file in the `src/` folder.  

2. Review the Verilog source code to understand the implemented logic and behavior.

3. Open the **[Tiny Tapeout VGA Playground](https://vga-playground.com/)** in your browser.

4. Copy and paste the Verilog code of the desired design into the Playground’s code editor.

5. Rename the module to `tt_um_vga_example` (required by VGA Playground).

6. Run the simulation directly in the browser to visualize the VGA output and verify its functionality.

---

## Generating the GDSII for the Workshop Designs

The repository supports the synthesis and backend flow via **GitHub Actions**, using the Tiny Tapeout Verilog template.

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

Once the workflow completes, all artifacts can be viewed in the **Actions** tab of the repository. Tiny Tapeout also provides detailed [documentation](https://tinytapeout.com/guides/workshop/create-your-gds/) on the GDS generation and the navigation of GitHub Actions. 

> **Note:** For some designs, you may need to adjust the number of `tiles` in the `info.yaml` file, as shown below:

| Design Name | Tiles |
|:--------------------------|:------:|
| `tt_um_vga_blue_car` | 1×1 |
| `tt_um_vga_aquarium` | 1×1 |
| `tt_um_vga_pixelart_cat` | 1×1 |
| `tt_um_vga_blue_square` | 1×1 |
| `tt_um_vga_stick_figure` | 2×2 |
| `tt_um_vga_red_car` | 1×1 |
| `tt_um_vga_unicorn` | 1×1 |
| `tt_um_vga_tree` | 1×2 |

## Chat Agent and Workflow Demo

Two hosted versions of the chat agent are available on Hugging Face:
- 🇬🇧 [**English version**](https://huggingface.co/spaces/lkrupp/prompt2rtl-demo-en)  
- 🇩🇪 [**German version**](https://huggingface.co/spaces/lkrupp/prompt2rtl-demo-de)

> ⚠️ **Note:** Using the chat agents requires an [**OpenAI API key**](https://platform.openai.com/api-keys).  
> Please ensure that a valid key is configured in the demo application.

To replicate the complete educational workflow used in the workshop:

1. Open the **Chat Agent** (in your preferred language) in one browser tab and insert your OpenAI API key.  
2. Open the **[Tiny Tapeout VGA Playground](https://vga-playground.com/)** in a second tab for simulation.  
3. Create a new design repository using the **[TinyTapeout Verilog Template](https://github.com/TinyTapeout/ttsky-verilog-template)**.  
4. Start the workflow and begin interacting with the chat agent:
   - Describe your design idea in natural language.  
   - Let the LLM-based agent generate Verilog code.  
   - Paste the generated code into the VGA Playground for simulation.
   - Perform debugging or refinement iterations. 
   - Once satisfied, commit the design to your Tiny Tapeout repo and trigger the GDSII workflow.

## Contact Information

For questions, collaboration requests, or further details about the **Prompt2Silicon** workshop or the paper, please contact:

Dr.-Ing. Lukas Krupp  
Microelectronic System Design Research Group  
RPTU University of Kaiserslautern-Landau  
📧 lukas.krupp [AT] rptu.de
