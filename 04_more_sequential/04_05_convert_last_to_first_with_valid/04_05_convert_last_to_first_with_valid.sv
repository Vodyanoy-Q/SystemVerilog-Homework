//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that converts 'last' input status signal
// to the 'first' output status signal.
//
// See README for full description of the task with timing diagram.

module conv_last_to_first
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_last,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_first,
    output [width - 1:0] down_data
);
    logic dlast_ff;

    always_ff @(posedge clock or posedge reset)
        if (reset)
            dlast_ff <= '1;
        else if (up_valid)
            dlast_ff <= up_last;
 
    assign down_first = up_valid ? dlast_ff : '0;
        
    assign down_valid = up_valid;
    assign down_data  = up_data;

endmodule
