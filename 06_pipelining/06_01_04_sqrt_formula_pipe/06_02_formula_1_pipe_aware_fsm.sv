//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
//
// Implement a module formula_1_pipe_aware_fsm
// with a Finite State Machine (FSM)
// that drives the inputs and consumes the outputs
// of a single pipelined module isqrt.
//
// The formula_1_pipe_aware_fsm module is supposed to be instantiated
// inside the module formula_1_pipe_aware_fsm_top,
// together with a single instance of isqrt.
//
// The resulting structure has to compute the formula
// defined in the file formula_1_fn.svh.
//
// The formula_1_pipe_aware_fsm module
// should NOT create any instances of isqrt module,
// it should only use the input and output ports connecting
// to the instance of isqrt at higher level of the instance hierarchy.
//
// All the datapath computations except the square root calculation,
// should be implemented inside formula_1_pipe_aware_fsm module.
// So this module is not a state machine only, it is a combination
// of an FSM with a datapath for additions and the intermediate data
// registers.
//
// Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
// It should be able to accept new arguments a, b and c
// arriving at every N+3 clock cycles.
//
// In order to achieve this latency the FSM is supposed to use the fact
// that isqrt is a pipelined module.
//
// For more details, see the discussion of this problem
// in the article by Yuri Panchul published in
// FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
// You can download this issue from https://fpga-systems.ru/fsm#state_0

module formula_1_pipe_aware_fsm
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

    typedef enum logic [2:0]
    {
        READY_TO_PUT_A = 3'b000,
        READY_TO_PUT_B = 3'b001,
        READY_TO_PUT_C = 3'b010,
        WAIT_A_SQRT    = 3'b011,
        WAIT_B_SQRT    = 3'b100,
        WAIT_C_SQRT    = 3'b101
    } state_T;

    state_T state, new_state;

    //==================================
    //FSM MODULE
    always_ff @(posedge clk or posedge rst)
        if (rst)
            state <= READY_TO_PUT_A;
        else 
            state <= new_state;
    
    always_comb begin
        new_state = state;

        case (state)
        READY_TO_PUT_A : if (arg_vld)     new_state = READY_TO_PUT_B;
        READY_TO_PUT_B :                  new_state = READY_TO_PUT_C;
        READY_TO_PUT_C :                  new_state = WAIT_A_SQRT;
        WAIT_A_SQRT    : if (isqrt_y_vld) new_state = WAIT_B_SQRT;  
        WAIT_B_SQRT    : if (isqrt_y_vld) new_state = WAIT_C_SQRT;
        WAIT_C_SQRT    : if (isqrt_y_vld) new_state = READY_TO_PUT_A;      
        endcase
    end
            
    //load data when arg_vld
    logic [31:0] var_b, var_c;
    always_ff @(posedge clk)
        if (arg_vld) begin
            var_b <= b;
            var_c <= c;
        end

    //isqrt input manager
    always_comb begin
        case (state)
        READY_TO_PUT_A : if (arg_vld) isqrt_x = a;
        READY_TO_PUT_B :              isqrt_x = var_b;
        READY_TO_PUT_C :              isqrt_x = var_c;
        endcase
    end 

    always_comb begin
        case (state)
        READY_TO_PUT_A : isqrt_x_vld = arg_vld;
        READY_TO_PUT_B : isqrt_x_vld = '1;
        READY_TO_PUT_C : isqrt_x_vld = '1;
        WAIT_A_SQRT,
        WAIT_B_SQRT,
        WAIT_C_SQRT    : isqrt_x_vld = '0;
        endcase
    end

    //res valid signal
    assign res_vld = ( state == WAIT_C_SQRT ) & isqrt_y_vld;
    
    //res calculating
    always_comb begin
        case (state)
        WAIT_A_SQRT : if (isqrt_y_vld) res = isqrt_y;
        WAIT_B_SQRT : if (isqrt_y_vld) res = res + isqrt_y;
        WAIT_C_SQRT : if (isqrt_y_vld) res = res + isqrt_y;
        endcase
    end

endmodule
