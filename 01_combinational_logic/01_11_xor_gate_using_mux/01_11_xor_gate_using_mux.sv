//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement xor gate using instance(s) of mux,
// constants 0 and 1, and wire connections

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);
  wire mux1_res;
  wire mux2_res;

  mux mux1      (.d0( 0 ),        .d1( 1 ),        .sel( a ), .y( mux1_res ));
  mux mux2      (.d0( 1 ),        .d1( 0 ),        .sel( a ), .y( mux2_res ));
  mux mux_final (.d0( mux1_res ), .d1( mux2_res ), .sel( b ), .y( o ));

endmodule
