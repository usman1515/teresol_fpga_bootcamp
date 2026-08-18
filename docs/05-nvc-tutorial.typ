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
  #text(size: 25pt, weight: "bold")[Lab 5 — VHDL Simulation Using NVC]
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

The objective of this lab is to learn how to simulate a VHDL hardware design on a Linux system using
open-source tools.

In this lab, we will use:

- *NVC* for analyzing, elaborating, and simulating VHDL designs.
- *GTKWave* for viewing simulation waveforms.
- *GNU Make* for automating the simulation workflow.

For the hardware design used in this lab, we will implement an *8-bit Arithmetic Logic Unit (ALU)*.
The ALU supports four operations:

#table(
  columns: (20%, 30%, 50%), stroke: 0.5pt, inset: 8pt,
  [*Mode*], [*Operation*], [*Description*],
  [`00`], [OP_ADD], [8-bit addition of `i_a` and `i_b`],
  [`01`], [OP_SUB], [8-bit subtraction of `i_b` from `i_a`],
  [`10`], [OP_AND], [Bitwise AND of `i_a` and `i_b`],
  [`11`], [OP_OR], [Bitwise OR of `i_a` and `i_b`],
)

The complete workflow used in this lab is:

#align(center)[
```text
Write VHDL Design
        |
        v
Write VHDL Testbench
        |
        v
Analyze using NVC
        |
        v
Elaborate the Testbench
        |
        v
Run Simulation
        |
        v
Generate VCD Waveform
        |
        v
View Waveform using GTKWave
```
]

The purpose of this lab is not to program an FPGA. Instead, we will verify the behavior of a VHDL
design through software simulation using free and open-source software.

= Required Tools
For this lab, we need a Linux system with Fedora installed.

#table(
  columns: (20%, 80%), stroke: 0.5pt, inset: 8pt,
  [*Tool*], [*Purpose*],
  [`nvc`], [VHDL analyzer, elaborator, and simulator],
  [`gtkwave`], [Graphical waveform viewer],
  [`make`], [Automates analysis, elaboration, simulation, and waveform commands],
)

== Installing NVC from Source
NVC is a free and open-source VHDL compiler and simulator. Unlike several of the other
hardware-design tools used in this lab series, NVC is not included in the OSS CAD Suite. Therefore,
NVC will be built and installed separately from its source code.

Building NVC from source gives us a consistent installation method and allows the team to work with
the latest source or a specific released version when required.

You can refer to the installation instructions from here: 
#link("https://github.com/nickg/nvc#installing")[https://github.com/nickg/nvc#installing].

For this lab, we will use:
- `nvc` — VHDL analyzer, elaborator, and simulator.
- `gtkwave` — Graphical waveform viewer.

== Installing Other Tools
It is also useful to make sure that `make` is installed:
```bash
sudo dnf install make
```

Make sure NVC is available:
```bash
nvc --version
```

Verify GTKWave:
```bash
gtkwave --version
```

You can also check the NVC executable:
```bash
which nvc
```

= Creating the Lab Directory
Create a directory for the NVC VHDL simulation lab:
```bash
mkdir -p lab-05-vhdl-sim-nvc
cd lab-05-vhdl-sim-nvc
```

Create the source, testbench, and binary directories:
```bash
mkdir src tb bin
```

The resulting project structure is:
```text
lab-05-vhdl-sim-nvc/
├── src/
├── tb/
└── bin/
```

We will eventually have:
```text
lab-05-vhdl-sim-nvc/
├── src/
│   └── alu.vhd
├── tb/
│   └── tb_alu.vhd
├── bin/
│   └── tb_alu.vcd
├── work/
└── Makefile
```

The `src/` directory contains the Design Under Test (DUT).

The `tb/` directory contains the testbench used to stimulate and verify the DUT.

The `bin/` directory contains generated simulation outputs such as the VCD waveform.

The `work/` directory is the default NVC working library. NVC stores analyzed and elaborated design
information in this directory.

= Creating the VHDL Design
For this lab, we will implement an 8-bit Arithmetic Logic Unit (ALU).

The ALU accepts two 8-bit operands, `i_a` and `i_b`, and uses a 2-bit `i_mode` input to select one
of four operations. Create the RTL file:

```text
touch ./src/alu.vhd
```

Add:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        i_a      : in  std_logic_vector(7 downto 0);
        i_b      : in  std_logic_vector(7 downto 0);
        i_mode   : in  std_logic_vector(1 downto 0);
        o_result : out std_logic_vector(7 downto 0)
    );
end entity alu;

architecture rtl of alu is
begin

    proc_alu : process(all)
    begin
        case i_mode is
            when "00" =>
                o_result <= std_logic_vector(unsigned(i_a) + unsigned(i_b));
            when "01" =>
                o_result <= std_logic_vector(unsigned(i_a) - unsigned(i_b));
            when "10" =>
                o_result <= i_a and i_b;
            when "11" =>
                o_result <= i_a or i_b;
            when others =>
                o_result <= (others => '0');
        end case;
    end process proc_alu;

end architecture rtl;
```

#block(
  fill: luma(245), stroke: (left: 3pt + blue), inset: 10pt, radius: 4pt,
)[*NOTE:* Keep the entity name and source filename consistent. In this lab, the entity `alu` is
stored in `alu.vhd`. This naming convention makes larger VHDL projects easier to organize.]

== Understanding the Design
The design contains an entity named:
```vhdl
entity alu is
```

The entity defines the external interface of the ALU. It has four ports:

```text
i_a
i_b
i_mode
o_result
```

`i_a` and `i_b` are the two 8-bit input operands. `i_mode` is a 2-bit control signal that selects
the operation. `o_result` is the 8-bit output.

== The `std_logic_vector` Type
The operands are declared as. This represents an 8-bit vector:
```vhdl
std_logic_vector(7 downto 0)
```

For arithmetic operations, we use the `numeric_std` package and explicitly convert the vectors to
`unsigned` values:
```vhdl
unsigned(i_a) + unsigned(i_b)
```
This makes the intended arithmetic interpretation explicit.

The result is eight bits wide. Arithmetic results that exceed the available eight bits wrap around
according to the 8-bit representation.

= Creating the VHDL Testbench
A VHDL design does not automatically generate its own input stimuli during simulation. To test the
ALU, we need a separate VHDL testbench.

The testbench will:

- Instantiate the ALU.
- Apply different values to `A` and `B`.
- Select each of the four ALU modes.
- Wait for the combinational output to settle.
- End the simulation.

Create:
```text
touch ./tb/tb_alu.vhd
```

Add:
```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu is
end entity tb_alu;

architecture sim of tb_alu is

    signal i_a      : std_logic_vector(7 downto 0);
    signal i_b      : std_logic_vector(7 downto 0);
    signal i_mode   : std_logic_vector(1 downto 0);
    signal o_result : std_logic_vector(7 downto 0);

begin

    DUT_alu_1 : entity work.alu
        port map (
            i_a => i_a,
            i_b => i_b,
            i_mode => i_mode,
            o_result => o_result
        );

    main_tb : process
    begin
        -- ADD: 25 + 10 = 35
        i_a <= x"19";   i_b <= x"0A";   i_mode <= "00";
        wait for 10 ns;

        -- SUB: 25 - 10 = 15
        i_a <= x"19";   i_b <= x"0A";   i_mode <= "01";
        wait for 10 ns;

        -- AND: 0xF0 AND 0x0F = 0x00
        i_a <= x"F0";   i_b <= x"0F";   i_mode <= "10";
        wait for 10 ns;

        -- OR: 0xF0 OR 0x0F = 0xFF
        i_a <= x"F0";   i_b <= x"0F";   i_mode <= "11";
        wait for 10 ns;

        wait;
    end process main_tb;

end architecture sim;
```

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*NOTE:* Testbench entities should follow the naming convention `tb_<rtl_entity_name>`. In this
lab, the ALU entity is `alu`, so the testbench entity is `tb_alu`.]

= Understanding the Testbench
The testbench starts with:
```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
```

The `std_logic_1164` package provides commonly used digital logic types such as `std_logic` and
`std_logic_vector`. The `numeric_std` package provides numeric operations for types such as
`unsigned`.

== Testbench Signals
The testbench declares:
```vhdl
signal i_a : std_logic_vector(7 downto 0);
signal i_b : std_logic_vector(7 downto 0);
signal i_mode : std_logic_vector(1 downto 0);
signal o_result : std_logic_vector(7 downto 0);
```
These signals represent the inputs and output of the ALU.

== Instantiating the ALU
The ALU is instantiated using:
```vhdl
DUT_alu_1 : entity work.alu
    port map (
        i_a => i_a,
        i_b => i_b,
        i_mode => i_mode,
        o_result => o_result
    );
```

`DUT_alu_1` stands for *Unit Under Test*. The `entity work.alu` reference identifies the `alu`
entity in the VHDL working library. The `port map` connects testbench signals to the ALU ports.

== Applying Test Stimulus
The testbench uses a `process` block. Input values are assigned to the ALU, for example:
```vhdl
i_a <= x"19";   i_b <= x"0A";   i_mode <= "00";
```
The testbench then `wait for 10 ns` before applying the next set of inputs. Because the ALU is
combinational, no clock is required.

= Running the Simulation
Once both files have been created, the project should contain:
```text
lab-05-vhdl-sim-nvc/
├── src/
│   └── alu.vhd
├── tb/
│   └── tb_alu.vhd
└── bin/
```

NVC separates the VHDL workflow into three important stages:
```text
Analysis
   |
   v
Elaboration
   |
   v
Simulation
```

== Step 1: Analysis
*Analysis* checks the VHDL source and compiles it into NVC's working library.

For example:
```bash
nvc --std=08 -a ./src/alu.vhd
nvc --std=08 -a ./tb/tb_alu.vhd
```
Analysis does not run the testbench.

== Step 2: Elaboration
*Elaboration* prepares the selected top-level design for simulation. In this lab, the top-level
entity is `tb_alu`. Elaboration resolves the design hierarchy and prepares the selected top-level design for simulation:
```bash
nvc --std=08 -e tb_alu
```

== Step 3: Simulation
*Simulation* actually runs the testbench. For example:
```bash
nvc --std=08 -r tb_alu --format=vcd --wave=./bin/tb_alu.vcd \
    --dump-arrays --stop-time=200ns --exit-severity=error
```

During simulation, the testbench applies values to the ALU and the ALU produces the corresponding
results. The three stages can be summarized as:

#table(
  columns: (25%, 75%), stroke: 0.5pt, inset: 7pt,
  [*Stage*], [*Purpose*],
  [Analysis], [Check and compile each VHDL source file into the working library.],
  [Elaboration], [Build the selected top-level simulation hierarchy.],
  [Simulation], [Execute the testbench and observe the design behavior.],
)

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*EXERCISE:* Find out what is the purpose of every flag in the NVC commands are. In particular,
investigate the purpose of `--std=08`, `-a`, `-e`, `-r`, `--format=vcd`, `--dump-arrays`,
`--exit-severity`, and `--stop-time`.]

= Understanding the VCD File
VCD stands for *Value Change Dump*. A VCD file records changes in digital signals during simulation.
The VCD file can be opened using GTKWave.

= Automating the Process with GNU Make
Typing the complete NVC commands manually becomes inconvenient as a project becomes larger. For
example, every time the design is changed, we would need to execute:

```bash
nvc --std=08 -a ./src/alu.vhd
nvc --std=08 -a ./tb/tb_alu.vhd

nvc --std=08 -e tb_alu

nvc --std=08 -r tb_alu --format=vcd --wave=./bin/tb_alu.vcd \
    --dump-arrays --stop-time=200ns --exit-severity=error
```

We can automate these commands using a `Makefile`. Create:
```bash
touch Makefile
```

Add:
```makefile
TOP = tb_alu
SRC = ./src/alu.vhd
TB  = ./tb/tb_alu.vhd

NVC_FLAGS = --std=08

compile:
	mkdir -p ./bin
	nvc $(NVC_FLAGS) -a $(SRC)
	nvc $(NVC_FLAGS) -a $(TB)
	nvc $(NVC_FLAGS) -e $(TOP)

run:
	nvc $(NVC_FLAGS) -r $(TOP) --format=vcd --wave=./bin/$(TOP).vcd --stop-time=200ns

wave:
	gtkwave ./bin/$(TOP).vcd

clean:
	rm -rf ./bin/*.vcd
	rm -rf work/
```

The commands underneath each target must begin with a *tab character*, not spaces.

= Using the Makefile
The Makefile provides four targets.

== Compile
Run:
```bash
make compile
```

This performs analysis of both VHDL files and elaborates the testbench. It is equivalent to:
```bash
nvc --std=08 -a ./src/alu.vhd
nvc --std=08 -a ./tb/tb_alu.vhd
nvc --std=08 -e tb_alu
```

== Run
Run:
```bash
make run
```

This executes the simulation. The waveform is generated as:
```text
bin/tb_alu.vcd
```

== View the Waveform
Run:
```bash
make wave
```

== Clean
Run:
```bash
make clean
```

This removes generated simulation files.

= Final Project Structure
After completing the lab:
```text
lab-05-vhdl-sim-nvc/
├── src/
│   └── alu.vhd
├── tb/
│   └── tb_alu.vhd
├── bin/
│   └── tb_alu.vcd
├── work/
└── Makefile
```

= Simulation Versus FPGA Implementation
One of the most important concepts to understand is that *simulation is not the same as FPGA
implementation*.

In this lab, we are only simulating the VHDL design.

No FPGA is required.

No bitstream is generated.

No physical hardware is programmed.

= Important NVC Command Reference

#table(
  columns: (20%, 80%), stroke: 0.5pt, inset: 7pt,
  [`nvc -a`], [Analyze a VHDL source file and place the compiled design unit into the working
  library.],
  [`nvc -e`], [Elaborate the selected top-level entity and prepare the design for simulation.],
  [`nvc -r`], [Run a previously elaborated design using NVC's simulation runtime.],
  [`--std=2008`], [Use the VHDL-2008 language standard.],
  [`--format=vcd`], [Select VCD as the waveform output format.],
  [`--wave=FILE`], [Write waveform data to the specified file.],
  [`--stop-time=T`], [Stop the simulation after the specified simulation time.],
)

