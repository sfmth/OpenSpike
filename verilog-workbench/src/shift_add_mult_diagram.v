`default_nettype none
`timescale 1ns/1ns

module shift_add_mult (
    input wire [3:0] cntrl1,
    input wire [3:0] cntrl2,
    input wire [7:0] potential,
    input wire [7:0] potential_1,
    input wire [7:0] potential_2,
    input wire [7:0] potential_3,
    output reg [7:0] mult_ans
    );

    reg [7:0] mux_cntrl1_out;
    wire [7:0] p2_p1;
    wire [7:0] p3_mux;
    assign p2_p1 = potential_1 + potential_2;
    always @(*) begin
        case (cntrl1)
            4'd0:     mux_cntrl1_out <= potential_1;   
            4'd1:       mux_cntrl1_out <= p2_p1;
            4'd2:       mux_cntrl1_out <= potential_2;
            default: mux_cntrl1_out <= 8'bx;
        endcase
    end
    assign p3_mux = mux_cntrl1_out + potential_3;
    always @(*) begin
        case (cntrl2)
            4'd0:     mult_ans <= 0;
            4'd1:     mult_ans <= potential;   
            4'd2:     mult_ans <= potential_1;   
            4'd3:     mult_ans <= potential_2;   
            4'd4:     mult_ans <= potential_3;   
            4'd5:     mult_ans <= p2_p1;   
            4'd6:     mult_ans <= p3_mux;   
            default: mult_ans <= 8'bx;
        endcase
    end

    `ifdef COCOTB_SIM
    initial begin
    $dumpfile ("shift_add_mult.vcd");
    $dumpvars (0, shift_add_mult);
    #1;
    end
    `endif

endmodule

