`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: filber Inc.
// Engineer: filberol
// 
// Create Date: 02/18/2024 01:55:48 PM
// Design Name: Simple nor gate 1 to 4 demultiplexor test suite
// Module Name: nor_demultiplexor_tb
//////////////////////////////////////////////////////////////////////////////////

module nor_demultiplexor_tb;

    reg s0_in, s1_in;
    reg y_in;
    wire z0_out, z1_out, z2_out, z3_out;
    
    nor_demultiplexor demul_1(
        .y(y_in),
        .s0(s0_in),
        .s1(s1_in),
        .z0(z0_out),
        .z1(z1_out),
        .z2(z2_out),
        .z3(z3_out)
    );
    
    integer allow;
    integer i;
    
    reg [1:0] test_val;
    reg [3:0] expected_reg;
    
    reg [3:0] real_reg;
    
    initial begin
    
        for(allow = 0; allow < 2; allow = allow+1) begin
            y_in = allow;
            for(i = 0; i < 4; i = i+1) begin
                if(allow == 0) begin
                    expected_reg = 0;
                end else begin
                    expected_reg = 2 ** i;
                end
            
                test_val = i;
                s0_in = test_val[0];
                s1_in = test_val[1];
                
                #50     // allow everything to pass
                
                real_reg[0] = z0_out;
                real_reg[1] = z1_out;
                real_reg[2] = z2_out;
                real_reg[3] = z3_out;
                
                
                if(real_reg == expected_reg) begin
                    $display("The demultiplexor output is correct. real_reg=%b, expected_reg", real_reg, expected_reg);
                end else begin
                    $display("The demultiplexor output is incorrect. real_reg=%b, expected_reg", real_reg, expected_reg);
                end
            end    
        end
        
        #10
        
        $stop;
    end
    
endmodule
