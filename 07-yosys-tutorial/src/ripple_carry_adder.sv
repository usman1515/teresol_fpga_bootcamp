`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TeReSol Pvt. Ltd
// Engineer: Usman Siddique
//
// Design Name:
// Module Name: ripple_carry_adder
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////



module ripple_carry_adder #(parameter int DATA_WIDTH=8) (
    input logic [DATA_WIDTH-1:0] i_a,
    input logic [DATA_WIDTH-1:0] i_b,
    input logic i_cin,
    output logic [DATA_WIDTH-1:0] o_sum,
    output logic o_cout
);

    logic [DATA_WIDTH:0] carry;
    assign carry[0] = i_cin;
    assign o_cout = carry[DATA_WIDTH];

    genvar i;

    generate
        for(i=0; i<DATA_WIDTH; i++) begin : gen_loop_fa
            full_adder INST_FA (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (carry[i+1])
            );
        end
    endgenerate

endmodule

