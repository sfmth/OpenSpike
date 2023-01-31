`default_nettype none
`timescale 1ns/1ns

`define SIZE 512
`define WIDTH 32
`define WRITABLE 1
// `define WRITE_WIDTH 32

module sram (
    `ifdef WRITABLE
        input wire [`WIDTH-1:0] write_data,
        input wire [11:0] write_addr,
        input wire we,
    `endif
    output reg [`WIDTH-1:0] read_data,
    input wire [11:0] read_addr,
    input wire clk
    );
    parameter T_HOLD = 2000 ; //Delay to hold dout value after posedge. Value is arbitrary

    `ifdef WRITABLE
        reg [11:0] write_addr_reg;
        reg [`WIDTH-1:0] write_data_reg;
        reg we_reg;
    `endif
    
    initial begin
        clk2 <= 0;
    end
    reg clk2;
    always @(posedge clk) begin
        clk2 <= !clk2;
    end
    
    reg [11:0] read_addr_reg;
    reg [`WIDTH-1:0] mem_array [`SIZE-1:0];

    always @(posedge clk) begin
        read_addr_reg <= read_addr;
        #(T_HOLD) read_data <= 32'bx;
        `ifdef WRITABLE
            write_addr_reg <= write_addr;
            write_data_reg <= write_data;
            we_reg <= we;
        `endif
    end

    `ifdef WRITABLE
    always @(negedge clk) begin
        if (we) begin
            mem_array[write_addr_reg] <= write_data_reg;
        end
    end
    `endif

    always @(negedge clk) begin
        read_data <= mem_array[read_addr_reg];
    end

    `ifdef COCOTB_SIM 
    initial begin
    $dumpfile ("sram.vcd");
    $dumpvars (0, sram);
    #1;
    end
    `endif

endmodule