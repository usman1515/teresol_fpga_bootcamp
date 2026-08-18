`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TeReSol Pvt. Ltd
// Engineer: Usman Siddique
//
// Design Name:
// Module Name: carry_lookahead_adder
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



module carry_lookahead_adder #(parameter int DATA_WIDTH = 2) (
    input  logic [DATA_WIDTH-1:0] i_a,
    input  logic [DATA_WIDTH-1:0] i_b,
    output logic [DATA_WIDTH-1:0] o_sum,
    output logic                  o_cout
);

    logic [DATA_WIDTH-1:0] w_generate;
    logic [DATA_WIDTH-1:0] w_propagate;
    logic [DATA_WIDTH:0]   w_carry;
    assign w_carry[0] = 1'b0;

    // half adders
    genvar i;

    generate
        for (i=0; i<DATA_WIDTH; i++) begin : gen_loop_ha
            half_adder INST_HA (
                .i_a     (i_a[i]),
                .i_b     (i_b[i]),
                .o_sum   (w_propagate[i]),
                .o_cout  (w_generate[i])
            );
        end
    endgenerate

    // Carry Lookahead
    integer n;
    integer k;

    always_comb begin
        // Default value
        w_carry[DATA_WIDTH:1] = '0;

        for (n=0; n<DATA_WIDTH; n=n+1) begin : gen_prop
            // G[n]
            w_carry[n+1] = w_generate[n];

            // P[n] G[n-1]
            // P[n] P[n-1] G[n-2]
            // ...
            // P[n] ... P[k+1] G[k]
            for (k=n-1; k>=0; k=k-1) begin
                w_carry[n+1] = w_carry[n+1] | ( w_generate[k] & (&w_propagate[n:k+1]) );
            end

            // P[n] P[n-1] ... P[0] C0
            w_carry[n+1] = w_carry[n+1] | ( &w_propagate[n:0] & w_carry[0] );
        end
    end

    // Sum
    generate
        for (i=0; i<DATA_WIDTH; i++) begin : gen_sum
            assign o_sum[i] = w_propagate[i] ^ w_carry[i];
        end
    endgenerate

    // Carry Out
    assign o_cout = w_carry[DATA_WIDTH];

endmodule

