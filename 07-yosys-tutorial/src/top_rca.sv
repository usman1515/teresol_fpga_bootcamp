`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TeReSol Pvt. Ltd
// Engineer: Usman Siddique
//
// Design Name:
// Module Name: top_rca
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



module top_rca #(parameter int DATA_WIDTH=4) (
    input logic [DATA_WIDTH-1:0] i_a,
    input logic [DATA_WIDTH-1:0] i_b,
    input logic i_cin,
    output logic [DATA_WIDTH-1:0] o_sum,
    output logic o_cout
);

    ripple_carry_adder #(
        .DATA_WIDTH(DATA_WIDTH)
    ) INST_RCA (
        .i_a    (i_a),
        .i_b    (i_b),
        .i_cin  (carry),
        .o_sum  (o_sum),
        .o_cout (carry)
    );

endmodule

