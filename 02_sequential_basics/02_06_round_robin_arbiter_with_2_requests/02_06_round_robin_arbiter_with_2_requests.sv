//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a "arbiter" module that accepts up to two requests
// and grants one of them to operate in a round-robin manner.
//
// The module should maintain an internal register
// to keep track of which requester is next in line for a grant.
//
// Note:
// Check the waveform diagram in the README for better understanding.
//
// Example:
// requests -> 01 00 10 11 11 00 11 00 11 11
// grants   -> 01 00 10 01 10 00 01 00 10 01

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    logic [1:0] prev_roots;
    logic [1:0] roots;

    always_ff @(posedge clk or posedge rst) 
        if (rst)
            prev_roots <= '0;
        else if (requests != '0)
            prev_roots <= roots;

    always_comb begin
        case (requests)
        2'b00: roots = 2'b00;
        2'b01: roots = requests;
        2'b10: roots = requests;
        2'b11: roots = {prev_roots[0], prev_roots[1]};
        endcase
    end

    assign grants = roots;
    
endmodule
