//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that converts single-bit serial data to the multi-bit parallel value.
//
// The module should accept one-bit values with valid interface in a serial manner.
// After accumulating 'width' bits and receiving last 'serial_valid' input,
// the module should assert the 'parallel_valid' at the same clock cycle
// and output 'parallel_data' value.
//
// Note:
// Check the waveform diagram in the README for better understanding.

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    logic [width - 1:0]         data;
    logic [$clog2(width) - 1:0] cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            data           <= '0;
            cnt            <= '0;
        end
        else if (serial_valid) begin
            data[cnt] <= serial_data;        
            if (cnt == width - 1)
                cnt <= '0;
            else
                cnt <= cnt + 1;
        end
    end
    
    assign parallel_data  = (cnt == width - 1) ? { serial_data, data[width - 2:0] } : parallel_data; 
    assign parallel_valid = (serial_valid && cnt == width - 1) ? '1 : 0; 

endmodule
