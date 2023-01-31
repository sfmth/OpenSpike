`default_nettype none
`timescale 1ns/1ns


module accumulator (
    input wire [1023:0] w_in,
    input wire [1023:0] spk_in,
    output reg [7:0] u_out
    ); 

    wire [1023:0] synapse;
    assign synapse = w_in & spk_in;

    integer i;
    always @(*) begin
        u_out = 0;
        for (i = 0; i<1024 ; i=i+1) begin
            if (u_out >= 255) begin
                u_out = 255;
            end else if (synapse[i] == 1) begin
                u_out = u_out + 1;
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