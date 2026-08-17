# Teresol FPGA Onboarding Bootcamp

A comprehensive onboarding and reference guide for FPGA engineers, covering HDL, Linux, development
tools, FPGA workflows, simulation, synthesis, and team best practices. The material is primarily
intended for engineers working in a Linux-based FPGA development environment, with Fedora used as
the reference operating system.

## Repository Overview
The Teresol FPGA Onboarding Bootcamp is a collection of technical manuals designed to introduce
engineers to the tools, workflows, and practices used in FPGA development. The manuals are written
using **Typst** and are intended to be compiled into PDF documents for distribution and reference.

The bootcamp covers topics including:

- Linux and Fedora development environments
- SystemVerilog and VHDL
- RTL design
- HDL simulation
- RTL synthesis
- Netlist generation
- FPGA toolchains
- Yosys
- NVC
- Verilator
- FPGA place-and-route
- FPGA programming
- Open-source FPGA development workflows
- Development tools and team practices

The goal is to establish a common development environment and workflow so that FPGA engineers can
work with the same tools and procedures.

## Building the Manuals
The manuals are written using [Typst](https://typst.app/), a modern markup-based typesetting system.
Typst is used instead of traditional LaTeX because it provides a simple syntax, fast compilation,
and convenient support for technical documentation.

### Installing Typst on Fedora
Install Typst using Fedora's package manager:
```bash
sudo dnf install typst

# verify the installation:
typst --version
```

### Compiling the Manuals
Simply run the command `make compile_docs` to generate PDFs for all the lab manuals.

## FPGA Development Environment
The FPGA development environment uses Vivado along with several open-source tools.

## [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)
The OSS CAD Suite is a collection of open-source tools for digital design and FPGA development.

### Downloading OSS CAD Suite
Download the latest Linux x86-64 release from
[here](https://github.com/YosysHQ/oss-cad-suite-build/releases). For a normal x86-64 Fedora
workstation, select the `linux-x64` archive.

Download the latest build and extract it in `~/Tools/`:
```bash
mkdir -p ~/Tools

cd ~/Tools

tar -zxvf ~/Downloads/oss-cad-suite-linux-x64-<build-date>.tgz \
        -C ~/Tools/oss-cad-suite-linux-x64-<build-date>
```

Add the following `$PATH` in your `~/.bashrc`
```bash
# PATH oss-cad-suite
export PATH="$HOME/Tools/oss-cad-suite-linux-x64-<build-date>/bin:$PATH"

# restart the shell or run:
source ~/.bashrc

# verify the installation:
ghdl --version
iverilog --version
verilator --version
yosys --version
nextpnr-ice40 --version
nextpnr-ecp5 --version
openFPGALoader --version
```

The exact set of tools available depends on the current OSS CAD Suite release.

## [NVC](https://github.com/nickg/nvc)
NVC is an open-source **VHDL compiler and simulator**. It is used in this project for VHDL
simulation and is separate from the OSS CAD Suite.

### Installing NVC
```bash
# install dependencies
sudo dnf install -y gcc gcc-c++ make autoconf automake flex check llvm-devel \
    pkgconf-pkg-config zlib-devel elfutils-libdw-devel libffi-devel

# clone the repository:
git clone https://github.com/nickg/nvc.git ~/Tools/
cd ~/Tools/nvc/

# generate the build system:
./autogen.sh

# create a separate build directory:
mkdir build
cd build

# configure NVC:
../configure

# compile:
make -j$(nproc)

# run the test suite:
make check

# install:
sudo make install

# verify:
nvc --version
```


<!-- # OpenXC7 -->
<!---->
<!-- ## What is OpenXC7? -->
<!---->
<!-- OpenXC7 is an open-source FPGA toolchain for **Xilinx 7-series FPGAs**. -->
<!---->
<!-- It is relevant for devices such as: -->
<!---->
<!-- - Xilinx Artix-7 -->
<!-- - Xilinx Kintex-7 -->
<!-- - Xilinx Zynq-7000 -->
<!---->
<!-- For example, the **Digilent Basys 3** uses a Xilinx Artix-7 FPGA. -->
<!---->
<!-- The open-source Xilinx 7-series flow is built around projects including: -->
<!---->
<!-- - Yosys -->
<!-- - Project X-Ray -->
<!-- - nextpnr-xilinx -->
<!-- - related database and bitstream tools -->
<!---->
<!-- The general flow is: -->
<!---->
<!-- ```text -->
<!-- SystemVerilog / Verilog -->
<!--           | -->
<!--           v -->
<!--         Yosys -->
<!--           | -->
<!--           v -->
<!--    Xilinx 7-series -->
<!--       netlist -->
<!--           | -->
<!--           v -->
<!--    nextpnr-xilinx -->
<!--           | -->
<!--           v -->
<!--   placed and routed -->
<!--       design -->
<!--           | -->
<!--           v -->
<!--     bitstream -->
<!--           | -->
<!--           v -->
<!--        FPGA -->
<!-- ``` -->
<!---->
<!-- ## Installing OpenXC7 -->
<!---->
<!-- OpenXC7 is an evolving collection of open-source projects rather than a single universal Fedora package. -->
<!---->
<!-- The required components should therefore be installed according to the OpenXC7 project/toolchain documentation. -->
<!---->
<!-- At minimum, install: -->
<!---->
<!-- ```bash -->
<!-- sudo dnf install \ -->
<!--     git \ -->
<!--     make \ -->
<!--     cmake \ -->
<!--     gcc \ -->
<!--     gcc-c++ \ -->
<!--     python3 \ -->
<!--     python3-devel \ -->
<!--     boost-devel \ -->
<!--     eigen3-devel -->
<!-- ``` -->
<!---->
<!-- The exact dependencies can vary with the selected OpenXC7 components and build versions. -->
<!---->
<!-- ## Yosys -->
<!---->
<!-- Yosys is required for RTL synthesis. -->
<!---->
<!-- If OSS CAD Suite has already been installed and activated: -->
<!---->
<!-- ```bash -->
<!-- source ~/Tools/oss-cad-suite/environment -->
<!-- ``` -->
<!---->
<!-- then verify: -->
<!---->
<!-- ```bash -->
<!-- yosys --version -->
<!-- ``` -->
<!---->
<!-- There is normally no need to build a second copy of Yosys unless the OpenXC7 flow requires a particular version. -->
<!---->
<!-- ## nextpnr-xilinx -->
<!---->
<!-- Verify whether the Xilinx backend is available: -->
<!---->
<!-- ```bash -->
<!-- which nextpnr-xilinx -->
<!-- ``` -->
<!---->
<!-- If it is available: -->
<!---->
<!-- ```bash -->
<!-- nextpnr-xilinx --help -->
<!-- ``` -->
<!---->
<!-- If it is not available, build the appropriate nextpnr Xilinx backend together with the required Project X-Ray database and dependencies according to the OpenXC7 setup instructions. -->
<!---->
<!-- ## Project X-Ray -->
<!---->
<!-- Project X-Ray provides the reverse-engineered database information required to work with Xilinx 7-series devices using open-source tools. -->
<!---->
<!-- It is a required component of the open-source Xilinx 7-series flow. -->
<!---->
<!-- The database and toolchain versions must be compatible with the selected nextpnr-xilinx and Yosys versions. -->
<!---->
<!-- ## Verifying OpenXC7 -->
<!---->
<!-- After installation, verify: -->
<!---->
<!-- ```bash -->
<!-- yosys --version -->
<!-- ``` -->
<!---->
<!-- ```bash -->
<!-- nextpnr-xilinx --help -->
<!-- ``` -->
<!---->
<!-- A successful installation should allow the following general flow: -->
<!---->
<!-- ```text -->
<!-- RTL -->
<!--  | -->
<!--  v -->
<!-- Yosys -->
<!--  | -->
<!--  v -->
<!-- Xilinx 7-series JSON netlist -->
<!--  | -->
<!--  v -->
<!-- nextpnr-xilinx -->
<!--  | -->
<!--  v -->
<!-- placed/routed design -->
<!--  | -->
<!--  v -->
<!-- bitstream generation -->
<!-- ``` -->
<!---->
<!-- --- -->
<!---->
<!-- # Verifying the Installation -->
<!---->
<!-- ## Typst -->
<!---->
<!-- ```bash -->
<!-- typst --version -->
<!-- ``` -->
<!---->
<!-- ## Yosys -->
<!---->
<!-- ```bash -->
<!-- yosys --version -->
<!-- ``` -->
<!---->
<!-- ## Verilator -->
<!---->
<!-- ```bash -->
<!-- verilator --version -->
<!-- ``` -->
<!---->
<!-- ## NVC -->
<!---->
<!-- ```bash -->
<!-- nvc --version -->
<!-- ``` -->
<!---->
<!-- ## nextpnr -->
<!---->
<!-- For supported architectures: -->
<!---->
<!-- ```bash -->
<!-- nextpnr-ice40 --version -->
<!-- ``` -->
<!---->
<!-- ```bash -->
<!-- nextpnr-ecp5 --version -->
<!-- ``` -->
<!---->
<!-- For Xilinx 7-series: -->
<!---->
<!-- ```bash -->
<!-- nextpnr-xilinx --help -->
<!-- ``` -->
<!---->
<!-- ## FPGA Programmer -->
<!---->
<!-- If using OpenFPGALoader: -->
<!---->
<!-- ```bash -->
<!-- openFPGALoader --version -->
<!-- ``` -->
<!---->
<!-- --- -->
<!---->
<!-- # Development Workflow -->
<!---->
<!-- The general Teresol FPGA development workflow is: -->
<!---->
<!-- ```text -->
<!--               HDL Source -->
<!--                   | -->
<!--                   v -->
<!--           +---------------+ -->
<!--           | Simulation    | -->
<!--           | NVC/Verilator | -->
<!--           +---------------+ -->
<!--                   | -->
<!--                   v -->
<!--              RTL verified -->
<!--                   | -->
<!--                   v -->
<!--           +---------------+ -->
<!--           |    Yosys      | -->
<!--           |   Synthesis   | -->
<!--           +---------------+ -->
<!--                   | -->
<!--                   v -->
<!--              Netlist -->
<!--                   | -->
<!--                   v -->
<!--           +---------------+ -->
<!--           | Place & Route | -->
<!--           |    nextpnr    | -->
<!--           +---------------+ -->
<!--                   | -->
<!--                   v -->
<!--              Bitstream -->
<!--                   | -->
<!--                   v -->
<!--           +----------------+ -->
<!--           | FPGA Programmer | -->
<!--           +----------------+ -->
<!--                   | -->
<!--                   v -->
<!--                 FPGA -->
<!-- ``` -->
<!---->
<!-- The exact tools used for place-and-route and bitstream generation depend on the target FPGA architecture. -->
<!---->
<!-- | FPGA family | Synthesis | Place & Route | -->
<!-- |---|---|---| -->
<!-- | Lattice iCE40 | `synth_ice40` | `nextpnr-ice40` | -->
<!-- | Lattice ECP5 | `synth_ecp5` | `nextpnr-ecp5` | -->
<!-- | Xilinx 7-series | `synth_xilinx` | `nextpnr-xilinx` | -->
<!---->
<!-- --- -->
<!---->
<!-- # Recommended Setup -->
<!---->
<!-- For a new Fedora development machine, the recommended order is: -->
<!---->
<!-- ```text -->
<!-- 1. Install Fedora development packages -->
<!--              | -->
<!--              v -->
<!-- 2. Install Typst -->
<!--              | -->
<!--              v -->
<!-- 3. Install OSS CAD Suite -->
<!--              | -->
<!--              v -->
<!-- 4. Build and install NVC -->
<!--              | -->
<!--              v -->
<!-- 5. Set up OpenXC7 / Xilinx tools -->
<!--              | -->
<!--              v -->
<!-- 6. Verify all tools -->
<!--              | -->
<!--              v -->
<!-- 7. Build the onboarding manuals -->
<!-- ``` -->
<!---->
<!-- After completing the setup, engineers should be able to compile the documentation and perform the HDL simulation, synthesis, and FPGA implementation exercises covered by the bootcamp. -->
<!---->
<!-- --- -->
<!---->
<!-- # Contributing -->
<!---->
<!-- When adding or modifying a manual: -->
<!---->
<!-- 1. Keep the source in Typst format (`.typ`). -->
<!-- 2. Follow the existing manual structure and formatting. -->
<!-- 3. Use the same tool versions and workflows documented in this repository. -->
<!-- 4. Verify that the manual compiles successfully before committing. -->
<!-- 5. Avoid committing generated PDF files unless the repository explicitly requires them. -->
<!-- 6. Keep installation instructions reproducible on a clean Fedora installation. -->
<!---->
<!-- Before committing changes, compile the affected manuals: -->
<!---->
<!-- ```bash -->
<!-- typst compile path/to/manual.typ -->
<!-- ``` -->
<!---->
<!-- and verify that there are no compilation errors. -->
<!---->
<!-- --- -->
<!---->
<!-- # License -->
<!---->
<!-- See the repository license for information about using, modifying, and distributing the bootcamp material. -->
