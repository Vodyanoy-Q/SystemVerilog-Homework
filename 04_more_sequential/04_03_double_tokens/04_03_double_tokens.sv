//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a serial module that doubles each incoming token '1' two times.
// The module should handle doubling for at least 200 tokens '1' arriving in a row.
//
// In case module detects more than 200 sequential tokens '1', it should assert
// an overflow error. The overflow error should be sticky. Once the error is on,
// the only way to clear it is by using the "rst" reset signal.
//
// Note:
// Check the waveform diagram in the README for better understanding.
//
// Example:
// a -> 10010011000110100001100100
// b -> 11011011110111111001111110

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    logic [7:0] cnt;
    logic       busy;

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            overflow <= '0;
            cnt      <= '0;
            busy     <= '0;
        end
        else if (cnt >= 8'd200)
            overflow <= '1;
        else if (~ overflow) begin
            if (a) begin
                    cnt  <= cnt + 1;
                    busy <= '1;
                end
            else if (cnt != '0) begin
                cnt  <= cnt - 1;
                busy <= '1;
            end
            else 
                busy <= '0;
                
        end

    assign b = ( overflow ) ? '0 : ( a ? a : (busy & cnt != 0) ) ;
    
endmodule

