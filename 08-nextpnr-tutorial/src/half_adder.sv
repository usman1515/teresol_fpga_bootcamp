`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TeReSol Pvt. Ltd
// Engineer: Usman Siddique
//
// Design Name:
// Module Name: half_adder
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



module half_adder (
    input  logic i_a,
    input  logic i_b,
    output logic o_sum,
    output logic o_cout
);

    assign o_sum  = i_a ^ i_b;
    assign o_cout = i_a & i_b;

endmodule

