//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a serial module that reduces amount of incoming '1' tokens by half.
//
// Note:
// Check the waveform diagram in the README for better understanding.
//
// Example:
// a -> 110_011_101_000_1111
// b -> 010_001_001_000_0101

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);

    logic write;

    always_ff @(posedge clk or posedge rst)
        if (rst)
            write <= '1;
        else if (a)
            if (write)
                write <= '0;
            else
                write <= '1;

    assign b = ( write & a ) ? a : '0;

endmodule
