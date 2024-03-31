`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filberol Inc.
// Engineer: filberol
// 
// Create Date: 03/18/2024 02:08:32 PM
// Design Name: Dumb adder without using + symbol
// Module Name: adder_16to32
//////////////////////////////////////////////////////////////////////////////////


module adder_16to32 (
    input wire count,
    input wire [15:0] A,
    input wire [15:0] B,
    output wire [31:0] sum
);

reg [15:0] carry;
reg [15:0] sum_temp;
integer i;

always @(posedge count) begin
    sum_temp[0] = A[0] ^ B[0];
    carry[0] = A[0] & B[0];
    
    for (i = 1; i < 16; i = i + 1) begin
        sum_temp[i] = A[i] ^ B[i] ^ carry[i-1];
        carry[i] = (A[i] & B[i]) | (A[i] & carry[i-1]) | (B[i] & carry[i-1]);
    end
end

assign sum = {carry[15], sum_temp};

endmodule


