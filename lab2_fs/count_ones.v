`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 12:19:39 PM
// Design Name: Count positive edges from frequency divider
// Module Name: count_ones
//////////////////////////////////////////////////////////////////////////////////


module count_ones(
    input wire clk,
    input wire rst,
    input wire measure_req_i,
    output wire result_rsp_o,
    output wire busy_o,
    output wire [15:0] result_data_o
);

reg counting;
reg on_out;
reg need_out;

wire clk_out;
divider_2 div_inst (
    .clk(clk),
    .rst(rst),
    .clk_out(clk_out)
);

wire clk_access;
assign clk_access = counting & clk_out;
reg count_reset;
wire [15:0] counter_result;
counter_16bit count_inst (
    .clk(clk_access),
    .reset(count_reset),
    .count(counter_result)
);

always @(posedge clk) begin
    if (rst) begin
        counting <= 0;
        on_out <= 0;
        need_out <= 0;
        count_reset <= 1;
    end else if (measure_req_i) begin
        if (counting) begin
            need_out <= 1;
        end
        counting <= !counting;
    end else if (counting) begin
        count_reset <= 0;
    end else if (need_out) begin
        on_out <= 1;
        need_out <= 0;
    end else if (on_out) begin
        on_out <= 0;
        count_reset <= 1;
    end
end

//// synchronized with other posedges
//always @(posedge measure_req_i) begin
//    if (counting) begin
//        need_out <= 1;
//    end
//    counting <= !counting;
//end

assign busy_o = counting | measure_req_i | on_out | need_out;
assign result_rsp_o = on_out;
assign result_data_o = (on_out) ? counter_result : 16'b0;

endmodule
