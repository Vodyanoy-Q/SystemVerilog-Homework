//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that calculates the formula from the `formula_2_fn.svh` file
// using only one instance of the isqrt module.
//
// Design the FSM to calculate answer step-by-step and provide the correct `res` value
//
// You can read the discussion of this problem
// in the article by Yuri Panchul published in
// FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
// You can download this issue from https://fpga-systems.ru/fsm

module formula_2_fsm
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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    typedef enum logic[1:0]
    {
        IDLE        = 2'b00,
        WAIT_C_SQRT = 2'b01,
        WAIT_B_SQRT = 2'b10,
        WAIT_A_SQRT = 2'b11
    } state_T;

    state_T state, new_state;

    logic [31:0] new_res;
    logic [31:0] var_b_ff;
    logic [31:0] var_a_ff;

    //=======================
    //FSM BLOCK
    //=======================
    always_ff @(posedge clk or posedge rst)
        if (rst)
            state <= IDLE;
        else    
            state <= new_state;

    always_comb begin
        new_state = state;
        case (state)
        IDLE        : if (arg_vld)     new_state = WAIT_C_SQRT;
        WAIT_C_SQRT : if (isqrt_y_vld) new_state = WAIT_B_SQRT;
        WAIT_B_SQRT : if (isqrt_y_vld) new_state = WAIT_A_SQRT;
        WAIT_A_SQRT : if (isqrt_y_vld) new_state = IDLE;
        endcase
    end

    //creat out valid signal
    always_ff @(posedge clk or posedge rst)
        if (rst)
            res_vld <= '0;
        else 
            res_vld <= ( state == WAIT_A_SQRT ) & isqrt_y_vld;

    //calculate res
    always_ff @(posedge clk)
        if (state == IDLE)
            res <= '0;
        else
            res <= new_res;

    always_comb begin
        new_res = res;

        case (state)
        WAIT_C_SQRT : if (isqrt_y_vld) new_res = var_b_ff + isqrt_y;
        WAIT_B_SQRT : if (isqrt_y_vld) new_res = var_a_ff + isqrt_y;
        WAIT_A_SQRT : if (isqrt_y_vld) new_res = isqrt_y;
        endcase
    end

    //isqrt module manager  

    always_ff @(posedge clk)
        if (arg_vld) begin
            var_a_ff <= a;
            var_b_ff <= b;
        end

    always_comb begin
        isqrt_x_vld = '0;

        case (state)
            IDLE        : isqrt_x_vld = arg_vld;
            WAIT_C_SQRT : isqrt_x_vld = isqrt_y_vld;
            WAIT_B_SQRT : isqrt_x_vld = isqrt_y_vld;
        endcase
    end

    always_comb begin
        isqrt_x = 'x;

        case (state)
            IDLE        : isqrt_x = c;
            WAIT_C_SQRT : isqrt_x = new_res;
            WAIT_B_SQRT : isqrt_x = new_res;
        endcase
    end
    
endmodule