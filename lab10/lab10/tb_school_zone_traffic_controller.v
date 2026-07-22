`timescale 1ns / 1ps

module tb_school_zone_traffic_controller;
    reg clk;
    reg reset;
    reg ped_request;
    wire [2:0] main_light;
    wire [2:0] side_light;
    wire walk_light;
    wire ped_pending;

    localparam RED = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN = 3'b001;

    school_zone_traffic_controller uut (
        .clk(clk),
        .reset(reset),
        .ped_request(ped_request),
        .main_light(main_light),
        .side_light(side_light),
        .walk_light(walk_light),
        .ped_pending(ped_pending)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if ((main_light == GREEN) && (side_light == GREEN)) begin
            $display("ERROR: both roads are green at time %0t", $time);
            $finish;
        end

        if (walk_light && (side_light != GREEN)) begin
            $display("ERROR: walk_light is on outside side green at time %0t", $time);
            $finish;
        end

        $display("%0t reset=%b ped=%b pending=%b state=%0d timer=%0d main=%b side=%b walk=%b",
            $time, reset, ped_request, ped_pending, uut.state, uut.timer,
            main_light, side_light, walk_light);
    end

    initial begin
        $dumpfile("school_zone_traffic.vcd");
        $dumpvars(0, tb_school_zone_traffic_controller);

        $display("Smart school-zone traffic controller simulation");
        $display("main/side light encoding: RED=100 YELLOW=010 GREEN=001");

        reset = 1'b1;
        ped_request = 1'b0;
        #12;

        reset = 1'b0;
        #130;

        ped_request = 1'b1;
        #20;
        ped_request = 1'b0;
        #120;

        ped_request = 1'b1;
        #10;
        ped_request = 1'b0;
        #80;

        reset = 1'b1;
        #10;
        reset = 1'b0;
        #60;

        $display("Simulation completed without safety errors.");
        $finish;
    end
endmodule
