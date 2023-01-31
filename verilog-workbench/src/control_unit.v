`default_nettype none
`timescale 1ns/1ns

`define STATE_INIT               4'd0
`define STATE_INPUT_O            4'd1
`define STATE_PRE_INPUT          4'd2
`define STATE_INPUT              4'd3
`define STATE_P_H                4'd4
`define STATE_HIDDEN             4'd5
`define STATE_PRE_OUTPUT         4'd6
`define STATE_OUTPUT             4'd7

module control_unit (
    // w sram addr
    output reg [10:0] w_read_sram_addr,                 // w read

    // neuron selector
    output reg [5:0] cntrl_u_out_select,                // potential write
    output reg cntrl_spk_select,                        // input layer
    output reg [5:0] cntrl_u_in_select,                 // potential read

    // accumlators
    output reg cntrl_ac_reset,                          // reset ac when changing layers
    output reg cntrl_ac_oen,                            // read ac into the neuron when ready

    //neurons
    output reg cntrl_neu_reset,                         // reset neurons (on reset) (prob useless)

    //spk procssor
    output reg [2:0] cntrl_in_spk_reg_mask,             // read in_spk input layer
    output reg cntrl_in_spk_reg_we,                     // read in_spk input layer
    output reg cntrl_proc_reset,                        // reset in_spk (prob uselss)

    //u_b_processor


    //spk_memory_controler
    output reg [8:0] cntrl_spkblty_read_addr,           // spkblty read
    output reg [8:0] cntrl_spkblty_write_addr,          // spkblty write
    output reg cntrl_spkblty_write_we,                  // spkblty write
    output reg [2:0] cntrl_ac_spk_read_switch,          // spk read
    output reg [8:0] cntrl_ac_spk_read_addr,            // spk read
    output reg [8:0] cntrl_spk_write_addr,              // spk write
    output reg cntrl_spk_write_we,                      // spk write
    output reg [8:0] cntrl_in_spk_read_addr,            // in_spk read

    //u_b_memory_controler
    output reg [8:0] cntrl_potential_read_addr,         // potential read
    output reg [8:0] cntrl_potential_write_addr,        // potential write
    output reg cntrl_potential_write_we,                // potential write
    output reg [8:0] cntrl_beta_read_addr,              // beta read

    input wire clk, reset
    );

    reg [3:0] state;
    reg [7:0] time_step;
    reg [9:0] cnt_512;
    always @(posedge clk) begin
        case (state)
            `STATE_INIT: begin
                cntrl_proc_reset <= 1;
                cntrl_neu_reset <= 1;
                cnt_512 <= 0;
                time_step <= 0;
                state <= `STATE_INPUT_O;
                // in spk load
                cntrl_in_spk_reg_mask <= 0;
                cntrl_in_spk_reg_we <= 1;
                cntrl_in_spk_read_addr <= 0;
            end
            `STATE_INPUT_O: begin
                if (reset)
                    state <= `STATE_INIT;

                cnt_512 <= cnt_512 + 1;
                cntrl_proc_reset <= 0;
                cntrl_neu_reset <= 0;
                // 8 cycles
                if (cnt_512 < 7) begin
                    cntrl_in_spk_read_addr <= cntrl_in_spk_read_addr + 1;
                    cntrl_in_spk_reg_mask <= cntrl_in_spk_reg_mask + 1;
                end else begin
                    cntrl_in_spk_reg_we <= 0;
                    cntrl_ac_reset <= 1;
                    state <= `STATE_PRE_INPUT;
                end
            end
            `STATE_PRE_INPUT: begin
                cnt_512 <= 0;
                cntrl_ac_oen <= 0;

                // update addr
                // current layer:
                w_read_sram_addr  <= 0;
                cntrl_potential_read_addr <= 0;
                cntrl_beta_read_addr <= 0;
                // previous layer:
                cntrl_spkblty_read_addr <= 128;
                cntrl_potential_write_addr <= 128;
                cntrl_spkblty_write_addr <= 128;
                cntrl_spk_write_addr <= time_step;

                // neuron select
                cntrl_u_out_select <= 0;
                cntrl_spk_select <= 0;
                cntrl_u_in_select <= 0;
                // write enable
                cntrl_spkblty_write_we <= 1;
                cntrl_spk_write_we <= 1;
                cntrl_potential_write_we <= 1;

                state <= `STATE_INPUT;
            end
            `STATE_INPUT: begin
                if (reset)
                    state <= `STATE_INIT;

                cntrl_ac_reset <= 0;
                cnt_512 <= cnt_512 + 1;
                // 64 cycles
                if (cnt_512 < 63) begin      // timing check
                    cntrl_potential_read_addr <= cntrl_potential_read_addr + 1;
                    cntrl_beta_read_addr <= cntrl_beta_read_addr + 1;
                    cntrl_u_in_select <= cntrl_u_in_select + 1;
                end
                // 1 cycle
                if (cnt_512 < 1) begin
                    cntrl_ac_oen <= 1;
                    cntrl_ac_reset <= 1;
                end else begin
                    cntrl_ac_oen <= 0;
                    cntrl_spkblty_write_we <= 0;
                    cntrl_spk_write_we <= 0;
                    cntrl_potential_write_we <= 0;
                end
                // finish
                if (cnt_512 == 64) begin       // timing check
                    state <= `STATE_P_H;
                end
            end
            `STATE_P_H: begin
                cnt_512 <= 0;
                cntrl_ac_oen <= 0;
                // update addr
                // current layer:
                w_read_sram_addr  <= 1;
                cntrl_potential_read_addr <= 64;
                cntrl_beta_read_addr <= 64;
                // previous layer:
                cntrl_ac_spk_read_addr <= 0;
                cntrl_ac_spk_read_switch <= 0;
                cntrl_spkblty_read_addr <= 0;
                cntrl_potential_write_addr <= 0;
                cntrl_spkblty_write_addr <= 0;
                cntrl_spk_write_addr <= 0;
                // neuron select
                cntrl_u_out_select <= 0;
                cntrl_spk_select <= 0;
                cntrl_u_in_select <= 0;
                // write enable
                cntrl_spkblty_write_we <= 1;
                cntrl_spk_write_we <= 1;
                cntrl_potential_write_we <= 1;

                state <= `STATE_HIDDEN;
            end
            `STATE_HIDDEN: begin
                if (reset)
                    state <= `STATE_INIT;

                cntrl_ac_reset <= 0;
                cnt_512 <= cnt_512 + 1;
                // 512 cycles with 1 cycle delay
                // w read, spk read
                if (cnt_512 > 0) begin          // timing check
                    w_read_sram_addr <= w_read_sram_addr + 1;
                    cntrl_ac_spk_read_addr <= cntrl_ac_spk_read_addr + 1;
                    cntrl_ac_spk_read_switch <= cntrl_ac_spk_read_switch + 1;
                end
                // 64 cycles
                // potential r/w, spk w, spkblty r/w, beta r
                if (cnt_512 < 63) begin         // timing check
                    cntrl_potential_read_addr <= cntrl_potential_read_addr + 1;
                    cntrl_potential_write_addr <= cntrl_potential_write_addr + 1;
                    cntrl_spk_write_addr <= cntrl_spk_write_addr + 1;
                    cntrl_spkblty_read_addr <= cntrl_spkblty_read_addr + 1;
                    cntrl_spkblty_write_addr <= cntrl_spkblty_write_addr + 1;
                    cntrl_beta_read_addr <= cntrl_beta_read_addr + 1;
                    cntrl_u_out_select <= cntrl_u_out_select + 1;
                    cntrl_spk_select <= cntrl_spk_select + 1;
                    cntrl_u_in_select <= cntrl_u_in_select + 1;
                end else begin
                    cntrl_spkblty_write_we <= 0;
                    cntrl_spk_write_we <= 0;
                    cntrl_potential_write_we <= 0;
                end
                // finish
                if (cnt_512 == 511) begin       // timing check
                    cntrl_ac_oen <= 1;
                    cntrl_ac_reset <= 1;
                    state <= `STATE_PRE_OUTPUT;
                end
            end
            `STATE_PRE_OUTPUT: begin
                cnt_512 <= 0;
                cntrl_ac_oen <= 0;
                // update addr
                // current layer:
                w_read_sram_addr  <= 513;
                cntrl_potential_read_addr <= 128;
                cntrl_beta_read_addr <= 128;
                // previous layer:
                cntrl_ac_spk_read_addr <= 64;
                cntrl_ac_spk_read_switch <= 0;
                cntrl_spkblty_read_addr <= 64;
                cntrl_potential_write_addr <= 64;
                cntrl_spkblty_write_addr <= 64;
                cntrl_spk_write_addr <= 64;
                // neuron select
                cntrl_u_out_select <= 0;
                cntrl_spk_select <= 0;
                cntrl_u_in_select <= 0;
                // write enable
                cntrl_spkblty_write_we <= 1;
                cntrl_spk_write_we <= 1;
                cntrl_potential_write_we <= 1;
                // in spk load
                cntrl_in_spk_reg_mask <= 0;
                cntrl_in_spk_reg_we <= 1;
                cntrl_in_spk_read_addr <= time_step + 1;

                state <= `STATE_OUTPUT;
            end
            `STATE_OUTPUT: begin
                if (reset)
                    state <= `STATE_INIT;

                cntrl_ac_reset <= 0;
                cnt_512 <= cnt_512 + 1;
                // 512 cycles with 1 cycle delay
                // w read, spk read
                if (cnt_512 > 0) begin          // timing check
                    w_read_sram_addr <= w_read_sram_addr + 1;
                    cntrl_ac_spk_read_addr <= cntrl_ac_spk_read_addr + 1;
                    cntrl_ac_spk_read_switch <= cntrl_ac_spk_read_switch + 1;
                end
                // 64 cycles
                // potential r/w, spk w, spkblty r/w, beta r
                if (cnt_512 < 63) begin         // timing check
                    cntrl_potential_write_addr <= cntrl_potential_write_addr + 1;
                    cntrl_spk_write_addr <= cntrl_spk_write_addr + 1;
                    cntrl_spkblty_read_addr <= cntrl_spkblty_read_addr + 1;
                    cntrl_spkblty_write_addr <= cntrl_spkblty_write_addr + 1;
                    cntrl_u_out_select <= cntrl_u_out_select + 1;
                    cntrl_spk_select <= cntrl_spk_select + 1;
                end else begin
                    cntrl_spkblty_write_we <= 0;
                    cntrl_spk_write_we <= 0;
                    cntrl_potential_write_we <= 0;
                end
                // 8 cycles
                if (cnt_512 < 7) begin
                    cntrl_in_spk_read_addr <= cntrl_in_spk_read_addr + 1;
                    cntrl_in_spk_reg_mask <= cntrl_in_spk_reg_mask + 1;
                end else begin
                    cntrl_in_spk_reg_we <= 0;
                end
                // finish
                if (cnt_512 == 511) begin       // timing check
                    if (time_step < 128) begin
                        cntrl_ac_oen <= 1;
                        cntrl_ac_reset <= 1;
                        time_step <= time_step + 1;
                        state <= `STATE_PRE_INPUT;
                    end else begin
                        state <= `STATE_INIT;
                    end
                end
            end
            default: state <= `STATE_INIT;
        endcase
    end

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("control_unit.vcd");
    $dumpvars (0, control_unit);
    #1;
    end
    `endif

endmodule
