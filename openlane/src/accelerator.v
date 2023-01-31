`default_nettype none
`timescale 1ns/1ns

// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/accumulator.v"
// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/neuron_selector.v"
// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/neuron.v"
// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/spk_processor.v"
// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/u_b_processor.v"
// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/u_b_memory_controler.v"
// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/spk_memory_controler.v"
// `include "/root/projects/iscas-snn-accelerator/verilog-workbench/src/control_unit.v"

module accelerator (
    input wire [2047:0] w_read_sram,
    output wire [10:0] w_read_sram_addr,

    input wire [127:0] u_read_sram,
    output wire [8:0] u_read_sram_addr,
    output wire [127:0] u_write_sram,
    output wire [8:0] u_write_sram_addr,
    output wire u_write_sram_we,

    input wire [15:0] spk_read_sram,
    output wire [8:0] spk_read_sram_addr,
    output wire [15:0] spk_write_sram,
    output wire [8:0] spk_write_sram_addr,
    output wire spk_write_sram_we,

    input wire [15:0] spkblty_read_sram,
    output wire [8:0] spkblty_read_sram_addr,
    output wire [15:0] spkblty_write_sram,
    output wire [8:0] spkblty_write_sram_addr,
    output wire spkblty_write_sram_we,

    input wire [127:0] in_spk_read_sram,
    output wire [8:0] in_spk_read_sram_addr,

    input wire [63:0] b_read_sram,
    output wire [8:0] b_read_sram_addr,

    input wire clk, reset
    );

    //neurons I/O selector
    wire [127:0] ns_proc_u_out;
    wire [5:0] cntrl_u_out_select;
    wire [1023:0] proc_ns_in_spk;
    wire [1:0] proc_ns_ac_spk;
    wire cntrl_spk_select;
    wire [127:0] proc_ns_u_in;
    wire [5:0] cntrl_u_in_select;
    neuron_selector ns(
        .potential_out_all(neu_ns_u),
        .potential_out_16n(ns_proc_u_out),
        .cntrl_potential_out_sel(cntrl_u_out_select),

        .spk_out(ns_ac_spk),
        .in_spk(proc_ns_in_spk),
        .processed_spk(proc_ns_ac_spk),
        .cntrl_spk_select(cntrl_spk_select),

        .potential_in_16n(proc_ns_u_in),
        .potential_in_all(ns_neu_u_in),
        .potential_in_ien_all(ns_neu_u_ien),
        .cntrl_potential_in_sel(cntrl_u_in_select)
    );

    wire [2047:0] ns_ac_spk;
    wire [1023:0] ns_neu_u_ien;
    wire [8191:0] neu_ns_u;
    wire [8191:0] ns_neu_u_in;

    // generate 1024 accumlators
    wire cntrl_ac_reset;
    wire cntrl_ac_oen;
    genvar i;
    generate
        for (i=0;i<1024;i=i+1) begin
            accumulator acm(
                .w_read(w_read_sram[(i*2)+1:i*2]),
                .spk_in(ns_ac_spk[(i*2)+1:i*2]),
                .oen(cntrl_ac_oen),
                .accumulated_potential(ac_neu_u[(i*8)+7:i*8]),
                .clk(clk),
                .reset(cntrl_ac_reset)
            );
        end
    endgenerate

    wire [8191:0] ac_neu_u;

    // generate 1024 neurons
    wire cntrl_neu_reset;
    genvar j;
    generate
        for (j=0;j<1024;j=j+1) begin
            neuron neu(
                .potential_accumulated(ac_neu_u[(j*8)+7:j*8]),
                .potential_previous(ns_neu_u_in[(j*8)+7:j*8]),
                .potential_final(neu_ns_u[(j*8)+7:j*8]),
                .ien(ns_neu_u_ien[j]),
                .clk(clk),
                .reset(cntrl_neu_reset)
            );
        end
    endgenerate


    wire [15:0] proc_mem_spk;
    wire [15:0] proc_mem_spkblty;
    wire [15:0] mem_proc_spkblty;
    wire [1:0] mem_proc_ac_spk;
    wire [127:0] mem_proc_in_spk;
    wire [2:0] cntrl_in_spk_reg_mask;
    wire cntrl_in_spk_reg_we;
    wire cntrl_proc_reset;
    spk_processor spk_p(
        .hidden_16n_potential_in(ns_proc_u_out),
        .hidden_16n_spk_out(proc_mem_spk),
        .hidden_16n_spkblty_out(proc_mem_spkblty),
        .hidden_16n_spkblty_in(mem_proc_spkblty),
        .hidden_2n_spk_ac_in(mem_proc_ac_spk),
        .hidden_2n_spk_ac_out(proc_ns_ac_spk),
        .input_1024reg_spk_ac_out(proc_ns_in_spk),
        .input_128n_spk_in(mem_proc_in_spk),
        .input_128n_spk_in_we(cntrl_in_spk_reg_we),
        .input_128n_spk_in_mask(cntrl_in_spk_reg_mask),
        .clk(clk),
        .reset(cntrl_proc_reset)
    );


    wire [127:0] proc_mem_u;
    wire [127:0] mem_proc_u;
    wire [63:0] mem_proc_b;
    u_b_processor ub_p(
        .save_16n_potential_in(ns_proc_u_out),
        .save_16n_spk_in(proc_mem_spk),
        .save_16n_potential_out(proc_mem_u),
        .load_16n_potential_out(proc_ns_u_in),
        .load_16n_potential_in(mem_proc_u),
        .load_16n_beta_in(mem_proc_b)
    );


    wire [8:0] cntrl_spkblty_read_addr;
    wire [2:0] cntrl_ac_spk_read_switch;
    wire [8:0] cntrl_ac_spk_read_addr;
    wire [8:0] cntrl_in_spk_read_addr;
    wire [8:0] cntrl_spk_write_addr;
    wire cntrl_spk_write_we;
    wire [8:0] cntrl_spkblty_write_addr;
    wire cntrl_spkblty_write_we;
    spk_memory_controler spk_mem(
        .spkblty_read_sram(spkblty_read_sram),
        .spkblty_read_sram_addr(spkblty_read_sram_addr),
        .spkblty_read_out(mem_proc_spkblty),
        .cntrl_spkblty_read_addr(cntrl_spkblty_read_addr),

        .ac_spk_read_sram(spk_read_sram),
        .ac_spk_read_sram_addr(spk_read_sram_addr),
        .ac_spk_read_out(mem_proc_ac_spk),
        .cntrl_ac_spk_read_switch(cntrl_ac_spk_read_switch),
        .cntrl_ac_spk_read_addr(cntrl_ac_spk_read_addr),

        .in_spk_read_sram(in_spk_read_sram),
        .in_spk_read_sram_addr(in_spk_read_sram_addr),
        .in_spk_read_out(mem_proc_in_spk),
        .cntrl_in_spk_read_addr(cntrl_in_spk_read_addr),

        .spk_write_sram(spk_write_sram),
        .spk_write_sram_addr(spk_write_sram_addr),
        .spk_write_sram_we(spk_write_sram_we),
        .spk_write_in(proc_mem_spk),
        .cntrl_spk_write_addr(cntrl_spk_write_addr),
        .cntrl_spk_write_we(cntrl_spk_write_we),

        .spkblty_write_sram(spkblty_write_sram),
        .spkblty_write_sram_addr(spkblty_write_sram_addr),
        .spkblty_write_sram_we(spkblty_write_sram_we),
        .spkblty_write_in(proc_mem_spkblty),
        .cntrl_spkblty_write_addr(cntrl_spkblty_write_addr),
        .cntrl_spkblty_write_we(cntrl_spkblty_write_we)
    );


    wire [8:0] cntrl_potential_read_addr;
    wire [8:0] cntrl_beta_read_addr;
    wire [8:0] cntrl_potential_write_addr;
    wire cntrl_potential_write_we;
    u_b_memory_controler ub_mem(
        .potential_read_sram(u_read_sram),
        .potential_read_sram_addr(u_read_sram_addr),
        .potential_read_out(mem_proc_u),
        .cntrl_potential_read_addr(cntrl_potential_read_addr),

        .beta_read_sram(b_read_sram),
        .beta_read_sram_addr(b_read_sram_addr),
        .beta_read_out(mem_proc_b),
        .cntrl_beta_read_addr(cntrl_beta_read_addr),

        .potential_write_sram(u_write_sram),
        .potential_write_sram_addr(u_write_sram_addr),
        .potential_write_sram_we(u_write_sram_we),
        .potential_write_in(proc_mem_u),
        .cntrl_potential_write_addr(cntrl_potential_write_addr),
        .cntrl_potential_write_we(cntrl_potential_write_we)
    );

    control_unit cu(
        .w_read_sram_addr(w_read_sram_addr),
        .cntrl_u_out_select(cntrl_u_out_select),
        .cntrl_spk_select(cntrl_spk_select),
        .cntrl_u_in_select(cntrl_u_in_select),
        .cntrl_ac_reset(cntrl_ac_reset),
        .cntrl_ac_oen(cntrl_ac_oen),
        .cntrl_neu_reset(cntrl_neu_reset),
        .cntrl_in_spk_reg_we(cntrl_in_spk_reg_we),
        .cntrl_proc_reset(cntrl_proc_reset),
        .cntrl_spkblty_read_addr(cntrl_spkblty_read_addr),
        .cntrl_ac_spk_read_switch(cntrl_ac_spk_read_switch),
        .cntrl_ac_spk_read_addr(cntrl_ac_spk_read_addr),
        .cntrl_in_spk_read_addr(cntrl_in_spk_read_addr),
        .cntrl_spk_write_addr(cntrl_spk_write_addr),
        .cntrl_spk_write_we(cntrl_spk_write_we),
        .cntrl_spkblty_write_addr(cntrl_spkblty_write_addr),
        .cntrl_spkblty_write_we(cntrl_spkblty_write_we),
        .cntrl_potential_read_addr(cntrl_potential_read_addr),
        .cntrl_beta_read_addr(cntrl_beta_read_addr),
        .cntrl_potential_write_addr(cntrl_potential_write_addr),
        .cntrl_potential_write_we(cntrl_potential_write_we),
        .clk(clk),
        .reset(reset)
    );

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("accelerator.vcd");
    $dumpvars (0, accelerator);
    #1;
    end
    `endif

endmodule
