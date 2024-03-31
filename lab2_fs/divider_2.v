`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 12:24:30 PM
// Design Name: Simple divider based on counter
// Module Name: divider_2
//////////////////////////////////////////////////////////////////////////////////


module divider_2(
    input wire clk,
    input wire rst,
    output reg clk_out
);

// Use th same technique as with counter, but limit to one bit
wire count_next;
assign count_next = clk_out + 1;

always @(posedge clk) begin
    if (rst) begin
        clk_out <= 0;
    end else
        clk_out <= count_next;
end

endmodule
