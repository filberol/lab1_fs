`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/14/2024 12:34:56 PM
// Design Name: 16 bit counter with self reset
// Module Name: counter_16
//////////////////////////////////////////////////////////////////////////////////

module counter_16bit(
    input wire clk,
    input wire reset,
    output reg [15:0] count
);

wire [15:0] count_next;
assign count_next = count + 1;

// Reset the counter to 0 when the reset signal is asserted
always @(posedge clk)
begin
    if (reset)
        count <= 0;
    else
        count <= count_next;
end

endmodule

