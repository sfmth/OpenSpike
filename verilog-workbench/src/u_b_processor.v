`default_nettype none
`timescale 1ns/1ns


`include "/home/farhad/github/iscas-snn-accelerator/verilog-workbench/src/shift_add_mult.v"

module u_b_processor (
    // save
    input wire [127:0] save_16n_potential_in,
    input wire [15:0] save_16n_spk_in,
    output wire [127:0] save_16n_potential_out,

    //load
    output wire [127:0] load_16n_potential_out,
    input wire [127:0] load_16n_potential_in,
    input wire [63:0] load_16n_beta_in

    // input clk, reset
    );


    // save potentials for future use
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1 ) begin
            assign save_16n_potential_out[(i*8)+7:i*8] = (save_16n_spk_in[i]) ?
                                                            8'b0 :
                                                            save_16n_potential_in[(i*8)+7:i*8];
        end
    endgenerate


    //load potentials and apply beta
    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1 ) begin
            shift_add_mult sam(
                .beta(load_16n_beta_in[(j*4)+3:j*4]),
                .potential(load_16n_potential_in[(j*8)+7:j*8]),
                .mult_ans(load_16n_potential_out[(j*8)+7:j*8])
            );
        end
    endgenerate

    // hidden layer mode
    // process spks from input layer
    // genvar j;
    // generate
    //     for (j = 0; j < 16; j = j + 1 ) begin:g_hidden_mode
    //         schmitt_trigger sch0(
    //             .potential(hidden_16n_potential_in[(j*8)+7:j*8]),
    //             .spk(hidden_16n_spk_out[j]),
    //             .spkblty_out(hidden_16n_spkblty_out[j]),
    //             .spkblty_in(hidden_16n_spkblty_in[j])
    //         );
    //     end
    // endgenerate

    // //pass spk reads to the hidden layer
    // assign hidden_2n_spk_ac_out = hidden_2n_spk_ac_in;

    // // Input layer mode
    // // load the 1024bit input spk reg for the input layer
    // always @(posedge clk) begin
    //     if (reset) begin
    //         input_1024reg_spk_ac_out <= 0;
    //     end else begin
    //         if (input_128n_spk_in_we) begin
    //             case (input_128n_spk_in_mask)
    //                 0:  input_1024reg_spk_ac_out[127:0] <= input_128n_spk_in;
    //                 1:  input_1024reg_spk_ac_out[255:128] <= input_128n_spk_in;
    //                 2:  input_1024reg_spk_ac_out[383:256] <= input_128n_spk_in;
    //                 3:  input_1024reg_spk_ac_out[511:384] <= input_128n_spk_in;
    //                 4:  input_1024reg_spk_ac_out[639:512] <= input_128n_spk_in;
    //                 5:  input_1024reg_spk_ac_out[767:640] <= input_128n_spk_in;
    //                 6:  input_1024reg_spk_ac_out[895:768] <= input_128n_spk_in;
    //                 7:  input_1024reg_spk_ac_out[1023:896] <= input_128n_spk_in;
    //                 default:    input_1024reg_spk_ac_out <= 1024'bx;
    //             endcase
    //         end
    //     end
	// end

    // // process spk from output layer
    // genvar k;
	// generate
    //     for (k = 0; k < 10; k = k + 1 ) begin:g_input_mode
    //         schmitt_trigger sch1(
    //             .potential(input_10n_potential_in[(k*8)+7:k*8]),
    //             .spk(input_10n_spk_out[k]),
    //             .spkblty_out(input_10n_spkblty_out[k]),
    //             .spkblty_in(input_10n_spkblty_in[k])
    //         );
    //     end
    // endgenerate

    //output layer mode

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("u_b_processor.vcd");
    $dumpvars (0, u_b_processor);
    #1;
    end
    `endif

endmodule
