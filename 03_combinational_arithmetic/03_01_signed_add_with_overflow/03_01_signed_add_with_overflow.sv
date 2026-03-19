//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
//
// Implement a module that adds two signed numbers
// and detects an overflow.
//
// By "signed" we mean "two's complement numbers".
// See https://en.wikipedia.org/wiki/Two%27s_complement for details.
//
// The 'overflow' output bit should be set to 1
// when the resulting sum (either positive or negative)
// of two input arguments is greater or less than
// 4-bit maximum or minimum signed number.
//
// Otherwise the 'overflow' should be set to 0.

module signed_add_with_overflow
(
  input  [3:0] a, b,
  output logic [3:0] sum,
  output logic      overflow
);
  assign sum = a + b;
  assign overflow = (a[3] ^ b[3]) ? 0 : (sum[3] != a[3]);

endmodule
