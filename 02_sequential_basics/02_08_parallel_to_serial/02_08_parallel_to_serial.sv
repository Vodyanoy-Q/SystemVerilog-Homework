//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that converts multi-bit parallel value to the single-bit serial data.
//
// The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
// At the same clock cycle as 'parallel_valid' is asserted, the module should output
// the least significant bit of the input data. In the following clock cycles the module
// should output all the remaining bits of the parallel_data.
// Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
//
// Note:
// Check the waveform diagram in the README for better understanding.

module parallel_to_serial
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      parallel_valid,
    input        [width - 1:0] parallel_data,

    output                     busy,
    output logic               serial_valid,
    output logic               serial_data
);

    logic [$clog2(width) - 1:0] cnt;
    logic [width - 1:0]         data;
    logic                       busy_reg;

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            busy_reg <= '0;
            cnt      <= '0;
        end
        else if (parallel_valid & ~busy_reg) begin
            data     <= parallel_data;
            cnt      <= 'd1;
            busy_reg <= '1;
        end
        else if (cnt != width - 1) begin
            cnt <= cnt + 1;
        end
        else if (cnt == width - 1) begin
            busy_reg <= '0;
        end

    assign busy         = busy_reg;
    assign serial_data  = (parallel_valid & ~busy_reg) ? parallel_data[0] : data[cnt];
    assign serial_valid = (parallel_valid & ~busy_reg) ? '1 : busy_reg;;
    

endmodule
