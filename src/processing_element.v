`timescale 1ns / 1ps
(* use_dsp = "no" *)
module processing_element (
    input wire clk,
    input wire rst_n,
    input wire swp_en,      
    input wire [7:0] a,     
    input wire [7:0] b,     
    output reg [15:0] acc_out
);
    // Force Signed Multipliers to match GitHub Math
    wire signed [15:0] prod_int8 = $signed(a) * $signed(b);
    wire signed [7:0]  prod_int4_hi = $signed(a[7:4]) * $signed(b[7:4]);
    wire signed [7:0]  prod_int4_lo = $signed(a[3:0]) * $signed(b[3:0]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) acc_out <= 16'h0;
        else if (swp_en) begin
            acc_out[15:8] <= prod_int4_hi; // Direct output to match sync design
            acc_out[7:0]  <= prod_int4_lo;
        end else begin
            acc_out <= prod_int8;
        end
    end
endmodule

