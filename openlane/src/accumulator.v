`default_nettype none
`timescale 1ns/1ns

module accumulator (
    input wire [1:0] w_read,
    input wire [1:0] spk_in,
    input wire oen,
    output reg [7:0] accumulated_potential,
    // input wire [8:0] cntr,
    input wire clk, reset
    );

    wire [1:0] synapse;
    wire [8:0] accumulator_next;
    reg [7:0] accumulator_reg;

    always @(posedge clk) begin
        if (reset) begin
            accumulator_reg <= 0;
        end else begin
            if (accumulator_next[8]) begin
                accumulator_reg <= 8'd255;
            end else begin
                accumulator_reg <= accumulator_next;
            end
        end
    end

    assign synapse[0] = w_read[0] & spk_in[0];
    assign synapse[1] = w_read[1] & spk_in[1];

    assign accumulator_next = synapse[0] + synapse[1] + accumulator_reg;



    always @(posedge clk) begin
        if (oen == 1) begin
            if (accumulator_reg == 8'd255) begin
                accumulated_potential <= 8'd255;
            end else begin
                if (accumulator_next[8]) begin
                    accumulated_potential <= 8'd255;
                end else begin
                    accumulated_potential <= accumulator_next;
                end
            end
        end
    end

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("accumulator.vcd");
    $dumpvars (0, accumulator);
    #1;
    end
    `endif

endmodule

