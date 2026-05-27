`timescale 1ns / 1ps
module vector_npu_top (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [31:0] data_in,   
    input wire [31:0] weight_in,
    output reg busy,
    output reg done,
    output wire [63:0] vector_out 
);
    localparam IDLE=2'b00, PHASE1_VEC=2'b01, PHASE2_SWP=2'b10, FINISH=2'b11;
    reg [1:0] state;
    reg [7:0] counter;
    reg swp_mode;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : PE_ARRAY
            processing_element pe_inst (
                .clk(clk), .rst_n(rst_n), .swp_en(swp_mode),
                .a(data_in[(i*8)+7 : i*8]), .b(weight_in[(i*8)+7 : i*8]),
                .acc_out(vector_out[(i*16)+15 : i*16])
            );
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; counter <= 0; swp_mode <= 0; busy <= 0; done <= 0;
        end else begin
            case (state)
                IDLE: if (start) begin state <= PHASE1_VEC; busy <= 1; counter <= 0; swp_mode <= 0; end
                PHASE1_VEC: if (counter == 63) begin state <= PHASE2_SWP; counter <= 0; swp_mode <= 1; end 
                            else counter <= counter + 1;
                PHASE2_SWP: if (counter == 1) state <= FINISH; 
                            else counter <= counter + 1;
                FINISH: begin busy <= 0; done <= 1; state <= IDLE; end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

