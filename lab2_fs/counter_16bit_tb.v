`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/14/2024 10:46:46 PM
// Design Name: Test for counter
// Module Name: counter_16bit_tb
//////////////////////////////////////////////////////////////////////////////////

module counter_16bit_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds
    parameter SIM_TIME = 300; // Simulation time in nanoseconds

    // Signals
    reg clk = 0; // Clock signal
    reg reset = 0; // Reset signal
    wire [15:0] counter_out; // Output from the counter

    // Instantiate the counter
    counter_16bit counter_inst (
        .clk(clk),
        .reset(reset),
        .count(counter_out)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Stimulus generation
    initial begin
        // Reset counter initially
        reset = 1;
        #20 reset = 0;

        // Toggle reset after 50ns
        #50 reset = 1;
        #20 reset = 0;

        // Test the counter for SIM_TIME nanoseconds
        #SIM_TIME $finish;
    end

    // Display counter value
    always @(posedge clk) begin
        $display("Counter value: %d", counter_out);
    end

endmodule
