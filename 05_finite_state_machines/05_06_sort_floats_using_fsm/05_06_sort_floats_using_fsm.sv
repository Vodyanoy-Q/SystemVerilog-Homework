//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
// Task:
// Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.

// Requirements:
// The solution must have latency equal to the three clock cycles.
// The solution should use the inputs and outputs to the single "f_less_or_equal" module.
// The solution should NOT create instances of any modules.

// Notes:
// res0 must be less or equal to the res1
// res1 must be less or equal to the res1

// The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
// and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);
    typedef enum logic[2:0]
    {
        IDLE          = 3'b000,
        WAIT_B_C_COMP_A_LE_B = 3'b010,
        WAIT_B_C_COMP_A_GR_B = 3'b011,
        WAIT_A_C_COMP_A_LE_B = 3'b100,
        WAIT_A_C_COMP_A_GR_B = 3'b101
    } state_T;

    state_T state, new_state;

    //load data
    logic [0:2][FLEN - 1:0] unsorted_ff;
    always_ff @(posedge clk)
        if (valid_in)
            unsorted_ff = unsorted;

    //err of fle module
    always_comb begin
        if (state == IDLE)
            err = '0;
        else if (f_le_err)
            err = '1;
    end
            

    //========================================
    //FSM MODULE
    always_ff @(posedge clk or posedge rst)
        if (rst)
            state <= IDLE;
        else 
            state <= new_state;

    always_comb begin
        new_state = state;

        case (state)
        IDLE                 : if (valid_in) begin
                                   if (f_le_res) new_state = WAIT_B_C_COMP_A_LE_B;
                                   else          new_state = WAIT_B_C_COMP_A_GR_B;
                               end
        WAIT_B_C_COMP_A_LE_B : if (f_le_res) begin
                                             new_state = IDLE;
                                             sorted    = unsorted_ff;
                               end
                               else          new_state = WAIT_A_C_COMP_A_LE_B;
        WAIT_A_C_COMP_A_LE_B : begin         new_state = IDLE; 
                               if (f_le_res) sorted    = { unsorted_ff[0], unsorted_ff[2], unsorted_ff[1] };
                               else          sorted    = { unsorted_ff[2], unsorted_ff[0], unsorted_ff[1] };
                               end 
        WAIT_B_C_COMP_A_GR_B : if (f_le_res) new_state = WAIT_A_C_COMP_A_GR_B;
                               else begin         
                                             new_state = IDLE;
                                             sorted    = { unsorted_ff[2], unsorted_ff[1], unsorted_ff[0] };
                               end
        WAIT_A_C_COMP_A_GR_B : begin         new_state = IDLE; 
                               if (f_le_res) sorted    = { unsorted_ff[1], unsorted_ff[0], unsorted_ff[2] };
                               else          sorted    = { unsorted_ff[1], unsorted_ff[2], unsorted_ff[0] };
                               end
        endcase
    end
    
    //========================================
    //compare module
    
    always_comb begin
        case (state)
        IDLE                 : if (valid_in) begin
                                   f_le_a = unsorted[0];
                                   f_le_b = unsorted[1];
                               end
        WAIT_B_C_COMP_A_LE_B,
        WAIT_B_C_COMP_A_GR_B : begin 
                                   f_le_a = unsorted_ff[1];
                                   f_le_b = unsorted_ff[2];
                               end
        WAIT_A_C_COMP_A_LE_B,
        WAIT_A_C_COMP_A_GR_B : begin 
                                   f_le_a = unsorted_ff[0];
                                   f_le_b = unsorted_ff[2];
                               end       
        endcase
    end

    //valid_signal
    assign valid_out = (state != IDLE) & (new_state == IDLE);
    //busy signal
    assign busy = (state != IDLE);
    

endmodule
