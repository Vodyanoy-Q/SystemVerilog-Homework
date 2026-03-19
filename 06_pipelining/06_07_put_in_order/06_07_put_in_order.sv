// Task:

// Implement a module that accepts many outputs of the computational blocks
// and outputs them one by one in order. Input signals "up_vlds" and "up_data"
// are coming from an array of non-pipelined computational blocks.
// These external computational blocks have a variable latency.

// The order of incoming "up_vlds" is not determent, and the task is to
// output "down_vld" and corresponding data in a round-robin manner,
// one after another, in order.

// Comment:
// The idea of the block is kinda similar to the "parallel_to_serial" block
// from Homework 2, but here block should also preserve the output order.
module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);
    //put in mem data up vld and data   
    logic [n_inputs - 1:0] up_vld_ff;
    logic [width - 1:0]    up_data_ff [n_inputs - 1:0];

    always_ff @(posedge clk or posedge rst)
        if ( rst )
            up_vld_ff <= '0;
        else begin
            for ( int i = 0; i < n_inputs; i = i + 1 )
                if ( up_vlds[i] ) begin
                    up_vld_ff[i]  <= ( order_cnt == i ) ? '0 : '1 ;
                    up_data_ff[i] <= up_data[i];
                end
                else if (up_vld_ff[order_cnt])
                    up_vld_ff[order_cnt] <= '0;
        end

    //orderer
    logic [$clog2(n_inputs) - 1:0] order_cnt;
    logic                          down_vld_ff;
    logic [width - 1:0]            down_data_ff;
    
    always_ff @(posedge clk or posedge rst)
        if ( rst )
            order_cnt <= '0;
        else if ( up_vlds[order_cnt] | up_vld_ff[order_cnt]) begin
            order_cnt    <= (order_cnt == n_inputs - 1) ? '0 : order_cnt + 1;

            down_vld_ff  <= '1; 
            down_data_ff <= up_vlds[order_cnt] ? up_data[order_cnt] : up_data_ff[order_cnt]; 
        end
        else
            down_vld_ff  <= '0;

    assign down_vld  = down_vld_ff;
    assign down_data = down_data_ff;

endmodule
