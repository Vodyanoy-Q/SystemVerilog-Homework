//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// write code for 4:1 mux using only &, | and ~ operations.

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);


  wire sel0 = ~sel[1] & ~sel[0];
  wire sel1 = ~sel[1] &  sel[0];
  wire sel2 =  sel[1] & ~sel[0];
  wire sel3 =  sel[1] &  sel[0];

  assign y[0] = ( sel0 & d0[0] ) | ( sel1 & d1[0] ) | ( sel2 & d2[0] ) | ( sel3 & d3[0] ) ;
  assign y[1] = ( sel0 & d0[1] ) | ( sel1 & d1[1] ) | ( sel2 & d2[1] ) | ( sel3 & d3[1] ) ;
  assign y[2] = ( sel0 & d0[2] ) | ( sel1 & d1[2] ) | ( sel2 & d2[2] ) | ( sel3 & d3[2] ) ;
  assign y[3] = ( sel0 & d0[3] ) | ( sel1 & d1[3] ) | ( sel2 & d2[3] ) | ( sel3 & d3[3] ) ;

endmodule
