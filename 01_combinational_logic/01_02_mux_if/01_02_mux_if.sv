// Task:
// write code for 4:1 mux using the "if" statement

module mux_4_1
(
    input        [3:0] d0, d1, d2, d3,
    input        [1:0] sel,
    output logic [3:0] y
);
    always_comb 
        if ( sel[1] )
            if ( sel[0] )
                    y = d3;
                else
                    y = d2;
        else
            if ( sel[0] )
                y = d1;
            else
                y = d0;

endmodule
