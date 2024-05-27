/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

`include "sr_cpu.vh"

module sr_cpu
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output  [31:0]  regData,    // debug access reg data
    output  [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData,      // instruction memory data
    output  [1:0]   debug_execute_state
);
    //control wires
    wire        aluZero;
    wire        pcSrc;
    wire        regWrite;
    wire        aluSrc;
    wire        wdSrc;
    wire  [2:0] aluControl;

    wire        pcSrc_right;
    wire        regWrite_right;
    wire        aluSrc_right;
    wire        wdSrc_right;
    wire  [2:0] aluControl_right;

    //instruction decode wires
    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;
    
    wire [ 6:0] cmdOp_right;
    wire [ 4:0] rd_right;
    wire [ 2:0] cmdF3_right;
    wire [ 4:0] rs1_right;
    wire [ 4:0] rs2_right;
    wire [ 6:0] cmdF7_right;
    wire [31:0] immI_right;
    wire [31:0] immB_right;
    wire [31:0] immU_right;
    
    // activate certain datapath
    reg [1:0] exec_state;
    assign debug_execute_state = exec_state;
    wire active_left;
    wire active_right;
    assign active_left = exec_state[1];
    assign active_right = exec_state[0];
//    assign active_left = 1'b1;
//    assign active_right = 1'b0;

    //program counter
    wire [31:0] pc;
    // Pc branch can be used just by one alu, so it can be multiplexed
    wire [31:0] pcBranch = active_left ?
                    pc + immB       :
                    pc + immB_right ;
    wire [31:0] pcPlus4  = pc + 4;
    wire [31:0] pcNext = active_left ?
                    pcSrc ? pcBranch : pcPlus4          :
                    pcSrc_right ? pcBranch : pcPlus4    ;
    sm_register r_pc(clk ,rst_n, pcNext, pc);

    //program memory access
    assign imAddr = pc >> 2;

    // Here instructions to be placed in datapaths
    wire [31:0] instr_left = active_left ? imData : 32'h00000000;
    wire [31:0] instr_right = active_right ? imData : 32'h00000000;
   
    
    always @(negedge clk or negedge rst_n) begin
        if (~rst_n) exec_state = 2'b10;
        else if (exec_state == 2'b00 || exec_state == 2'b11 || exec_state == 2'b01) begin
            // here parse the collision logic!
            exec_state = 2'b10;
        end else if (exec_state == 2'b10) begin
            exec_state = 2'b01;
        end
    end

    //instruction decode
    sr_decode id (
        .instr      ( instr_left   ),
        .cmdOp      ( cmdOp        ),
        .rd         ( rd           ),
        .cmdF3      ( cmdF3        ),
        .rs1        ( rs1          ),
        .rs2        ( rs2          ),
        .cmdF7      ( cmdF7        ),
        .immI       ( immI         ),
        .immB       ( immB         ),
        .immU       ( immU         ) 
    );
    
    sr_decode id_right (
        .instr      ( instr_right  ),
        .cmdOp      ( cmdOp_right  ),
        .rd         ( rd_right     ),
        .cmdF3      ( cmdF3_right  ),
        .rs1        ( rs1_right    ),
        .rs2        ( rs2_right    ),
        .cmdF7      ( cmdF7_right  ),
        .immI       ( immI_right   ),
        .immB       ( immB_right   ),
        .immU       ( immU_right   )
    );

    // Прочитанные по адресам значения регистров
    // Появляются за один такт
    // Register file
    wire [31:0] rd0_left;
    wire [31:0] rd1_left;
    wire [31:0] rd2_left;
    wire [31:0] wd3_left;
    // Additional ports
    wire [31:0] rd0_right;
    wire [31:0] rd1_right;
    wire [31:0] rd2_right;
    wire [31:0] wd3_right;

    sm_register_file rf (
        .clk             ( clk          ),
        .a0_left         ( regAddr      ),
        .a1_left         ( rs1          ),
        .a2_left         ( rs2          ),
        .a3_left         ( rd           ),
        .rd0_left        ( rd0_left     ),
        .rd1_left        ( rd1_left     ),
        .rd2_left        ( rd2_left     ),
        .wd3_left        ( wd3_left     ),
        .we3_left        ( regWrite     ),
        
        .a1_right        ( rs1_right    ),
        .a2_right        ( rs2_right    ),
        .a3_right        ( rd_right     ),
        .rd1_right       ( rd1_right    ),
        .rd2_right       ( rd2_right    ),
        .wd3_right       ( wd3_right    ),
        .we3_right       ( regWrite_right)
    );

    // Debug register address
    // Here just reassign for one active alu
    assign regData = active_left ?
                        (regAddr != 0) ? rd0_left : pc   :
                        (regAddr != 0) ? rd0_right : pc  ;

    // Alu
    // modified rd left
    wire [31:0] srcB = aluSrc ? immI : rd2_left;
    wire [31:0] srcB_right = aluSrc_right ? immI_right : rd2_right;
    wire [31:0] aluResult;
    wire [31:0] aluResult_right;

    // To modify here and split datapaths for 
    // srcb
    // alucontrol
    // aluresult ()
    sr_alu alu_left (
        // modified rd left
        .srcA       ( rd1_left          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .zero       ( aluZero      ),
        .result     ( aluResult    ) 
    );
    
    sr_alu alu_right (
        // modified rd left
        .srcA       ( rd1_right          ),
        .srcB       ( srcB_right         ),
        .oper       ( aluControl_right   ),
        .zero       ( aluZero            ),
        .result     ( aluResult_right    ) 
    ); 

    // modified rd left
    assign wd3_left = wdSrc ? immU : aluResult;
    assign wd3_right = wdSrc_right ? immU_right : aluResult_right;

    // Control
    sr_control sm_control (
        .cmdOp      ( cmdOp        ),
        .cmdF3      ( cmdF3        ),
        .cmdF7      ( cmdF7        ),
        .aluZero    ( aluZero      ),
        .pcSrc      ( pcSrc        ),
        .regWrite   ( regWrite     ),
        .aluSrc     ( aluSrc       ),
        .wdSrc      ( wdSrc        ),
        .aluControl ( aluControl   ) 
    );
    
    sr_control sm_control_right (
        .cmdOp      ( cmdOp_right        ),
        .cmdF3      ( cmdF3_right        ),
        .cmdF7      ( cmdF7_right        ),
        // Aluzero is a constant
        .aluZero    ( aluZero            ),
        .pcSrc      ( pcSrc_right        ),
        .regWrite   ( regWrite_right     ),
        .aluSrc     ( aluSrc_right       ),
        .wdSrc      ( wdSrc_right        ),
        .aluControl ( aluControl_right   ) 
    );

endmodule

module sr_decode
(
    input      [31:0] instr,
    output     [ 6:0] cmdOp,
    output     [ 4:0] rd,
    output     [ 2:0] cmdF3,
    output     [ 4:0] rs1,
    output     [ 4:0] rs2,
    output     [ 6:0] cmdF7,
    output reg [31:0] immI,
    output reg [31:0] immB,
    output reg [31:0] immU 
);
    assign cmdOp = instr[ 6: 0];
    assign rd    = instr[11: 7];
    assign cmdF3 = instr[14:12];
    assign rs1   = instr[19:15];
    assign rs2   = instr[24:20];
    assign cmdF7 = instr[31:25];

    // I-immediate
    always @ (*) begin
        immI[10: 0] = instr[30:20];
        immI[31:11] = { 21 {instr[31]} };
    end

    // B-immediate
    always @ (*) begin
        immB[    0] = 1'b0;
        immB[ 4: 1] = instr[11:8];
        immB[10: 5] = instr[30:25];
        immB[   11] = instr[7];
        immB[31:12] = { 20 {instr[31]} };
    end

    // U-immediate
    always @ (*) begin
        immU[11: 0] = 12'b0;
        immU[31:12] = instr[31:12];
    end

endmodule

module sr_control
(
    input     [ 6:0] cmdOp,
    input     [ 2:0] cmdF3,
    input     [ 6:0] cmdF7,
    input            aluZero,
    output           pcSrc, 
    output reg       regWrite, 
    output reg       aluSrc,
    output reg       wdSrc,
    output reg [2:0] aluControl
);
    reg          branch;
    reg          condZero;
    assign pcSrc = branch & (aluZero == condZero);

    always @ (*) begin
        branch      = 1'b0;
        condZero    = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        wdSrc       = 1'b0;
        aluControl  = `ALU_ADD;

        casez( {cmdF7, cmdF3, cmdOp} )
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  end

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc  = 1'b1; end

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB; end
        endcase
    end
endmodule

module sr_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [ 2:0] oper,
    output        zero,
    output reg [31:0] result
);
    always @ (*) begin
        case (oper)
            default   : result = srcA + srcB;
            `ALU_ADD  : result = srcA + srcB;
            `ALU_OR   : result = srcA | srcB;
            `ALU_SRL  : result = srcA >> srcB [4:0];
            `ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            `ALU_SUB : result = srcA - srcB;
        endcase
    end

    assign zero   = (result == 0);
endmodule

module sm_register_file
(
    input         clk,
    input  [ 4:0] a0_left,
    input  [ 4:0] a1_left,
    input  [ 4:0] a2_left,
    input  [ 4:0] a3_left,
    output [31:0] rd0_left,
    output [31:0] rd1_left,
    output [31:0] rd2_left,
    input  [31:0] wd3_left,
    input         we3_left,
    input  [ 4:0] a1_right,
    input  [ 4:0] a2_right,
    input  [ 4:0] a3_right,
    output [31:0] rd1_right,
    output [31:0] rd2_right,
    input  [31:0] wd3_right,
    input         we3_right
);
    reg [31:0] rf [31:0];

    assign rd0_left = (a0_left != 0) ? rf [a0_left] : 32'b0;
    assign rd1_left = (a1_left != 0) ? rf [a1_left] : 32'b0;
    assign rd2_left = (a2_left != 0) ? rf [a2_left] : 32'b0;
    assign rd1_right = (a1_right != 0) ? rf [a1_right] : 32'b0;
    assign rd2_right = (a2_right != 0) ? rf [a2_right] : 32'b0;


    always @ (posedge clk) begin
        if (we3_left) rf [a3_left] <= wd3_left;
        if (we3_right) rf [a3_right] <= wd3_right;
    end
endmodule