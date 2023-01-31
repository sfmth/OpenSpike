`default_nettype none
`timescale 1ns/1ns


module neuron (
    input wire [7:0] potential_accumulated,
    input wire [7:0] potential_previous,
    output wire [7:0] potential_final,
    input wire ien,
    input wire clk, reset
    );

    reg [7:0] potential_previous_reg;
    always @(posedge clk) begin
        if (reset) begin
            potential_previous_reg <= 0;
        end else begin
            if (ien) begin
            potential_previous_reg <= potential_previous;
            end
        end
    end

    wire [8:0] potential_final_with_carry;
    assign potential_final_with_carry = potential_previous_reg + potential_accumulated;
    assign potential_final = (potential_final_with_carry[8]) ?
                                8'd255 : potential_final_with_carry;

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("neuron.vcd");
    $dumpvars (0, neuron);
    #1;
    end
    `endif

endmodule

