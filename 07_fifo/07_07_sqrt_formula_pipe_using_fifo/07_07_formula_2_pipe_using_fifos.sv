//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
//
// Implement a pipelined module formula_2_pipe_using_fifos that computes the result
// of the formula defined in the file formula_2_fn.svh.
//
// The requirements:
//
// 1. The module formula_2_pipe has to be pipelined.
//
// It should be able to accept a new set of arguments a, b and c
// arriving at every clock cycle.
//
// It also should be able to produce a new result every clock cycle
// with a fixed latency after accepting the arguments.
//
// 2. Your solution should instantiate exactly 3 instances
// of a pipelined isqrt module, which computes the integer square root.
//
// 3. Your solution should use FIFOs instead of shift registers
// which were used in 06_04_formula_2_pipe.sv.
//
// You can read the discussion of this problem
// in the article by Yuri Panchul published in
// FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
// You can download this issue from https://fpga-systems.ru/fsm

module formula_2_pipe_using_fifos
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);
    localparam [4:0] N_ISQRT_STAGES = 5'd16;
    localparam [5:0] DATA_WIDTH     = 6'd32;

    //ISQRT MODULES
    logic [15:0] isqrt2_out, isqrt1_out;
    logic        isqrt2_vld, isqrt1_vld;

    isqrt #(.n_pipe_stages(N_ISQRT_STAGES)) isqrt_1 
    (
        .clk   ( clk        ),
        .rst   ( rst        ),
        .x_vld ( arg_vld    ),
        .x     ( c          ),
        .y_vld ( isqrt1_vld ),
        .y     ( isqrt1_out )
    );

    isqrt #(.n_pipe_stages(N_ISQRT_STAGES)) isqrt_2 
    (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt1_vld_ff ),
        .x     ( sum1_res      ),
        .y_vld ( isqrt2_vld    ),
        .y     ( isqrt2_out    )
    );

    isqrt #(.n_pipe_stages(N_ISQRT_STAGES)) isqrt_3 
    (
        .clk   ( clk           ),
        .rst   ( rst           ),
        .x_vld ( isqrt2_vld_ff ),
        .x     ( sum2_res      ),
        .y_vld ( res_vld       ),
        .y     ( res           )
    );

    //SHIFT REG MODULES
    logic [DATA_WIDTH - 1:0] fifo_N_res;
    logic                    fifo_N_pop;
    logic                    fifo_N_empty;
    logic                    fifo_N_full;

    flip_flop_fifo_with_counter #(.width(DATA_WIDTH), .depth(N_ISQRT_STAGES)) fifo_N
    (
        .clk       ( clk          ),
        .rst       ( rst          ),
        .push      ( arg_vld      ),
        .pop       ( fifo_N_pop   ),
        .write_data( b            ),
        .read_data ( fifo_N_res   ),
        .empty     ( fifo_N_empty ),
        .full      ( fifo_N_full  )
    );

    logic [DATA_WIDTH - 1:0] fifo_2N_res;
    logic                    fifo_2N_pop;
    logic                    fifo_2N_empty;
    logic                    fifo_2N_full;

    flip_flop_fifo_with_counter #(.width(DATA_WIDTH), .depth(2 * N_ISQRT_STAGES + 1)) fifo_2N
    (
        .clk       ( clk           ),
        .rst       ( rst           ),
        .push      ( arg_vld       ),
        .pop       ( fifo_2N_pop   ),
        .write_data( a             ),
        .read_data ( fifo_2N_res   ),
        .empty     ( fifo_2N_empty ),
        .full      ( fifo_2N_full  )
    );

    assign fifo_N_pop  = isqrt1_vld;
    assign fifo_2N_pop = isqrt2_vld;

    //SUM sqrt(c) + b
    logic [DATA_WIDTH - 1:0] sum1_res;
    logic                    isqrt1_vld_ff;

    always_ff @(posedge clk or posedge rst)
        if (rst)
            isqrt1_vld_ff <= '0;
        else 
            isqrt1_vld_ff <= isqrt1_vld;
    
    always_ff @(posedge clk)
        if (isqrt1_vld) 
            sum1_res <= isqrt1_out + fifo_N_res;

    //SUM sqrt(sqrt(c) + b) + a
    logic [DATA_WIDTH - 1:0] sum2_res;
    logic                    isqrt2_vld_ff;

    always_ff @(posedge clk or posedge rst)
        if (rst)
            isqrt2_vld_ff <= '0;
        else 
            isqrt2_vld_ff <= isqrt2_vld;


    always_ff @(posedge clk)
        if (isqrt2_vld) 
            sum2_res <= isqrt2_out + fifo_2N_res;

endmodule
