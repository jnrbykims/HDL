# Smart School-Zone Traffic Controller Report

## Design Summary

The smart school-zone traffic controller is a Verilog FSM that controls the main-road light, side-road light, pedestrian walk light, and pedestrian request behavior. Reset returns the controller to a safe starting state with the main road green and the side road red.

## State Table

| State | Main Light | Side Light | Walk Light | Next State |
| --- | --- | --- | --- | --- |
| MAIN_GREEN | GREEN | RED | 0 | MAIN_YELLOW |
| MAIN_YELLOW | YELLOW | RED | 0 | SIDE_GREEN |
| SIDE_GREEN | RED | GREEN | 1 | SIDE_YELLOW |
| SIDE_YELLOW | RED | YELLOW | 0 | MAIN_GREEN |

## Timing Explanation

During normal operation, `MAIN_GREEN` lasts 6 clock ticks, `MAIN_YELLOW` lasts 2 clock ticks, `SIDE_GREEN` lasts 4 clock ticks, and `SIDE_YELLOW` lasts 2 clock ticks. When `ped_request` is active, the request is stored in `ped_pending`. This shortens `MAIN_GREEN` to 3 clock ticks and extends `SIDE_GREEN` to 6 clock ticks so pedestrians get a longer crossing interval.

## Safety Behavior

The controller never allows the main road and side road to be green at the same time. Yellow states are always used before switching right-of-way: `MAIN_YELLOW` appears before `SIDE_GREEN`, and `SIDE_YELLOW` appears before returning to `MAIN_GREEN`.

## Guide Questions

1. Reset returns the controller to `MAIN_GREEN`, with main green, side red, walk light off, timer cleared, and no pending pedestrian request.
2. The required state order is `MAIN_GREEN -> MAIN_YELLOW -> SIDE_GREEN -> SIDE_YELLOW -> MAIN_GREEN`.
3. `ped_request` makes the behavior visibly change by shortening the main-green interval and extending the side-green/walk interval.

## Waveform Observations

In the waveform, `state` follows the required FSM order and `timer` resets to 0 at each transition. When `ped_request` becomes active, `ped_pending` turns on, `MAIN_GREEN` ends sooner, and `walk_light` turns on only during `SIDE_GREEN`. The testbench prints simulation evidence and stops with an error if both roads are green at the same time or if `walk_light` turns on outside side green.
