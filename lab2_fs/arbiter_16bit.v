`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 10:09:28 AM
// Design Name: Simple signal arbiter with round robin algorithm
// Module Name: arbiter_16bit
//////////////////////////////////////////////////////////////////////////////////


module arbiter_16bit(
    input wire clk,
    input wire reset,
    input wire [15:0] port_0,
    input wire port_0_ireq,
    output wire port_0_succ,
    input wire [15:0] port_1,
    input wire port_1_ireq,
    output wire port_1_succ,
    input wire [15:0] port_2,
    input wire port_2_ireq,
    output wire port_2_succ,
    input wire [15:0] port_3,
    input wire port_3_ireq,
    output wire port_3_succ,
    output wire busy_o,
    output wire [15:0] out_port
);

// Ready valid protocol
// individual ready feedback for all ports
    
// multi driven net warning    
    
reg[1:0] curr_in_port;
reg[15:0] arbit_state;

reg port_0_out;
reg port_1_out;
reg port_2_out;
reg port_3_out;

wire[1:0] next_port;
assign next_port = curr_in_port + 1;

// do not use negedge
//always @(negedge reset)
//begin
//    curr_in_port <= 0;
//end

always @(posedge clk)
begin
    if (reset) begin
        curr_in_port <= 2'b0;
        arbit_state <= 16'b0;
        port_0_out <= 0;
        port_1_out <= 0;
        port_2_out <= 0;
        port_3_out <= 0;
    end
    else begin
        if (port_0_ireq == 0 && port_1_ireq == 0 && port_2_ireq == 0 && port_3_ireq == 0) begin
            arbit_state <= 16'b0;
            port_0_out <= 0;
            port_1_out <= 0;
            port_2_out <= 0;
            port_3_out <= 0;
        end
        else if (curr_in_port == 0) begin
            port_3_out <= 0;
            if (port_0_ireq == 1) begin
                arbit_state <= port_0;
                port_0_out <= 1;
            end
        end
        else if (curr_in_port == 1) begin
            port_0_out <= 0;
            if (port_1_ireq == 1) begin
                arbit_state <= port_1;
                port_1_out <= 1;
            end
        end
        else if (curr_in_port == 2) begin
            port_1_out <= 0;
            if (port_2_ireq == 1) begin
                arbit_state <= port_2;
                port_2_out <= 1;
            end
        end
        else if (curr_in_port == 3) begin
            port_2_out <= 0;
            if (port_3_ireq == 1) begin
                arbit_state <= port_3;
                port_3_out <= 1;
            end
        end
        curr_in_port <= next_port;
    end
end

assign out_port = arbit_state;
assign busy_o = port_0_out | port_1_out | port_2_out | port_3_out;

assign port_0_succ = port_0_out;
assign port_1_succ = port_1_out;
assign port_2_succ = port_2_out;
assign port_3_succ = port_3_out;

endmodule
