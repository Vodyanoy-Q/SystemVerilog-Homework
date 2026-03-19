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
// Implement a module that adds two signed numbers with saturation.
//
// "Adding with saturation" means:
//
// When the result does not fit into 4 bits,
// and the arguments are positive,
// the sum should be set to the maximum positive number.
//
// When the result does not fit into 4 bits,
// and the arguments are negative,
// the sum should be set to the minimum negative number.

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);
  wire overflow;
  wire [3:0] standart_sum;

  assign standart_sum = a + b;
  assign overflow = (a[3] ^ b[3]) ? 0 : (standart_sum[3] != a[3]);

  assign sum = overflow ? ( a[3] == 1 ? 4'b1000 : 4'b0111 ) : standart_sum;

endmodule
