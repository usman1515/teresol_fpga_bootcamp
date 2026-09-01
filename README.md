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
sudo dnf copr enable claaj/typst
sudo dnf install -y typst

# verify the installation:
typst --version
```

### Compiling the Manuals
Simply run the command `make compile_docs` to generate PDFs for all the lab manuals.

## FPGA Development Environment
The FPGA development environment uses Vivado along with several open-source tools.

## [Vivado]()

### Install Cable Drivers (Linux Only)
Once vivado is installed you need to setup the cable drivers and board definitions.
```bash
# got to directory
cd /tools/Xilinx/2025.1/Vivado/data/xicom/cable_drivers/lin64/install_script/install_drivers/

# run script
sudo ./install_drivers
```

### [Install Digilent's Board Files]()
Once you have installed the cable drivers we need to setup the board definitions.
```bash
mkdir -p ~/Tools/
cd ~/Tools/

# clone the repo
git clone https://github.com/Digilent/vivado-boards.git
cd vivado-boards

# copy board files
sudo cp -rv ~/Tools/vivado-boards/new/board_files /tools/Xilinx/2025.1/Vivado/data/boards/
```

## [Verible](https://github.com/chipsalliance/verible)
Verible is a suite of SystemVerilog developer tools, including a parser, style-linter, formatter and
language server. To start download the latest `*-linux-static-x86_64.tart.gz` file this
[link](https://github.com/chipsalliance/verible/releases)
```bash
# after downloading the tar file
mkdir -p ~/Tools
cd ~/Tools

tar -zxvf ~/Downloads/verible-v0.0-4148-g1ea007ec-linux-static-x86_64.tar.gz \
        -C ~/Tools/verible-v0.0-4148-g1ea007ec-linux-static-x86_64
```

Add the following `$PATH` in your `~/.bashrc`
```bash
# PATH oss-cad-suite
export PATH="$HOME/Tools/verible-v0.0-4148-g1ea007ec/bin:$PATH"

# restart the shell or run:
source ~/.bashrc

# verify the installation:
verible-verilog-diff --version
verible-verilog-format --version
verible-verilog-lint --version
verible-verilog-ls --version
verible-verilog-syntax --version
```

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

# goto Tools directory
mkdir -p ~/Tools
cd ~/Tools

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

