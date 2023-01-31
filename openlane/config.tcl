# User config
set ::env(DESIGN_NAME) accelerator

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "40"
set ::env(CLOCK_NET) "clk"
set ::env(CLOCK_PORT) "clk"

set ::env(RUN_KLAYOUT_XOR) 0
set ::env(RUN_KLAYOUT_DRC) 0
set ::env(ROUTING_CORES) 16
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
# set ::env(DESIGN_IS_CORE) 0
# set ::env(RT_MAX_LAYER) {met4}
# set ::env(VDD_NETS) [list {vccd1}]
# set ::env(GND_NETS) [list {vssd1}]
# don't put clock buffers on the outputs, need tristates to be the final cells
# set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0
# set ::env(FP_SIZING) absolute
# set ::env(DIE_AREA) "0 0 100 100"
#
# set ::env(PL_TARGET_DENSITY) 0.65
# set ::env(BOTTOM_MARGIN_MULT) 2
# set ::env(TOP_MARGIN_MULT) 2

# set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0
# set ::env(GRT_ALLOW_CONGESTION) 1
# set ::env(PL_ROUTABILITY_DRIVEN) 0
# set ::env(FP_CORE_UTIL) 10
set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 3000 3000"
# set ::env(FP_CORE_UTIL) 45
set ::env(PL_TARGET_DENSITY) 0.20
set ::env(FP_CORE_UTIL) 15


set ::env(DESIGN_IS_CORE) 0
set ::env(RT_MAX_LAYER) {met4}


set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
	}


