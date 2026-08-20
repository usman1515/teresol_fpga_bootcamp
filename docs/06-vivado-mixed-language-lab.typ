// global page size and page margins.
#set page(paper: "a4", margin: 1in)
// global default font family and font size for the document.
#set text(font: "Noto Sans", size: 11pt)
// #set text(font: "New Computer Modern", size: 11pt)
// global paragraph alignment and line spacing.
// #set par(justify: true, leading: 0.65em, spacing: 2em)
#set par(leading: 0.65em, spacing: 2em)
// show all links as underlined and blue
#show link: underline
#show link: set text(blue)
// number all headings
#set heading(numbering: "1.1.")
// number all pages
#set page(numbering: "1")

// Define a reusable "note" block.
#let note(body) = block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
  body
)

// Define a reusable "warning" block.
#let warning(body) = block(
  fill: rgb("#FFF3CD"),
  // stroke: (left: 3pt + rgb("#C58A00")),
  stroke: (left: 3pt + red),
  inset: 10pt,
  radius: 4pt,
  body,
)

// Define a reusable block for displaying shell commands.
#let command(body) = block(
  fill: rgb("#F5F5F5"),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
  body,
)


// title page
#align(center)[
  #v(3cm)
  #text(size: 15pt, weight: "bold")[FPGA Development Team]
  #v(1.2cm)
  #text(size: 25pt, weight: "bold")[Lab 6 — Mixed-Language FPGA Design and Simulation with Vivado]
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
Modern FPGA projects frequently contain RTL written in more than one hardware description language.
A project may contain legacy VHDL IP, newer SystemVerilog RTL, and verification environments written
in either language.

For this reason, an FPGA engineer should understand how a commercial FPGA toolchain handles multiple
HDLs within the same project.

This lab introduces the mixed-language workflow using *AMD Vivado*. The lab starts with individual
VHDL and SystemVerilog flows and gradually combines them into a single design hierarchy.

The objective is not simply to simulate these designs. The main objective is to understand how
Vivado compiles, elaborates, simulates, and synthesizes designs containing VHDL and SystemVerilog
together.

You should have AMD Xilinx Vivado installed. If Vivado is not in your `PATH`, source its environment
script. For example:

#command[
  ```bash
  source /tools/Xilinx/Vivado/<version>/settings64.sh
  ```
]

Replace `<version>` with the installed Vivado version.

#note[*NOTE:* This lab intentionally emphasizes the command line. The same concepts can be performed
through the Vivado GUI, but command-line flows are easier to reproduce and automate using Tcl,
Makefiles, and CI/CD systems.]

= What Is Vivado?
*AMD Vivado Design Suite* is a development environment for designing and implementing digital systems on AMD/Xilinx FPGAs.

A simplified FPGA development flow is:

#align(center)[
```text
RTL Design
    |
    v
Compilation / Elaboration
    |
    +----> Simulation
    |
    v
Synthesis
    |
    v
Implementation
    |
    v
Bitstream Generation
    |
    v
FPGA Programming
```
]

This lab concentrates on:
- HDL compilation;
- elaboration;
- RTL simulation;
- synthesis;
- mixed-language design handling.

Vivado supports VHDL, Verilog, and SystemVerilog, allowing different parts of a design to be written
in different HDLs.

= Vivado Project Mode
In *project mode*, Vivado creates a project containing information about the design.

A project can contain:
- RTL source files;
- simulation files;
- constraint files;
- FPGA part information;
- synthesis settings;
- implementation settings;
- simulation settings;
- generated outputs.

A typical project may look like:

#command[
```text
my_project/
├── my_project.xpr
├── my_project.srcs/
├── my_project.gen/
├── my_project.sim/
├── my_project.runs/
└── ...
```
]

The project can be opened with:
#command[
  ```bash
  vivado my_project.xpr
  ```
]

Project mode is useful for interactive development because Vivado maintains the project
configuration for you.

= Non-Project and Batch Mode
Vivado can also be operated without maintaining a traditional project. In a command-line flow,
source files and configuration are supplied through Tcl commands.

For example:
#command[
  ```tcl
  read_vhdl ./rtl/half_adder.vhd
  read_verilog -sv ./rtl/ripple_adder.sv
  ```
]

A Tcl script can then be executed in batch mode:
#command[
```bash
vivado -mode batch -source build.tcl
```
]

Vivado starts, executes the commands, and exits. The resulting flow is:
#align(center)[
```text
Source Files
     |
     v
Tcl Script
     |
     v
Vivado Batch Mode
     |
     +--> Compile
     +--> Elaborate
     +--> Simulate
     +--> Synthesize
     |
     v
Generated Results
```
]

#note[*NOTE:* Batch mode is particularly useful for FPGA teams because the build procedure can be
stored in version control and reproduced on another machine without manually configuring the Vivado
GUI.]

= Compilation, Elaboration, Simulation, and Synthesis
These terms describe different stages of an HDL workflow.

== Compilation
Compilation reads HDL source code and converts it into a representation that the tool can use.
Compilation primarily deals with the source file itself and checks language syntax and semantics.

== Elaboration
Elaboration constructs the actual design hierarchy from the compiled HDL objects. During
elaboration, instances, parameters, generics, ports, and hierarchical relationships are resolved.

== Simulation
Simulation executes the elaborated RTL together with a testbench over simulated time. Simulation is
primarily used to verify functional behavior before synthesis and implementation.

== Synthesis
Synthesis transforms synthesizable RTL into a hardware representation suitable for the target FPGA.
A testbench is normally not synthesized because it contains simulation-only constructs.

= Mixed-Language Compilation
Mixed-language compilation means compiling source files written in different HDLs so that they can
participate in the same design environment.

For example:

#align(center)[
```text
half_adder.vhd
      |
      | VHDL
      v
   Vivado
      ^
      | SystemVerilog
      |
ripple_adder.sv
```
]

The two source files can subsequently form one design hierarchy.

#note[*NOTE:* Throughout this manual, use the term *mixed-language compilation* rather than *cross
compilation* when referring to VHDL and SystemVerilog being used together. ]

= Mixed-Language Synthesis
Similarly, the preferred term for synthesizing a hierarchy containing multiple HDLs is
Mixed-Language Synthesis.

For example:

#v(2cm)
#align(center)[
```text
             ripple_adder
            SystemVerilog
                  |
         +--------+--------+
         |        |        |
         v        v        v
      half_adder half_adder ...
          VHDL       VHDL
```
]

Vivado elaborates the hierarchy and then synthesizes the combined design into an FPGA-oriented
netlist. The HDL language boundary does not remain as a hardware boundary.

= Labs
== Design 1: VHDL Half Adder and SystemVerilog Ripple-Carry Adder
The first design demonstrates mixed-language RTL hierarchy. The one-bit full adder is written in
VHDL. The N-bit ripple-carry structure is written in SystemVerilog. The top wrapper top_rca is
written again in VHDL.

#warning[ *WARNING:* When instantiating VHDL entities from SystemVerilog, follow Vivado's
mixed-language binding rules for the particular Vivado version being used. If elaboration fails,
inspect the entity name, port names, port types, libraries, and generated hierarchy. ]

== Design 2: 8-Bit ALU
The second design is an 8-bit ALU with 16 operations. The VHDL version should expose equivalent
functionality and an equivalent interface. The same ALU functionality will be verified using both
VHDL and SystemVerilog testbenches.

This allows four combinations:

#table(
  columns: (15%, 20%, 20%, 45%),
  inset: 6pt,
  align: center,
  [*Experiment*], [*RTL*], [*Testbench*], [*Purpose*],
  [1], [VHDL], [VHDL], [VHDL-only simulation],
  [2], [SystemVerilog], [SystemVerilog], [SystemVerilog-only simulation],
  [3], [VHDL], [SystemVerilog], [Mixed-language simulation],
  [4], [SystemVerilog], [VHDL], [Mixed-language simulation],
)

= Mixed-Language Synthesis
== Part 1: Direct VHDL Synthesis
The first stage is to synthesize a VHDL design directly from the Vivado command line. Assume:
`full_adder.vhd`

Create a Tcl script called `./scripts/synth_vhdl_full_adder.tcl`:

#command[
  ```tcl
  read_vhdl ./src/full_adder.vhd

  synth_design -top full_adder -part xc7a35tcpg236-1 -flatten_hierarchy rebuilt

  file mkdir ./bin

  report_utilization -file ./bin/vhdl_full_adder_utilization.rpt

  report_timing_summary -file ./bin/vhdl_full_adder_timing.rpt

  write_checkpoint -force ./bin/vhdl_full_adder_synthesis.dcp
  ```
]

Here `xc7a35tcpg236-1` is the target FPGA part. In our case we are using the Basys3. This value
can be changed depending on the FPGA we are using. Run:

#command[
```bash
vivado -mode batch -source ./scripts/synth_vhdl_full_adder.tcl -notrace
```
]

== Part 2: VHDL + SystemVerilog Synthesis
Now synthesize the SystemVerilog `ripple-carry-adder` design. Assume:

#command[
```text
rtl/
├── half_adder.vhd
└── ripple_adder.sv
```
]

Create a Tcl script called `./scripts/synth_mixed_ripple_carry_adder.tcl`:

#command[
```tcl
read_vhdl ./src/full_adder.vhd
read_verilog -sv ./src/ripple_carry_adder.sv
read_vhdl ./src/top_rca.vhd

synth_design -top top_rca -part xc7a35tcpg236-1 -flatten_hierarchy rebuilt

file mkdir ./bin

report_utilization -file ./bin/vhdl_top_rca_utilization.rpt

report_timing_summary -file ./bin/vhdl_top_rca_timing.rpt

write_checkpoint -force ./bin/vhdl_top_rca_synthesis.dcp
```
]

Notice that the VHDL `full_adder` is also read. This is necessary because the SystemVerilog design
depends on the VHDL IP. Vivado does not synthesize the VHDL and SystemVerilog portions as two
unrelated designs. Instead, it resolves the complete hierarchy and synthesizes the combined
hardware.

= Mixed-Language Simulation
== Part 1: VHDL RTL and VHDL Testbench
The first simulation experiment uses VHDL for both RTL and testbench.

Create a Bash script called `./scripts/sim_vhdl_ip_vhdl_tb.sh`:

#command[
```bash
xvhdl -incr -2008 -v 0 ./src/alu.vhd
xvhdl -incr -2008 -v 0 ./tb/tb_alu.vhd

xelab --snapshot behav_tb_alu -O2 -v 0 -incr --mt 8 -stats \
    -log ./elab_tb_alu_vhdl_ip_vhdl_tb.log tb_alu

xsim behav_tb_alu -runall -ieeewarnings -log ./bin/sim_tb_alu_vhdl_ip_vhdl_tb.log
```
]

The testbench `tb_alu` is the simulation top not the DUT. Both files are VHDL, so this is a
single-language simulation flow.

== Part 2: VHDL RTL and SystemVerilog Testbench
Now change only the testbench language.

Create a Bash script called `./scripts/sim_vhdl_ip_sv_tb.sh`:

#command[
```bash
xvhdl -incr -2008 -v 0 ./src/alu.vhd
xvlog -incr -sv -v 0 ./tb/tb_alu.sv

xelab --snapshot behav_tb_alu -O2 -v 0 -incr --mt 8 -stats \
    -log ./elab_tb_alu_vhdl_ip_sv_tb.log tb_alu

xsim behav_tb_alu -runall -ieeewarnings -log ./bin/sim_tb_alu_vhdl_ip_sv_tb.log
```
]

This is a mixed-language simulation because the elaborated hierarchy contains both VHDL and SystemVerilog.

#note[*NOTE:* The important concept is that the testbench language does not need to match the RTL
language. Vivado's simulator can elaborate a hierarchy containing both. ]

== Part 3: SystemVerilog RTL and VHDL Testbench
Now reverse the languages.

Create a Bash script called `./scripts/sim_sv_ip_vhdl_tb.sh`:

#command[
```bash
xvlog -incr -sv -v 0 ./src/alu.sv
xvhdl -incr -2008 -v 0 ./tb/tb_alu.vhd

xelab --snapshot behav_tb_alu -O2 -v 0 -incr --mt 8 -stats \
    -log ./elab_tb_alu_vhdl_ip_sv_tb.log tb_alu

xsim behav_tb_alu -runall -ieeewarnings -log ./bin/sim_tb_alu_sv_ip_vhdl_tb.log
```
]

== Part 4: SystemVerilog RTL and SystemVerilog Testbench
Now use SystemVerilog for both RTL and testbench.

Create a Bash script called `./scripts/sim_sv_ip_sv_tb.sh`:

#command[
```bash
xvlog -incr -sv -v 0 ./src/alu.sv
xvlog -incr -sv -v 0 ./tb/tb_alu.sv

xelab --snapshot behav_tb_alu -O2 -v 0 -incr --mt 8 -stats \
    -log ./elab_tb_alu_vhdl_ip_sv_tb.log tb_alu

xsim behav_tb_alu -runall -ieeewarnings -log ./bin/sim_tb_alu_sv_ip_sv_tb.log
```
]
Vivado identifies SystemVerilog source from the `.sv` extension and compiles the files using its
SystemVerilog support.

= Project Mode vs Batch Mode in This Lab

The same design can be developed in Vivado project mode. A project provides persistent
configuration:

```text
Project
 |
 +-- RTL
 +-- Simulation
 +-- Constraints
 +-- Synthesis settings
 +-- Implementation settings
 +-- Generated data
```

However, for reproducible engineering workflows, the batch approach is often preferable. For
example:

```bash
vivado -mode batch -source scripts/sim_vhdl_sv.tcl
```

The complete flow is then represented by source-controlled Tcl scripts.

This makes it possible to reproduce the build on:

- another workstation;
- a clean build machine;
- a CI/CD runner;
- a different engineer's development environment.

= Recommended Project Structure
Use the following directory structure:

```text
vivado-mixed-language/
├── rtl/
├── tb/
├── constraints/
├── scripts/
└── bin/
```

Keep generated files under `bin/` rather than mixing them with source files. This makes the
repository easier to manage with Git.

= Automating the Flow
Once the Tcl commands have been verified manually, they can be invoked from a Makefile.

For example:
#command[
```makefile
sim_vhdl:
	vivado -mode batch -source scripts/sim_vhdl.tcl

sim_sv:
	vivado -mode batch -source scripts/sim_sv.tcl

sim_vhdl_sv:
	vivado -mode batch -source scripts/sim_vhdl_sv.tcl

sim_sv_vhdl:
	vivado -mode batch -source scripts/sim_sv_vhdl.tcl

synth:
	vivado -mode batch -source scripts/synth_mixed.tcl
```
]

This creates a simple workflow:

```bash
make sim_vhdl
make sim_sv
make sim_vhdl_sv
make sim_sv_vhdl
make synth
```

The Makefile becomes the interface used by engineers while the Tcl scripts contain the
Vivado-specific implementation.

  #v(1cm)
= Key Concepts

#table(
  columns: (30%, 70%),
  inset: 6pt,
  align: left,
  [*Concept*], [*Meaning*],
  [Vivado], [AMD's FPGA development suite for RTL design, simulation, synthesis, implementation, and bitstream generation.],
  [Project mode], [Vivado maintains a project containing sources, configuration, runs, and generated data.],
  [Batch mode], [Vivado executes Tcl commands non-interactively, making the flow suitable for automation.],
  [Compilation], [Parses HDL source and creates a compiled representation.],
  [Elaboration], [Builds the actual hierarchical design from compiled HDL objects.],
  [Simulation], [Executes the elaborated RTL and testbench over simulated time.],
  [Synthesis], [Transforms synthesizable RTL into an FPGA-oriented netlist.],
  [Mixed-language compilation], [Compiles VHDL and SystemVerilog source so they can participate in the same design hierarchy.],
  [Mixed-language simulation], [Simulates a hierarchy containing VHDL and SystemVerilog components.],
  [Mixed-language synthesis], [Synthesizes a hardware hierarchy containing RTL written in multiple HDLs.],
  [Simulation top], [The top-level testbench used to start a simulation hierarchy.],
  [Synthesis top], [The top-level RTL entity/module passed to synthesis.],
)

= References

- #link("https://docs.amd.com/r/en-US/ug900-vivado-logic-simulation")[AMD Vivado Logic Simulation]
- #link("https://docs.amd.com/r/en-US/ug901-vivado-synthesis")[AMD Vivado Synthesis]
- #link("https://docs.amd.com/r/en-US/ug835-vivado-tcl-commands")[AMD Vivado Tcl Command Reference]
- #link("https://docs.amd.com/")[AMD Documentation]
