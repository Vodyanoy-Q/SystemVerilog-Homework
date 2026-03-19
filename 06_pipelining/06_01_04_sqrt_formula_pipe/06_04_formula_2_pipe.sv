//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
//
// Implement a pipelined module formula_2_pipe that computes the result
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
// 3. Your solution should save dynamic power by properly connecting
// the valid bits.
//
// You can read the discussion of this problem
// in the article by Yuri Panchul published in
// FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
// You can download this issue from https://fpga-systems.ru/fsm#state_0

module formula_2_pipe
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
    logic [DATA_WIDTH - 1:0] shift_reg_N_res;
    logic                    shift_reg_N_vld;

    shift_register_with_valid #(.width(DATA_WIDTH), .depth(N_ISQRT_STAGES)) shift_reg_N
    (
        .clk      ( clk             ),
        .rst      ( rst             ),
        .in_vld   ( arg_vld         ),
        .in_data  ( b               ),
        .out_vld  ( shift_reg_N_vld ),
        .out_data ( shift_reg_N_res )
    );

    logic [DATA_WIDTH - 1:0] shift_reg_2N_res;
    logic                    shift_reg_2N_vld;

    shift_register_with_valid #(.width(DATA_WIDTH), .depth(2 * N_ISQRT_STAGES + 1)) shift_reg_2N
    (
        .clk      ( clk              ),
        .rst      ( rst              ),
        .in_vld   ( arg_vld          ),
        .in_data  ( a                ),
        .out_vld  ( shift_reg_2N_vld ),
        .out_data ( shift_reg_2N_res )
    );

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
            sum1_res <= isqrt1_out + shift_reg_N_res;

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
            sum2_res <= isqrt2_out + shift_reg_2N_res;



endmodule
