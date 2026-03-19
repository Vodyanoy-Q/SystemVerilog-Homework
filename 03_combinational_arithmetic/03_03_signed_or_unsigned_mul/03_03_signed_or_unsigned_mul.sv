//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

// A non-parameterized module
// that implements the signed multiplication of 4-bit numbers
// which produces 8-bit result

module signed_mul_4
(
  input  signed [3:0] a, b,
  output signed [7:0] res
);

  assign res = a * b;

endmodule

// A parameterized module
// that implements the unsigned multiplication of N-bit numbers
// which produces 2N-bit result

module unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  output [2 * n - 1:0] res
);

  assign res = a * b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

// Task:
//
// Implement a parameterized module
// that produces either signed or unsigned result
// of the multiplication depending on the 'signed_mul' input bit.

module signed_or_unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  input                signed_mul,
  output [2 * n - 1:0] res
);
  logic [2 * n - 1:0] mul;
  logic [n - 1:0]     abs_a, abs_b;
  logic               a_is_neg, b_is_neg;

  always_comb begin
    a_is_neg = a[n - 1];
    b_is_neg = b[n - 1];

    abs_a = ~ ( signed_mul & a_is_neg ) ? a : ~ a + 1'd1;     
    abs_b = ~ ( signed_mul & b_is_neg ) ? b : ~ b + 1'd1;     

    mul = abs_a * abs_b;

    if (signed_mul & ( a_is_neg ^ b_is_neg ))
      mul = ~ mul + 1'b1;      
  end

  assign res = mul;

endmodule

/* MEM SOLUTION
  wire [2 * n - 1:0] umul_res;
  wire [2 * n - 1:0] smul_res; 
  
  assign umul_res = a * b;
  assign smul_res = $signed(a) * $signed(b);
  
  assign res = signed_mul ? smul_res : umul_res;
*/