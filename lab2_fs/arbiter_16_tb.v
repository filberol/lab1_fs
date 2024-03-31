`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 11:21:07 PM
// Design Name: Arbiter simulation, load all ports
// Module Name: arbiter_16_tb
//////////////////////////////////////////////////////////////////////////////////


module arbiter_16_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds
    parameter SIM_TIME = 150; // Simulation time in nanoseconds

    // Signals
    reg clk = 0;         // Clock signal
    reg reset = 0;       // Reset signal
    
    reg [15:0] port_0 = 16'hF000;   // Ports and null requirements
    reg port_0_ireq = 0;
    wire port_0_succ;
    reg [15:0] port_1 = 16'h0F00;
    reg port_1_ireq = 0;
    wire port_1_succ;
    reg [15:0] port_2 = 16'h00F0;
    reg port_2_ireq = 0;
    wire port_2_succ;
    reg [15:0] port_3 = 16'h000F;
    reg port_3_ireq = 0;
    wire port_3_succ;
    wire busy_o;                  // Check for output signals
    wire [15:0] out_port;

    // Instantiate the shift register
    arbiter_16bit arbiter_inst (
        .clk(clk),
        .reset(reset),
        .port_0(port_0),
        .port_0_ireq(port_0_ireq),
        .port_0_succ(port_0_succ),
        .port_1(port_1),
        .port_1_ireq(port_1_ireq),
        .port_1_succ(port_1_succ),
        .port_2(port_2),
        .port_2_ireq(port_2_ireq),
        .port_2_succ(port_2_succ),
        .port_3(port_3),
        .port_3_ireq(port_3_ireq),
        .port_3_succ(port_3_succ),
        .busy_o(busy_o),
        .out_port(out_port)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Stimulus generation
    initial begin
        reset = 1;
        port_1_ireq = 1;
        #20 reset = 0;
        
        #60
        port_0_ireq = 1;
        port_2_ireq = 1;
        port_3_ireq = 1;
        
        #80
        port_1_ireq = 0;
        port_3_ireq = 0;
        
        #60
        reset = 1;
        #10
        reset = 0;
        
        #40
        port_0_ireq = 0;
        port_2_ireq = 0;
        


        // Shift clock for SIM_TIME nanoseconds
        #SIM_TIME $finish;
    end

    // Display output data
    always @(posedge clk) begin
        $display("Output data: %h", out_port);
    end

endmodule
