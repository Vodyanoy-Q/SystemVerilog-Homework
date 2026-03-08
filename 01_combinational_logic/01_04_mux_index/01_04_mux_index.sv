//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// write code for 4:1 mux using array index

module mux_4_1
(
    input  [3:0] d0, d1, d2, d3,
    input  [1:0] sel,
    output [3:0] y
    );
    wire [3:0] d [3:0];

    assign d[0] = d0;
    assign d[1] = d1;
    assign d[2] = d2;
    assign d[3] = d3;

    assign y = d[sel];
    
endmodule
