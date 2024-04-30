`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 04/29/2024 03:43:57 PM
// Design Name: Port to seven segments indicator
// Module Name: segments
//////////////////////////////////////////////////////////////////////////////////

module segments
#(parameter DIGIT_DURATION = 200_000)
    (
        input clk,
        input rst,
        input [3:0] size,
        input [15:0] data_in,
        output reg[6:0] CAT,
        output reg[7:0] AN
    );
    
reg[2:0] current_dg = 0;
reg[3:0] hex;
wire[31:0] result;
reg[$clog2(DIGIT_DURATION + 1):0] counter;

wire[15:0] size_num = 0; 

assign result[31:20] = 0;
assign result[15:0] = data_in;
assign result[19:16] = size;

always @(posedge clk) begin
    if (rst) begin
        AN <= 8'b11111110;
        current_dg <= 0;
    end else
    if (counter == DIGIT_DURATION) begin
        AN <= {AN[6:0], AN[7]};
        current_dg <= current_dg + 1;   
        counter <= 0;
     end else begin
        counter <= counter + 1;
     end
end


always @(*) begin
    case(current_dg)
        0: hex = result[3:0];
        1: hex = result[7:4];
        2: hex = result[11:8];
        3: hex = result[15:12];
        4: hex = result[19:16];
        5: hex = result[23:20];
        6: hex = result[27:24];
        7: hex = result[31:28];
    endcase
end    

always @(*) begin
    case(hex)
        4'h0: CAT = 7'b0000001;
        4'h1: CAT = 7'b1001111;
        4'h2: CAT = 7'b0010010;
        4'h3: CAT = 7'b0000110;
        4'h4: CAT = 7'b1001100;
        4'h5: CAT = 7'b0100100;
        4'h6: CAT = 7'b0100000;
        4'h7: CAT = 7'b0001111;
        4'h8: CAT = 7'b0000000;
        4'h9: CAT = 7'b0000100;
        4'ha: CAT = 7'b0001000;
        4'hb: CAT = 7'b1100000;
        4'hc: CAT = 7'b0110001;
        4'hd: CAT = 7'b1000010;
        4'he: CAT = 7'b0110000;
        4'hf: CAT = 7'b0111000;
    endcase
end
endmodule

