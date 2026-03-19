//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that calculates the formula from the `formula_1_fn.svh` file
// using two instances of the isqrt module in parallel.
//
// Design the FSM to calculate an answer and provide the correct `res` value
//
// You can read the discussion of this problem
// in the article by Yuri Panchul published in
// FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
// You can download this issue from https://fpga-systems.ru/fsm

module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);
    logic [31:0] prev_c;

    typedef enum logic[1:0]
    {
        IDLE          = 2'b00,
        WAIT_A_B_SQRT = 2'b01,
        WAIT_C_SQRT   = 2'b10
    } state_T;

    state_T state, next_state;

    //STATE BLOCK
    always_ff @(posedge clk or posedge rst)
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
            
    always_comb begin
        next_state = state;

        case (state)
        IDLE          : if (arg_vld)                       next_state = WAIT_A_B_SQRT; 
        WAIT_A_B_SQRT : if (isqrt_1_y_vld & isqrt_2_y_vld) next_state = WAIT_C_SQRT;
        WAIT_C_SQRT   : if (isqrt_1_y_vld)                 next_state = IDLE;
        endcase
    end 
    
    //ISQRT MANAGER BLOCK
    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            isqrt_1_x_vld <= '0;
            isqrt_2_x_vld <= '0;
        end 
        else if (arg_vld)
            prev_c <= c;

    //sqrt vld signal
    always_comb begin
        isqrt_1_x_vld = '0;
        isqrt_2_x_vld = '0;

        case (state)
        IDLE          : { isqrt_1_x_vld, isqrt_2_x_vld } = { arg_vld, arg_vld };
        WAIT_A_B_SQRT : isqrt_1_x_vld = isqrt_1_y_vld;
        endcase
    end

    //sqrt input signal
    always_comb begin
        isqrt_1_x = 'x;
        isqrt_2_x = 'x;

        case (state)
        IDLE          : { isqrt_1_x, isqrt_2_x } = { a, b };
        WAIT_A_B_SQRT : isqrt_1_x = prev_c;
        endcase
    end

    //GET RESULT AND VALID SIGNAL
    logic [31:0] new_res;

    always_ff @(posedge clk)
        if (state == IDLE)
            res <= '0;
        else 
            res <= new_res;

    always_comb begin
        new_res = res;

        case (state)
        WAIT_A_B_SQRT : if (isqrt_1_y_vld & isqrt_2_y_vld) new_res = isqrt_1_y + isqrt_2_y;
        WAIT_C_SQRT   : if (isqrt_1_y_vld)                 new_res = res + isqrt_1_y;
        endcase
    end
    
    //VALID BLOCK
    always_ff @(posedge clk or posedge rst)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= (state == WAIT_C_SQRT) & isqrt_1_y_vld;

endmodule
