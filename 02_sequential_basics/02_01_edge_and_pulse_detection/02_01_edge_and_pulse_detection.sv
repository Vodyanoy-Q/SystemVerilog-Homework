//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Create an one cycle pulse (010) detector.
//
// Note:
// See the testbench for the output format ($display task).

module one_cycle_pulse_detector 
(
  input clk, 
  input rst, 
  input a, 
  output detected
);
  logic reg1, reg2;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      reg1 <= '1;
      reg2 <= '1;
    end
    else begin
      reg1 <= a;
      reg2 <= reg1;
    end
  end

  assign detected = ~a & reg1 & ~reg2;

endmodule
