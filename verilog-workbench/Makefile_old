# Set the following parameters for your project:
NAM = accumulator
# In this example we have a verilog file at verilog/pwm.v
# FILE is the address to your main verilog file
FILE = src/$(NAM)

# PREFIX is the prefix for the verilog file
PREFIX = $(NAM)

# TOPLEVEL is the name of the toplevel module in your Verilog file
TOPLEVEL = $(NAM)

# MODULE is the basename of the Python test file
MODULE = test.test_$(NAM)

SINGLE = True

IGNORE = 'memory.v'



# Find all of the source files
PWD = $(shell pwd)
DIRLIST_FULL := $(shell find $(PWD)/src/ -name "*.*v" | grep -v $(FILE) | grep -v $(IGNORE))
DIRLIST := $(shell find src/ -name "*.*v" | grep -v $(FILE) | grep -v $(IGNORE))
DIRLIST_IVERILOG := $(PWD)/$(FILE).v $(PWD)/src/ $(DIRLIST_FULL)
# COCOTB stuff
ifeq (True, $(SINGLE))
	VERILOG_SOURCES := $(PWD)/$(FILE).v
else
	VERILOG_SOURCES := $(DIRLIST_IVERILOG)
endif
#VERILOG_SOURCES := $(PWD)/$(FILE).v
# include $(shell cocotb-config --makefiles)/Makefile.sim
include Makefile.icarus

tes:
	echo $(DIRLIST)
# Show synthesized diagram with yosys
# #yosys -p "read_verilog $(FILE).v; proc; opt -full; show -prefix $(FILE) -format png -viewer gwenview -colors 2 -width -signed"
# yosys -p "read_verilog $(FILE); hierarchy -top $(TOPLEVEL) -libdir src/; proc; extract -map ${dirlist[*]}; opt -full ; show -colors 2 -width -signed -long rgb_mixer"
# test_:
# 	rm -rf sim_build/
# 	mkdir sim_build/
# 	iverilog -o sim_build/sim.vvp -s rgb_mixer -s dump -g2012 src/rgb_mixer.v test/dump.v src/ $(DIRLIST_FULL)
# 	PYTHONOPTIMIZE=0 MODULE=test.test_rgb_mixer vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
# 	! grep failure results.xml



formal:
	sby -f properties.sby
	gtkwave properties/engine_0/trace0.vcd $(PREFIX).gtkw
show_synth_png:
	yosys -p "read_verilog $(FILE).v; hierarchy -top $(TOPLEVEL) -libdir src/; proc; extract -map ${DIRLIST}; opt -full ; show -prefix show_synth/$(PREFIX) -format png -viewer gwenview -colors 2 -width -signed $(TOPLEVEL)"
show_synth_dot:
	yosys -p "read_verilog $(FILE).v; hierarchy -top $(TOPLEVEL) -libdir src/; proc; extract -map ${DIRLIST}; opt -full ; show -prefix show_synth/$(PREFIX) -colors 2 -width -signed -long $(TOPLEVEL)"
	# Show waveforms after simulation with gtkwave
gtkwave:
	gtkwave $(PREFIX).vcd $(PREFIX).gtkw
gtkwave_good:
	gtkwave $(PREFIX)_good.vcd $(PREFIX).gtkw

# Delete simulation files
delete:
	rm -rf sim_build/ test/__pycache__/ $(PREFIX).vcd results.xml properties/
	rm show_synth/*
