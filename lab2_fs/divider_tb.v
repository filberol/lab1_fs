`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 11:21:07 PM
// Design Name: Shift register, that can be witten by whole
// Module Name: shift_reg_16bit
//////////////////////////////////////////////////////////////////////////////////


module divider_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds
    parameter SIM_TIME = 200; // Simulation time in nanoseconds

    // Signals
    reg clk = 0; // Just clock
    reg rst = 0;
    wire clk_out;

    // Instantiate the shift register
    divider_2 divider_inst (
        .clk(clk),
        .rst(rst),
        .clk_out(clk_out)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Stimulus generation
    initial begin
        // Write data to shift register
        rst = 1;
        #20 rst = 0;

        // Shift clock for SIM_TIME nanoseconds
        #SIM_TIME $finish;
    end

    // Display output data
    always @(posedge clk) begin
        $display("Output data: %h", clk_out);
    end

endmodule
