`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 11:21:07 PM
// Design Name: Shift register, that can be witten by whole
// Module Name: shift_reg_16bit
//////////////////////////////////////////////////////////////////////////////////


module count_ones_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds
    parameter SIM_TIME = 200; // Simulation time in nanoseconds

    // Signals
    reg clk = 0; // Just clock
    reg rst = 0;
    reg measure_req_i = 0;
    wire result_rsp_o;
    wire busy_o;
    wire [15:0] result_data_o;
    
    // Instantiate the count module
    count_ones count_ones_inst (
        .clk(clk),
        .rst(rst),
        .measure_req_i(measure_req_i),
        .result_rsp_o(result_rsp_o),
        .busy_o(busy_o),
        .result_data_o(result_data_o)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Stimulus generation
    initial begin
        // Write data to shift register
        rst = 1;
        #20 rst = 0;
        #10 measure_req_i = 1;
        #10 measure_req_i = 0;
        
        #40 measure_req_i = 1;
        #10 measure_req_i = 0;

        // Shift clock for SIM_TIME nanoseconds
        #SIM_TIME $finish;
    end

    // Display output data
    always @(posedge clk) begin
        $display("Output data: %h", result_data_o);
    end

endmodule
