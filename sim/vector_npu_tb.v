`timescale 1ns / 1ps
module vector_npu_tb();
    reg clk; reg rst_n; reg start;
    reg [31:0] data_in; reg [31:0] weight_in;
    wire busy; wire done; wire [63:0] vector_out;
    reg [31:0] data_mem [0:65];
    reg [31:0] weight_mem [0:65];
    
    integer i;
    real start_time, end_time, latency_cycles;

    vector_npu_top uut (.clk(clk), .rst_n(rst_n), .start(start), 
                        .data_in(data_in), .weight_in(weight_in), 
                        .busy(busy), .done(done), .vector_out(vector_out));

    always #5 clk = ~clk;

    initial begin
        $readmemh("stimulus_data.mem", data_mem);
        $readmemh("stimulus_weights.mem", weight_mem);
        clk = 0; rst_n = 0; start = 0; data_in = 0; weight_in = 0; i = 0;

        #100 rst_n = 1; #100;
        @(posedge clk); start = 1; 
        start_time = $time;
        @(posedge clk); start = 0;

        wait(busy == 1);
        for (i = 0; i < 66; i = i + 1) begin
            data_in = data_mem[i];
            weight_in = weight_mem[i];
            @(posedge clk);
        end

        wait(done == 1);
        end_time = $time;
        latency_cycles = (end_time - start_time) / 10;

        $display("\n-----------------------------------------------------");
        $display("PERFORMANCE COMPARISON REPORT");
        $display("-----------------------------------------------------");
        $display("GitHub Design Latency: 263 Cycles");
        $display("Your Vector NPU Latency: %0f Cycles", latency_cycles);
        $display("Speedup Achieved:      %0.2f x", 263.0 / latency_cycles);
        $display("-----------------------------------------------------");
        #100 $finish;
    end
endmodule

