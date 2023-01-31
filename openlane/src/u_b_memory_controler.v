`default_nettype none
`timescale 1ns/1ns


/* `include "shift_add_mult.v" */

module u_b_memory_controler(
    //potential read
    input wire [127:0] potential_read_sram,
    output wire [8:0] potential_read_sram_addr,

    output wire [127:0] potential_read_out,

    input wire [8:0] cntrl_potential_read_addr,

    //beta read
    input wire [63:0] beta_read_sram,
    output wire [8:0] beta_read_sram_addr,

    output wire [63:0] beta_read_out,

    input wire [8:0] cntrl_beta_read_addr,

    // potential write
    output wire [127:0] potential_write_sram,
    output wire [8:0] potential_write_sram_addr,
    output wire potential_write_sram_we,

    input wire [127:0] potential_write_in,

    input wire [8:0] cntrl_potential_write_addr,
    input wire cntrl_potential_write_we
    );

    //potential read
    assign potential_read_out = potential_read_sram;
    assign potential_read_sram_addr = cntrl_potential_read_addr;

    //beta read
    assign beta_read_out = beta_read_sram;
    assign beta_read_sram_addr = cntrl_beta_read_addr;

    //potential write
    assign potential_write_sram = potential_write_in;
    assign potential_write_sram_addr = cntrl_potential_write_addr;
    assign potential_write_sram_we = cntrl_potential_write_we;

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("u_b_memory_controler.vcd");
    $dumpvars (0, u_b_memory_controler);
    #1;
    end
    `endif

endmodule

