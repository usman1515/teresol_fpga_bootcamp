#set page(
  paper: "a4",
  margin: 1in,
)

#set text(
  font: "Noto Sans",
  size: 11pt,
)

// number all headings
#set heading(numbering: "1.1.")

// show all links as underlined and blue
#show link: underline
#show link: set text(blue)

// number all pages
#set page(numbering: "1")

// global paragraph spacing
#set par(
  spacing: 2em,
)

// title page
#align(center)[
  #v(3cm)
  #text(
    size: 15pt, weight: "bold",
  )[FPGA Development Team]

  #v(1.2cm)
  #text(
    size: 25pt, weight: "bold",
  )[Lab 2 — Verilog Simulation Using Icarus Verilog]

  #v(0.8cm)
  #text(
    size: 14pt, style: "italic",
  )[Onboarding Lab Manual]

  #v(3cm)
  #line(length: 70%)

  #v(1.5cm)
  #table(
    columns: (30%, 70%),
    align: (right, left),
    inset: 8pt,

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

// Table of Contents
#pagebreak()
#outline()
#pagebreak()



// LAB MANUAL begins from here
= Objective
The objective of this lab is to learn how to simulate a Verilog hardware design on a Linux system
using open-source tools.

In this lab, we will use:
- *Icarus Verilog* for compiling and simulating Verilog designs.
- *VVP* for executing the compiled simulation.
- *GTK Wave* for viewing simulation waveforms.
- *GNU Make* for automating the simulation workflow.

The complete workflow used in this lab is:

#align(center)[
```text
Write Verilog Design
        |
        v
Write Testbench
        |
        v
Compile using Icarus Verilog
        |
        v
Execute Simulation using VVP
        |
        v
Generate VCD Waveform
        |
        v
View Waveform using GTKWave
```
]

The purpose of this lab is not to program an FPGA. Instead, we will verify the behavior of a Verilog
design through simulation using OSS (Free Open Source Software) Verilog simulator.

= Required Tools
For this lab, we need a Linux system with Fedora installed. The following software is required:

#table(
  columns: (20%, 80%),
  stroke: 0.5pt,
  inset: 8pt,

  [*Tool*], [*Purpose*],
  [`iverilog`], [Verilog compiler and simulator],
  [`vvp`], [Executes the compiled Icarus Verilog simulation],
  [`gtkwave`], [Graphical waveform viewer],
  [`make`], [Automates compilation and simulation commands],
)

== Installing the OSS CAD Suite

For FPGA development, we will use the *OSS CAD Suite*, a collection of free and open-source tools for digital design, simulation, synthesis, and FPGA development. The suite brings together several commonly used FPGA and hardware-design tools into a single installation, making it easier to set up a consistent development environment across the team.

For this lab, we will use the following tools from the OSS CAD Suite:

- `iverilog` — Verilog compiler and simulator
- `vvp` — Simulation runtime used by Icarus Verilog
- `gtkwave` — Graphical waveform viewer

Instead of installing each tool individually through Fedora's package manager, we will install the OSS CAD Suite and use the tools provided by the suite throughout this onboarding series.

== Installing other tools
It is also useful to make sure that `make` is installed:
```bash
sudo dnf install make
```

Make sure, Icarus Verilog is installed and present in current shell session:
```bash
iverilog -V
```

Verify GTKWave:
```bash
gtkwave --version
```

You can also check that the Icarus Verilog simulator executable is available:
```bash
which iverilog
which vvp
```
The exact version numbers and installation paths may differ depending on the Fedora release.

= Creating the Lab Directory
Create a directory for the Verilog simulation lab:
```bash
mkdir -p lab-02-verilog-sim-iverilog
cd lab-02-verilog-sim-iverilog
```

We will organize the project into separate directories for the design source code, testbench, and generated simulation files.

Create the following directories:
```bash
mkdir src tb sim
```

The resulting project structure will be:
```text
verilog-lab/
├── src/
├── tb/
└── sim/
```

We will eventually have a project structure similar to:
```text
verilog-lab/
├── src/
│   └── counter.v
├── tb/
│   └── tb_counter.v
├── bin/
│   ├── counter.vvp
│   └── counter.vcd
└── Makefile
```

The purpose of separating these files is to keep the project organized.

The `src/` directory contains the actual hardware design/s, commonly referred to as the *Device Under
Test (DUT)*.

The `tb/` directory contains the testbench/es used to stimulate and verify the design.

The `sim/` directory contains files generated during simulation, such as the compiled simulation and
waveform file/s.

= Creating the Verilog Design
For this lab, we will implement a simple 4-bit binary counter.

Create the RTL file:
```text
touch ./src/counter.v
```

Add the following Verilog code:
```systemverilog
`timescale 1ns/1ps

module counter (
    input  wire       clk,
    input  wire       reset,
    output reg [3:0]  count
);

always @(posedge clk) begin
    if (reset)
        count <= 4'b0000;
    else
        count <= count + 1'b1;
end

endmodule

```

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*NOTE:* Always make sure that whenever you create an RTL design file the `module_name` and
  `file_name` are same. Otherwise this may cause compiilation issues depending upon the simulator.]

== Understanding the Design
The module is called `counter`:
```systemverilog
module counter (
```

It has three ports:
```text
clk
reset
count
```

- The `clk` input is the clock signal used to control when the counter changes.
- The `reset` input is used to return the counter to zero.
- The `count` output contains the current four-bit counter value.

The declaration:
```systemverilog
output reg [3:0] count
```
means that `count` is a four-bit register.

Therefore, the counter can represent values from `0000 = 0` through `1111 = 15`.
After 15, the four-bit counter wraps around to zero.

== Sequential Logic
The counter uses:
```systemverilog
always @(posedge clk)
```

This means that the statements inside the block execute whenever the clock transitions from `0` to `1`.

This is called a *positive clock edge* or *rising edge*.

Inside the block:

```systemverilog
if (reset)
    count <= 4'b0000;
```

When reset is active, the counter is set to zero.
Otherwise:

```systemverilog
// count <= count + 1'b1;
// ```

increments the counter by one.
The `<=` operator is a *non-blocking assignment*. Non-blocking assignments are commonly used when describing sequential hardware such as flip-flops and registers.

= Creating the Testbench
A Verilog design by itself does not automatically generate input signals.

To test the counter, we need another Verilog module called a *testbench*.

The testbench will:

- Generate a clock.
- Generate the reset signal.
- Instantiate the counter.
- Run the simulation for a specified amount of time.
- Record signals into a waveform file.
- Stop the simulation.

Create:
```text
touch ./tb/tb_counter.v
```

Add the following code snippet:
```systemverilog

`timescale 1ns/1ps

module tb_counter;

    reg clk;
    reg reset;
    wire [3:0] count;

    counter UUT_counter_1 (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // Clock generation
    always begin
        #5 clk=1'b1; #5 clk=1'b0;
    end

    initial begin

        // Initial values
        clk = 0;
        reset = 1;

        #10; reset = 0;

        #100;
        $finish;
    end

    // Generate waveform
    initial begin
        $dumpfile("./bin/tb_counter.vcd");
        $dumpvars(0, tb_counter);
    end

endmodule
```

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*NOTE:* Always make sure that whenever you create an TB file the `module_name` and
  `file_name` are same. Make sure that testbenches always follow the convention
  `tb_<rtl_module_name>`. Otherwise this may cause compiilation issues depending upon the simulator.]

= Understanding the Testbench
The testbench begins with:
```systemverilog
`timescale 1ns/1ps
```

This specifies the simulation time unit and time precision.
In this example:
```text
1 time unit = 1 nanosecond
```

and the simulator has a precision of:
```text
1 picosecond
```

== Declaring Testbench Signals
The testbench declares:
```systemverilog
reg clk;
reg reset;
wire [3:0] count;
```

The clock and reset are declared as `reg` because the testbench will actively drive these signals. The counter output is declared as a `wire` because it is driven by the counter module.

== Instantiating the Counter
The counter is instantiated using:

```systemverilog
counter UUT_counter_1 (
    .clk(clk),
    .reset(reset),
    .count(count)
);
```

Here `counter` is the module being instantiated and `UUT_counter_1` stands for *Unit Under Test*.
The testbench connects its signals to the ports of the counter. The connection:
```systemverilog
.clk(clk)
```

means that the testbench signal `clk` is connected to the counter's `clk` input. Similarly:
```systemverilog
.reset(reset)
```

connects the reset signal. And:
```systemverilog
.count(count)
```
connects the counter output to the testbench.

= Running the Simulation
Once both files have been created, the project should contain:
```text
lab-02-verilog-sim-iverilog/
├── src/
│   └── counter.v
├── tb/
│   └── tb_counter.v
└── bin/
```

We can now compile the design and testbench using Icarus Verilog. From the project directory, run:
```bash
iverilog -Wall -Winfloop -gno-shared-loop-index \
  ./src/counter.v ./tb/tb_counter.v \
  -o ./bin/tb_counter.vvp
```

The `-o` option specifies the output file. In this case:
```text
./bin/tb_counter.vvp
```
is the compiled simulation.

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*EXERCISE:* Find out what is the purpose of every flag in the iverilog command.]

If there are no errors, Icarus Verilog will return to the shell without producing an error message. The project should now contain:

```text
bin/
└── tb_counter.vvp
```

== Executing the Simulation
Compiling the Verilog source does not actually run the simulation. The compiled simulation must be executed using `vvp`:

```bash
vvp ./bin/tb_counter.vvp
```

The `$dumpfile` statement in the testbench tells the simulator to create:
```text
counter.vcd
```

The `$dumpvars` statement tells the simulator which signals should be recorded. You should see output similar to:

```text
VCD info: dumpfile counter.vcd opened for output.
```

The exact message may vary slightly depending on the installed version of Icarus Verilog. The generated VCD file contains the signal transitions produced during simulation.

== Understanding the VCD File
VCD stands for *Value Change Dump*. A VCD file records how digital signals change over simulation time. For example, the counter may produce values such as:

```text
Time       count
----------------
0 ns       0
10 ns      1
20 ns      2
30 ns      3
40 ns      4
50 ns      5
...
```

The VCD file itself is not normally meant to be read manually. Instead, we use a waveform viewer such as GTKWave.

== Viewing the Waveform with GTKWave
Launch GTKWave using:
```bash
gtkwave ./bin/tb_counter.vcd
```

GTKWave will open a graphical interface where the signals recorded during the simulation can be examined. Add the signals to the waveform display:

You should see the clock continuously toggling. During reset, the counter should remain at zero.

After reset is released, the counter should increment on every rising edge of the clock. The exact graphical appearance will depend on GTKWave's display settings.

= Automating the Process with GNU Make
Typing the complete commands manually becomes inconvenient as a project becomes larger. For example, every time the design is changed, we would need to execute:

```bash
iverilog -Wall -Winfloop -gno-shared-loop-index \
  ./src/counter.v ./tb/tb_counter.v \
  -o ./bin/tb_counter.vvp
```

followed by:
```bash
vvp ./bin/tb_counter.vvp
```

and then:
```bash
gtkwave ./bin/tb_counter.vcd
```

We can automate these commands using a `Makefile`. Create a file called `Makefile` in the root of the project:
```text
lab-02-verilog-sim-iverilog/
├── src/
│   └── counter.v
├── tb/
│   └── tb_counter.v
├── bin/
└── Makefile
```

```bash
touch Makefile
```

Add the following:

```makefile
TOP = tb_counter
SRC = ./src/counter.v
TB  = ./tb/tb_counter.v

build:
	iverilog -Wall -Winfloop -gno-shared-loop-index $(SRC) $(TB) \
    -o ./bin/$(TOP).vvp

run: build
	cd bin && vvp $(TOP).vvp

wave: run
	gtkwave ./bin/tb_counter.vcd

clean:
	rm -rf sim/*.vvp sim/*.vcd
```

Note that the commands underneath each target must begin with a *tab character*, not spaces.

= Using the Makefile
The Makefile provides four targets.

== Build
Run:
```bash
make build
```

This compiles the Verilog design and testbench. It is equivalent to:
```bash
iverilog -g2012 -o sim/counter_tb.vvp src/counter.v tb/counter_tb.v
```

== Run
Run:
```bash
make run
```

This first builds the simulation and then executes it. It is equivalent to:
```bash
iverilog -Wall -Winfloop -gno-shared-loop-index \
  ./src/counter.v ./tb/tb_counter.v -o ./bin/tb_counter.vvp
cd bin
vvp ./bin/tb_counter.vvp
```
After execution, the waveform file will be generated.

== View the Waveform
Run:
```bash
make wave
```
This performs the complete workflow:

== 13.4 Clean
Run:
```bash
make clean
```

This removes generated simulation files:
```text
*.vvp
*.vcd
```

The Verilog source and testbench remain untouched. This is useful when you want to perform a clean simulation.

= Final Project Structure

After completing the lab, the project should look similar to:

```text
lab-02-verilog-sim-iverilog/
├── src/
│   └── counter.v
├── tb/
│   └── tb_counter.v
├── sim/
│   ├── tb_counter.vvp
│   └── tb_counter.vcd
└── Makefile
```

= Simulation Versus FPGA Implementation
One of the most important concepts to understand is that *simulation is not the same as FPGA
implementation*.

In this lab, we are only simulating the Verilog design.

No FPGA is required.

No bitstream is generated.

No physical hardware is programmed.

= EXERCISE
After completing this lab, create additional Verilog designs such as combinational circuits, flip-flops, registers, counters, and finite-state machines, and develop testbenches to verify their behavior.

