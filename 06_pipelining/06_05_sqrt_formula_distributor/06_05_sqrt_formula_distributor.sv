// Task:
//
// Implement a module that will calculate formula 1 or formula 2
// based on the parameter values. The module must be pipelined.
// It should be able to accept new triple of arguments a, b, c arriving
// at every clock cycle.
//
// The idea of the task is to implement hardware task distributor,
// that will accept triplet of the arguments and assign the task
// of the calculation formula 1 or formula 2 with these arguments
// to the free FSM-based internal module.
//
// The first step to solve the task is to fill 03_04 and 03_05 files.
//
// Note 1:
// Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
// or simply assumed to be equal 50 clock cycles.
//
// Note 2:
// The task assumes idealized distributor (with 50 internal computational blocks),
// because in practice engineers rarely use more than 10 modules at ones.
// Usually people use 3-5 blocks and utilize stall in case of high load.
//
// Hint:
// Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
// or "formula_2_top" modules to achieve desired performance.

//formula 1 impl 1 fsm latency = 13 cycles
//formula 1 impl 2 fsm latency = 33 cycles
//formula 2 fsm latency = 49 cycles

module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
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
    localparam int N = (formula == 1 && impl == 1) ? 13 :
                       (formula == 1 && impl == 2) ? 33 : 49;

    //module outputs
    logic [N - 1:0] module_res_vld;
    logic [31:0]    module_res [N - 1:0];

    //module inputs
    logic [N - 1:0] module_vld_in;
    logic [31:0]    module_a [N - 1:0];
    logic [31:0]    module_b [N - 1:0];
    logic [31:0]    module_c [N - 1:0];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1)
            if (formula == 1 && impl == 1) begin : gen_type
                formula_1_impl_1_top formula_1_1 (
                    .clk     ( clk               ),
                    .rst     ( rst               ),
                    .arg_vld ( module_vld_in[i]  ),
                    .a       ( module_a[i]       ),
                    .b       ( module_b[i]       ),
                    .c       ( module_c[i]       ),
                    .res_vld ( module_res_vld[i] ),
                    .res     ( module_res[i]     )
                );
            end
            else if (formula == 1 && impl == 2) begin : gen_type
                formula_1_impl_2_top formula_1_2 (
                    .clk     ( clk               ),
                    .rst     ( rst               ),
                    .arg_vld ( module_vld_in[i]  ),
                    .a       ( module_a[i]       ),
                    .b       ( module_b[i]       ),
                    .c       ( module_c[i]       ),
                    .res_vld ( module_res_vld[i] ),
                    .res     ( module_res[i]     )
                );
            end
            else begin : gen_type
                formula_2_top formula_2 (
                    .clk     ( clk               ),
                    .rst     ( rst               ),
                    .arg_vld ( module_vld_in[i]  ),
                    .a       ( module_a[i]       ),
                    .b       ( module_b[i]       ),
                    .c       ( module_c[i]       ),
                    .res_vld ( module_res_vld[i] ),
                    .res     ( module_res[i]     )
                );
            end
    endgenerate

    //distributor
    logic [$clog2(N) - 1:0] cur_cnt;
    logic [$clog2(N) - 1:0] prev_cnt;
    logic                   start_flag;

    always_ff @(posedge clk or posedge rst)
        if ( rst ) begin
            cur_cnt    <= '0;
            prev_cnt   <= '0;
            start_flag <= '0;
        end
        else if ( arg_vld ) begin
            cur_cnt  <= ( cur_cnt == N - 1 ) ? 0 : cur_cnt + 1 ;
            prev_cnt <= cur_cnt;

            module_vld_in[cur_cnt] <= arg_vld;
            module_a[cur_cnt]      <= a;
            module_b[cur_cnt]      <= b;
            module_c[cur_cnt]      <= c;

            if ( start_flag ) 
                module_vld_in[prev_cnt] <= '0;
            else
                start_flag <= '1;
        end

    //get res
    logic [$clog2(N) - 1:0] cur_out_cnt;

    always_ff @(posedge clk or posedge rst)
        if ( rst )
            cur_out_cnt <= '0;
        else if ( module_res_vld[cur_out_cnt] )
            cur_out_cnt  <= ( cur_out_cnt == N - 1 ) ? 0 : cur_out_cnt + 1 ;

    assign res     = module_res[cur_out_cnt];
    assign res_vld = module_res_vld[cur_out_cnt];

endmodule
