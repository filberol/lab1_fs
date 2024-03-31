`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/18/2024 01:40:06 PM
// Design Name: Multiply unsigned 16 bit by 4 reassigning the bits
// Module Name: mul4_16to32
//////////////////////////////////////////////////////////////////////////////////


module div2_16to32(
    input wire [15:0] in,
    input wire count,
    output wire [31:0] out
);

reg [31:0] result;
assign new_result = {17'b0, in[14:0]};

always @(posedge count) begin
    result <= new_result;
end

assign out = result;

endmodule
