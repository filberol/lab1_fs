`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 04/29/2024 02:08:02 PM
// Design Name: Button debouncer with clock
// Module Name: debouncer
//////////////////////////////////////////////////////////////////////////////////

module debouncer
#(parameter WAIT_CLOCKS = 1_000_000)
    (
        input clk,
        input btn_i,
        output reg activated    
    );
    
initial activated = 0;

reg [$clog2(WAIT_CLOCKS+1)-1:0] cnt;
    
always @(posedge clk) begin
    if (cnt == WAIT_CLOCKS) begin
        if (btn_i) begin
            if (!activated) activated <= 1;
        end else activated <= 0;
        cnt <= 0;
        end else cnt <= cnt + 1;
    end
endmodule

