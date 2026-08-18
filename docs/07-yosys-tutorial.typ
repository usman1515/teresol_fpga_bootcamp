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
  #text(size: 25pt, weight: "bold")[Lab 7 — RTL Synthesis Using Yosys]
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



= Objective

Learn how to synthesize a SystemVerilog design using Yosys and generate a synthesizable netlist for
different FPGA architectures.

At the end of this lab, you should be able to:
- Explain RTL synthesis.
- Describe what Yosys is and where it fits in an FPGA design flow.
- Understand the difference between RTL and a synthesized netlist.
- Use Yosys to read and elaborate SystemVerilog RTL.
- Synthesize an RTL design into a technology-independent representation.
- Generate netlists targeting different FPGA architectures.
- Inspect synthesis statistics and generated netlists.

= Background
*Register Transfer Level (RTL)* describes digital hardware using a hardware description language
such as SystemVerilog.

RTL describes registers, combinational logic, datapaths, control logic, arithmetic operations, and
connections between hardware components.

For example:

```systemverilog
assign sum = a + b;
```

describes the desired hardware behavior. It does not directly specify the exact FPGA resources that
implement the addition. Synthesis transforms this RTL description into a lower-level hardware
representation.

== Installing the OSS CAD Suite
For FPGA synthesis, we will use the *OSS CAD Suite*, a collection of free and open-source tools
for digital design, simulation, synthesis, and FPGA development. The suite brings together several
commonly used FPGA and hardware-design tools into a single installation, making it easier to set up
a consistent development environment across the team.

For this lab, we will use:
- `yosys` — Verilog/SystemVerilog netlist generator.
- `gtkwave` — Graphical waveform viewer.

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

Verify GTKWave:
```bash
gtkwave --version
```

You can also check the yosys executable:
```bash
which ghdl
```

The exact version numbers and installation paths may differ depending on the Fedora release and the
OSS CAD Suite version.

== What is Yosys?
Yosys is an open-source framework for *RTL synthesis* and hardware design processing.

It reads Verilog/SystemVerilog RTL and converts the design into internal representations that can be
analyzed, optimized, and mapped to hardware cells.

A simplified flow is:
#align(center)[
```text
SystemVerilog RTL
        |
        v
       Yosys
        |
        v
RTL processing
        |
        v
Optimization
        |
        v
Technology mapping
        |
        v
Technology-specific netlist
```
]

Yosys is commonly used in open-source FPGA and ASIC design flows. It can perform RTL elaboration,
logic optimization, technology mapping, and netlist generation. For FPGA development, Yosys is often
combined with other tools. The exact downstream tools depend on the target FPGA architecture.

== What is Synthesis?
*Synthesis* converts an RTL description into a hardware implementation represented using lower-level logic elements.

Conceptually:
#align(center)[
```text
RTL description
      |
      v
   Synthesis
      |
      v
Logic / cells / registers
```
]

For example:
```systemverilog
assign y = a & b;
```
may become an AND gate or an equivalent FPGA primitive after synthesis.

= What is a Netlist?
A *netlist* is a structural description of a digital circuit. Instead of primarily describing
behavior, a netlist describes:

- hardware cells or primitives,
- instances of those cells,
- wires connecting the cells,
- inputs and outputs,
- relationships between hardware elements.

Conceptually:

== RTL Versus Netlist
A useful distinction is:
```text
RTL:
"What hardware behavior do I want?"

Netlist:
"What hardware elements and connections implement that behavior?"
```

== Why is a Netlist Used?
A netlist is an important intermediate representation because downstream implementation tools need a
structural hardware description.

A typical FPGA flow is:
#align(center)[
```text
SystemVerilog RTL
       |
       v
     Yosys
       |
       v
Synthesized Netlist
       |
       v
Place and Route
       |
       v
Bitstream
       |
       v
     FPGA
```
]

The netlist therefore forms the interface between logic synthesis and later physical implementation.
It can also be used for inspecting synthesized hardware, counting resources, downstream
timing/implementation analysis, place-and-route, and bitstream generation.

= Technology-Independent and Technology-Specific Netlists
A technology-independent netlist contains generic structures such as: `AND, OR, MUX, DFF, adder, `
`logic, memory structures`. A technology-specific netlist uses cells or primitives belonging to a
particular FPGA architecture. Conceptually:

#align(center)[
```text
RTL
 |
 v
Generic synthesized logic
 |
 +-----------------------+
 |                       |
 v                       v
ECP5 mapping          Xilinx mapping
 |                       |
 v                       v
ECP5 cells             Xilinx cells
```
]

This is why the target FPGA architecture matters during synthesis.

= Parameterized N-Bit Ripple-Carry Adder
The design used in this lab is an `N`-bit adder which has already been provided. A reusable 1-bit
full adder is instantiated `N` times using a SystemVerilog generate loop. The RTL source does not
need to be rewritten for different widths.

= Project Structure
Organize the project as:
```text
07-yosys-tutorial/
├── src/
│   ├── full_adder.sv
│   └── ripple_carry_adder.sv
├── tb/
│   └── tb_ripple_carry_adder.sv
├── bin/
│   ├── netlist_ripple_carry_adder.v
│   └── ripple_carry_adder.sv
└── Makefile
```

= Basic Yosys Synthesis
In this section, we will perform synthesis directly from the *Yosys interactive shell* instead of
creating a `.ys` synthesis script.

First, start Yosys from the project directory: `yosys`

You should see the Yosys prompt: `yosys>`

Commands can now be entered directly at this prompt.

== Reading the SystemVerilog Files
Start by reading the three SystemVerilog source files:
```yosys
read -sv ./src/full_adder.sv
read -sv ./src/ripple_carry_adder.sv
read -sv ./src/top_rca.sv
```
The `read -sv` command reads the specified SystemVerilog source files into Yosys. The `-sv` option
tells Yosys to interpret the files as SystemVerilog rather than plain Verilog. After reading the
files, Yosys knows about the modules `full_adder` and `ripple_carry_adder`.

== Checking and Selecting the Design Hierarchy
Next, check the design hierarchy:
```yosys
hierarchy -check -auto-top
```
The `hierarchy` command analyzes the module hierarchy, while `-check` reports hierarchy problems and
`-auto-top` automatically selects the top-level module. The resulting hierarchy is conceptually. The
number of `full_adder` instances depends on the value of the `WIDTH` parameter.

== Converting RTL Processes
Run:
```yosys
proc
```
The `proc` command converts behavioral RTL processes into a lower-level representation of
multiplexers, registers, and other logic structures. Although our adder is primarily combinational,
this command is a standard part of many Yosys synthesis flows.

== Optimizing the Design
Run:
```yosys
opt
```
The `opt` command performs general-purpose logic optimizations and removes unnecessary or redundant hardware.

== Finite-State Machine Processing
Run:
```yosys
fsm
```
The `fsm` command detects and optimizes finite-state-machine structures present in the design. Our
adder does not contain an FSM, so this command will not have a significant effect on this particular
design.

== Optimizing Again
Run:
```yosys
opt
```
The second optimization pass removes additional redundancies that may have become visible after
previous synthesis transformations.

== Technology Mapping
Run:
```yosys
techmap
```
The `techmap` command maps generic RTL cells into lower-level logic structures using Yosys
technology-mapping rules.

== Arithmetic Optimization
Run:
```yosys
alumacc
```
The `alumacc` command identifies arithmetic operations and maps them into optimized arithmetic
structures such as adders and multipliers. For this design, the adder logic is particularly relevant
to this stage.

== Optimizing Again
Run:
```yosys
opt
```
The `opt` command performs another general optimization pass after arithmetic processing.

== Memory Processing
Run:
```yosys
memory
```
The `memory` command processes and maps memory structures into logic or technology-specific memory
resources. Our adder contains no memories, so this command has little effect on this design.

== Logic Optimization with ABC
Run:
```yosys
abc
```
The `abc` command sends combinational logic to the ABC optimization engine for additional Boolean
logic optimization and technology mapping.

== Final Optimization
Run:
```yosys
opt
```
The final `opt` command performs another cleanup and optimization pass after ABC processing.

== Writing the Synthesized Verilog Netlist
Once synthesis is complete, generate the synthesized Verilog netlist:
```yosys
write_verilog ./bin/netlist_ripple_carry_adder.v
```
The `write_verilog` command writes the current synthesized design into a Verilog source file. The
resulting file is: `./bin/netlist_ripple_carry_adder.v` This file represents the synthesized structural implementation rather than the original RTL description.

== Displaying Synthesis Statistics
Run:
```yosys
stat -tech cmos -width
```

The `stat` command displays statistics about the synthesized design, including the number and types
of cells used. You can use these statistics to get an idea of the hardware resources required by the
design.

== Generating netlist diagram
Finally run:
```yosys
show -format svg -stretch -width -colors 10000 -signed \
    -prefix ./bin/rtl_elab_ripple_carry_adder
```
This will generate the diagram `./bin/rtl_elab_ripple_carry_adder.dot` which you can
view using #link("https://flathub.org/en/apps/org.kde.kgraphviewer")[KGraphViewer].

== Complete Yosys Shell Procedure
The complete sequence of commands is:

```yosys
read -sv ./src/full_adder.sv
read -sv ./src/ripple_carry_adder.sv
read -sv ./src/top_rca.sv

hierarchy -check -auto-top

proc
opt
fsm
opt
techmap
alumacc
opt
memory
opt
abc
opt

write_verilog ./bin/netlist_ripple_carry_adder.sv
stat -tech cmos -width

show -format dot -stretch -width -colors 10000 -signed \
    -prefix ./bin/rtl_elab_ripple_carry_adder
```

After entering the commands, exit the Yosys shell using:
```yosys
exit
```

This procedure demonstrates the basic Yosys synthesis flow interactively and allows each synthesis
stage to be executed and observed individually.

= Using the Previous Explicit Yosys Script
The explicit synthesis flow used in the previous Yosys material can be used for this design:
```yosys
# ----- read all RTL files
read -sv ./src/full_adder.sv
read -sv ./src/ripple_carry_adder.sv
read -sv ./src/top_rca.sv

# ----- find the top module
hierarchy -check -auto-top

# ----- synthesis
proc
opt
fsm
opt
techmap
alumacc
opt
memory
opt
abc
opt

# ----- write verilog netlist
write_verilog ./bin/top_rca.sv

# ----- write json netlist
json -aig -o ./bin/top_rca.json

# ----- find resource utilization
stat -tech cmos -width

# ----- generate ntelihs schematic
show -format dot -stretch -width -colors 10000 -signed -prefix ./bin/top_rca
```

The script can be saved as:
```text
./yosys_run.ys
```

and executed with:
```bash
yosys ./yosys_run.ys
```

== #text(fill: red)[EXERCISE]
Try to generate a netlist schematic for the module `./src/full_adder.sv` and observe what is the
difference.

= FPGA Architectures Supported by Yosys
Yosys is primarily an RTL synthesis framework. FPGA support is provided through
architecture-specific synthesis and mapping flows. Different FPGA families contain different
primitive resources, so the same RTL must be mapped differently for different targets.

Conceptually:

#align(center)[
```text
                    RTL
                     |
                   Yosys
                     |
          +----------+----------+
          |                     |
          v                     v
    Lattice ECP5            Xilinx
       mapping              mapping
          |                     |
          v                     v
   ECP5 primitives       Xilinx primitives
```
]

Yosys-based flows support many FPGA families, including commonly used Lattice and Xilinx families.
The exact synthesis and downstream implementation flow depends on the device.

This lab focuses on:

- #link("https://radiona.org/ulx3s/")[Radiona ULX3S using Lattice ECP5]
- #link("https://digilent.com/shop/basys-3-amd-artix-7-fpga-trainer-board-recommended-for-introductory-users/")[DigilentBasys 3 using Xilinx Artix-7 series]

= Synthesizing for Radiona ULX3S
The ULX3S belongs to the Lattice ECP5 family. Yosys provides the architecture-specific command:
```yosys
synth_ecp5 -top top_rca -json ./bin/top_rca_ecp5.json
```
This performs synthesis and mapping appropriate for the ECP5 architecture. It requires a JSON
netlist as a pre requisite. The resulting JSON netlist can then be used by an appropriate ECP5
place-and-route flow.

For a particular board, the exact device, package, pin constraints, and bitstream-generation
commands must match the board documentation.

== #text(fill: red)[EXERCISE]
Try to generate a JSON netlist and a netlist schematic of the module `./src/top_rca.sv` for the
ULX3S FPGA running Lattice ECP chip.

= Synthesizing for the Basys 3
The Digilent Basys 3 uses a Xilinx Artix-7 FPGA. For Xilinx 7-series devices, Yosys provides:
```yosys
synth_xilinx -top top_rca -flatten -json ./bin/top_rca_xilinx.json
```

This maps the design toward Xilinx 7-series primitives. The resulting netlist is intended for the
downstream Xilinx implementation flow. Unlike the ECP5 flow, the Basys 3 is not implemented using
`nextpnr-ecp5`. The downstream implementation tools must support the Xilinx 7-series architecture.

== #text(fill: red)[EXERCISE]
Try to generate a JSON netlist and a netlist schematic of the module `./src/top_rca.sv` for the
Basys3 FPGA running Xilinx Artix-7 chip.

= Same RTL, Different FPGA Architectures
The RTL does not need to change simply because the target FPGA changes. The same files can be
synthesized for different FPGA families. What changes is the technology mapping:

#align(center)[
```text
                     Same RTL
                        |
             +----------+----------+
             |                     |
             v                     v
       synth_ecp5            synth_xilinx
             |                     |
             v                     v
       iCE40 cells           Xilinx cells
```
]

This demonstrates a major advantage of RTL design: the hardware description can remain largely
technology-independent while the synthesis flow maps it to the resources of a particular FPGA.

= Makefile Automation
A Makefile can automate the architecture-specific flows:

```makefile
RTL = src/full_adder.sv src/ripple_carry_adder.sv src/top_rca.sv
TOP = top_rca

synth_default:
    mkdir -p ./bin
    yosys -p "\
    read -sv $(RTL); \
        hierarchy -check -auto-top; \
        proc; opt; fsm; opt; \
        techmap; alumacc; \
        opt; memory; opt; abc; opt; \
        write_verilog ./bin/top_rca.sv; \
        json -aig -o ./bin/top_rca.json; \
        stat -tech cmos -width; \
        show -format dot -stretch -width -colors 10000 -signed -prefix ./bin/$(TOP)"
```

== #text(fill: red)[EXERCISE]
- Write `Makefile` targets `synth_exp5` and `synth_xilinx` that can generate netlists for the ECP5
  and Artix-7 families of FPGAs.
- Write `Makefile` targets that use yosys scripts (`.ys`) to generate netlists for all posiible
  architectures.

= Inspecting the Generated Netlist
After synthesis, inspect the generated netlist. The generated file should no longer look like the
original behavioral RTL. Depending on the synthesis flow, it may contain wires, cells, instantiated
primitives, LUT structures, and registers.

= Inspecting Synthesis Statistics
Run Yosys with `stat` and `stat -tech cmos -width`. The final synthesized cell count may differ from
the number of RTL module instances because Yosys can optimize and restructure the design.

= Generic Versus Architecture-Specific Synthesis
A generic netlist can be produced with:
```yosys
write_verilog
```
while architecture-specific synthesis uses:
```yosys
synth_ecp5
```
or:
```yosys
synth_xilinx
```

Conceptually:
#align(center)[
```text
                  RTL
                   |
                   v
             Generic synthesis
                   |
                   v
            Generic netlist
              /         \
             /           \
            v             v
      iCE40 mapping   Xilinx mapping
            |             |
            v             v
      iCE40 netlist   Xilinx netlist
```
]

= Lab Procedure

- *Step 1:* Run Generic Synthesis
- *Step 2:* Inspect the Netlist
- *Step 3:* Check Statistics
- *Step 4:* Synthesize for ULX3S
- *Step 5:* Synthesize for Basys 3
- *Step 6:* Compare the Results

Compare the generated outputs.

The source RTL remains the same, but the synthesized structures differ because the target
architectures contain different hardware resources.

= Key Concepts

#table(
  columns: (1.5fr, 3fr),
  table.header([*Concept*], [*Description*]),
  [RTL], [Behavioral or structural description of the intended hardware.],
  [Synthesis], [Transformation of RTL into a lower-level hardware representation.],
  [Netlist], [Structural description of cells and their interconnections.],
  [Technology mapping], [Conversion of generic hardware into cells or primitives belonging to a target technology.],
  [`genvar`], [SystemVerilog construct used to generate repeated hardware structures during elaboration.],
  [`WIDTH`], [Parameter controlling the data width and number of generated full-adder instances.],
  [`synth_ecp5`], [Yosys synthesis flow for Lattice ECP devices.],
  [`synth_xilinx`], [Yosys synthesis flow for Xilinx devices, including 7-series families.],
  [Place and route], [Maps the synthesized design into physical FPGA resources and routing.],
  [Bitstream], [Final configuration data used to program an FPGA.]
)
