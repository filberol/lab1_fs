`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/14/2024 11:21:07 PM
// Design Name: Shift register, that can be witten by whole
// Module Name: shift_reg_16bit
//////////////////////////////////////////////////////////////////////////////////


module shift_reg_16_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds
    parameter SIM_TIME = 200; // Simulation time in nanoseconds

    // Signals
    reg wr_reg = 0;         // Write enable signal
    reg sh_clk = 0;         // Shift clock signal
    reg reset = 0;          // Reset signal
    reg data_in = 0;        // Input bit
    reg [15:0] reg_in = 16'h8;   // Write register
    wire [15:0] data_out;   // Output data

    // Instantiate the shift register
    shift_register_16bit shift_reg_inst (
        .wr_reg(wr_reg),
        .sh_clk(sh_clk),
        .reset(reset),
        .data_in(data_in),
        .reg_in(reg_in),
        .data_out(data_out)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) sh_clk = ~sh_clk;

    // Stimulus generation
    initial begin
        // Write data to shift register
        wr_reg = 1;
        #20 wr_reg = 0;
        #40 data_in = 1;
        #10 data_in = 0;
        #100 reset = 1;
        data_in = 1;
        #10 reset = 0;

        // Shift clock for SIM_TIME nanoseconds
        #SIM_TIME $finish;
    end

    // Display output data
    always @(posedge sh_clk) begin
        $display("Output data: %h", data_out);
    end

endmodule
