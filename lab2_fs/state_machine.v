`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Filberol Inc.
// Engineer: filberol
// 
// Create Date: 03/15/2024 12:10:39 AM
// Design Name: State machine realizing function ((A + B)*4 + B)/2 + (B/2 + A*4)
// Module Name: state_machine
//////////////////////////////////////////////////////////////////////////////////


module state_machine(
    input wire clk,
    input wire rst,
    input wire [15:0] A,
    input wire [15:0] B,
    output reg [31:0] out
);

// State tracking
reg [2:0] state;
reg [2:0] next_state;

// Signals and allows for siganl passing
reg allow_count_add_1;
reg allow_count_add_2;
reg allow_count_div;
reg allow_count_mul;

// Inverse clock signal
wire inv_clk;
assign inv_clk = !clk;
// Use inverse clock to invoke calculation in between the states
// On posedge in this module, count signals are off, then on, if allow is one

// First counter init
wire count_add1_sig;
assign count_add1_sig = inv_clk & allow_count_add_1;
reg [15:0] add1_l;
reg [15:0] add1_r;
wire [31:0] add1_res;
adder_16to32 adder_inst_1(
    .A(add1_l),
    .B(add1_r),
    .sum(add1_res),
    .count(count_add1_sig)
);

// Second counter init
wire count_add2_sig;
assign count_add2_sig = inv_clk & allow_count_add_2;
reg [15:0] add2_l;
reg [15:0] add2_r;
wire [31:0] add2_res;
adder_16to32 adder_inst_2(
    .A(add2_l),
    .B(add2_r),
    .sum(add2_res),
    .count(count_add1_sig)
);

// Third multiplier init
wire count_mul_sig;
assign count_mul_sig = inv_clk & allow_count_mul;
reg [15:0] mul_in;
wire [31:0] mul_res;
mul4_16to32 mul_inst(
    .in(mul_in),
    .count(count_mul_sig),
    .out(mul_res)
);

// Fourth divider init
wire count_div_sig;
assign count_div_sig = inv_clk & allow_count_div;
reg [15:0] div_in;
wire [31:0] div_res;
div2_16to32 div_inst(
    .in(div_in),
    .count(count_div_sig),
    .out(div_res)
);

// Ready signal
reg ready;

// States enumeration
parameter S_IDLE = 4'b0000;
parameter S_ADD_A_B_DIV_MUL = 4'b0001;
parameter S_ADD_DIV_MUL = 4'b0010;
parameter S_ADD_B = 4'b0011;
parameter S_DIV = 4'b0100;
parameter S_ADD_RESULT = 4'b0101;
parameter S_FINISH = 4'b1001;

// DO IN 5 STATES
// State should trigger not process logic, but control signal
always @(posedge clk) begin
    if (rst) begin
        // Clear state
        ready <= 0;
        state <= 0;
        // Clear allows and signals
        allow_count_add_1 <= 0;
        allow_count_add_2 <= 0;
        allow_count_div <= 0;
        allow_count_mul <= 0;
        // Clear inputs
        add1_l <= 0;
        add1_r <= 0;
        add2_l <= 0;
        add2_r <= 0;
        mul_in <= 0;
        div_in <= 0;
    end else case(state)
        S_IDLE: begin
            ready <= 0;
        end
        S_ADD_A_B_DIV_MUL: begin
            // Perform A + B
            add1_l <= A;
            add1_r <= B;
            allow_count_add_1 <= 1;
            // Perform B/2
            div_in <= B;
            allow_count_div <= 1;
            // Perform A*4
            mul_in <= A;
            allow_count_mul <= 1;
        end
        S_ADD_DIV_MUL: begin
            // Reset allows to stop counting
            allow_count_add_1 <= 0;
            allow_count_div <= 0;
            // Perform (B/2 + A*4)
            // Result isn this counter will be saved throughout
            add2_l <= div_res;
            add2_r <= mul_res;
            allow_count_add_2 <= 1;
            // Perform (A + B)*4
            mul_in <= add1_res;
            // allow_count_mul <= 1; Remains from state
        end
        S_ADD_B: begin
            // Reset allows
            allow_count_add_2 <= 0;
            allow_count_mul <= 0;
            // Perform (A + B)*4 + B
            add1_l <= mul_res;
            add1_r <= B;
            allow_count_add_1 <= 1;
        end
        S_DIV: begin
            // Reset allows
            allow_count_add_1 <= 0;
            // Perform ((A + B)*4 + B)/2
            div_in <= add1_res;
            allow_count_div <= 1;
        end
        S_ADD_RESULT: begin
            // Reset allows
            allow_count_div <= 0;
            // Perform ((A + B)*4 + B)/2 + (B/2 + A*4)
            add1_l <= add1_res;
            add1_r <= div_res;
            allow_count_add_1 <= 1;
        end
        S_FINISH: begin
            // Finish calculations
            allow_count_add_1 <= 0;
            out <= add1_res;
            ready <= 1;
        end
    endcase
end

always @(state)
    case (state)
        S_IDLE: next_state <= S_ADD_A_B_DIV_MUL;
        S_ADD_A_B_DIV_MUL: next_state <= S_ADD_DIV_MUL;
        S_ADD_DIV_MUL: next_state <= S_ADD_B;
        S_ADD_B: next_state <= S_DIV;
        S_DIV: next_state <= 
        default: next_state <= S_IDLE;
endcase

endmodule
