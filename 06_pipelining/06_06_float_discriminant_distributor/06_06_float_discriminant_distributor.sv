// Task:
//
// Implement a module that will calculate the discriminant based
// on the triplet of input number a, b, c. The module must be pipelined.
// It should be able to accept a new triple of arguments on each clock cycle
// and also, after some time, provide the result on each clock cycle.
// The idea of the task is similar to the task 04_11. The main difference is
// in the underlying module 03_08 instead of formula modules.
//
// Note 1:
// Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
//
// Note 2:
// Latency of the module "float_discriminant" should be clarified from the waveform.

module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);
    localparam int N = 13;

    //module outputs
    logic [N - 1:0]    module_res_vld;
    logic [FLEN - 1:0] module_res [N - 1:0];

    //module inputs
    logic [N - 1:0]    module_vld_in;
    logic [FLEN - 1:0] module_a [N - 1:0];
    logic [FLEN - 1:0] module_b [N - 1:0];
    logic [FLEN - 1:0] module_c [N - 1:0];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_type
            float_discriminant float (
                .clk     ( clk               ),
                .rst     ( rst               ),
                .arg_vld ( module_vld_in[i]  ),
                .a       ( module_a[i]       ),
                .b       ( module_b[i]       ),
                .c       ( module_c[i]       ),
                .res_vld ( module_res_vld[i] ),
                .res     ( module_res[i]     ),
                .err     (                   ),
                .busy    (                   ),
                .res_negative (              )
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
