`timescale 1ns / 1ps

module school_zone_traffic_controller(
    input clk,
    input reset,
    input ped_request,
    output reg [2:0] main_light,
    output reg [2:0] side_light,
    output reg walk_light,
    output reg ped_pending
);
    localparam RED = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN = 3'b001;

    localparam MAIN_GREEN = 2'd0;
    localparam MAIN_YELLOW = 2'd1;
    localparam SIDE_GREEN = 2'd2;
    localparam SIDE_YELLOW = 2'd3;

    localparam MAIN_GREEN_NORMAL_TICKS = 4'd6;
    localparam MAIN_GREEN_PED_TICKS = 4'd3;
    localparam YELLOW_TICKS = 4'd2;
    localparam SIDE_GREEN_NORMAL_TICKS = 4'd4;
    localparam SIDE_GREEN_PED_TICKS = 4'd6;

    reg [1:0] state;
    reg [3:0] timer;
    reg [3:0] limit;

    always @(*) begin
        case (state)
            MAIN_GREEN: begin
                main_light = GREEN;
                side_light = RED;
                walk_light = 1'b0;
                limit = (ped_pending || ped_request) ? MAIN_GREEN_PED_TICKS : MAIN_GREEN_NORMAL_TICKS;
            end
            MAIN_YELLOW: begin
                main_light = YELLOW;
                side_light = RED;
                walk_light = 1'b0;
                limit = YELLOW_TICKS;
            end
            SIDE_GREEN: begin
                main_light = RED;
                side_light = GREEN;
                walk_light = 1'b1;
                limit = ped_pending ? SIDE_GREEN_PED_TICKS : SIDE_GREEN_NORMAL_TICKS;
            end
            SIDE_YELLOW: begin
                main_light = RED;
                side_light = YELLOW;
                walk_light = 1'b0;
                limit = YELLOW_TICKS;
            end
            default: begin
                main_light = GREEN;
                side_light = RED;
                walk_light = 1'b0;
                limit = MAIN_GREEN_NORMAL_TICKS;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= MAIN_GREEN;
            timer <= 4'd0;
            ped_pending <= 1'b0;
        end else begin
            if (ped_request) begin
                ped_pending <= 1'b1;
            end

            if (timer >= limit - 4'd1) begin
                timer <= 4'd0;
                case (state)
                    MAIN_GREEN: state <= MAIN_YELLOW;
                    MAIN_YELLOW: state <= SIDE_GREEN;
                    SIDE_GREEN: begin
                        state <= SIDE_YELLOW;
                        ped_pending <= 1'b0;
                    end
                    SIDE_YELLOW: state <= MAIN_GREEN;
                    default: state <= MAIN_GREEN;
                endcase
            end else begin
                timer <= timer + 4'd1;
            end
        end
    end
endmodule
