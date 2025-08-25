# VLSI Project

This repository contains a collection of standard cells, a custom datapath design, and place-and-route (PnR) flows for building and integrating a RISC-V datapath and controller. The work spans from transistor-level cell design to automated digital implementation flows using TCL scripts.

---

## Repository Structure
```text
vlsi-project/
├── stdcell/        # Standard cell library (custom layouts for AND, OR, INV, DFF, etc.)
├── datapath/       # Custom RISC-V datapath (schematic + manual layout)
└── pnr/            # Automated place-and-route (TCL scripts + outputs)
```


---

## Standard Cell Library (`stdcell/`)

A compact CMOS standard cell library was created with uniform cell height and consistent VDD/VSS rails for seamless row placement. All cells are area-efficient, DRC-compliant, and accessible up to **Metal 2**.

### Implemented Cells
- **Logic Gates**: `and2`, `or2`, `nor2`, `nand2`, `xor2`, `xnor2`
- **Complex Gates**: `aoi21`, `oai21`
- **Sequential Elements**: `dff` (D flip-flop), `latch` (D latch)
- **Others**: `inv`, `buf`, `mux2`

**Design Notes:**
- Worst-case pull-up/pull-down matched to NMOS (W=90nm, L=50nm).
- CMOS logic only (no complementary inputs).
- Well taps included in each cell.
- Pins routed to **Metal 2** for compatibility with automated flows.

---

## Datapath (`datapath/`)

A custom datapath for a bit-sliced **RISC-V32I single-cycle processor** was designed and laid out.

### Highlights
- **Bitsliced design**: 32 identical slices stitched to form the datapath.
- **Top-level cells**:
  - `datapath`: Base single-cycle datapath
  - `bitslice`: One slice of the datapath
  - `datapath_s`: Extended datapath with shifter support (optional)
- **Metal usage**: Up to **Metal 6** for routing.
- **Inputs/Outputs**:
  - Bitsliced inputs: `dmem_rdata`, `imm`
  - Bitsliced outputs: `dmem_addr`, `dmem_wdata`, `imem_addr`
- Controller signals routed along the **top edge** of the datapath.

---

## Place-and-Route (`pnr/`)

Automated place-and-route flows were developed to integrate the standard cell library with datapath and controller components.

### Flow Stages
1. **Library Packaging**  
   - Exported `.lib` and `.lef` for standard cells.  
   - Used in Innovus for PnR.

2. **Controller Auto PnR**  
   - Implemented via `controller.tcl`.  
   - Produces placed-and-routed controller (`controller.dat`) with screenshots for validation.

3. **Integration with Datapath**  
   - Imported controller into Virtuoso and stitched with datapath layout.  
   - Captured in `integration.png`.

4. **Full CPU PnR (Standard Cells Only)**  
   - Generated using `cpu1.tcl`.  
   - Output: `cpu1.dat` + Innovus screenshots.

5. **Full CPU PnR (With Custom Register File)**  
   - Packaged custom register file (`regfile.lib`, `regfile.lef`).  
   - Integrated into CPU build (`cpu2.tcl`, `cpu2.dat`).  
   - Screenshots show the final CPU layout.

---

## Key Features
- End-to-end flow: **from transistor-level cells → datapath layout → full CPU auto PnR**.
- Custom standard cell library compatible with automated PnR tools.
- Modular design for experimentation with datapath structures and shifters.
- TCL automation for reproducible Innovus flows.

---

## Notes
- This repo is structured for ** reference, and experimentation** in digital IC design flows.
- Standard cells and datapath are manually designed to match area and DRC efficiency goals.
- PnR flows can be re-run using the provided TCL scripts in the `pnr/` folder.

