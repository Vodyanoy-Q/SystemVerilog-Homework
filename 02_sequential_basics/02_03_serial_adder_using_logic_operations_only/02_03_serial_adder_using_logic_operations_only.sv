//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_adder
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output sum
);

  // Note:
  // carry_d represents the combinational data input to the carry register.

  logic carry;
  wire carry_d;

  assign { carry_d, sum } = a + b + carry;

  always_ff @ (posedge clk)
    if (rst)
      carry <= '0;
    else
      carry <= carry_d;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a serial adder using only ^ (XOR), | (OR), & (AND), ~ (NOT) bitwise operations.

module serial_adder_using_logic_operations_only
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output sum
);
  logic carry_reg;
  wire  ab_xor;

  assign ab_xor = a ^ b;

  always_ff @(posedge clk or posedge rst)
    if (rst)
      carry_reg <= '0;
    else
      carry_reg <= (ab_xor & carry_reg ) ^ ( a & b );
  
  assign sum = ab_xor ^ carry_reg;

endmodule
