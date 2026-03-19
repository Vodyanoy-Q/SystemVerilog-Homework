//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that converts 'first' input status signal
// to the 'last' output status signal.

// See README for full description of the task with timing diagram.

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);
    logic               cnt;
    logic [width - 1:0] ddata_ff;           
    
    always_ff @(posedge clock or posedge reset)
        if ( reset ) begin
            cnt <= '0;
        end
        else if ( up_valid ) begin
            if ( ~ cnt ) cnt <= '1;
            ddata_ff  <= up_data;
        end

    assign down_data  = ddata_ff;
    assign down_valid = up_valid & cnt;
    assign down_last = up_first;

endmodule
