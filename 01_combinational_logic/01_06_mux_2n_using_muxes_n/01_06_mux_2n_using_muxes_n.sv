module mux_2_1
(
  input  [3:0] d0, d1,
  input        sel,
  output [3:0] y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement mux_4_1 using three instances of mux_2_1

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);

  wire [3:0] mux1_res;
  wire [3:0] mux2_res;


  mux_2_1 mux1      (.d0( d0 ), .d1( d1 ), .sel( sel[0] ), .y( mux1_res ));
  mux_2_1 mux2      (.d0( d2 ), .d1( d3 ), .sel( sel[0] ), .y( mux2_res ));
  mux_2_1 mux_final (.d0( mux1_res ), .d1( mux2_res ), .sel( sel[1] ), .y( y ));


endmodule
