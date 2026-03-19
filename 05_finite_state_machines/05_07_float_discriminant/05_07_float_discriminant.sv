//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
// The resulting value res should be calculated as a discriminant of the quadratic polynomial.
// That is, res = b^2 - 4ac == b*b - 4*a*c
//
// Note:
// If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
//
// The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
// and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);
    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;
    
    //mul params
    logic [FLEN - 1:0] fvar_a, fvar_b, fmul_bb_var;
    logic              mul_arg_valid;
    logic              mul_valid;
    logic [FLEN - 1:0] mul_res;
    logic              mul_busy;
    logic              mul_error;

    f_mult fmul (
        .clk         ( clk           ),
        .rst         ( rst           ),
        .a           ( fvar_a        ),
        .b           ( fvar_b        ),
        .res         ( mul_res       ),
        .up_valid    ( mul_arg_valid ),
        .down_valid  ( mul_valid     ),
        .busy        ( mul_busy      ),
        .error       ( mul_error     )
    );

    //sub params
    logic              sub_arg_valid;
    logic              sub_valid;
    logic [FLEN - 1:0] sub_res;
    logic              sub_busy;
    logic              sub_error;

    f_sub fsub (
        .clk         ( clk           ),
        .rst         ( rst           ),
        .a           ( fvar_a        ),
        .b           ( fvar_b        ),
        .res         ( sub_res       ),
        .up_valid    ( sub_arg_valid ),
        .down_valid  ( sub_valid     ),
        .busy        ( sub_busy      ),
        .error       ( sub_error     )
    );

    //================================================================

    typedef enum logic [2:0]
    {
        IDLE         = 3'b000,
        WAIT_MUL_BB  = 3'b001,
        WAIT_MUL_AC  = 3'b010,
        WAIT_MUL_4AC = 3'b011,
        WAIT_SUB     = 3'b100
    } state_T;

    state_T state, new_state;

    //================================================================
    //FSM MODULE
    always_ff @(posedge clk or posedge rst)
        if (rst)
            state <= IDLE;
        else
            state <= new_state;

    always_comb begin
        new_state = state;

        case (state)
        IDLE         : if ( arg_vld   ) new_state = WAIT_MUL_BB;
        WAIT_MUL_BB  : if ( mul_valid ) new_state = WAIT_MUL_AC;
        WAIT_MUL_AC  : if ( mul_valid ) new_state = WAIT_MUL_4AC;
        WAIT_MUL_4AC : if ( mul_valid ) new_state = WAIT_SUB;
        WAIT_SUB     : if ( sub_valid ) new_state = IDLE;
        endcase
    end

    //create res_vld
    assign res_vld = ( state == WAIT_SUB ) & sub_valid;

    //================================================================
    //MUL AND SUB MANAGER MODULE
    logic [FLEN - 1:0] var_a_ff;
    logic [FLEN - 1:0] var_c_ff;

    always_ff @(posedge clk) begin
        if (arg_vld) begin
            var_a_ff <= a;
            var_c_ff <= c;
        end
    end

    //vld signal
    always_comb begin
        mul_arg_valid = '0;
        sub_arg_valid = '0;

        case (state)
        IDLE         : mul_arg_valid = arg_vld;
        WAIT_MUL_BB  : mul_arg_valid = mul_valid;
        WAIT_MUL_AC  : mul_arg_valid = mul_valid;
        WAIT_MUL_4AC : sub_arg_valid = mul_valid;
        endcase
    end

    //up and out signals
    always_comb begin

        case (state)
        IDLE         : if ( arg_vld   ) { fvar_a, fvar_b }               = { b, b };
        WAIT_MUL_BB  : if ( mul_valid ) { fvar_a, fvar_b, fmul_bb_var  } = {    var_a_ff,   var_c_ff, mul_res };
        WAIT_MUL_AC  : if ( mul_valid ) { fvar_a, fvar_b }               = {        four,  mul_res };
        WAIT_MUL_4AC : if ( mul_valid ) { fvar_a, fvar_b }               = { fmul_bb_var,  mul_res };
        WAIT_SUB     : if ( sub_valid ) res = sub_res;
        endcase
    end

endmodule
