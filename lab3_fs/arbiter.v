`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filber Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 10:09:28 AM
// Design Name: Simple signal arbiter with round robin algorithm
// Module Name: arbiter_16bit
//////////////////////////////////////////////////////////////////////////////////


module arbiter(
    // Manual and inner clocks
    input wire inner_clk,
    input wire clk_button_in,
    input wire reset,
    // Inputs with requests and valids
    input wire [2:0] port_0,
    input wire port_0_ireq,
    output wire port_0_succ,
    input wire [2:0] port_1,
    input wire port_1_ireq,
    output wire port_1_succ,
    input wire [2:0] port_2,
    input wire port_2_ireq,
    output wire port_2_succ,
    input wire [2:0] port_3,
    input wire port_3_ireq,
    output wire port_3_succ,
    // Status signal
    output wire busy_o,
    // Additional ports
    output wire filtered_clk,
    // Segment indicator ports
    output wire [7:0] segment_switch,
    output wire [6:0] number_switch
);

// Inner logic state
reg[1:0] curr_in_port;
reg[2:0] arbit_state;

// Valid signals for leds
reg port_0_out;
reg port_1_out;
reg port_2_out;
reg port_3_out;

// Registers for segments output
reg [7:0] current_segment;
reg [6:0] current_number;

// Switching port logic
wire[1:0] next_port;
assign next_port = curr_in_port + 1;

// CDC synchronizer for clock button
debouncer debouncer_inst(
    .clk(inner_clk),
    .btn_i(clk_button_in),
    .activated(filtered_clk)
);
//reg [8:0] counter;
//wire [8:0] next_counter;
//assign next_counter = counter + 1;
//reg prev_signal;
//reg filtered_sig;
//always @(inner_clk) begin
//    if (prev_signal != clk_button_in) begin
//        counter <= 0;
//    end
//    else begin
//        if (counter >= 8'h0F) begin
//            filtered_sig <= clk_button_in;
//        end
//    end
//    if (counter < 8'h0F) begin
//        counter <= next_counter;
//    end
//    prev_signal <= clk_button_in;
//end
//assign filtered_clk = filtered_sig;

// Main switch logic, trigger on manual clk
always @(posedge filtered_clk)
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

// Output logic, combinational
assign busy_o = port_0_out | port_1_out | port_2_out | port_3_out;

// Assigning wires for leds
assign port_0_succ = port_0_out;
assign port_1_succ = port_1_out;
assign port_2_succ = port_2_out;
assign port_3_succ = port_3_out;



segments segments_inst(
    .clk(inner_clk),
    .rst(reset),
    .size(curr_in_port),
    .data_in(arbit_state),
    .CAT(number_switch),
    .AN(segment_switch)
);

//// Assigning segments
//assign segment_switch = current_segment;
//assign number_switch = current_number;

//// When the output changes, bcd also change
//wire [7:0] out_number_bcd;
//wire [7:0] out_port_bcd;
//assign out_number_bcd = bcd(arbit_state);
//assign out_port_bcd = bcd(curr_in_port);

//// Create a static function to port out number to bcd
//function [7:0] bcd(input [2:0] number);
//    case (number)
//        0 : bcd = 7'b0000001;
//        1 : bcd = 7'b1001111;
//        2 : bcd = 7'b0010010;
//        3 : bcd = 7'b0000110;
//        4 : bcd = 7'b1001100;
//        5 : bcd = 7'b0100100;
//        6 : bcd = 7'b0100000;
//        7 : bcd = 7'b0001111;
//        default : bcd = 7'b1111111; 
//    endcase
//endfunction
    
//// Circle through segments
//wire [7:0] next_segment;
//reg [7:0] counter;
//wire [7:0] next_counter;
//assign next_segment = {current_segment[6:0], current_segment[7]};
//assign next_counter = counter + 1;
//always @(posedge inner_clk)
//begin
//    if (reset) begin
//        current_segment <= 8'b11111110;
//        current_number <= 7'b0000001;
//        counter <= 0;
//    end
//    // Print nothing if not desired number
//    else begin
//        if (counter != 0) begin
//            counter <= next_counter;
//        end
//        else begin
//            current_segment <= next_segment;
//            if (current_segment == 8'b11111110) begin
//                current_number <= out_number_bcd;
//            end
//            else if (current_segment == 8'b11101111) begin
//                current_number <= out_port_bcd;
//            end
//            else begin
//                current_number <= 7'b0000001;
//            end
//        end
//    end
//end

endmodule
