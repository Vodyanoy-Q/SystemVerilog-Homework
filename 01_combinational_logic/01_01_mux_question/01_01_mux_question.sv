//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// write code for 4:1 mux using "?:" operator

module mux_4_1 
(
    input        [3:0] d3, d2, d1, d0,
    input        [1:0] sel,

    output logic [3:0] y
);

    assign y = sel[1] ? ( sel[0] ? d3 : d2 ) : ( sel[0] ? d1 : d0 );

endmodule