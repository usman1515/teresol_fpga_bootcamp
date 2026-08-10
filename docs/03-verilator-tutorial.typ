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
  )[Lab 3 — Verilog Simulation Using Verilator]

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
using *Verilator* and other open-source tools.

In this lab, we will use:

- *Verilator* for compiling, linting, and generating an executable simulation model from
  Verilog/SystemVerilog designs.
- *GTKWave* for viewing simulation waveforms.
- *GNU Make* for automating the simulation workflow.

Unlike a traditional event-driven Verilog simulator, Verilator translates the HDL design into an
optimized C++ simulation model and can build a standalone simulation executable. For this lab, the
`--binary` mode is used so that students do not need to write a separate C++ wrapper.

The complete workflow used in this lab is:

#align(center)[
```text
Write Verilog Design
        |
        v
Write Testbench
        |
        v
Verilate and Build Simulation
        |
        v
Execute Verilator Simulation
        |
        v
Generate VCD Waveform
        |
        v
View Waveform using GTKWave
```
]

The purpose of this lab is not to program an FPGA. Instead, we will verify the behavior of a Verilog
design through software simulation using OSS (Free Open Source Software).

= Required Tools
For this lab, we need a Linux system with Fedora installed. The following software is required:

#table(
  columns: (20%, 80%),
  stroke: 0.5pt,
  inset: 8pt,

  [*Tool*], [*Purpose*],
  [`verilator`], [Verilog compiler, linter, and simulation model generator],
  [`gtkwave`], [Graphical waveform viewer],
  [`make`], [Automates compilation and simulation commands],
)

== Installing the OSS CAD Suite
For FPGA development, we will use the *OSS CAD Suite*, a collection of free and open-source tools
for digital design, simulation, synthesis, and FPGA development. The suite brings together several
commonly used FPGA and hardware-design tools into a single installation, making it easier to set up
a consistent development environment across the team.

For this lab, we will use the following tools from the OSS CAD Suite:
- `verilator` — Verilog/SystemVerilog compiler, linter, and simulation model generator.
- `gtkwave` — Graphical waveform viewer.

Instead of installing each tool individually through Fedora's package manager, we will install the
OSS CAD Suite and use the tools provided by the suite throughout this onboarding series.

== Installing Other Tools
It is also useful to make sure that `make` is installed:
```bash
sudo dnf install make
```

Make sure Verilator is installed and present in the current shell session:
```bash
verilator --version
```

Verify GTKWave:
```bash
gtkwave --version
```

You can also check that the Verilator executable is available:
```bash
which verilator
```

The exact version numbers and installation paths may differ depending on the Fedora release and the
OSS CAD Suite version.

= Creating the Lab Directory
Create a directory for the Verilator simulation lab:
```bash
mkdir -p lab-03-verilog-sim-verilator
cd lab-03-verilog-sim-verilator
```

We will organize the project into separate directories for the design source code, testbench, and
generated simulation files.

Create the following directories:
```bash
mkdir src tb bin
```

The resulting project structure will be:
```text
lab-03-verilog-sim-verilator/
├── src/
├── tb/
└── bin/
```

We will eventually have a project structure similar to:
```text
lab-03-verilog-sim-verilator/
├── src/
│   └── counter.v
├── tb/
│   └── tb_counter.v
├── bin/
│   ├── tb_counter
│   └── tb_counter.vcd
├── obj_dir/
└── Makefile
```

The purpose of separating these files is to keep the project organized.

The `src/` directory contains the actual hardware design/s, commonly referred to as the *Device Under
Test (DUT)*.

The `tb/` directory contains the testbench/es used to stimulate and verify the design.

The `bin/` directory contains the simulation executable and waveform file generated by the simulation.

The `obj_dir/` directory is created and managed by Verilator and contains generated C++ source files,
object files, and build artifacts. It should generally be treated as a generated directory.

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
)[*NOTE:* Always make sure that whenever you create an RTL design file the `<module_name>` and
`<file_name>` are the same. Although Verilator does not require the filename to match the module
name, following this convention makes projects easier to organize and maintain.]

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

This means that the statements inside the block execute whenever the clock transitions from `0` to
`1`. This is called a *positive clock edge* or *rising edge*.

Inside the block:
```systemverilog
if (reset)
    count <= 4'b0000;
```

When reset is active, the counter is set to zero. Otherwise:
```systemverilog
count <= count + 1'b1;
```

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

    counter UUT_counter_2 (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // Clock generation
    always begin
        #5 clk = 1'b1;
        #5 clk = 1'b0;
    end

    initial begin

        // Initial values
        clk = 0;
        reset = 1;

        #10;
        reset = 0;

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
)[*NOTE:* Always make sure that whenever you create a testbench file the `<module_name>` and
`<file_name>` follow the project naming convention. In this lab, testbenches follow the
`tb_<rtl_module_name>` convention.]

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*VERILATOR NOTE:* Verilator supports Verilog/SystemVerilog testbench timing constructs such as `#`
delays when timing support is enabled. The `--timing` option is therefore required for this
testbench.]

= Understanding the Testbench
The testbench begins with:
```systemverilog
`timescale 1ns/1ps
```

This specifies the simulation time unit and time precision. In this example:
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

The clock and reset are declared as `reg` because the testbench will actively drive these signals.
The counter output is declared as a `wire` because it is driven by the counter module.

== Instantiating the Counter
The counter is instantiated using:
```systemverilog
counter UUT_counter_2 (
    .clk(clk),
    .reset(reset),
    .count(count)
);
```

Here `counter` is the module being instantiated and `UUT_counter_2` stands for *Unit Under Test*.
The testbench connects its signals to the ports of the counter.

The connection:
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

= Understanding Verilator
Verilator is different from a traditional event-driven Verilog simulator.

Instead of interpreting the HDL directly at simulation runtime, Verilator translates the
Verilog/SystemVerilog design into an optimized C++ model and can compile that model into a
standalone simulation executable.

For this laboratory, the `--binary` option is used. This lets Verilator generate the simulation
executable without requiring students to write a separate C++ simulation wrapper.

The basic command is conceptually:
```text
Verilog/SystemVerilog
        |
        v
    Verilator
        |
        v
Generated C++ model
        |
        v
   C++ compiler
        |
        v
Simulation executable
```

This is an important distinction from the Icarus Verilog workflow:
```text
Icarus Verilog:
Verilog → iverilog → VVP → simulation

Verilator:
Verilog → Verilator → C++ model → executable → simulation
```

Verilator can also perform extensive linting while processing the HDL, making it useful both as a
simulator and as a static-analysis tool.

= Running the Simulation
Once both files have been created, the project should contain:
```text
lab-03-verilog-sim-verilator/
├── src/
│   └── counter.v
├── tb/
│   └── tb_counter.v
└── bin/
```

We can now use Verilator to build the simulation executable. From the project directory, run:
```bash
verilator --binary --timing --trace-vcd -Wall -Wno-fatal \
  -Mdir ./bin/tb_counter \
  --top-module tb_counter \
  ./src/counter.v ./tb/tb_counter.v \
  -o ./bin/tb_counter
```

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*EXERCISE:* Find out what is the purpose of every option in the Verilator command. In particular,
investigate the difference between `--binary`, `--timing`, `--trace-vcd`, `--top-module`, `-Wall`,
and `-Wno-fatal`.]

If the build is successful, Verilator will generate its intermediate build files in `obj_dir/` and
the simulation executable will be placed at:

```text
./bin/tb_counter
```

The project should now contain directories similar to:

```text
lab-03-verilog-sim-verilator/
├── src/
├── tb/
├── bin/
│   └── tb_counter
└── Makefile
```

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*NOTE:* Verilator's generated `./bin/tb_counter` (default `./obj_dir/`) directory contains C++
source files, object files, dependency files, and other generated build artifacts. These files are
not normally edited by the student.]

== Executing the Simulation
The Verilator-generated simulation is an executable program. Run it using:
```bash
./bin/tb_counter/tb_counter
```

The `$dumpfile` statement in the testbench specifies:
```text
./bin/tb_counter.vcd
```

as the waveform file.

The `$dumpvars` statement tells Verilator which simulation signals should be traced. Because
`--trace-vcd` was supplied during the Verilator build, the VCD tracing support is enabled. The
generated VCD file should now be:
```text
./bin/tb_counter.vcd
```

= Viewing the Waveform with GTKWave
VCD stands for *Value Change Dump*. A VCD file records how digital signals change over simulation
time.

Launch GTKWave using:
```bash
gtkwave ./bin/tb_counter.vcd
```

GTKWave will open a graphical interface where the signals recorded during the simulation can be
examined. You should see the clock continuously toggling. During reset, the counter should remain at
zero.

After reset is released, the counter should increment on every rising edge of the clock. The exact
graphical appearance will depend on GTKWave's display settings.

#block(
  fill: luma(245),
  stroke: (left: 3pt + blue),
  inset: 10pt,
  radius: 4pt,
)[*IMPORTANT:* If the counter does not increment, inspect the clock and reset signals first. A
waveform viewer is often the fastest way to identify problems in sequential logic. ]

= Automating the Process with GNU Make
Typing the complete Verilator command manually becomes inconvenient as a project becomes larger. For
example, every time the design is changed, we would need to execute:

```bash
verilator \
  --binary \
  --timing \
  --trace-vcd \
  --top-module tb_counter \
  -Wall \
  -Wno-fatal \
  -o ./bin/tb_counter \
  ./src/counter.v \
  ./tb/tb_counter.v
```

followed by:
```bash
./bin/tb_counter
```

and then:
```bash
gtkwave ./bin/tb_counter.vcd
```

We can automate these commands using a `Makefile`. Create a file called `Makefile` in the root of
the project:
```text
lab-03-verilog-sim-verilator/
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

VERILATOR_FLAGS = --binary --timing --trace-vcd --top-module $(TOP) -Wall -Wno-fatal

build:
	mkdir -p bin
	verilator $(VERILATOR_FLAGS) -o $(CURDIR)/bin/$(TOP) $(SRC) $(TB)

run: build
	./bin/$(TOP)

wave: run
	gtkwave ./bin/$(TOP).vcd

clean:
	rm -rf obj_dir
	rm -f bin/$(TOP) bin/$(TOP).vcd
```

Note that the commands underneath each target must begin with a *tab character*, not spaces.

= Using the Makefile
The Makefile provides four targets.

== Build
Run:
```bash
make build
```

This invokes Verilator, generates the required C++ simulation model, compiles it, and creates the
standalone simulation executable. The executable will be:
```text
bin/tb_counter
```

== Run
Run:
```bash
make run
```

This first builds the simulation and then executes it. The simulation generates:
```text
bin/tb_counter.vcd
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

This removes:
```text
obj_dir/
bin/tb_counter
bin/tb_counter.vcd
```

The Verilog source, testbench, and Makefile remain untouched. This is useful when you want to
perform a completely clean Verilator build.

= Final Project Structure
After completing the lab, the project should look similar to:

```text
lab-03-verilog-sim-verilator/
├── src/
│   └── counter.v
├── tb/
│   └── tb_counter.v
├── bin/
│   ├── tb_counter/
│   │   └── ...
│   └── tb_counter.vcd
└── Makefile
```

The `./bin/tb_counter` contents may vary with the Verilator version and build configuration.

= Simulation Versus FPGA Implementation
One of the most important concepts to understand is that *simulation is not the same as FPGA
implementation*.

In this lab, we are only simulating the Verilog design.

No FPGA is required.

No bitstream is generated.

No physical hardware is programmed.

= Important Differences from Icarus Verilog

The following differences are important when moving from Icarus Verilog to Verilator.

#table(
  columns: (50%, 50%),
  stroke: 0.5pt,
  inset: 7pt,

  [*Icarus Verilog*], [*Verilator*],
  [`iverilog` compiles the design], [`verilator` translates and builds a simulation model],
  [`vvp` executes the compiled simulation], [A Verilator-generated executable runs the simulation],
  [VVP is the simulation runtime], [C++ is generated and compiled behind the scenes],
  [Waveform tracing is enabled by the testbench and simulator], [VCD tracing must be enabled with `--trace-vcd`],
  [No explicit top module is usually needed for a simple project], [`--top-module` is useful when multiple top-level modules exist],
  [Traditional event-driven simulator], [HDL compiler/model generator optimized for fast simulation],
)

= Lab Exercises

== Exercise 1: Modify the Counter Width
Modify the counter so that it is 8 bits wide instead of 4 bits. The output should become: Compile
and simulate the modified design.

== Exercise 2: Change the Clock Frequency

== Exercise 3: Observe Reset Behavior

== Exercise 4: Add a Second Output
Modify the counter so that an additional output becomes high whenever the counter reaches `4'b1111`.

== Exercise 5: Add Simulation Messages
Add a `$monitor` statement to the testbench. Run the simulation and compare the textual output with
the GTKWave waveform.

