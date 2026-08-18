RTL := ./src/half_adder.sv ./src/carry_lookahead_adder.sv
TOP = carry_lookahead_adder



synth_design_ecp5:
	mkdir -p ./bin
	yosys -p "\
		read -sv $(RTL); \
		hierarchy -check -auto-top; \
		proc; opt; fsm; opt; \
		techmap; alumacc; \
		opt; memory; opt; abc; opt; \
		synth_ecp5 -top $(TOP); \
		write_verilog ./bin/netlist_ecp5_$(TOP).sv; \
		write_json ./bin/netlist_ecp5_$(TOP).json; \
		stat -tech cmos -width; \
		show -format dot -stretch -width -colors 10000 -signed -prefix ./bin/ecp5_$(TOP);"

