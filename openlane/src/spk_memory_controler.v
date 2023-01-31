`default_nettype none
`timescale 1ns/1ns


/* `include "shift_add_mult.v" */

module spk_memory_controler (
    // spkblty read
    input wire [15:0] spkblty_read_sram,
    output wire [8:0] spkblty_read_sram_addr,

    output wire [15:0] spkblty_read_out,

    input wire [8:0] cntrl_spkblty_read_addr,

    // AC spk read
    input wire [15:0] ac_spk_read_sram,
    output wire [8:0] ac_spk_read_sram_addr,

    output reg [1:0] ac_spk_read_out,

    input wire [2:0] cntrl_ac_spk_read_switch,
    input wire [8:0] cntrl_ac_spk_read_addr,

    // input spk read
    input wire [127:0] in_spk_read_sram,
    output wire [8:0] in_spk_read_sram_addr,

    output wire [127:0] in_spk_read_out,

    input wire [8:0] cntrl_in_spk_read_addr,

    // spk write
    output wire [15:0] spk_write_sram,
    output wire [8:0] spk_write_sram_addr,
    output wire spk_write_sram_we,

    input wire [15:0] spk_write_in,

    input wire [8:0] cntrl_spk_write_addr,
    input wire cntrl_spk_write_we,

    // spkblty write
    output wire [15:0] spkblty_write_sram,
    output wire [8:0] spkblty_write_sram_addr,
    output wire spkblty_write_sram_we,

    input wire [15:0] spkblty_write_in,

    input wire [8:0] cntrl_spkblty_write_addr,
    input wire cntrl_spkblty_write_we
    );

    // spkblty read
    assign spkblty_read_out = spkblty_read_sram;
    assign spkblty_read_sram_addr = cntrl_spkblty_read_addr;

    //ac spk read
    assign ac_spk_read_sram_addr = cntrl_ac_spk_read_addr;
    always @(*) begin
        case (cntrl_ac_spk_read_switch)
            3'd0: ac_spk_read_out <= ac_spk_read_sram[1:0];
            3'd1: ac_spk_read_out <= ac_spk_read_sram[3:2];
            3'd2: ac_spk_read_out <= ac_spk_read_sram[5:4];
            3'd3: ac_spk_read_out <= ac_spk_read_sram[7:6];
            3'd4: ac_spk_read_out <= ac_spk_read_sram[9:8];
            3'd5: ac_spk_read_out <= ac_spk_read_sram[11:10];
            3'd6: ac_spk_read_out <= ac_spk_read_sram[13:12];
            3'd7: ac_spk_read_out <= ac_spk_read_sram[15:14];
            default: ac_spk_read_out <= 2'bxx;
        endcase
    end

    //input spk read
    assign in_spk_read_out = in_spk_read_sram;
    assign in_spk_read_sram_addr = cntrl_in_spk_read_addr;

    // spk write
    assign spk_write_sram = spk_write_in;
    assign spk_write_sram_addr = cntrl_spk_write_addr;
    assign spk_write_sram_we = cntrl_spk_write_we;

    //spkblty write
    assign spkblty_write_sram = spkblty_write_in;
    assign spkblty_write_sram_addr = cntrl_spkblty_write_addr;
    assign spkblty_write_sram_we = cntrl_spkblty_write_we;


    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("spk_memory_controler.vcd");
    $dumpvars (0, spk_memory_controler);
    #1;
    end
    `endif

endmodule

