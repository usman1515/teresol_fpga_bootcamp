#set page(paper: "a4", margin: 1in)
#set text(font: "Noto Sans", size: 11pt)
// number all headings
#set heading(numbering: "1.1.")
// show all links as underlined and blue
#show link: underline
#show link: set text(blue)
// number all pages
#set page(numbering: "1")
// global paragraph spacing
#set par(spacing: 2em,)



// title page
#align(center)[
  #v(3cm)
  #text(size: 15pt, weight: "bold")[FPGA Development Team]
  #v(1.2cm)
  #text(size: 25pt, weight: "bold")[Lab 8 — Place and Route Using NextPnR]
  #v(0.8cm)
  #text(size: 14pt, style: "italic")[Onboarding Lab Manual]
  #v(3cm)
  #line(length: 70%)
  #v(1.5cm)
  #table(
    columns: (30%, 70%), align: (right, left), inset: 8pt,
    [*Author:*], [Usman Siddique],
    [*Organization:*], [TeReSol Pvt. Ltd.],
    [*Department:*], [Hardware Design - FPGA Engineering Team],
    [*Document Version:*], [v1.0],
    [*Last Updated:*], [#datetime.today().display()],
  )
  #v(1fr)
  #text(size: 9pt, fill: gray)[FPGA Development Onboarding Series]
  #v(1cm)
]

#pagebreak()
#outline()
#pagebreak()



= Lab Overview

This lab introduces the FPGA implementation stages that occur after RTL synthesis. The previous labs
focused on writing and simulating HDL and using Yosys to transform RTL into a synthesized netlist.
In this lab, that netlist is taken through *place and route* using nextpnr, constrained
using an LPF constraint file, and checked using static timing analysis.

The target platform is the *Radiona ULX3S*, which uses a *Lattice ECP5 FPGA*. The open-source ECP5
flow combines `yosys` for synthesis, `nextpnr-ecp5` for placement and routing, and `ecppack` for
generating the final FPGA configuration bitstream.

The design used throughout the lab is the same style of ripple-carry adder introduced in lab 07: a
N-bit ripple carry adder.


#block(
  fill: luma(245), stroke: (left: 3pt + blue), inset: 10pt, radius: 4pt,
)[*NOTE:* The exact `nextpnr-ecp5` device option must match the FPGA fitted to your ULX3S. The
official Project Trellis ULX3S example uses `--25k` for an LFE5U-25F board, while nextpnr also
supports `--45k` and `--85k` ECP5 variants. The package for the common ULX3S examples is `CABGA381`.
Check the marking on your board before selecting the device option.]

= Objectives
By the end of this lab, you should be able to:

- Explain the difference between synthesis and place-and-route;
- Describe what nextpnr does in an FPGA implementation flow;
- Explain the purpose of a physical constraint file;
- Understand the structure and purpose of an ECP5 LPF file;
- Use an LPF file with `nextpnr-ecp5`;
- Understand the difference between timing constraints and physical pin constraints;
- Explain what static timing analysis (STA) is;
- Describe what OpenSTA does and what input files it requires;
- Understand why nextpnr's built-in FPGA timing analysis is the primary timing check for this ECP5 flow;
- implement the ripple-carry adder from the previous lab on the ULX3S;
- generate a placed-and-routed ECP5 configuration and FPGA bitstream.

== Installing the OSS CAD Suite
For FPGA place-and-route, we will use the *OSS CAD Suite*, a collection of free and open-source
tools for digital design, simulation, synthesis, and FPGA development. The suite brings together
several commonly used FPGA and hardware-design tools into a single installation, making it easier to
set up a consistent development environment across the team.

For this lab, we will use:
- `yosys` — Verilog/SystemVerilog netlist generator.
- `nextpnr-ecp5` — Netlist place and route.

Instead of installing each tool individually through Fedora's package manager, we will install the
OSS CAD Suite and use the tools provided by the suite throughout this onboarding series.

== Installing Other Tools
It is also useful to make sure that `make` is installed:
```bash
sudo dnf install make
```
Make sure yosys is available:
```bash
yosys --version
```
Verify nextPnR:
```bash
nextpnr-ecp5 --version
```
You can also check the nextpnr-ecp5 executable:
```bash
which nextpnr-ecp5
```

The exact version numbers and installation paths may differ depending on the Fedora release and the
OSS CAD Suite version.

= Prerequisites
Verify the main tools:
```bash
yosys --version
nextpnr-ecp5 --version
ecppack --help
```

= The FPGA Implementation Flow
The complete open-source FPGA flow used in this lab is:

#align(center)[
```text
SystemVerilog RTL
       |
       v
     Yosys
       |
       | synthesis
       v
JSON netlist
       |
       v
  nextpnr-ecp5
       |
       | place + route timing analysis
       |
       v
ECP5 configuration
       |
       v
    ecppack
       |
       v
  .bit bitstream
       |
       v
     ULX3S
```
]

#table(columns: (25%, 75%), inset: 6pt, align: left,
  [*Tool*], [*Purpose*],
  [Yosys], [Converts RTL into a synthesized netlist suitable for the target FPGA flow.],
  [nextpnr-ecp5], [Places the synthesized logic into physical FPGA resources and routes the
  connections between them.],
  [LPF constraints], [Tell the implementation tool where top-level signals are physically connected
  and provide board/timing constraints.],
  [ecppack], [Converts the routed ECP5 configuration into a bitstream/configuration file.],
  [ujprog / openFPGALoader], [Transfers the generated bitstream to the ULX3S.],
)

= What Is nextpnr?
Nextpnr is an open-source, timing-driven FPGA place-and-route tool. It is designed to work with
several FPGA architectures and uses architecture-specific backends for devices such as Lattice iCE40
and ECP5.

For the ULX3S, the relevant executable is: `nextpnr-ecp5`

Yosys performs synthesis, but synthesis alone does not determine where the resulting logic will
physically reside inside the FPGA. nextpnr takes the synthesized representation and performs two
major implementation tasks:

1. *Placement* — selecting physical FPGA resources for the synthesized cells.
2. *Routing* — selecting programmable routing resources that connect those placed cells.

Nextpnr is timing-driven, meaning timing information can influence placement and routing decisions.

#block(
  fill: luma(245), stroke: (left: 3pt + blue), inset: 10pt, radius: 4pt,
)[*NOTE:* \
*Synthesis answers:* "What logic does the design require?" \
*Place and route answers:* "Where should that logic go in the FPGA, and how should the FPGA's
routing resources connect it?" ]

= What Does Placement Mean?
An FPGA contains many physical resources, including:

- lookup tables (LUTs);
- flip-flops;
- carry-chain resources;
- input/output cells;
- routing resources;
- clock resources;
- device-specific blocks.

After Yosys synthesizes your design file/s, the resulting logic must be assigned to actual resources
in the ECP5. Placement determines the physical locations used by the logic.

= What Does Routing Mean?
Once cells have been placed, their signals must be connected through the FPGA's programmable routing
network. The implementation tool must connect these signals while respecting the FPGA architecture
and timing requirements.

= The ULX3S and ECP5
The ULX3S is an open-source FPGA development board built around a Lattice ECP5 FPGA family device.
The ECP5 architecture is supported by the open-source Project Trellis database and by the
`nextpnr-ecp5` backend.

The important tools for this lab are:

#align(center)[
```text
Yosys
  |
  +--> synth_ecp5
  |
  v
JSON netlist
  |
  +--> nextpnr-ecp5
  |
  v
Trellis text configuration
  |
  +--> ecppack
  |
  v
bitstream
```
]

#block(
  fill: luma(245), stroke: (left: 3pt + blue), inset: 10pt, radius: 4pt,
)[*NOTE:* The ULX3S exists with different ECP5 device sizes. This manual uses the `--25k` command in
the primary example because that is the device used by the official Project Trellis ULX3S example.
If your board uses an LFE5U-45F or LFE5U-85F, replace `--25k` with `--45k` or `--85k` respectively.
]

= The Ripple-Carry Adder
The design for this lab is an N-bit ripple-carry adder which is already provided in
`./08-nextpnr-tutorial/`. The underlying `adder` remains parameterized and can be synthesized at any
supported width.

= What Is a Constraint File?
A constraint file describes requirements that cannot be completely inferred from RTL source code.
For an FPGA design, one important type of constraint is a physical pin constraint.

For example, your SystemVerilog may contain:
```systemverilog
input logic [3:0] sw;
output logic [3:0] led;
```

The RTL does not say which physical FPGA package pins are connected to the board's switches and
LEDs. The constraint file provides that information. Conceptually:

#align(center)[
```text
HDL signal        Physical FPGA pin
------------------------------------------------
sw[0]              --->  E8
sw[1]              --->  D8
sw[2]              --->  D7
sw[3]              --->  E7

led[0]             --->  B2
led[1]             --->  C2
led[2]             --->  C1
led[3]             --->  D2
```
]

= LPF: The ULX3S Constraint File
For Lattice ECP5 devices, nextpnr uses an *LPF (Lattice Preference File)* to describe physical and
timing constraints which you can download from the official
#link("https://github.com/ulx3s/blink/blob/main/ulx3s_v20.lpf")[blink LED] repository.

The official ULX3S v2.x/v3.0 constraints include:
```lpf
LOCATE COMP "clk_25mhz" SITE "G2";
IOBUF PORT "clk_25mhz" PULLMODE=NONE IO_TYPE=LVCMOS33;
FREQUENCY PORT "clk_25mhz" 25 MHZ;
```

This states that `clk_25mhz` is located at FPGA site `G2`, uses `LVCMOS33`, and is a 25 MHz clock.

The same file maps the board LEDs:
```lpf
LOCATE COMP "led[7]" SITE "H3";
LOCATE COMP "led[6]" SITE "E1";
LOCATE COMP "led[5]" SITE "E2";
LOCATE COMP "led[4]" SITE "D1";
LOCATE COMP "led[3]" SITE "D2";
LOCATE COMP "led[2]" SITE "C1";
LOCATE COMP "led[1]" SITE "C2";
LOCATE COMP "led[0]" SITE "B2";
```

and the four DIP switches:
```lpf
LOCATE COMP "sw[0]" SITE "E8";
LOCATE COMP "sw[1]" SITE "D8";
LOCATE COMP "sw[2]" SITE "D7";
LOCATE COMP "sw[3]" SITE "E7";
```

= How the Constraint File Connects to the Design
The names in the LPF file must match the top-level ports in your HDL. For example:
```systemverilog
module adder_top (
    input  logic [3:0] sw,
    output logic [3:0] led
);
```

matches:
```lpf
LOCATE COMP "sw[0]" SITE "E8";
LOCATE COMP "sw[1]" SITE "D8";
LOCATE COMP "sw[2]" SITE "D7";
LOCATE COMP "sw[3]" SITE "E7";

LOCATE COMP "led[0]" SITE "B2";
LOCATE COMP "led[1]" SITE "C2";
LOCATE COMP "led[2]" SITE "C1";
LOCATE COMP "led[3]" SITE "D2";
```

#block(
  fill: luma(245), stroke: (left: 3pt + blue), inset: 10pt, radius: 4pt,
)[*WARNING:* Do not invent FPGA package pins for a board. Use the constraint file corresponding to
the exact ULX3S PCB version and signal you are using.]

= Project Structure
A typical project for this lab is:

```text
08-nextpnr-tutorial/
├── src/
│   ├── half_adder.sv
│   └── carry_lookahead_adder.sv
├── constraints/
│   └── ulx3s_v20.lpf
├── bin/
└── Makefile
```

== Synthesis for the ULX3S
Simple run the Makefile target `synth_design_ecp5` to generate a device specific netlist. Look for
`./bin/netlist_ecp5_carry_lookahead_adder.json`

== Running nextpnr-ecp5
For a 25F device:
```bash
nextpnr-ecp5 --25k --package CABGA381 \
    --json ./bin/netlist_ecp5_carry_lookahead_adder.json \
    --lpf ./constraints/ulx3s_v20.lpf --textcfg ./bin/build_ecp5_25k_$(TOP).config
```

== Understanding the Command
`--25k`, `--45k`, or `--85k` selects the ECP5 device size. \
`--package CABGA381` selects the FPGA package. \
`--json netlist/adder_ulx3s.json` supplies the synthesized netlist. \
`--lpf constraints/ulx3s_v20.lpf` supplies the physical and timing constraints. \
`--textcfg build/adder_ulx3s.config` writes the routed ECP5 configuration. 

== #text(fill: red)[EXERCISE]
Try to create Makefile targets and generate a PnR config file for the `25k`, `45k` and `85k`
variants of the same FPGA chip.

= Timing-Driven Place and Route
nextpnr can use timing information while performing placement and routing. For a clocked design, a
timing constraint tells the implementation tool the required clock period.

= Understanding the nextpnr Report
When nextpnr completes, look for sections containing timing information. Useful information includes:

- maximum frequency;
- setup and hold results where applicable;
- slack;
- critical timing paths;
- warnings about unconstrained paths.

A successful implementation should indicate that placement and routing completed successfully. The
important relationship is:

#align(center)[
```text
Required timing
       |
       v
Implementation
       |
       v
Actual delay
       |
       v
Slack
```
]

For a simple synchronous path:
```text
slack = required arrival time - actual arrival time
```

A positive value is generally desirable.

= Generating the ECP5 Bitstream
After nextpnr successfully places and routes the design, generate the FPGA bitstream using
`ecppack`.

The device-specific IDCODE must match the FPGA being programmed. The official Project Trellis ULX3S
12F/25K example uses:

```bash
ecppack --idcode 0x21111043 \
    ./bin/build_ecp5_25k_carry_lookahead_adder.config \
    ./bin/bit_ecp5_25k_carry_lookahead_adder.bit
```

Use the correct IDCODE for your device variant. The resulting file is:
```text
build/bit_ecp5_25k_carry_lookahead_adder.bit
```

= Programming the ULX3S
A commonly used programmer for ULX3S is `ujprog`:
```bash
ujprog ./bin/bit_ecp5_25k_carry_lookahead_adder.bit
```

If using OpenFPGALoader and it is configured for your board:
```bash
openFPGALoader ./bin/bit_ecp5_25k_carry_lookahead_adder.bit
```

After programming, operate the four DIP switches and observe the LEDs.

== Inspect Timing Results

Read the nextpnr output and identify:

- whether placement succeeded;
- whether routing succeeded;
- timing information;
- maximum frequency or slack information;
- warnings concerning unconstrained paths.

= Makefile Automation
After understanding the individual commands, automate the place and route and bitstream generation
flow with a Makefile. The synthesis target has already been provided.

= Key Concepts to Remember
#table(columns: (30%, 70%), inset: 6pt, align: left,
  [*Concept*], [*Meaning*],
  [Synthesis], [Transforms RTL into a hardware-oriented netlist.],
  [Placement], [Assigns synthesized cells to physical FPGA resources.],
  [Routing], [Connects placed cells using FPGA routing resources.],
  [nextpnr], [Performs FPGA place and route and provides FPGA-aware timing analysis.],
  [Constraint file], [Describes physical and timing requirements that cannot be inferred from RTL alone.],
  [LPF], [The Lattice constraint format used by the ECP5 flow.],
  [STA], [Analyzes timing paths without requiring exhaustive functional simulation.],
  [OpenSTA], [A standalone gate-level static timing analyzer based on standard timing formats such as Verilog, Liberty, and SDC.],
  [nextpnr timing], [The appropriate primary timing analysis for the ULX3S ECP5 implementation flow.],
  [ecppack], [Converts the routed ECP5 configuration into a programmable bitstream.],
)

= References
- #link("https://github.com/YosysHQ/nextpnr")[YosysHQ nextpnr]
- #link("https://github.com/The-OpenROAD-Project/OpenSTA")[OpenSTA]
- #link("https://foss-fpga-tools.googlesource.com/prjtrellis/+/HEAD/examples/ulx3s/")[Project Trellis ULX3S examples]
- #link("https://foss-fpga-tools.googlesource.com/prjtrellis/+/HEAD/examples/ulx3s/ulx3s_v20.lpf")[Official ULX3S v20 LPF constraints]
- #link("https://github.com/emard/ulx3s")[ULX3S repository and board documentation]
