    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: filber Inc.
    // Engineer: filberol
    // 
    // Create Date: 02/18/2024 01:50:16 PM
    // Design Name: Simple nor gate 1 to 4 demultiplexor
    // Module Name: nor_demultiplexor
    //////////////////////////////////////////////////////////////////////////////////
    
    module nor_demultiplexor(
            input   y,  // allow signal
            input   s0, // a
            input   s1, // b
            output  z0,
            output  z1,
            output  z2,
            output  z3
        );
        
        wire not_y;     // allow signal with nor
        wire r0, r1, r2, r3;    // results
        wire not_r0, not_r1, not_r2, not_r3;    // inverted results for nor gate pass
    
        wire not_s1_r1;     // inversions for demultiplexing itself
        wire not_s0_r2;
        wire not_s0_r3, not_s1_r3;
        
        nor(not_y, y, y);
        
        nor(not_s1_r1, s1, s1);     // first inversions
        nor(not_s0_r2, s0, s0);
        nor(not_s0_r3, s0, s0);
        nor(not_s1_r3, s1, s1);
        
        nor(r0, s0, s1);            // logic
        nor(r1, s0, not_s1_r1);
        nor(r2, not_s0_r2, s1);
        nor(r3, not_s0_r3, not_s1_r3);
        
        nor(not_r0, r0, r0);    // inversions for gate
        nor(not_r1, r1, r1);
        nor(not_r2, r2, r2);
        nor(not_r3, r3, r3);
        
        nor(z0, not_r0, not_y);     // results after gate
        nor(z1, not_r1, not_y);
        nor(z2, not_r2, not_y);
        nor(z3, not_r3, not_y);
        
    endmodule
