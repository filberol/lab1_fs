`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/14/2024 11:21:07 PM
// Design Name: Shift register, that can be witten by whole
// Module Name: shift_reg_16bit
//////////////////////////////////////////////////////////////////////////////////

module shift_register_16bit(
    input wire wr_reg,   // Write enable signal
    input wire sh_clk,   // Shift clock signal
    input wire reset,    // Reset signal
    input wire data_in,  // Input data
    input wire [15:0] reg_in,   // Input registe
    output wire [15:0] data_out // Output data
);

// Internal register to store the 16-bit shift register
reg [15:0] shift_reg;

// ?????????? ????? ????????? ? ???????????????? ?????? ??????? ??????

// Reset the shift register to all zeros when the reset signal is asserted
always @(posedge sh_clk or posedge reset or posedge wr_reg)
begin
    if (reset)
        shift_reg <= 16'b0; // Reset register
    else if (wr_reg)
        shift_reg <= reg_in; // Write data to the shift register
    else if (sh_clk)
        shift_reg <= {shift_reg[14:0], data_in}; // Shift the data left by one bit
        // Write data_in to first bit
end

// Output the shifted data
assign data_out = shift_reg;

endmodule

