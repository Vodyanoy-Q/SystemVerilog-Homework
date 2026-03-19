//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module arithmetic_right_shift_of_N_by_S_using_arithmetic_right_shift_operation
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output [N - 1:0] res);

  wire signed [N - 1:0] as = a;
  assign res = as >>> S;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
//
// Implement a module with the logic for the arithmetic right shift,
// but without using ">>>" operation. You are allowed to use only
// concatenations ({a, b}), bit repetitions ({ a { b }}), bit slices
// and constant expressions.

module arithmetic_right_shift_of_N_by_S_using_concatenation
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output [N - 1:0] res);

  assign res = { { S{ a[N - 1] } }, a[N - 1:S] };

endmodule

// Task:
//
// Implement a module with the logic for the arithmetic right shift,
// but without using ">>>" operation, concatenations or bit slices.
// You are allowed to use only "always_comb" with a "for" loop
// that iterates through the individual bits of the input.

module arithmetic_right_shift_of_N_by_S_using_for_inside_always
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output logic [N - 1:0] res);

  always_comb begin
    for (int i = 0; i < N ; i = i + 1)
      if (i < S)
        res[N - 1 - i] = a[N - 1];
      else 
        res[N - 1 - i] = a[N - 1 - i + S];
  end

endmodule

// Task:
// Implement a module that arithmetically shifts input exactly
// by `S` bits to the right using "generate" and "for"

module arithmetic_right_shift_of_N_by_S_using_for_inside_generate
# (parameter N = 8, S = 3)
(input  [N - 1:0] a, output [N - 1:0] res);

  genvar i;
  generate;
    for (i = 0; i < N; i = i + 1)
      if (i < S) begin : sign_bit_gen
        assign res[N - 1 - i] = a[N - 1];
      end
      else begin : shift_gen
        assign res[N - 1 - i] = a[N - 1 - i + S];
      end
  endgenerate


endmodule
