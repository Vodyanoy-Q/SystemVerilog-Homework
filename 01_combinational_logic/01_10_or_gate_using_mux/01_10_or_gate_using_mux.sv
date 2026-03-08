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
// Implement or gate using instance(s) of mux,
// constants 0 and 1, and wire connections

module or_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  mux mux1 (.d0( a ), .d1( 1 ), .sel( b ), .y( o ));

endmodule
