`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/31/2024 16:57:07 PM
// Design Name: Test state machine counting fucnion on one example
// Module Name: arbiter_16_tb
//////////////////////////////////////////////////////////////////////////////////


module state_machine_calc_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds
    parameter SIM_TIME = 80; // Simulation time in nanoseconds

    // Signals
    reg clk = 0;         // Clock signal
    reg rst = 0;       // Reset signal
    
    reg [15:0] a_val = 16'hF000;   // Ports and null requirements
    reg [15:0] b_val = 16'h00F0;
    wire [31:0] result;
    
        // Debug
    wire [31:0] add1_out_d;
    wire [31:0] add2_out_d;
    wire [15:0] div_in_d;
    wire [31:0] div_out_d;
    wire [15:0] mul_in_d;
    wire [31:0] mul_out_d;
    wire [2:0] state_d;

    // Instantiate the state machine
    state_machine state_machine_inst (
        .clk(clk),
        .rst(rst),
        .A(a_val),
        .B(b_val),
        .out(result),
        .add1_out_d(add1_out_d),
        .add2_out_d(add2_out_d),
        .div_in_d(div_in_d),
        .div_out_d(div_out_d),
        .mul_in_d(mul_in_d),
        .mul_out_d(mul_out_d),
        .state_d(state_d)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Stimulus generation
    initial begin
        rst = 1;
        #10 rst = 0;

        // Shift clock for SIM_TIME nanoseconds
        #SIM_TIME $finish;
    end
    
    // Working sample trace
//    ((A + B)*4 + B)/2 + (B/2 + A*4)

//    a = f000
//    b = 00f0
    
//    a + b = f0f0 ++2
//    * 4 = 3�3�0 ++3
//    + b = 3c4b0 +-4 钺疱玎眍 c4b0
//    / 2 = 1e258 +-5 钺疱玎眍 6258
//    b / 2 = 78 ++2
//    a * 4 = 3c000 ++2
//      + = 3c078 +-4 钺疱玎眍 c078
//    res = 5a2d0 +-6 钺疱玎眍 122d0

endmodule
