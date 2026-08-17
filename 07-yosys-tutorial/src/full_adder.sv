`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TeReSol Pvt. Ltd
// Engineer: Usman Siddique
//
// Design Name:
// Module Name: full_adder
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



module full_adder (
    input  logic i_a,
    input  logic i_b,
    input  logic i_cin,
    output logic o_sum,
    output logic o_cout
);

    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_a & i_cin) | (i_b & i_cin);

endmodule

